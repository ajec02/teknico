// Modelo de Conexão Guardada no Sistema Suporte OS

import 'dart:convert';

class SavedConnection {
  final String id;
  final String name;
  final String host;
  final int port;
  final String user;
  final String password;
  final String database;
  final DateTime createdAt;
  final DateTime? lastUsedAt;

  SavedConnection({
    required this.id,
    required this.name,
    required this.host,
    required this.port,
    required this.user,
    required this.password,
    this.database = 'suporte_db',
    DateTime? createdAt,
    this.lastUsedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  SavedConnection copyWith({
    String? id,
    String? name,
    String? host,
    int? port,
    String? user,
    String? password,
    String? database,
    DateTime? createdAt,
    DateTime? lastUsedAt,
  }) {
    return SavedConnection(
      id: id ?? this.id,
      name: name ?? this.name,
      host: host ?? this.host,
      port: port ?? this.port,
      user: user ?? this.user,
      password: password ?? this.password,
      database: database ?? this.database,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'host': host,
      'port': port,
      'user': user,
      'password': password,
      'database': database,
      'createdAt': createdAt.toIso8601String(),
      'lastUsedAt': lastUsedAt?.toIso8601String(),
    };
  }

  factory SavedConnection.fromMap(Map<String, dynamic> map) {
    return SavedConnection(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Conexão MySQL',
      host: map['host'] ?? '127.0.0.1',
      port: map['port'] is int ? map['port'] : (int.tryParse(map['port'].toString()) ?? 3306),
      user: map['user'] ?? 'root',
      password: map['password'] ?? '',
      database: map['database'] ?? 'suporte_db',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      lastUsedAt: map['lastUsedAt'] != null ? DateTime.parse(map['lastUsedAt']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory SavedConnection.fromJson(String source) => SavedConnection.fromMap(json.decode(source));
}
