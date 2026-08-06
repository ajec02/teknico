// Ecrã de Gestão de Conexões Guardadas (Multi-Conexões MySQL) do Suporte OS

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/saved_connection.dart';
import '../models/db_connection_config.dart';
import '../providers/app_state.dart';
import '../widgets/custom_modal.dart';
import '../widgets/extravagant_preloader.dart';

class SavedConnectionsScreen extends StatefulWidget {
  const SavedConnectionsScreen({super.key});

  @override
  State<SavedConnectionsScreen> createState() => _SavedConnectionsScreenState();
}

class _SavedConnectionsScreenState extends State<SavedConnectionsScreen> {
  @override
  void initState() {
    super.initState();
    // Garante que o estado de carregamento esteja desativado ao entrar no ecrã de conexões
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      if (appState.isLoading) {
        appState.setLoading(false);
      }
    });
  }

  void _openNewOrEditConnectionModal([SavedConnection? existing]) {
    final isEditing = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final hostCtrl = TextEditingController(text: existing?.host ?? '127.0.0.1');
    final portCtrl = TextEditingController(text: (existing?.port ?? 3306).toString());
    final userCtrl = TextEditingController(text: existing?.user ?? 'root');
    final passCtrl = TextEditingController(text: existing?.password ?? 'Senha123');
    final dbCtrl = TextEditingController(text: existing?.database ?? 'suporte_db');

    final appState = Provider.of<AppState>(context, listen: false);
    final isDark = appState.isDarkMode;
    const accentColor = Color(0xFFFF6B00);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (modalContext) {
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF141519) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 16,
          child: Container(
            width: 520,
            padding: const EdgeInsets.all(28),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isEditing ? Icons.edit_rounded : Icons.add_link_rounded,
                              color: accentColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isEditing ? 'Editar Conexão Guardada' : 'Adicionar Nova Conexão MySQL',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(modalContext).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Campos do Formulário
                  _buildDialogTextField(controller: nameCtrl, label: 'Nome da Conexão / Apelido', icon: Icons.label_rounded, isDark: isDark),
                  const SizedBox(height: 12),
                  _buildDialogTextField(controller: hostCtrl, label: 'Endereço Host / IP', icon: Icons.computer_rounded, isDark: isDark),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildDialogTextField(controller: userCtrl, label: 'Utilizador', icon: Icons.person_rounded, isDark: isDark),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: _buildDialogTextField(controller: portCtrl, label: 'Porta', icon: Icons.numbers_rounded, isDark: isDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDialogTextField(controller: passCtrl, label: 'Palavra-passe', icon: Icons.key_rounded, isObscure: true, isDark: isDark),
                  const SizedBox(height: 12),
                  _buildDialogTextField(controller: dbCtrl, label: 'Base de Dados Padrão (Opcional)', icon: Icons.dns_rounded, isDark: isDark),
                  const SizedBox(height: 24),

                  // Botões de Ação do Dialog
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(modalContext).pop(),
                        child: const Text('CANCELAR'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.save_rounded, size: 18),
                        label: Text(isEditing ? 'GUARDAR ALTERAÇÕES' : 'GRAVAR CONEXÃO'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () async {
                          final name = nameCtrl.text.trim();
                          final host = hostCtrl.text.trim();
                          final port = int.tryParse(portCtrl.text.trim()) ?? 3306;
                          final user = userCtrl.text.trim();
                          final pass = passCtrl.text;
                          final db = dbCtrl.text.trim();

                          if (name.isEmpty || host.isEmpty || user.isEmpty) {
                            CustomModal.show(
                              context: modalContext,
                              title: 'Campos Obrigatórios',
                              message: 'Por favor preencha o nome da conexão, host e utilizador.',
                              type: ModalType.warning,
                            );
                            return;
                          }

                          final newConn = SavedConnection(
                            id: isEditing ? existing.id : 'conn_${DateTime.now().millisecondsSinceEpoch}',
                            name: name,
                            host: host,
                            port: port,
                            user: user,
                            password: pass,
                            database: db.isNotEmpty ? db : 'suporte_db',
                            createdAt: isEditing ? existing.createdAt : DateTime.now(),
                            lastUsedAt: DateTime.now(),
                          );

                          await appState.saveConnection(newConn);
                          if (mounted) {
                            Navigator.of(modalContext).pop();
                            CustomModal.show(
                              context: context,
                              title: 'Conexão Gravada!',
                              message: 'A conexão "$name" foi guardada com sucesso.',
                              type: ModalType.success,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isObscure = false,
    required bool isDark,
  }) {
    const accentColor = Color(0xFFFF6B00);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: isObscure,
          style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF111827)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: accentColor, size: 18),
            filled: true,
            fillColor: isDark ? const Color(0xFF18191E) : const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? const Color(0xFF2A2C35) : const Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: accentColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleTestSavedConnection(SavedConnection conn) async {
    final appState = Provider.of<AppState>(context, listen: false);
    final config = DbConnectionConfig(
      host: conn.host,
      port: conn.port,
      user: conn.user,
      password: conn.password,
      database: conn.database,
    );

    final success = await appState.testConnection(config);
    if (mounted) {
      if (success) {
        CustomModal.show(
          context: context,
          title: 'Conexão Bem-Sucedida!',
          message: 'Ligação estabelecida com sucesso ao MySQL em ${conn.host}:${conn.port}.',
          type: ModalType.success,
        );
      } else {
        CustomModal.show(
          context: context,
          title: 'Falha na Ligação',
          message: 'Não foi possível ligar ao MySQL em ${conn.host}:${conn.port}.\nVerifique se o servidor está ativo.',
          type: ModalType.error,
        );
      }
    }
  }

  Future<void> _handleConnectSavedConnection(SavedConnection conn) async {
    final appState = Provider.of<AppState>(context, listen: false);
    final config = DbConnectionConfig(
      host: conn.host,
      port: conn.port,
      user: conn.user,
      password: conn.password,
      database: conn.database,
    );

    final success = await appState.connectToDatabase(config);
    if (success) {
      // Atualizar data de último uso
      final updated = conn.copyWith(lastUsedAt: DateTime.now());
      await appState.saveConnection(updated);

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } else if (mounted) {
      CustomModal.show(
        context: context,
        title: 'Erro de Conexão',
        message: 'Não foi possível ligar ao servidor MySQL (${conn.host}:${conn.port}).',
        type: ModalType.error,
      );
    }
  }

  void _confirmDeleteConnection(SavedConnection conn) {
    CustomModal.showConfirm(
      context: context,
      title: 'Eliminar Conexão',
      message: 'Tem a certeza que deseja eliminar a conexão guardada "${conn.name}"?',
      confirmText: 'ELIMINAR',
      cancelText: 'CANCELAR',
      type: ModalType.confirm,
      onConfirm: () async {
        final appState = Provider.of<AppState>(context, listen: false);
        await appState.deleteConnection(conn.id);
        if (mounted) {
          CustomModal.show(
            context: context,
            title: 'Conexão Eliminada',
            message: 'A conexão foi removida com sucesso.',
            type: ModalType.info,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final user = appState.currentUser;
    final connections = appState.savedConnections;
    const accentColor = Color(0xFFFF6B00);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0C0E) : const Color(0xFFF3F4F6),
      body: Column(
        children: [
          // 1. Barra Superior (ALWAYS Interactive and Clickable)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141519) : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF2A2C35) : const Color(0xFFE5E7EB),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.storage_rounded, color: accentColor, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CONEXÕES GUARDADAS',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                            color: isDark ? Colors.white : const Color(0xFF111827),
                          ),
                        ),
                        Text(
                          'Selecione ou adicione um servidor MySQL',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Utilizador Autenticado e Ações do Cabeçalho
                Row(
                  children: [
                    if (user != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1C1D24) : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(20),
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
                                user.name.substring(0, 1),
                                style: const TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              user.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                user.roleDisplayName,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: accentColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],

                    IconButton(
                      tooltip: 'Alternar Tema',
                      icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: accentColor),
                      onPressed: () => appState.toggleTheme(),
                    ),
                    const SizedBox(width: 8),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text('NOVA CONEXÃO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _openNewOrEditConnectionModal(),
                    ),
                    const SizedBox(width: 8),

                    OutlinedButton.icon(
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text('SAIR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        appState.logout();
                        Navigator.of(context).pushReplacementNamed('/');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Área do Conteúdo com Overlay de Preloader Local
          Expanded(
            child: Stack(
              children: [
                connections.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.link_off_rounded, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhuma Conexão Guardada',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Clique no botão "+ NOVA CONEXÃO" para adicionar um servidor MySQL.',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add_rounded),
                              label: const Text('NOVA CONEXÃO'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => _openNewOrEditConnectionModal(),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(36),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1200),
                            child: Wrap(
                              spacing: 24,
                              runSpacing: 24,
                              children: connections.map((conn) {
                                return _buildConnectionCard(conn, isDark, accentColor);
                              }).toList(),
                            ),
                          ),
                        ),
                      ),

                if (appState.isLoading)
                  ExtravagantPreloader(message: appState.loadingMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionCard(SavedConnection conn, bool isDark, Color accentColor) {
    return Container(
      width: 360,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141519) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2C35) : const Color(0xFFE5E7EB),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.dns_rounded, color: accentColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      conn.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                  ),
                ],
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded, color: isDark ? Colors.white60 : Colors.black54),
                color: isDark ? const Color(0xFF1C1D24) : Colors.white,
                onSelected: (val) {
                  if (val == 'edit') {
                    _openNewOrEditConnectionModal(conn);
                  } else if (val == 'delete') {
                    _confirmDeleteConnection(conn);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded, size: 16),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_forever_rounded, size: 16, color: Colors.redAccent),
                        SizedBox(width: 8),
                        Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: isDark ? const Color(0xFF2A2C35) : const Color(0xFFE5E7EB)),
          const SizedBox(height: 12),

          _buildDetailRow(Icons.computer_rounded, 'Host/IP:', '${conn.host}:${conn.port}', isDark),
          const SizedBox(height: 8),
          _buildDetailRow(Icons.person_rounded, 'Utilizador:', conn.user, isDark),
          const SizedBox(height: 8),
          _buildDetailRow(Icons.storage_rounded, 'Base de Dados:', conn.database, isDark),
          const SizedBox(height: 20),

          // Botões de Ação: TESTAR CONEXÃO e LIGAR AO MYSQL
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: accentColor,
                    side: BorderSide(color: accentColor.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _handleTestSavedConnection(conn),
                  child: const Text('Testar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _handleConnectSavedConnection(conn),
                  child: const Text('LIGAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 15, color: isDark ? Colors.white54 : Colors.black45),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white54 : Colors.black54,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
        ),
      ],
    );
  }
}
