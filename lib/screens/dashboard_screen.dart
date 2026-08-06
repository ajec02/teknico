// Dashboard Principal do Sistema Suporte OS - Seletor de BD na Barra Superior & Logo Suporte

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/searchable_dropdown.dart';
import '../widgets/extravagant_preloader.dart';
import '../widgets/custom_modal.dart';
import 'table_crud_screen.dart';
import 'audit_logs_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _topSearchController = TextEditingController();
  final TextEditingController _tableSearchController = TextEditingController();
  String _tableSearchQuery = '';

  @override
  void dispose() {
    _topSearchController.dispose();
    _tableSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final user = appState.currentUser;
    final config = appState.config;
    const accentColor = Color(0xFFFF6B00);

    if (!appState.isConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (appState.isLoggedIn) {
          Navigator.of(context).pushReplacementNamed('/connections');
        } else {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      });
      return const Scaffold();
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0C0E) : const Color(0xFFF3F4F6),
      body: Stack(
        children: [
          Column(
            children: [
              // Barra Superior (Header Bar com Logótipo SUPORTE, Conexão Ativa e Seletor de BD)
              Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF101114) : Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? const Color(0xFF22242B) : const Color(0xFFE5E7EB),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Brand Logo Badge (SUPORTE OS)
                    InkWell(
                      onTap: () => Navigator.of(context).pushNamed('/'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.35),
                              blurRadius: 12,
                            )
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.storage_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'SUPORTE OS',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: Colors.white,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Container(
                      height: 24,
                      width: 1,
                      color: isDark ? const Color(0xFF22242B) : const Color(0xFFE5E7EB),
                    ),
                    const SizedBox(width: 14),

                    // Badge da Conexão Ativa (com botão para Alternar Conexão)
                    Tooltip(
                      message: 'Conectado a ${config.user}@${config.host}:${config.port}',
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed('/connections');
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF18191E) : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? const Color(0xFF2A2C35) : const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${config.host}:${config.port}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : const Color(0xFF111827),
                                    ),
                                  ),
                                  Text(
                                    'Utilizador: ${config.user}',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.swap_horiz_rounded, size: 16, color: accentColor),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Seletor de Base de Dados (SearchableDropdown)
                    SizedBox(
                      width: 210,
                      child: SearchableDropdown<String>(
                        label: 'Base de Dados',
                        isCompact: true,
                        value: appState.selectedDatabase,
                        items: appState.databases
                            .map((db) => DropdownMenuItem(
                                  value: db,
                                  child: Text(
                                    db,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ))
                            .toList(),
                        onChanged: (newDb) {
                          if (newDb != null) {
                            appState.selectDatabase(newDb);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),

                    const Spacer(),

                    // Barra de Pesquisa Rápida Central no Topo
                    Container(
                      width: 260,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF18191E) : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? const Color(0xFF2A2C35) : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: TextField(
                        controller: _topSearchController,
                        onChanged: (val) {
                          setState(() {
                            _tableSearchQuery = val;
                            _tableSearchController.text = val;
                            _tableSearchController.selection = TextSelection.fromPosition(TextPosition(offset: val.length));
                          });
                        },
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Pesquisar registos...',
                          hintStyle: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            size: 16,
                            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Botão Minhas Conexões + Perfil de Utilizador & Tema
                    Row(
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.hub_rounded, size: 16),
                          label: const Text('CONEXÕES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor.withValues(alpha: 0.15),
                            foregroundColor: accentColor,
                            elevation: 0,
                            side: BorderSide(color: accentColor.withValues(alpha: 0.4)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushNamed('/connections');
                          },
                        ),
                        const SizedBox(width: 10),

                        IconButton(
                          icon: Icon(
                            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                            color: accentColor,
                            size: 20,
                          ),
                          onPressed: () => appState.toggleTheme(),
                          tooltip: 'Alternar Modo Escuro / Claro',
                        ),
                        const SizedBox(width: 8),

                        // Perfil do Utilizador Autenticado
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF18191E) : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? const Color(0xFF2A2C35) : const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: accentColor.withValues(alpha: 0.2),
                                child: Text(
                                  (user?.name ?? 'A').substring(0, 1),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: accentColor),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    user?.name ?? 'Utilizador',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : const Color(0xFF111827),
                                    ),
                                  ),
                                  Text(
                                    user?.roleDisplayName ?? 'Administrador',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Corpo Principal (Sidebar Categorizada + Conteúdo)
              Expanded(
                child: Row(
                  children: [
                    // Sidebar Retrátil Categorizada (MenuT)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: appState.isDrawerOpen ? 260 : 72,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF101114) : Colors.white,
                        border: Border(
                          right: BorderSide(
                            color: isDark ? const Color(0xFF22242B) : const Color(0xFFE5E7EB),
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Botão de Recolher/Expandir Menu
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                if (appState.isDrawerOpen)
                                  const Text(
                                    'NAVEGAÇÃO',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.1,
                                      color: Color(0xFFFF6B00),
                                    ),
                                  ),
                                const Spacer(),
                                IconButton(
                                  icon: Icon(
                                    appState.isDrawerOpen ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                    size: 20,
                                  ),
                                  onPressed: () => appState.toggleDrawer(),
                                  tooltip: 'Recolher/Expandir Menu (MenuT)',
                                ),
                              ],
                            ),
                          ),

                          // Itens de Menu Principal (Operações & Tabelas)
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              children: [
                                if (appState.isDrawerOpen)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    child: Text(
                                      'OPERAÇÕES',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.1,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                  ),
                                _buildSidebarItem(
                                  index: 0,
                                  icon: Icons.table_chart_rounded,
                                  label: 'Tabelas & Registos',
                                  isDrawerOpen: appState.isDrawerOpen,
                                  isDark: isDark,
                                  appState: appState,
                                ),
                                _buildSidebarItem(
                                  index: 1,
                                  icon: Icons.history_rounded,
                                  label: 'Histórico de Logs',
                                  isDrawerOpen: appState.isDrawerOpen,
                                  isDark: isDark,
                                  appState: appState,
                                ),
                                const SizedBox(height: 16),

                                // Lista de Tabelas da BD Ativa
                                if (appState.activeViewIndex == 0 && appState.isDrawerOpen) ...[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    child: Text(
                                      'TABELAS DA BD (${appState.tables.length})',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.1,
                                        color: Color(0xFFFF6B00),
                                      ),
                                    ),
                                  ),
                                  // Campo de Pesquisa de Tabelas na Sidebar
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Container(
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF18191E) : const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isDark ? const Color(0xFF2A2C35) : const Color(0xFFE5E7EB),
                                        ),
                                      ),
                                      child: TextField(
                                        controller: _tableSearchController,
                                        onChanged: (val) {
                                          setState(() {
                                            _tableSearchQuery = val;
                                          });
                                        },
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? Colors.white : const Color(0xFF111827),
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Pesquisar tabela...',
                                          hintStyle: TextStyle(
                                            fontSize: 11,
                                            color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                                          ),
                                          prefixIcon: Icon(
                                            Icons.search_rounded,
                                            size: 14,
                                            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                          ),
                                          suffixIcon: _tableSearchQuery.isNotEmpty
                                              ? IconButton(
                                                  icon: const Icon(Icons.clear_rounded, size: 14),
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                  onPressed: () {
                                                    _tableSearchController.clear();
                                                    setState(() {
                                                      _tableSearchQuery = '';
                                                    });
                                                  },
                                                )
                                              : null,
                                          border: InputBorder.none,
                                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  ...(){
                                    final filteredTables = appState.tables.where((tbl) {
                                      return tbl.toLowerCase().contains(_tableSearchQuery.toLowerCase().trim());
                                    }).toList();

                                    if (filteredTables.isEmpty) {
                                      return [
                                        Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Center(
                                            child: Text(
                                              'Nenhuma tabela encontrada',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontStyle: FontStyle.italic,
                                                color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ];
                                    }

                                    return filteredTables.map((tbl) {
                                      final isSelected = tbl == appState.selectedTable;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: InkWell(
                                          onTap: () => appState.selectTable(tbl),
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? (isDark ? const Color(0xFF1C1D24) : const Color(0xFFF3F4F6))
                                                  : Colors.transparent,
                                              borderRadius: BorderRadius.circular(8),
                                              border: isSelected
                                                  ? const Border(left: BorderSide(color: accentColor, width: 3))
                                                  : null,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.grid_on_rounded,
                                                  size: 14,
                                                  color: isSelected
                                                      ? accentColor
                                                      : (isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF)),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    tbl,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                      color: isSelected
                                                          ? (isDark ? Colors.white : Colors.black)
                                                          : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563)),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    });
                                  }(),
                                ],
                              ],
                            ),
                          ),

                          // Rodapé do Menu (Status Online & Desconectar)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF141519) : const Color(0xFFF9FAFB),
                              border: Border(
                                top: BorderSide(
                                  color: isDark ? const Color(0xFF22242B) : const Color(0xFFE5E7EB),
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                if (appState.isDrawerOpen) ...[
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Sistemas online',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF10B981),
                                          ),
                                        ),
                                        Text(
                                          '${config.host}:${config.port}',
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.power_settings_new_rounded, color: Color(0xFFEF4444), size: 18),
                                    onPressed: () {
                                      CustomModal.show(
                                        context: context,
                                        title: 'Desconectar Server',
                                        message: 'Deseja terminar a sessão atual com o servidor MySQL (${config.host}:${config.port})?',
                                        type: ModalType.confirm,
                                        onConfirm: () {
                                          appState.disconnect();
                                          Navigator.of(context).pushReplacementNamed('/connections');
                                        },
                                      );
                                    },
                                    tooltip: 'Desconectar',
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Área Principal de Trabalho (CRUD / Audit Logs)
                    Expanded(
                      child: _buildBodyContent(appState),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Preloader Visual Overlay
          if (appState.isLoading)
            ExtravagantPreloader(message: appState.loadingMessage),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isDrawerOpen,
    required bool isDark,
    required AppState appState,
  }) {
    final isSelected = appState.activeViewIndex == index;
    const accentColor = Color(0xFFFF6B00);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () {
          appState.setActiveViewIndex(index);
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF18191E) : const Color(0xFFF3F4F6))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? const Border(left: BorderSide(color: accentColor, width: 3.5))
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? accentColor : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
              ),
              if (isDrawerOpen) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? (isDark ? Colors.white : const Color(0xFF111827))
                          : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent(AppState appState) {
    switch (appState.activeViewIndex) {
      case 0:
        return const TableCrudScreen();
      case 1:
        return const AuditLogsScreen();
      default:
        return const TableCrudScreen();
    }
  }
}
