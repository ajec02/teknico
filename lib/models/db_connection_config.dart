// Modelo para configuração de conexão com servidor MySQL em Dart

class DbConnectionConfig {
  String host;
  int port;
  String user;
  String password;
  String database;
  bool isTestMode;

  DbConnectionConfig({
    this.host = '127.0.0.1',
    this.port = 3306,
    this.user = 'root',
    this.password = 'Senha123',
    this.database = 'suporte_db',
    this.isTestMode = true,
  });

  Map<String, dynamic> toJson() => {
        'host': host,
        'port': port,
        'user': user,
        'password': password,
        'database': database,
        'isTestMode': isTestMode,
      };

  factory DbConnectionConfig.fromJson(Map<String, dynamic> json) =>
      DbConnectionConfig(
        host: json['host'] ?? '127.0.0.1',
        port: json['port'] ?? 3306,
        user: json['user'] ?? 'root',
        password: json['password'] ?? 'Senha123',
        database: json['database'] ?? 'suporte_db',
        isTestMode: json['isTestMode'] ?? true,
      );
}
