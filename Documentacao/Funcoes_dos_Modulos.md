# Funções dos Módulos do Sistema Suporte OS

| Módulo | Ficheiro Fonte | Descrição da Função |
|---|---|---|
| Landing Page Extravagante | `lib/screens/landing_page_screen.dart` | Ecrã de apresentação pública do sistema com hero section, destaques dos recursos (multi-conexões, CRUD, auditoria, PDF com QR code) e botão para aceder ao login. |
| Autenticação & Login | `lib/screens/login_screen.dart` | Autenticação com suporte dinâmico para os modos MTeste (seleção instantânea com 1 clique de utilizadores predefinidos) e MProducao (formulário seguro com credenciais). |
| Gestão de Conexões Guardadas | `lib/screens/saved_connections_screen.dart` | Painel pós-login com suporte a multi-conexões MySQL guardadas (diferentes hosts, portas, utilizadores e palavras-passe), botão "+ Nova Conexão", teste de conexão e ligação dinâmica. |
| Modelo de Conexão Guardada | `lib/models/saved_connection.dart` | Estrutura de dados e serialização JSON para persistência de múltiplos perfis de servidores MySQL. |
| Modelo de Conta de Utilizador | `lib/models/user_account.dart` | Estrutura de dados dos utilizadores do sistema (Super Admin, Administrador, Técnico) com utilitários para MTeste. |
| Ponte API MySQL Real | `bin/mysql_api_bridge.dart` | Serviço HTTP na porta 8085 que conecta diretamente ao MySQL real (`127.0.0.1:3306`) e executa queries reais. |
| Conexão MySQL Híbrida | `lib/services/mysql_service.dart` | Conexão MySQL transparente que consome a ponte API real no browser e sockets nativos em Desktop. |
| Estado Global & Persistência | `lib/providers/app_state.dart` | Gestão de estado reativo, sessão do utilizador, alternância MTeste/MProducao, CRUD de conexões guardadas e persistência via `SharedPreferences`. |
| Tela Principal & Roteamento | `lib/main.dart` | Configuração do aplicativo, rotas (`/`, `/login`, `/connections`, `/dashboard`), restauração de sessão na inicialização, temas extravagantes e captura global de erros. |
| Dashboard Principal | `lib/screens/dashboard_screen.dart` | Shell de trabalho com indicação da conexão MySQL ativa (`host:port`), botão "Alternar Conexão", seletor de base de dados no cabeçalho e menu lateral retrátil (MenuT). |
| CRUD de Tabelas | `lib/screens/table_crud_screen.dart` | Gestão de dados dinâmicos com ordenação descendente (último registo em primeiro), paginação, filtros e modal de confirmação para edições e eliminações. |
| Histórico de Auditoria | `lib/screens/audit_logs_screen.dart` | Visualização de logs armazenados na tabela `historico_logs` da base `suporte_db`. |
| Exportação (Excel/PDF) | `lib/services/export_service.dart` | Geração de relatórios nos formatos .xlsx e .pdf com cabeçalho corporativo e QR Code no rodapé (Relrel). |
| Preloader Visual | `lib/widgets/extravagant_preloader.dart` | Preloader visual e ecrã de carregamento splash em tema extravagante Hyper POS (fundo escuro `#0B0C0E` e acentos a laranja `#FF6B00`). |
| Modal de Confirmação e Erros | `lib/widgets/custom_modal.dart` | Diálogo modal extravagante que obedece ao tema do sistema para mensagens de confirmação, avisos, sucesso e erro. |
| Documentação do Projeto | `Documentacao/` | Pasta contendo os ficheiros de documentação (.md) do projeto (Manual, API, Dicionário, Backups, Módulos, Código Fonte e Correções). |
