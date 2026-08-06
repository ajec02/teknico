// Landing Page Extravagante do Sistema Suporte OS - Estilo Hyper POS

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class LandingPageScreen extends StatelessWidget {
  const LandingPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    const accentColor = Color(0xFFFF6B00);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0C0E) : const Color(0xFFF3F4F6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Navegação Superior / Barra de Cabeçalho
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141519).withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.9),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? const Color(0xFF2A2C35) : const Color(0xFFE5E7EB),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logótipo da Marca
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: accentColor.withValues(alpha: 0.4)),
                        ),
                        child: const Icon(Icons.storage_rounded, color: accentColor, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SUPORTE OS',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: isDark ? Colors.white : const Color(0xFF111827),
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: accentColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Hyper POS Edition',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Ações no Cabeçalho
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Alternar Tema',
                        icon: Icon(
                          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                          color: accentColor,
                        ),
                        onPressed: () => appState.toggleTheme(),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.login_rounded, size: 18),
                        label: const Text(
                          'ACEDER AO SISTEMA',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 6,
                          shadowColor: accentColor.withValues(alpha: 0.4),
                        ),
                        onPressed: () {
                          if (appState.isLoggedIn) {
                            Navigator.of(context).pushNamed('/connections');
                          } else {
                            Navigator.of(context).pushNamed('/login');
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. Hero Section Extravagante
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 80),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.2,
                  colors: isDark
                      ? [
                          const Color(0xFF1C1E26),
                          const Color(0xFF101115),
                          const Color(0xFF0B0C0E),
                        ]
                      : [
                          const Color(0xFFFFF7ED),
                          const Color(0xFFF9FAFB),
                          const Color(0xFFF3F4F6),
                        ],
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Column(
                    children: [
                      // Badge Superior
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt_rounded, size: 16, color: accentColor),
                            SizedBox(width: 8),
                            Text(
                              'GESTAO INTELIGENTE DE BASES DE DADOS MYSQL',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.1,
                                color: accentColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Título Principal
                      Text(
                        'Controlo Total das Suas Conexões,\nTabelas e Auditoria de Dados',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Descrição
                      Text(
                        'Gerencie múltiplos servidores MySQL em portas e endereços distintos, execute operações CRUD com validação instantânea, exporte relatórios PDF com QR Code corporativo e acompanhe auditorias em tempo real.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Botão Principal Hero
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.power_settings_new_rounded, size: 22),
                            label: const Text(
                              'FAZER LOGIN E GERIR CONEXÕES',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 8,
                              shadowColor: accentColor.withValues(alpha: 0.5),
                            ),
                            onPressed: () {
                              if (appState.isLoggedIn) {
                                Navigator.of(context).pushNamed('/connections');
                              } else {
                                Navigator.of(context).pushNamed('/login');
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Cartões de Funcionalidades / Destaques
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 60),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    children: [
                      Text(
                        'Recursos Concebidos para Máximo Rendimento',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildFeatureCard(
                            isDark: isDark,
                            icon: Icons.hub_rounded,
                            title: 'Múltiplas Conexões Guardadas',
                            description: 'Guarde os acessos de diferentes servidores com portas, IPs, utilizadores e palavras-passe customizadas. Alterne num clique.',
                            accentColor: accentColor,
                          ),
                          _buildFeatureCard(
                            isDark: isDark,
                            icon: Icons.table_chart_rounded,
                            title: 'CRUD Dinâmico de Tabelas',
                            description: 'Visualize tabelas com o registo mais recente em primeiro lugar (ID DESC), filtre e edite registos com confirmação de segurança.',
                            accentColor: accentColor,
                          ),
                          _buildFeatureCard(
                            isDark: isDark,
                            icon: Icons.qr_code_2_rounded,
                            title: 'Relatórios PDF com QR Code',
                            description: 'Gere relatórios elegantes (Relrel) com título, empresa, responsável, data de emissão e código QR de verificação de dados.',
                            accentColor: accentColor,
                          ),
                          _buildFeatureCard(
                            isDark: isDark,
                            icon: Icons.history_toggle_off_rounded,
                            title: 'Auditoria & Logs em Tempo Real',
                            description: 'Registo automático de todas as inserções, edições e eliminações de dados na base de dados de suporte.',
                            accentColor: accentColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 4. Rodapé Corporativo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 48),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF090A0C) : const Color(0xFFE5E7EB),
                border: Border(
                  top: BorderSide(
                    color: isDark ? const Color(0xFF1F2128) : const Color(0xFFD1D5DB),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '© 2026 Suporte OS - Todos os direitos reservados.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                  Text(
                    'Moeda Padrão: Kwanza (Kz) | Desenvolvido em Português de Portugal',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String description,
    required Color accentColor,
  }) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141519) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2C35) : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accentColor, size: 28),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }
}
