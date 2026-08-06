# Código Fonte Comentado - Arquitetura do Sistema Suporte OS

## 1. Visão Geral da Arquitetura
O sistema **Suporte OS** foi desenvolvido em **Flutter/Dart** com padrões limpos de arquitetura, separando o estado da aplicação (`AppState`), a camada de apresentação (`screens/` e `widgets/`), os serviços de comunicação e persistência (`services/`) e a ponte de serviço backend real MySQL (`bin/mysql_api_bridge.dart`).

---

## 2. Estrutura de Ficheiros do Código Fonte

### A. Ponto de Entrada & Estado Global
- **`lib/main.dart`**:
  - `main()`: Ponto de entrada da aplicação. Inicializa a ligação e configura o `AppState` via Provider.
  - `ErrorWidget.builder`: Previne telas brancas genéricas no navegador/desktop apresentando uma janela estilizada de erro.
- **`lib/providers/app_state.dart`**:
  - Encarregado de gerir a ligação ativa ao MySQL, seleção dinâmica de bases de dados, tabelas, carregamento de registos, paginação, registos de auditoria e tema (Dark/Light).

---

### B. Serviços de Dados & Conectividade
- **`bin/mysql_api_bridge.dart`**:
  - Servidor HTTP em Dart (porta 8085) que executa consultas nativas e CLI `mysql.exe` no servidor de base de dados real.
  - Formata e descodifica JSON via `HEX()` para evitar corrupção de caracteres.
- **`lib/services/mysql_service.dart`**:
  - Abstração transparente que deteta a plataforma (`kIsWeb` vs Desktop) e escolhe automaticamente entre chamadas REST à ponte ou ligação nativa por Socket.
- **`lib/services/export_service.dart`**:
  - Responsável por gerar relatórios em **Excel (.xlsx)** e **PDF (.pdf)** com marca d'água corporativa, emissor, data/hora e QR Code no rodapé.

---

### C. Componentes de Interface Gráfica (UI)
- **`lib/screens/connection_screen.dart`**: Ecrã de autenticação com suporte a **MTeste** (dados preenchidos automaticamente) e **MProducao**.
- **`lib/screens/dashboard_screen.dart`**: Shell principal com menu lateral retrátil (**MenuT**), seletor de base de dados e navegação dinâmica entre tabelas e auditoria.
- **`lib/screens/table_crud_screen.dart`**: Tabela dinâmica de registos com suporte a listagem descendente (último inserido em primeiro lugar), paginação, filtros em tempo real e operações CRUD.
- **`lib/screens/audit_logs_screen.dart`**: Ecrã do histórico de auditoria (`historico_logs`) com visualizador comparativo (Diff Viewer) em nível de palavra.
- **`lib/widgets/searchable_dropdown.dart`**: Dropdown com campo de pesquisa em tempo real.
- **`lib/widgets/custom_modal.dart`**: Modais personalizadas para alertas, avisos e confirmações no estilo do template (**ModalT**).
- **`lib/widgets/extravagant_preloader.dart`**: Overlay com indicador de carregamento animado para operações assíncronas.
