# ✅ Problemas Corrigidos - Registo de Logs de Resolução

## [v1.0.0] - 2026-08-06

- ✅ **Posicionamento do Logótipo SUPORTE e Seletor de Base de Dados na Barra Superior**:
  - **Logótipo SUPORTE**: O emblema no canto superior esquerdo foi alterado de `HYPER POS` para **`SUPORTE`** com fundo laranja brilhante (`#FF6B00`), sombra suave e ícone corporativo.
  - **Seletor de BD na Barra Superior**: O dropdown de escolha da Base de Dados (`SearchableDropdown`) foi movido da barra lateral esquerda diretamente para a barra superior (Header Bar) ao lado do logótipo e do badge **`Ao vivo`**.
  - **Limpeza do Menu Lateral**: A seção duplicada de seleção de base de dados foi removida do menu lateral, permitindo que a lista de tabelas (`TABELAS DA BD (34)`) seja apresentada imediatamente abaixo do item `Tabelas & Registos`.
- ✅ **Alteração da Designação Oficial do Projeto para Teknico OS (`pubspec.yaml`, `main.dart`, `dashboard_screen.dart`, `web/index.html`)**:
  - **Requisito**: Atualizar a marca, títulos, metadados e identidade visual do projeto para **Teknico OS**.
  - **Solução**: Atualizado o nome no `pubspec.yaml` (`name: teknico`), substituição do logótipo no cabeçalho para **`TEKNICO`**, e alteração dos metadados HTML splash, títulos de páginas e mensagens de erro globais para **Teknico OS**.
- ✅ **Eliminação dos Espaços Vazios na Lateral e Inferior do Ecrã (`web/index.html` & `main.dart`)**:
  - **Causa**: O zoom CSS (`zoom: 90%`) aplicado no nível da tag `<html>` reduziu o tamanho do Viewport do navegador, originando margens pretas vazias no lado direito e inferior do ecrã.
  - **Solução**: Removida a propriedade `zoom: 90%` do CSS principal em `web/index.html`, redefinido `html, body { width: 100%; height: 100%; overflow: hidden; }` para ocupação de 100% da janela sem margens, mantendo a redução de tamanho interna responsiva via `textScaler: TextScaler.linear(0.88)` e `VisualDensity.compact` no Flutter.
- ✅ **Redução Global do Zoom e Ajuste Compacto do Sistema (`web/index.html` & `main.dart`)**:
  - **Requisito**: Reduzir a escala e a proporção de zoom em toda a interface do sistema para proporcionar uma visualização mais elegante, compacta e com maior aproveitamento de ecrã.
  - **Solução**: Aplicado `zoom: 90%` no CSS principal do `web/index.html`, configurada a densidade visual compacta (`VisualDensity.compact`) nos temas globalmente e aplicado um escalonador de texto compacto (`textScaler: TextScaler.linear(0.88)`) no `MaterialApp` em `main.dart`.

  - **Paleta de Cores Hyper Dark & Hyper Orange**: Fundo principal `#0B0C0E` (preto profundo fosco), superfície de cartões e modais em `#141519` / `#18191E`, bordas finas `#22242B` e acentos em **Hyper Orange (`#FF6B00`)** com brilho volumétrico (`glow`).
  - **Barra Superior (Header Bar)**: Adicionado emblema da marca "SUPORTE", seletor de base de dados em badge pill estilo `● BD: ajec_os_db • Ao vivo` em verde reluzente (`#10B981`), campo de pesquisa central com atalho visual `Ctrl+K` e perfil de administrador.
  - **Sidebar Categorizada com Indicador Ativo**: Menu lateral organizado pelas seções `OPERAÇÕES`, `BASE DE DADOS ATIVA` e `SISTEMAS ONLINE`. Os itens ativos exibem um indicador vertical laranja de 3.5px na borda esquerda e fundo `#18191E`.
  - **Tabela CRUD e Cartão de Métricas**: Adicionado painel no topo com contagem total de registos, chave primária e nome da tabela. A tabela conta com cabeçalhos escuros `#18191E`, ícone de chave primária em laranja e botões de ação com brilho suave.
  - **Modais e Preloader Hyper POS**: Modais de confirmação, adição/edição e histórico de auditoria redesenhadas em tema escuro com botões primários `#FF6B00`.
- ✅ **Resolução da Exceção de Caracteres de Controlo (`\r` Carriage Return) no `jsonDecode`**: Adicionada a higienização `str.replaceAll('\r', '')` no `AuditLogsScreen` e na ponte API, garantindo 100% de decodificação perfeita de todos os registos.
- ✅ **Resolução da Seleção de Base de Dados e Carregamento de Tabelas (`_selectedDatabase` & `selectTable`)**: O método `loadTablesForDatabase(dbName)` no `AppState` foi atualizado para atribuir imediatamente `_selectedDatabase = dbName;`, atualizando dinamicamente a base de dados ativa e carregando instantaneamente os registos reais de qualquer BD selecionada.
- ✅ **Atualização Automática dos Logs em Tempo Real (`AppState`)**: Sempre que um registo é inserido, atualizado ou eliminado, o `AppState` chama automaticamente `await loadAuditLogs()`.
- ✅ **Resolução da Leitura e Decodificação de JSON no Log (`HEX()` Encoding)**: A ponte API (`bin/mysql_api_bridge.dart`) passou a utilizar a função `HEX(dados_anteriores)` e `HEX(dados_novos)` nas queries MySQL.
- ✅ **Destaque Comparativo Inline no Conteúdo de Logs de Auditoria**: Implementada a comparação em nível de palavra (`_diffStrings`) no visualizador de logs com destaques em verde e vermelho.
- ✅ **Resolução de Falha na Edição/Atualização de Registos (`ERROR 1292`)**: Implementado o formatador `_formatSqlValue` na ponte de serviço (`bin/mysql_api_bridge.dart`).
- ✅ **Listagem e CRUD Completo em Todas as Bases de Dados Reais**: Corrigida a execução da query com troca de contexto `USE database;` na ponte de serviço (`bin/mysql_api_bridge.dart`).
- ✅ **Histórico de Audit Trail Automático (`historico_logs`)**: Tabela de registos de alterações na base de dados do sistema `suporte_db`.
- ✅ **Ordenação Descendente Padrão**: Apresenta sempre o **último registo cadastrado no topo da lista**.
- ✅ **Dropdowns Pesquisáveis**: Componente `SearchableDropdown` em tempo real.
- ✅ **Persistência Completa de Navegação e Menu ao Atualizar a Página (MenuT / Page Refresh)**:
- ✅ **Mapeamento Automático do MySQL do Próprio Computador Cliente na Rede Local (`bin/mysql_api_bridge.dart`)**:
  - **Causa**: Ao aceder ao sistema a partir de outro computador da rede local (ex: `192.168.1.50`), o formulário de conexão enviava o host padrão `127.0.0.1`. A ponte API no servidor principal executava o `mysql.exe -h 127.0.0.1` na sua própria máquina, acedendo aos dados do servidor em vez do MySQL do computador do próprio utilizador cliente.
  - **Solução**: Atualizado o servidor `mysql_api_bridge.dart` para detetar o IP do cliente remoto (`request.connectionInfo.remoteAddress.address`). Quando o host solicitado for `127.0.0.1` ou `localhost` por um cliente externo na rede, a ponte API converte automaticamente `127.0.0.1` para o IP do próprio computador cliente (ex: `192.168.1.50`), ligando-se diretamente ao MySQL desse computador. Se o utilizador desejar ligar-se ao servidor principal, basta introduzir o IP do servidor (`192.168.1.171`) no campo *Endereço (Host / IP)*.
- ✅ **Implementação do Campo de Pesquisa em Tempo Real para Tabelas (`DashboardScreen` Sidebar)**:
  - **Requisito**: Permitir filtrar a lista de tabelas da base de dados ativa rapidamente no menu lateral quando existir um grande volume de tabelas.
  - **Solução**: Adicionado o campo de texto `Pesquisar tabela...` com ícone de lupa, botão de limpeza rápida (`X`) e filtragem insensível a maiúsculas/minúsculas diretamente na barra lateral, além da sincronização em tempo real com a barra de pesquisa do topo (`Ctrl+K`).

