# Plano de Backup e Recuperação - Sistema Suporte

## 1. Estratégia de Backup do MySQL
O sistema Suporte inclui rotinas recomendadas de segurança para a preservação das bases de dados geridas e da própria base de dados do sistema (`suporte_db`).

### Backup Diário Completo (mysqldump)
Executar o comando `mysqldump` para exportar o esquema e dados da base `suporte_db`:
```bash
mysqldump -u root -pSenha123 --databases suporte_db > backup_suporte_db_$(date +%Y%m%d).sql
```

## 2. Procedimento de Restauração
Em caso de falha de hardware ou perda de dados:
```bash
mysql -u root -pSenha123 < backup_suporte_db_20260805.sql
```
