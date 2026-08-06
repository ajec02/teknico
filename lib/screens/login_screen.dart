// Ecrã de Login do Sistema Suporte OS com MTeste e MProducao

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_account.dart';
import '../providers/app_state.dart';
import '../widgets/custom_modal.dart';
import '../widgets/extravagant_preloader.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController(text: 'superadmin');
  final TextEditingController _passwordController = TextEditingController(text: '123456');

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleQuickLogin(UserAccount user) async {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.setLoading(true, 'A iniciar sessão como ${user.name}...');
    await Future.delayed(const Duration(milliseconds: 400));
    await appState.login(user);
    appState.setLoading(false);

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/connections');
    }
  }

  void _handleManualLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      CustomModal.show(
        context: context,
        title: 'Preencha os Campos',
        message: 'Por favor introduza o nome de utilizador e a palavra-passe.',
        type: ModalType.warning,
      );
      return;
    }

    final appState = Provider.of<AppState>(context, listen: false);
    appState.setLoading(true, 'A autenticar utilizador...');
    await Future.delayed(const Duration(milliseconds: 500));
    final success = await appState.loginWithCredentials(username, password);
    appState.setLoading(false);

    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/connections');
    } else if (mounted) {
      CustomModal.show(
        context: context,
        title: 'Falha na Autenticação',
        message: 'Credenciais inválidas. Por favor verifique o utilizador e a palavra-passe.',
        type: ModalType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final isTestMode = appState.isTestMode;
    const accentColor = Color(0xFFFF6B00);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0C0E) : const Color(0xFFF3F4F6),
      body: Stack(
        children: [
          // Fundo Decorativo
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.4,
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
                width: 500,
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
                    // Voltar para Landing Page + Botão Tema
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.arrow_back_rounded, size: 18),
                          label: const Text('Voltar à Landing Page'),
                          style: TextButton.styleFrom(foregroundColor: accentColor),
                          onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
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
                    const SizedBox(height: 16),

                    // Cabeçalho da Ecrã de Login
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
                            Icons.lock_person_rounded,
                            size: 28,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AUTENTICAÇÃO',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: isDark ? Colors.white : const Color(0xFF111827),
                              ),
                            ),
                            Text(
                              'Aceda ao seu painel de suporte',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Selector MTeste / MProducao (Super Admin Control)
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
                              onTap: () => appState.toggleTestMode(true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isTestMode ? accentColor : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: isTestMode
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
                                      color: isTestMode ? Colors.white : (isDark ? Colors.white60 : Colors.black54),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Modo Teste (MTeste)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: isTestMode ? Colors.white : (isDark ? Colors.white60 : Colors.black54),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => appState.toggleTestMode(false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: !isTestMode ? const Color(0xFF10B981) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: !isTestMode
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
                                      Icons.verified_user_rounded,
                                      size: 16,
                                      color: !isTestMode ? Colors.white : (isDark ? Colors.white60 : Colors.black54),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Modo Produção',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: !isTestMode ? Colors.white : (isDark ? Colors.white60 : Colors.black54),
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

                    // Conteúdo Dinâmico: Se MTeste exibe Lista de Utilizadores, se MProducao exibe Formulário
                    if (isTestMode) ...[
                      Text(
                        'Selecione um Utilizador para Login Rápido (MTeste):',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Column(
                        children: UserAccount.testUsers.map((user) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF18191E) : const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? const Color(0xFF2A2C35) : const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              leading: CircleAvatar(
                                backgroundColor: accentColor.withValues(alpha: 0.2),
                                child: Text(
                                  user.name.substring(0, 1),
                                  style: const TextStyle(color: accentColor, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(
                                user.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isDark ? Colors.white : const Color(0xFF111827),
                                ),
                              ),
                              subtitle: Text(
                                '${user.roleDisplayName} • ${user.email}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                              trailing: ElevatedButton.icon(
                                icon: const Icon(Icons.login_rounded, size: 16),
                                label: const Text('Entrar', style: TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () => _handleQuickLogin(user),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ] else ...[
                      // Formulário de Produção (MProducao)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Utilizador ou Email',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _usernameController,
                            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF111827)),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.person_rounded, color: accentColor, size: 20),
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
                                borderSide: const BorderSide(color: accentColor, width: 1.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Palavra-passe',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF111827)),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.key_rounded, color: accentColor, size: 20),
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
                                borderSide: const BorderSide(color: accentColor, width: 1.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.login_rounded, size: 20),
                              label: const Text(
                                'FAZER LOGIN',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accentColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 6,
                                shadowColor: accentColor.withValues(alpha: 0.5),
                              ),
                              onPressed: _handleManualLogin,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          if (appState.isLoading)
            ExtravagantPreloader(message: appState.loadingMessage),
        ],
      ),
    );
  }
}
