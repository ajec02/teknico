// Servidor de Ponte API MySQL em Dart para o Sistema Teknico (Bridge HTTP/REST para MySQL Real no Laragon)

import 'dart:convert';
import 'dart:io';

Map<String, dynamic>? gConfig;

const String mysqlExePath = r'C:\laragon\bin\mysql\mysql-8.4.3-winx64\bin\mysql.exe';

void main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8085);
  print('Ponte API MySQL do Teknico ativa em http://0.0.0.0:8085 (Rede Local Ativa)');

  await for (final request in server) {
    // Definir cabeçalhos CORS
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    request.response.headers.add('Access-Control-Allow-Headers', 'Content-Type, Authorization');

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      continue;
    }

    try {
      final path = request.uri.path;
      final bodyStr = await utf8.decoder.bind(request).join();
      final Map<String, dynamic> body = bodyStr.isNotEmpty ? jsonDecode(bodyStr) : {};

      switch (path) {
        case '/api/connect':
          await handleConnect(request, body);
          break;
        case '/api/databases':
          await handleGetDatabases(request, body);
          break;
        case '/api/tables':
          await handleGetTables(request, body);
          break;
        case '/api/schema':
          await handleGetSchema(request, body);
          break;
        case '/api/records':
          await handleGetRecords(request, body);
          break;
        case '/api/insert':
          await handleInsert(request, body);
          break;
        case '/api/update':
          await handleUpdate(request, body);
          break;
        case '/api/delete':
          await handleDelete(request, body);
          break;
        case '/api/logs':
          await handleGetLogs(request, body);
          break;
        default:
          sendResponse(request, {'error': 'Rota não encontrada'}, status: 404);
      }
    } catch (e) {
      print('Erro no servidor bridge: $e');
      sendResponse(request, {'error': e.toString()}, status: 500);
    }
  }
}

void sendResponse(HttpRequest request, Map<String, dynamic> data, {int status = 200}) {
  request.response
    ..statusCode = status
    ..headers.contentType = ContentType.json
    ..write(jsonEncode(data));
  request.response.close();
}

/// Formata valores dinâmicos para SQL seguro tratando campos vazios como NULL
String _formatSqlValue(dynamic val) {
  if (val == null) return "NULL";
  final str = val.toString().trim();
  if (str.isEmpty || str.toLowerCase() == 'null') return "NULL";
  final escaped = str.replaceAll("'", "''").replaceAll(r'\', r'\\');
  return "'$escaped'";
}

/// Decodifica string hexadecimal devolvida pelo MySQL HEX()
String _decodeHex(String? hex) {
  if (hex == null || hex.isEmpty || hex.toUpperCase() == 'NULL') return '';
  try {
    final cleanHex = hex.trim();
    final bytes = <int>[];
    for (var i = 0; i < cleanHex.length; i += 2) {
      if (i + 2 <= cleanHex.length) {
        bytes.add(int.parse(cleanHex.substring(i, i + 2), radix: 16));
      }
    }
    return utf8.decode(bytes);
  } catch (_) {
    return hex;
  }
}

/// Executa query via CLI do mysql.exe com USE db automático
Future<String?> _execMysqlCli(Map<String, dynamic> config, String sql, {String? db}) async {
  final host = config['host'] ?? gConfig?['host'] ?? '127.0.0.1';
  final port = (config['port'] ?? gConfig?['port'] ?? 3306).toString();
  final user = config['user'] ?? gConfig?['user'] ?? 'root';
  final pass = config['password'] ?? gConfig?['password'] ?? 'Senha123';

  final fullSql = (db != null && db.isNotEmpty) ? 'USE `$db`; $sql' : sql;

  final List<String> args = [
    '-u', user,
    '-p$pass',
    '-h', host,
    '-P', port,
    '--default-character-set=utf8mb4',
    '-e', fullSql,
  ];

  final res = await Process.run(mysqlExePath, args);
  if (res.exitCode == 0) {
    return res.stdout.toString();
  } else {
    print("MySQL CLI Warning/Error: ${res.stderr}");
    return res.stdout.toString().isNotEmpty ? res.stdout.toString() : null;
  }
}

Future<void> handleConnect(HttpRequest request, Map<String, dynamic> body) async {
  gConfig = body;
  final out = await _execMysqlCli(body, "SHOW DATABASES;");
  if (out != null) {
    await _execMysqlCli(body, "CREATE DATABASE IF NOT EXISTS `suporte_db` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
    await _execMysqlCli(body, '''
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

    sendResponse(request, {'success': true, 'message': 'Conectado ao MySQL com sucesso'});
  } else {
    sendResponse(request, {'error': 'Falha ao conectar ao MySQL'}, status: 400);
  }
}

Future<void> handleGetDatabases(HttpRequest request, Map<String, dynamic> body) async {
  final out = await _execMysqlCli(body, "SHOW DATABASES;");
  final List<String> dbs = [];

  if (out != null) {
    final lines = out.split('\n');
    for (var line in lines) {
      line = line.trim();
      if (line.isNotEmpty &&
          line != 'Database' &&
          line != 'information_schema' &&
          line != 'mysql' &&
          line != 'performance_schema' &&
          line != 'sys') {
        dbs.add(line);
      }
    }
  }

  sendResponse(request, {'databases': dbs});
}

Future<void> handleGetTables(HttpRequest request, Map<String, dynamic> body) async {
  final dbName = body['database'] ?? gConfig?['database'] ?? 'suporte_db';
  final out = await _execMysqlCli(body, "SHOW TABLES;", db: dbName);
  final List<String> tables = [];

  if (out != null) {
    final lines = out.split('\n');
    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isNotEmpty) {
        tables.add(line);
      }
    }
  }

  sendResponse(request, {'tables': tables});
}

Future<void> handleGetSchema(HttpRequest request, Map<String, dynamic> body) async {
  final dbName = body['database'] ?? gConfig?['database'] ?? 'suporte_db';
  final tableName = body['table'];
  final out = await _execMysqlCli(body, "DESCRIBE `$tableName`;", db: dbName);
  final List<Map<String, dynamic>> cols = [];
  String? pk;

  if (out != null) {
    final lines = out.split('\n');
    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      final parts = line.split('\t');
      if (parts.length >= 2) {
        final field = parts[0];
        final type = parts[1];
        final nullability = parts.length > 2 ? parts[2] : 'YES';
        final key = parts.length > 3 ? parts[3] : '';
        final extra = parts.length > 5 ? parts[5] : '';
        final defVal = parts.length > 4 ? parts[4] : null;

        final isPk = key.toUpperCase() == 'PRI';
        if (isPk) pk = field;

        cols.add({
          'name': field,
          'type': type,
          'isNullable': nullability.toUpperCase() == 'YES',
          'isPrimaryKey': isPk,
          'isAutoIncrement': extra.toLowerCase().contains('auto_increment'),
          'defaultValue': defVal != 'NULL' ? defVal : null,
        });
      }
    }
  }

  sendResponse(request, {
    'tableName': tableName,
    'columns': cols,
    'primaryKey': pk,
  });
}

Future<void> handleGetRecords(HttpRequest request, Map<String, dynamic> body) async {
  final dbName = body['database'] ?? gConfig?['database'] ?? 'suporte_db';
  final tableName = body['table'];
  final searchFilter = body['filter'];

  final descOut = await _execMysqlCli(body, "DESCRIBE `$tableName`;", db: dbName);
  String? pk;
  final List<String> colNames = [];

  if (descOut != null) {
    final lines = descOut.split('\n');
    for (var i = 1; i < lines.length; i++) {
      final parts = lines[i].trim().split('\t');
      if (parts.isNotEmpty && parts[0].isNotEmpty) {
        colNames.add(parts[0]);
        if (parts.length > 3 && parts[3].toUpperCase() == 'PRI') {
          pk = parts[0];
        }
      }
    }
  }

  final orderCol = pk ?? (colNames.isNotEmpty ? colNames.first : null);
  String query = "SELECT * FROM `$tableName`";

  if (searchFilter != null && searchFilter.toString().trim().isNotEmpty) {
    final safeFilter = searchFilter.toString().replaceAll("'", "''");
    final whereClauses = colNames.map((c) => "`$c` LIKE '%$safeFilter%'").join(" OR ");
    query += " WHERE $whereClauses";
  }

  if (orderCol != null) {
    query += " ORDER BY `$orderCol` DESC";
  }

  query += " LIMIT 500;";

  final out = await _execMysqlCli(body, query, db: dbName);
  final List<Map<String, dynamic>> records = [];

  if (out != null) {
    final lines = out.split('\n');
    if (lines.length > 1) {
      final headers = lines[0].split('\t').map((h) => h.trim()).toList();
      for (var i = 1; i < lines.length; i++) {
        final line = lines[i];
        if (line.trim().isEmpty) continue;
        final rowVals = line.split('\t');
        final Map<String, dynamic> rowMap = {};
        for (var j = 0; j < headers.length; j++) {
          final val = j < rowVals.length ? rowVals[j] : '';
          rowMap[headers[j]] = val != 'NULL' ? val : null;
        }
        records.add(rowMap);
      }
    }
  }

  sendResponse(request, {'records': records});
}

Future<void> handleInsert(HttpRequest request, Map<String, dynamic> body) async {
  final dbName = body['database'];
  final tableName = body['table'];
  final Map<String, dynamic> data = body['data'];

  final cols = <String>[];
  final vals = <String>[];

  for (final entry in data.entries) {
    final formatted = _formatSqlValue(entry.value);
    if (formatted != 'NULL') {
      cols.add("`${entry.key}`");
      vals.add(formatted);
    }
  }

  if (cols.isEmpty) {
    sendResponse(request, {'error': 'Nenhum dado válido para inserção'}, status: 400);
    return;
  }

  final sql = "INSERT INTO `$tableName` (${cols.join(', ')}) VALUES (${vals.join(', ')});";
  await _execMysqlCli(body, sql, db: dbName);

  final safeData = jsonEncode(data).replaceAll("'", "''");
  final logSql = "INSERT INTO `suporte_db`.`historico_logs` (`base_dados_alvo`, `tabela_alvo`, `registo_id`, `acao`, `dados_novos`, `utilizador_sistema`, `criado_em`) VALUES ('$dbName', '$tableName', 'NEW', 'INSERIR', '$safeData', 'root', NOW());";
  await _execMysqlCli(body, logSql);

  sendResponse(request, {'success': true});
}

Future<void> handleUpdate(HttpRequest request, Map<String, dynamic> body) async {
  final dbName = body['database'];
  final tableName = body['table'];
  final pkCol = body['primaryKeyCol'] ?? 'id';
  final pkVal = body['primaryKeyValue'];
  final Map<String, dynamic> newData = body['newData'];
  final Map<String, dynamic> oldData = body['oldData'];

  final setClauses = <String>[];
  for (final entry in newData.entries) {
    if (entry.key.toLowerCase() == pkCol.toString().toLowerCase()) continue;
    setClauses.add("`${entry.key}` = ${_formatSqlValue(entry.value)}");
  }

  if (setClauses.isEmpty) {
    sendResponse(request, {'success': true});
    return;
  }

  final sql = "UPDATE `$tableName` SET ${setClauses.join(', ')} WHERE `$pkCol` = '$pkVal';";
  final res = await _execMysqlCli(body, sql, db: dbName);

  if (res != null) {
    final safeOld = jsonEncode(oldData).replaceAll("'", "''");
    final safeNew = jsonEncode(newData).replaceAll("'", "''");
    final logSql = "INSERT INTO `suporte_db`.`historico_logs` (`base_dados_alvo`, `tabela_alvo`, `registo_id`, `acao`, `dados_anteriores`, `dados_novos`, `utilizador_sistema`, `criado_em`) VALUES ('$dbName', '$tableName', '$pkVal', 'ATUALIZAR', '$safeOld', '$safeNew', 'root', NOW());";
    await _execMysqlCli(body, logSql);
  }

  sendResponse(request, {'success': true});
}

Future<void> handleDelete(HttpRequest request, Map<String, dynamic> body) async {
  final dbName = body['database'];
  final tableName = body['table'];
  final pkCol = body['primaryKeyCol'] ?? 'id';
  final pkVal = body['primaryKeyValue'];
  final Map<String, dynamic> oldData = body['oldData'];

  final sql = "DELETE FROM `$tableName` WHERE `$pkCol` = '$pkVal';";
  await _execMysqlCli(body, sql, db: dbName);

  final safeOld = jsonEncode(oldData).replaceAll("'", "''");
  final logSql = "INSERT INTO `suporte_db`.`historico_logs` (`base_dados_alvo`, `tabela_alvo`, `registo_id`, `acao`, `dados_anteriores`, `utilizador_sistema`, `criado_em`) VALUES ('$dbName', '$tableName', '$pkVal', 'ELIMINAR', '$safeOld', 'root', NOW());";
  await _execMysqlCli(body, logSql);

  sendResponse(request, {'success': true});
}

Future<void> handleGetLogs(HttpRequest request, Map<String, dynamic> body) async {
  final filterText = body['filter'];
  String sql = "SELECT id, base_dados_alvo, tabela_alvo, registo_id, acao, HEX(dados_anteriores) as dados_anteriores, HEX(dados_novos) as dados_novos, utilizador_sistema, criado_em FROM `suporte_db`.`historico_logs`";

  if (filterText != null && filterText.toString().trim().isNotEmpty) {
    final safe = filterText.toString().replaceAll("'", "''");
    sql += " WHERE `base_dados_alvo` LIKE '%$safe%' OR `tabela_alvo` LIKE '%$safe%' OR `acao` LIKE '%$safe%' OR `registo_id` LIKE '%$safe%'";
  }
  sql += " ORDER BY `id` DESC LIMIT 500;";

  final out = await _execMysqlCli(body, sql);
  final List<Map<String, dynamic>> logs = [];

  if (out != null) {
    final lines = out.split('\n');
    if (lines.length > 1) {
      final headers = lines[0].split('\t').map((h) => h.trim()).toList();
      for (var i = 1; i < lines.length; i++) {
        final line = lines[i];
        if (line.trim().isEmpty) continue;
        final rowVals = line.split('\t');
        final Map<String, dynamic> rowMap = {};
        for (var j = 0; j < headers.length; j++) {
          final val = j < rowVals.length ? rowVals[j] : '';
          final key = headers[j];
          if (key == 'dados_anteriores' || key == 'dados_novos') {
            rowMap[key] = _decodeHex(val);
          } else {
            rowMap[key] = val != 'NULL' ? val : null;
          }
        }
        logs.add(rowMap);
      }
    }
  }

  sendResponse(request, {'logs': logs});
}
