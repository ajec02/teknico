# Dicionário de Dados - Base de Dados do Sistema (`suporte_db`)

## Tabela: `historico_logs`
Tabela de auditoria encarregada de armazenar todas as mutações de dados ocorridas em qualquer base de dados gerida pelo sistema Suporte (ex.: `negomil`, `suporte_db`).

| Campo | Tipo de Dado | Nulo | Chave | Descrição |
|---|---|---|---|---|
| `id` | `INT` | NÃO | PRI (Auto Increment) | Identificador único incremental do log |
| `base_dados_alvo` | `VARCHAR(100)` | NÃO | | Nome da base de dados afetada (ex.: `negomil`) |
| `tabela_alvo` | `VARCHAR(100)` | NÃO | | Nome da tabela afetada (ex.: `clientes`) |
| `registo_id` | `VARCHAR(100)` | NÃO | | Identificador da chave primária do registo alterado |
| `acao` | `ENUM('INSERIR', 'ATUALIZAR', 'ELIMINAR')` | NÃO | | Tipo de operação realizada |
| `dados_anteriores` | `LONGTEXT / JSON` | SIM | | Registo em formato JSON **antes** da alteração |
| `dados_novos` | `LONGTEXT / JSON` | SIM | | Registo em formato JSON **após** a alteração |
| `utilizador_sistema` | `VARCHAR(100)` | SIM | | Utilizador que realizou a operação |
| `criado_em` | `DATETIME` | SIM | | Data e hora em que a ação foi efetuada |
