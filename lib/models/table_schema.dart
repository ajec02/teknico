// Modelo para informações das colunas de uma tabela MySQL

class ColumnInfo {
  final String name;
  final String type;
  final bool isNullable;
  final bool isPrimaryKey;
  final bool isAutoIncrement;
  final String? defaultValue;

  ColumnInfo({
    required this.name,
    required this.type,
    required this.isNullable,
    required this.isPrimaryKey,
    required this.isAutoIncrement,
    this.defaultValue,
  });

  bool get isNumeric =>
      type.toLowerCase().contains('int') ||
      type.toLowerCase().contains('decimal') ||
      type.toLowerCase().contains('float') ||
      type.toLowerCase().contains('double');

  bool get isDateOrTime =>
      type.toLowerCase().contains('date') ||
      type.toLowerCase().contains('time') ||
      type.toLowerCase().contains('year');

  bool get isBoolean =>
      type.toLowerCase().contains('tinyint(1)') ||
      type.toLowerCase().contains('bool');
}

class TableSchema {
  final String tableName;
  final List<ColumnInfo> columns;
  final String? primaryKey;

  TableSchema({
    required this.tableName,
    required this.columns,
    this.primaryKey,
  });
}
