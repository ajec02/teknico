// Ecrã de Conexão MySQL com Estilo Hyper POS (Codecanyon)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/db_connection_config.dart';
import '../providers/app_state.dart';
import '../widgets/custom_modal.dart';
import '../widgets/extravagant_preloader.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  late TextEditingController _hostController;
  late TextEditingController _portController;
  late TextEditingController _userController;
  late TextEditingController _passwordController;
  late TextEditingController _databaseController;

  bool _isTestMode = true;

  @override
  void initState() {
    super.initState();
    final state = Provider.of<AppState>(context, listen: false);
    _hostController = TextEditingController(text: state.config.host);
    _portController = TextEditingController(text: state.config.port.toString());
    _userController = TextEditingController(text: state.config.user);
    _passwordController = TextEditingController(text: state.config.password);
    _databaseController = TextEditingController(text: state.config.database);
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    _databaseController.dispose();
    super.dispose();
  }

  void _applyTestMode(bool isTest) {
    setState(() {
      _isTestMode = isTest;
      if (isTest) {
        _hostController.text = '127.0.0.1';
        _portController.text = '3306';
        _userController.text = 'root';
        _passwordController.text = 'Senha123';
        _databaseController.text = 'suporte_db';
      } else {
        _hostController.clear();
        _portController.text = '3306';
        _userController.clear();
        _passwordController.clear();
        _databaseController.clear();
      }
    });
  }

  DbConnectionConfig _buildConfigFromFields() {
    return DbConnectionConfig(
      host: _hostController.text.trim(),
      port: int.tryParse(_portController.text.trim()) ?? 3306,
      user: _userController.text.trim(),
      password: _passwordController.text,
      database: _databaseController.text.trim(),
      isTestMode: _isTestMode,
    );
  }

  Future<void> _handleTestConnection() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final config = _buildConfigFromFields();

    try {
      await appState.testConnection(config);
      if (mounted) {
        CustomModal.show(
          context: context,
          title: 'Conexão Bem-Sucedida!',
          message: 'Conectado com sucesso ao servidor MySQL em ${config.host}:${config.port}.',
          type: ModalType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        CustomModal.show(
          context: context,
          title: 'Falha na Conexão',
          message: 'Não foi possível conectar com o servidor MySQL.\nVerifique se as credenciais inseridas estão corretas.\n\nDetalhes: $e',
          type: ModalType.error,
        );
      }
    }
  }

  Future<void> _handleConnect() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final config = _buildConfigFromFields();

    try {
      final success = await appState.connectToDatabase(config);
      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        CustomModal.show(
          context: context,
          title: 'Erro de Conexão',
          message: 'Não foi possível ligar ao servidor MySQL.\nDetalhes: $e',
          type: ModalType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;

    const accentColor = Color(0xFFFF6B00);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0C0E) : const Color(0xFFF3F4F6),
      body: Stack(
        children: [
          // Fundo Decorativo Gradiente Hyper POS Style
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.5,
                  colors: isDark
                      ? [
                          const Color(0xFF18191E),
                          const Color(0xFF101114),
                          const Color(0xFF0B0C0E),
                        ]
                      : [
                          const Color(0xFFE5E7EB),
                          const Color(0xFFF3F4F6),
                          Colors.white,
                        ],
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: 520,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141519).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2A2C35) : const Color(0xFFE5E7EB),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.15),
                      blurRadius: 35,
                      spreadRadius: 2,
                    ),
                  ],
                ),
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
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                              ),
                              child: const Icon(
                                Icons.storage_rounded,
                                size: 28,
                                color: accentColor,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SUPORTE OS',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                    color: isDark ? Colors.white : const Color(0xFF111827),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFF6B00),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Hyper POS Edition',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? const Color(0xFFFF6B00) : const Color(0xFFD97706),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(
                            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                            color: accentColor,
                          ),
                          onPressed: () => appState.toggleTheme(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Alternador Modo Teste / Modo Produção (MTeste / MProducao)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1C1D24) : const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _applyTestMode(true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _isTestMode ? accentColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: _isTestMode
                                      ? [
                                          BoxShadow(
                                            color: accentColor.withValues(alpha: 0.3),
                                            blurRadius: 10,
                                          )
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.science_rounded,
                                      size: 16,
                                      color: _isTestMode ? Colors.white : (isDark ? Colors.white60 : Colors.black54),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Modo Teste (MTeste)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: _isTestMode ? Colors.white : (isDark ? Colors.white60 : Colors.black54),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _applyTestMode(false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: !_isTestMode ? const Color(0xFF10B981) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: !_isTestMode
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                            blurRadius: 10,
                                          )
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.lock_rounded,
                                      size: 16,
                                      color: !_isTestMode ? Colors.white : (isDark ? Colors.white60 : Colors.black54),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Modo Produção',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: !_isTestMode ? Colors.white : (isDark ? Colors.white60 : Colors.black54),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Formulário de Conexão
                    _buildTextField(
                      controller: _hostController,
                      label: 'Endereço (Host / IP)',
                      icon: Icons.computer_rounded,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildTextField(
                            controller: _userController,
                            label: 'Utilizador',
                            icon: Icons.person_rounded,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: _buildTextField(
                            controller: _portController,
                            label: 'Porta',
                            icon: Icons.numbers_rounded,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Palavra-passe',
                      icon: Icons.key_rounded,
                      isObscure: true,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 14),
                    _buildTextField(
                      controller: _databaseController,
                      label: 'Base de Dados (Opcional)',
                      icon: Icons.dns_rounded,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 28),

                    // Botões de Ação: TESTAR CONEXÃO e LIGAR AO MYSQL
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.network_check_rounded, size: 20),
                              label: const Text(
                                'TESTAR CONEXÃO',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: accentColor,
                                side: BorderSide(
                                  color: accentColor.withValues(alpha: 0.6),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: _handleTestConnection,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 52,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.power_settings_new_rounded, size: 20),
                              label: const Text(
                                'LIGAR AO MYSQL',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 6,
                                shadowColor: accentColor.withValues(alpha: 0.5),
                              ),
                              onPressed: _handleConnect,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Preloader Overlay
          if (appState.isLoading)
            ExtravagantPreloader(message: appState.loadingMessage),
        ],
      ),
    );
  }

  Widget _buildTextField({
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
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isObscure,
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF111827)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: accentColor, size: 20),
            filled: true,
            fillColor: isDark ? const Color(0xFF18191E) : const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF2A2C35) : const Color(0xFFE5E7EB),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: accentColor,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
