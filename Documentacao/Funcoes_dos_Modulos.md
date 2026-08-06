# Funções dos Módulos do Sistema Teknico

| Módulo | Ficheiro Fonte | Descrição da Função |
|---|---|---|
| Ponte API MySQL Real | `bin/mysql_api_bridge.dart` | Serviço HTTP na porta 8085 que conecta diretamente ao MySQL real (`127.0.0.1:3306`) e executa queries reais. |
| Conexão MySQL Híbrida | `lib/services/mysql_service.dart` | Conexão MySQL transparente que consome a ponte API real no browser e sockets nativos em Desktop. |
| Estado Global & Persistência | `lib/providers/app_state.dart` | Gestão de estado reativo e suporte integral à persistência de navegação, sessão, BD/tabela selecionada, menu e temas via `SharedPreferences`. |
| Tela Principal & Error Boundary | `lib/main.dart` | Configuração do aplicativo, restauração prévia de sessão na inicialização, temas extravagantes, roteamento e captura global de exceções `ErrorWidget.builder`. |
| Conexão à BD | `lib/screens/connection_screen.dart` | Gestão de acesso ao servidor, alternância entre MTeste e MProducao. |
| Dashboard Principal | `lib/screens/dashboard_screen.dart` | Shell de navegação com menu lateral persistente (MenuT), seletor de base de dados no cabeçalho e campo de pesquisa de tabelas em tempo real. |
| CRUD de Tabelas | `lib/screens/table_crud_screen.dart` | Gestão de dados dinâmicos com ordenação descendente, paginação e pesquisa. |
| Histórico de Auditoria | `lib/screens/audit_logs_screen.dart` | Visualização de logs armazenados na tabela `historico_logs` da base `suporte_db`. |
| Exportação (Excel/PDF) | `lib/services/export_service.dart` | Geração de relatórios nos formatos .xlsx e .pdf com cabeçalho corporativo e QR Code no rodapé. |
| Preloader Visual & Splash | `lib/widgets/extravagant_preloader.dart` & `web/index.html` | Preloader visual e ecrã de carregamento splash em tema extravagante Hyper POS (fundo escuro `#0B0C0E` e acentos em laranja `#FF6B00`). |
| Dropdown Pesquisável | `lib/widgets/searchable_dropdown.dart` | Componente de seleção pesquisável em tempo real, com suporte a modo compacto (`isCompact`) para prevenir distorções e overflows no cabeçalho. |
| Documentação do Projeto | `Documentacao/` | Pasta contendo os ficheiros de documentação (.md) do projeto (Manual, API, Dicionário, Backups, Módulos, Código Fonte e Correções). |
