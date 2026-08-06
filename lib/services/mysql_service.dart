// Serviço principal de Conexão e Execução MySQL em Dart com Conexão Transparente a MySQL Real

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mysql_client/mysql_client.dart';
import '../models/db_connection_config.dart';
import '../models/table_schema.dart';
import '../models/audit_log.dart';

class MySqlService {
  MySQLConnection? _connection;
  DbConnectionConfig? _currentConfig;
  bool _isApiBridgeConnected = false;

  static const String _apiBridgeBaseUrl = 'http://127.0.0.1:8085/api';

  bool get isConnected => _isApiBridgeConnected || (_connection != null && _connection!.connected);
  DbConnectionConfig? get currentConfig => _currentConfig;

  /// Testar a conexão com o servidor MySQL sem alterar estado global
  Future<List<String>> testConnection(DbConnectionConfig config) async {
    try {
      final res = await http.post(
        Uri.parse('$_apiBridgeBaseUrl/databases'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(config.toJson()),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['databases'] != null) {
          return List<String>.from(data['databases']);
        }
      }
    } catch (_) {}

    if (!kIsWeb) {
      final conn = await MySQLConnection.createConnection(
        host: config.host,
        port: config.port,
        userName: config.user,
        password: config.password,
        databaseName: config.database.isNotEmpty ? config.database : null,
        secure: false,
      );
      await conn.connect();
      final res = await conn.execute("SHOW DATABASES;");
      final List<String> dbs = [];
      for (final row in res.rows) {
        final name = row.assoc()['Database'] ?? row.assoc()['database'] ?? row.colAt(0);
        if (name != null) dbs.add(name.toString());
      }
      await conn.close();
      return dbs;
    }

    throw Exception('Não foi possível estabelecer comunicação com o servidor MySQL.');
  }

  /// Estabelece a ligação ao servidor MySQL real
  Future<void> connect(DbConnectionConfig config) async {
    await disconnect();
    _currentConfig = config;

    // Tentar primeiro a ponte API HTTP na porta 8085 (que acede a MySQL real no host)
    try {
      final res = await http.post(
        Uri.parse('$_apiBridgeBaseUrl/connect'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(config.toJson()),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true) {
          _isApiBridgeConnected = true;
          return;
        }
      }
    } catch (_) {}

    // Em Desktop/Mobile Nativo sem bridge HTTP, usar mysql_client direto por socket
    if (!kIsWeb) {
      _connection = await MySQLConnection.createConnection(
        host: config.host,
        port: config.port,
        userName: config.user,
        password: config.password,
        databaseName: config.database.isNotEmpty ? config.database : null,
        secure: false,
      );

      await _connection!.connect();
      await _initializeSystemDatabase(config);
    } else {
      throw Exception(
        'Não foi possível ligar ao servidor MySQL em ${config.host}:${config.port}.\n'
        'Certifique-se de que o servidor MySQL está ativo na porta 3306 e que a ponte API está ligada na porta 8085.',
      );
    }
  }

  /// Desconecta do servidor MySQL
  Future<void> disconnect() async {
    _isApiBridgeConnected = false;
    if (_connection != null && _connection!.connected) {
      await _connection!.close();
    }
    _connection = null;
  }

  /// Inicializa a base de dados de auditoria do sistema 'suporte_db' em MySQL Nativo
  Future<void> _initializeSystemDatabase(DbConnectionConfig config) async {
    if (_connection == null || !_connection!.connected) return;

    try {
      await _connection!.execute(
        "CREATE DATABASE IF NOT EXISTS `suporte_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;",
      );

      await _connection!.execute('''
        CREATE TABLE IF NOT EXISTS `suporte_db`.`historico_logs` (
          `id` INT AUTO_INCREMENT PRIMARY KEY,
          `base_dados_alvo` VARCHAR(100) NOT NULL,
          `tabela_alvo` VARCHAR(100) NOT NULL,
          `registo_id` VARCHAR(100) NOT NULL,
          `acao` ENUM('INSERIR', 'ATUALIZAR', 'ELIMINAR') NOT NULL,
          `dados_anteriores` LONGTEXT NULL,
          `dados_novos` LONGTEXT NULL,
          `utilizador_sistema` VARCHAR(100) DEFAULT 'root',
          `criado_em` DATETIME DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
      ''');
    } catch (e) {
      print("Aviso ao inicializar suporte_db: $e");
    }
  }

  /// Regista um log na tabela historico_logs da base de dados suporte_db
  Future<void> logAuditAction({
    required String baseDadosAlvo,
    required String tabelaAlvo,
    required String registoId,
    required String acao,
    Map<String, dynamic>? dadosAnteriores,
    Map<String, dynamic>? dadosNovos,
  }) async {
    if (_connection == null || !_connection!.connected) return;

    try {
      final strAnteriores = dadosAnteriores != null ? jsonEncode(dadosAnteriores) : null;
      final strNovos = dadosNovos != null ? jsonEncode(dadosNovos) : null;
      final user = _currentConfig?.user ?? 'root';

      final sql = '''
        INSERT INTO `suporte_db`.`historico_logs` 
        (`base_dados_alvo`, `tabela_alvo`, `registo_id`, `acao`, `dados_anteriores`, `dados_novos`, `utilizador_sistema`, `criado_em`)
        VALUES (:db, :tbl, :reg, :act, :ant, :nov, :usr, NOW())
      ''';

      await _connection!.execute(sql, {
        'db': baseDadosAlvo,
        'tbl': tabelaAlvo,
        'reg': registoId,
        'act': acao,
        'ant': strAnteriores,
        'nov': strNovos,
        'usr': user,
      });
    } catch (e) {
      print("Erro ao gravar log de auditoria: $e");
    }
  }

  /// Obtém a lista de TODAS as bases de dados reais no servidor MySQL
  Future<List<String>> getDatabases() async {
    if (_isApiBridgeConnected) {
      final res = await http.post(
        Uri.parse('$_apiBridgeBaseUrl/databases'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(_currentConfig?.toJson() ?? {}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return List<String>.from(data['databases'] ?? []);
      }
      return [];
    }

    if (_connection == null || !_connection!.connected) return [];
    final res = await _connection!.execute("SHOW DATABASES;");
    final List<String> dbs = [];
    for (final row in res.rows) {
      final dbName = row.assoc()['Database'] ?? row.assoc()['database'] ?? row.colAt(0);
      if (dbName != null &&
          dbName != 'information_schema' &&
          dbName != 'mysql' &&
          dbName != 'performance_schema' &&
          dbName != 'sys') {
        dbs.add(dbName.toString());
      }
    }
    return dbs;
  }

  /// Altera a base de dados ativa
  Future<void> selectDatabase(String dbName) async {
    if (_currentConfig != null) {
      _currentConfig!.database = dbName;
    }
    if (_isApiBridgeConnected) return;
    if (_connection == null || !_connection!.connected) return;
    await _connection!.execute("USE `$dbName`;");
  }

  /// Obtém a lista de tabelas reais na base de dados selecionada
  Future<List<String>> getTables(String dbName) async {
    await selectDatabase(dbName);

    if (_isApiBridgeConnected) {
      final payload = {
        ...(_currentConfig?.toJson() ?? {}),
        'database': dbName,
      };

      final res = await http.post(
        Uri.parse('$_apiBridgeBaseUrl/tables'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return List<String>.from(data['tables'] ?? []);
      }
      return [];
    }

    if (_connection == null || !_connection!.connected) return [];
    final res = await _connection!.execute("SHOW TABLES;");
    final List<String> tables = [];
    for (final row in res.rows) {
      final name = row.colAt(0);
      if (name != null) {
        tables.add(name.toString());
      }
    }
    return tables;
  }

  /// Inspeciona o esquema de colunas de uma tabela real
  Future<TableSchema> getTableSchema(String tableName, {String? dbName}) async {
    final activeDb = dbName ?? _currentConfig?.database ?? 'suporte_db';

    if (_isApiBridgeConnected) {
      final payload = {
        ...(_currentConfig?.toJson() ?? {}),
        'database': activeDb,
        'table': tableName,
      };

      final res = await http.post(
        Uri.parse('$_apiBridgeBaseUrl/schema'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final rawCols = List<Map<String, dynamic>>.from(data['columns'] ?? []);
        final cols = rawCols.map((c) => ColumnInfo(
          name: c['name'],
          type: c['type'],
          isNullable: c['isNullable'] ?? true,
          isPrimaryKey: c['isPrimaryKey'] ?? false,
          isAutoIncrement: c['isAutoIncrement'] ?? false,
          defaultValue: c['defaultValue'],
        )).toList();

        return TableSchema(
          tableName: tableName,
          columns: cols,
          primaryKey: data['primaryKey'],
        );
      }
      return TableSchema(tableName: tableName, columns: []);
    }

    if (_connection == null || !_connection!.connected) {
      return TableSchema(tableName: tableName, columns: []);
    }

    await selectDatabase(activeDb);
    final res = await _connection!.execute("DESCRIBE `$tableName`;");
    final List<ColumnInfo> cols = [];
    String? pk;

    for (final row in res.rows) {
      final map = row.assoc();
      final field = map['Field'] ?? map['field'] ?? row.colAt(0) ?? '';
      final type = map['Type'] ?? map['type'] ?? row.colAt(1) ?? '';
      final nullability = map['Null'] ?? map['null'] ?? row.colAt(2) ?? 'YES';
      final key = map['Key'] ?? map['key'] ?? row.colAt(3) ?? '';
      final extra = map['Extra'] ?? map['extra'] ?? row.colAt(5) ?? '';
      final defVal = map['Default'] ?? map['default'];

      final isPk = key.toString().toUpperCase() == 'PRI';
      if (isPk) pk = field.toString();

      cols.add(ColumnInfo(
        name: field.toString(),
        type: type.toString(),
        isNullable: nullability.toString().toUpperCase() == 'YES',
        isPrimaryKey: isPk,
        isAutoIncrement: extra.toString().toLowerCase().contains('auto_increment'),
        defaultValue: defVal?.toString(),
      ));
    }

    return TableSchema(
      tableName: tableName,
      columns: cols,
      primaryKey: pk,
    );
  }

  /// Busca os registos de uma tabela real ordenada de forma DESCENDENTE
  Future<List<Map<String, dynamic>>> getTableRecords(
    String tableName, {
    String? dbName,
    String? searchFilter,
    String? orderByColumn,
    bool isDesc = true,
  }) async {
    final activeDb = dbName ?? _currentConfig?.database ?? 'suporte_db';

    if (_isApiBridgeConnected) {
      final payload = {
        ...(_currentConfig?.toJson() ?? {}),
        'database': activeDb,
        'table': tableName,
        'filter': searchFilter,
      };

      final res = await http.post(
        Uri.parse('$_apiBridgeBaseUrl/records'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return List<Map<String, dynamic>>.from(data['records'] ?? []);
      }
      return [];
    }

    if (_connection == null || !_connection!.connected) return [];

    await selectDatabase(activeDb);
    final schema = await getTableSchema(tableName, dbName: activeDb);
    final orderCol = orderByColumn ?? schema.primaryKey ?? (schema.columns.isNotEmpty ? schema.columns.first.name : null);

    String query = "SELECT * FROM `$tableName`";

    if (searchFilter != null && searchFilter.trim().isNotEmpty) {
      final safeFilter = searchFilter.replaceAll("'", "''");
      final whereClauses = schema.columns.map((c) => "`${c.name}` LIKE '%$safeFilter%'").join(" OR ");
      query += " WHERE $whereClauses";
    }

    if (orderCol != null) {
      query += " ORDER BY `$orderCol` ${isDesc ? 'DESC' : 'ASC'}";
    }

    query += " LIMIT 500;";

    final res = await _connection!.execute(query);
    final List<Map<String, dynamic>> records = [];

    for (final row in res.rows) {
      final Map<String, dynamic> rowMap = {};
      final assoc = row.assoc();
      for (final col in schema.columns) {
        rowMap[col.name] = assoc[col.name];
      }
      records.add(rowMap);
    }

    return records;
  }

  /// Inserção de um novo registo em tabela MySQL real
  Future<void> insertRecord(
    String dbName,
    String tableName,
    Map<String, dynamic> data,
  ) async {
    if (_isApiBridgeConnected) {
      final payload = {
        ...(_currentConfig?.toJson() ?? {}),
        'database': dbName,
        'table': tableName,
        'data': data,
      };

      await http.post(
        Uri.parse('$_apiBridgeBaseUrl/insert'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      return;
    }

    if (_connection == null || !_connection!.connected) return;

    await selectDatabase(dbName);
    final schema = await getTableSchema(tableName, dbName: dbName);

    final Map<String, dynamic> cleanData = {};
    for (final entry in data.entries) {
      final col = schema.columns.firstWhere(
        (c) => c.name == entry.key,
        orElse: () => ColumnInfo(name: entry.key, type: 'text', isNullable: true, isPrimaryKey: false, isAutoIncrement: false),
      );
      if (col.isAutoIncrement && (entry.value == null || entry.value.toString().isEmpty)) {
        continue;
      }
      cleanData[entry.key] = entry.value;
    }

    final colsStr = cleanData.keys.map((k) => "`$k`").join(", ");
    final placeholders = cleanData.keys.map((k) => ":$k").join(", ");

    final sql = "INSERT INTO `$tableName` ($colsStr) VALUES ($placeholders);";
    final res = await _connection!.execute(sql, cleanData);

    final insertedId = res.lastInsertID.toString();

    await logAuditAction(
      baseDadosAlvo: dbName,
      tabelaAlvo: tableName,
      registoId: insertedId,
      acao: 'INSERIR',
      dadosNovos: cleanData,
    );
  }

  /// Atualização de um registo em MySQL real
  Future<void> updateRecord(
    String dbName,
    String tableName,
    String primaryKeyCol,
    dynamic primaryKeyValue,
    Map<String, dynamic> newData,
    Map<String, dynamic> oldData,
  ) async {
    if (_isApiBridgeConnected) {
      final payload = {
        ...(_currentConfig?.toJson() ?? {}),
        'database': dbName,
        'table': tableName,
        'primaryKeyCol': primaryKeyCol,
        'primaryKeyValue': primaryKeyValue,
        'newData': newData,
        'oldData': oldData,
      };

      await http.post(
        Uri.parse('$_apiBridgeBaseUrl/update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      return;
    }

    if (_connection == null || !_connection!.connected) return;

    await selectDatabase(dbName);
    final setClauses = newData.keys.map((k) => "`$k` = :$k").join(", ");
    final params = Map<String, dynamic>.from(newData);
    params['pk_val'] = primaryKeyValue;

    final sql = "UPDATE `$tableName` SET $setClauses WHERE `$primaryKeyCol` = :pk_val;";
    await _connection!.execute(sql, params);

    await logAuditAction(
      baseDadosAlvo: dbName,
      tabelaAlvo: tableName,
      registoId: primaryKeyValue.toString(),
      acao: 'ATUALIZAR',
      dadosAnteriores: oldData,
      dadosNovos: newData,
    );
  }

  /// Eliminação de um registo em MySQL real
  Future<void> deleteRecord(
    String dbName,
    String tableName,
    String primaryKeyCol,
    dynamic primaryKeyValue,
    Map<String, dynamic> oldData,
  ) async {
    if (_isApiBridgeConnected) {
      final payload = {
        ...(_currentConfig?.toJson() ?? {}),
        'database': dbName,
        'table': tableName,
        'primaryKeyCol': primaryKeyCol,
        'primaryKeyValue': primaryKeyValue,
        'oldData': oldData,
      };

      await http.post(
        Uri.parse('$_apiBridgeBaseUrl/delete'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      return;
    }

    if (_connection == null || !_connection!.connected) return;

    await selectDatabase(dbName);
    final sql = "DELETE FROM `$tableName` WHERE `$primaryKeyCol` = :pk_val;";
    await _connection!.execute(sql, {'pk_val': primaryKeyValue});

    await logAuditAction(
      baseDadosAlvo: dbName,
      tabelaAlvo: tableName,
      registoId: primaryKeyValue.toString(),
      acao: 'ELIMINAR',
      dadosAnteriores: oldData,
    );
  }

  /// Obtém a lista de logs da base de dados suporte_db real
  Future<List<AuditLog>> getAuditLogs({String? filterText}) async {
    if (_isApiBridgeConnected) {
      final payload = {
        ...(_currentConfig?.toJson() ?? {}),
        'filter': filterText,
      };

      final res = await http.post(
        Uri.parse('$_apiBridgeBaseUrl/logs'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final rawLogs = List<Map<String, dynamic>>.from(data['logs'] ?? []);
        return rawLogs.map((l) => AuditLog.fromMap(l)).toList();
      }
      return [];
    }

    if (_connection == null || !_connection!.connected) return [];

    try {
      String sql = "SELECT * FROM `suporte_db`.`historico_logs`";
      if (filterText != null && filterText.trim().isNotEmpty) {
        final safe = filterText.replaceAll("'", "''");
        sql += " WHERE `base_dados_alvo` LIKE '%$safe%' OR `tabela_alvo` LIKE '%$safe%' OR `acao` LIKE '%$safe%' OR `registo_id` LIKE '%$safe%'";
      }
      sql += " ORDER BY `id` DESC LIMIT 500;";

      final res = await _connection!.execute(sql);
      final List<AuditLog> logs = [];

      for (final row in res.rows) {
        final assoc = row.assoc();
        logs.add(AuditLog.fromMap(assoc));
      }
      return logs;
    } catch (e) {
      print("Erro ao carregar logs de auditoria: $e");
      return [];
    }
  }
}
