# Manual do Utilizador - Sistema Suporte

## 1. Introdução
O **Suporte** é um sistema multiplataforma desenvolvido em Dart/Flutter para a gestão e administração completa de bases de dados MySQL.

## 2. Conexão ao Servidor
1. Abra a aplicação.
2. Selecione o modo pretendido:
   - **Modo Teste (MTeste)**: Preenche automaticamente credenciais locais (`localhost`, `root`, `Senha123`, `3306`, `suporte_db`).
   - **Modo Produção**: Permite a introdução manual dos dados do servidor MySQL de produção.
3. Clique em **LIGAR AO SERVIDOR MYSQL**.

## 3. Gestão e Operações CRUD em Tabelas
- **Visualização**: Selecione a tabela no menu lateral esquerdo. Os dados são apresentados com os **últimos registos cadastrados em primeiro lugar**.
- **Pesquisa**: Utilize a barra superior de pesquisa para filtrar registos em tempo real.
- **Adicionar Registo**: Clique em **Novo Registo**, preencha o formulário e guarde.
- **Editar Registo**: Clique no ícone de lápis ao lado do registo. Confirme a alteração na janela modal.
- **Eliminar Registo**: Clique no ícone de lixeira e confirme a eliminação.

## 4. Histórico de Auditoria (`historico_logs`)
- Aceda a **Histórico de Logs** no menu lateral.
- Todas as inserções, edições e eliminações efetuadas em qualquer base de dados (ex.: `negomil`) são registadas automaticamente com os dados anteriores e novos em formato JSON.

## 5. Exportação de Relatórios (Export / Relrel)
- Clique em **Exportar Excel** ou **Exportar PDF (Relrel)**.
- O PDF gerado inclui cabeçalho corporativo com nome da empresa, logótipo, emissor, data/hora e um código QR no rodapé com a assinatura digital do relatório.
