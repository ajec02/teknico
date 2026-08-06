# Documentação de API & Serviços - Sistema Suporte

## 1. Visão Geral dos Serviços Internos em Dart

### `MySqlService`
Responsável pela comunicação direta com o driver `mysql_client`.

#### Métodos Principais:
- `connect(DbConnectionConfig config)`: Estabelece a ligação socket ao MySQL e inicializa a base de dados `suporte_db`.
- `getDatabases()`: Retorna a lista de bases de dados ativas (`SHOW DATABASES`).
- `getTables(String dbName)`: Retorna as tabelas da base de dados selecionada (`SHOW TABLES`).
- `getTableSchema(String tableName)`: Inspeciona a estrutura de colunas e chave primária (`DESCRIBE table`).
- `getTableRecords(String tableName, {searchFilter, isDesc: true})`: Executa a consulta SELECT com ordenação descendente por chave primária.
- `insertRecord(...)`: Executa o INSERT e envia o registo para `logAuditAction`.
- `updateRecord(...)`: Executa o UPDATE e regista `dadosAnteriores` e `dadosNovos` em `historico_logs`.
- `deleteRecord(...)`: Executa o DELETE e grava os `dadosAnteriores` em `historico_logs`.

### `ExportService`
- `exportToExcel(...)`: Gera ficheiro no formato `.xlsx`.
- `exportToPdf(...)`: Constrói o relatório PDF com marca d'água corporativa, emissor, data e QR Code no rodapé.
