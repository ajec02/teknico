// Estado Global da Aplicação Teknico (AppState Provider)

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/db_connection_config.dart';
import '../models/table_schema.dart';
import '../models/audit_log.dart';
import '../services/mysql_service.dart';
import '../services/export_service.dart';

class AppState extends ChangeNotifier {
  static const String _keyActiveView = 'suporte_active_view';
  static const String _keySelectedDb = 'suporte_selected_db';
  static const String _keySelectedTable = 'suporte_selected_table';
  static const String _keyMenuCollapsed = 'suporte_menu_collapsed';
  static const String _keyDarkMode = 'suporte_dark_mode';
  static const String _keyHost = 'suporte_db_host';
  static const String _keyPort = 'suporte_db_port';
  static const String _keyUser = 'suporte_db_user';
  static const String _keyPass = 'suporte_db_pass';
  static const String _keyDbName = 'suporte_db_name';
  static const String _keyIsConnected = 'suporte_is_connected';

  final MySqlService _mysqlService = MySqlService();

  DbConnectionConfig? _currentConfig;
  bool _isConnected = false;
  bool _isLoading = false;
  String _loadingMessage = 'A carregar...';

  List<String> _databases = [];
  String? _selectedDatabase;

  List<String> _tables = [];
  String? _selectedTable;

  TableSchema? _currentSchema;
  List<Map<String, dynamic>> _currentRecords = [];
  List<AuditLog> _auditLogs = [];

  bool _isDarkMode = true;
  bool _isMenuCollapsed = false;
  int _activeViewIndex = 0; // 0: CRUD de Tabelas, 1: Histórico de Auditoria

  // Getters & Aliases de Compatibilidade
  DbConnectionConfig? get currentConfig => _currentConfig;
  DbConnectionConfig get config => _currentConfig ?? DbConnectionConfig(host: '127.0.0.1', port: 3306, user: 'root', password: 'Senha123', database: 'suporte_db');

  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  String get loadingMessage => _loadingMessage;

  List<String> get databases => _databases;
  String? get selectedDatabase => _selectedDatabase;

  List<String> get tables => _tables;
  String? get selectedTable => _selectedTable;

  TableSchema? get currentSchema => _currentSchema;
  List<Map<String, dynamic>> get currentRecords => _currentRecords;
  List<AuditLog> get auditLogs => _auditLogs;

  bool get isDarkMode => _isDarkMode;
  bool get isMenuCollapsed => _isMenuCollapsed;
  bool get isDrawerOpen => !_isMenuCollapsed;
  int get activeViewIndex => _activeViewIndex;

  Future<void> loadPreferencesAndRestoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_keyDarkMode) ?? true;
    _isMenuCollapsed = prefs.getBool(_keyMenuCollapsed) ?? false;
    _activeViewIndex = prefs.getInt(_keyActiveView) ?? 0;
    _selectedDatabase = prefs.getString(_keySelectedDb);
    _selectedTable = prefs.getString(_keySelectedTable);

    final host = prefs.getString(_keyHost);
    if (host != null) {
      final config = DbConnectionConfig(
        host: host,
        port: prefs.getInt(_keyPort) ?? 3306,
        user: prefs.getString(_keyUser) ?? '',
        password: prefs.getString(_keyPass) ?? '',
        database: prefs.getString(_keyDbName) ?? 'suporte_db',
      );
      if (prefs.getBool(_keyIsConnected) ?? false) {
        await connect(config);
      }
    }
    notifyListeners();
  }

  void setActiveViewIndex(int index) async {
    _activeViewIndex = index;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyActiveView, index);
    } catch (_) {}
  }

  void toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyDarkMode, _isDarkMode);
    } catch (_) {}
  }

  void toggleTheme() => toggleDarkMode();

  void toggleMenuCollapsed() async {
    _isMenuCollapsed = !_isMenuCollapsed;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyMenuCollapsed, _isMenuCollapsed);
    } catch (_) {}
  }

  void toggleDrawer() => toggleMenuCollapsed();

  void setLoading(bool loading, [String message = 'A carregar...']) {
    _isLoading = loading;
    _loadingMessage = message;
    notifyListeners();
  }

  /// Testar conexão sem salvar estado global
  Future<bool> testConnection(DbConnectionConfig config) async {
    setLoading(true, 'A testar conexão com ${config.host}:${config.port}...');
    try {
      final dbs = await _mysqlService.testConnection(config);
      return dbs.isNotEmpty;
    } catch (_) {
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Conectar à base de dados
  Future<bool> connectToDatabase(DbConnectionConfig config) async {
    return connect(config);
  }

  /// Estabelece conexão com o servidor MySQL
  Future<bool> connect(DbConnectionConfig config) async {
    setLoading(true, 'A ligar ao servidor MySQL (${config.host}:${config.port})...');
    try {
      await _mysqlService.connect(config);
      _isConnected = _mysqlService.isConnected;
      if (_isConnected) {
        _currentConfig = config;
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(_keyIsConnected, true);
          await prefs.setString(_keyHost, config.host);
          await prefs.setInt(_keyPort, config.port);
          await prefs.setString(_keyUser, config.user);
          await prefs.setString(_keyPass, config.password);
          await prefs.setString(_keyDbName, config.database);
        } catch (_) {}
        await loadDatabases();
        await loadAuditLogs();
      }
      return _isConnected;
    } catch (e) {
      _isConnected = false;
      print("Erro ao ligar ao MySQL: $e");
      return false;
    } finally {
      setLoading(false);
    }
  }

  /// Desliga do servidor ativo
  void disconnect() async {
    _isConnected = false;
    _currentConfig = null;
    _databases = [];
    _selectedDatabase = null;
    _tables = [];
    _selectedTable = null;
    _currentRecords = [];
    _auditLogs = [];
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsConnected, false);
      await prefs.remove(_keySelectedDb);
      await prefs.remove(_keySelectedTable);
    } catch (_) {}
  }

  /// Carrega a lista de bases de dados reais
  Future<void> loadDatabases() async {
    setLoading(true, 'A listar bases de dados disponíveis...');
    try {
      _databases = await _mysqlService.getDatabases();
      if (_databases.isNotEmpty) {
        if (_selectedDatabase == null || !_databases.contains(_selectedDatabase)) {
          _selectedDatabase = _databases.first;
        }
        await loadTablesForDatabase(_selectedDatabase!);
      }
    } catch (e) {
      print("Erro ao carregar bases de dados: $e");
    } finally {
      setLoading(false);
    }
  }

  /// Seleciona uma base de dados e carrega as suas tabelas
  Future<void> selectDatabase(String dbName) async {
    _selectedDatabase = dbName;
    _selectedTable = null;
    _currentRecords = [];
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySelectedDb, dbName);
      await prefs.remove(_keySelectedTable);
    } catch (_) {}
    await loadTablesForDatabase(dbName);
  }

  /// Carrega as tabelas de uma base de dados específica
  Future<void> loadTablesForDatabase(String dbName) async {
    _selectedDatabase = dbName;
    setLoading(true, 'A carregar tabelas de $dbName...');
    try {
      _tables = await _mysqlService.getTables(dbName);
      if (_tables.isNotEmpty) {
        if (_selectedTable == null || !_tables.contains(_selectedTable)) {
          _selectedTable = _tables.first;
        }
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_keySelectedDb, dbName);
          await prefs.setString(_keySelectedTable, _selectedTable!);
        } catch (_) {}
        await loadRecordsForTable(_selectedTable!);
      } else {
        _selectedTable = null;
        _currentRecords = [];
      }
    } catch (e) {
      print("Erro ao carregar tabelas: $e");
    } finally {
      setLoading(false);
    }
  }

  /// Seleciona uma tabela e carrega os seus registos (Último registo em primeiro)
  Future<void> selectTable(String tableName) async {
    _selectedTable = tableName;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySelectedTable, tableName);
    } catch (_) {}
    await loadRecordsForTable(tableName);
  }

  /// Carrega os registos de uma tabela ordenada por ID DESC (Último registo em primeiro lugar)
  Future<void> loadRecordsForTable(String tableName, {String? searchFilter}) async {
    setLoading(true, 'A carregar dados de $tableName...');
    try {
      _selectedTable = tableName;
      _currentSchema = await _mysqlService.getTableSchema(tableName, dbName: _selectedDatabase);
      _currentRecords = await _mysqlService.getTableRecords(
        tableName,
        dbName: _selectedDatabase,
        searchFilter: searchFilter,
        isDesc: true,
      );
    } catch (e) {
      print("Erro ao carregar registos da tabela: $e");
    } finally {
      setLoading(false);
    }
  }

  /// Carrega o Histórico de Logs de Auditoria da base de dados suporte_db
  Future<void> loadAuditLogs({String? filterText}) async {
    setLoading(true, 'A carregar histórico de auditoria...');
    try {
      _auditLogs = await _mysqlService.getAuditLogs(filterText: filterText);
    } catch (e) {
      print("Erro ao carregar logs: $e");
    } finally {
      setLoading(false);
    }
  }

  /// Inserir novo registo com refresh imediato da tabela e dos logs
  Future<void> insertRecord(Map<String, dynamic> data) async {
    if (_selectedDatabase == null || _selectedTable == null) return;
    setLoading(true, 'A guardar novo registo...');
    try {
      await _mysqlService.insertRecord(_selectedDatabase!, _selectedTable!, data);
      await loadRecordsForTable(_selectedTable!);
      await loadAuditLogs();
    } finally {
      setLoading(false);
    }
  }

  /// Atualizar registo existente com refresh imediato da tabela e dos logs
  Future<void> updateRecord(
    dynamic primaryKeyValue,
    Map<String, dynamic> newData,
    Map<String, dynamic> oldData,
  ) async {
    if (_selectedDatabase == null || _selectedTable == null || _currentSchema?.primaryKey == null) return;
    setLoading(true, 'A atualizar registo...');
    try {
      await _mysqlService.updateRecord(
        _selectedDatabase!,
        _selectedTable!,
        _currentSchema!.primaryKey!,
        primaryKeyValue,
        newData,
        oldData,
      );
      await loadRecordsForTable(_selectedTable!);
      await loadAuditLogs();
    } finally {
      setLoading(false);
    }
  }

  /// Eliminar registo com refresh imediato da tabela e dos logs
  Future<void> deleteRecord(
    dynamic primaryKeyValue,
    Map<String, dynamic> oldData,
  ) async {
    if (_selectedDatabase == null || _selectedTable == null || _currentSchema?.primaryKey == null) return;
    setLoading(true, 'A eliminar registo...');
    try {
      await _mysqlService.deleteRecord(
        _selectedDatabase!,
        _selectedTable!,
        _currentSchema!.primaryKey!,
        primaryKeyValue,
        oldData,
      );
      await loadRecordsForTable(_selectedTable!);
      await loadAuditLogs();
    } finally {
      setLoading(false);
    }
  }

  /// Exportar registos atuais para Excel
  Future<void> exportToExcel() async {
    if (_selectedTable == null || _currentRecords.isEmpty || _currentSchema == null) return;
    setLoading(true, 'A gerar ficheiro Excel (.xlsx)...');
    try {
      final cols = _currentSchema!.columns.map((c) => c.name).toList();
      await ExportService.exportToExcel(
        title: 'Relatório da Tabela $_selectedTable',
        tableName: _selectedTable!,
        columns: cols,
        records: _currentRecords,
      );
    } finally {
      setLoading(false);
    }
  }

  /// Exportar registos atuais para PDF com cabeçalho corporativo e QR Code (Relrel)
  Future<void> exportToPdf() async {
    if (_selectedTable == null || _currentRecords.isEmpty || _currentSchema == null) return;
    setLoading(true, 'A gerar relatório PDF com QR Code...');
    try {
      final cols = _currentSchema!.columns.map((c) => c.name).toList();
      await ExportService.exportToPdf(
        title: 'Relatório da Tabela $_selectedTable',
        databaseName: _selectedDatabase ?? 'BD',
        tableName: _selectedTable!,
        columns: cols,
        records: _currentRecords,
        emittedBy: 'root',
      );
    } finally {
      setLoading(false);
    }
  }
}
