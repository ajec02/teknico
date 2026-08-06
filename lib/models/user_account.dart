// Modelo de Conta de Utilizador do Sistema Suporte OS

class UserAccount {
  final String id;
  final String name;
  final String email;
  final String username;
  final String role; // 'super_admin', 'admin', 'tecnico'
  final String avatarUrl;

  const UserAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.role,
    required this.avatarUrl,
  });

  bool get isSuperAdmin => role == 'super_admin';
  bool get isAdmin => role == 'admin' || role == 'super_admin';

  String get roleDisplayName {
    switch (role) {
      case 'super_admin':
        return 'Super Administrador';
      case 'admin':
        return 'Administrador';
      case 'tecnico':
        return 'Técnico de Suporte';
      default:
        return 'Utilizador';
    }
  }

  /// Lista de Utilizadores Predefinidos para o Modo Teste (MTeste)
  static const List<UserAccount> testUsers = [
    UserAccount(
      id: 'usr_01',
      name: 'António E. Cruz (Proprietário)',
      email: 'antonio.cruz@suporte.ao',
      username: 'superadmin',
      role: 'super_admin',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    ),
    UserAccount(
      id: 'usr_02',
      name: 'Manuel Francisco',
      email: 'manuel.francisco@suporte.ao',
      username: 'admin',
      role: 'admin',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    ),
    UserAccount(
      id: 'usr_03',
      name: 'Teresa Domingos',
      email: 'teresa.domingos@suporte.ao',
      username: 'tecnico',
      role: 'tecnico',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    ),
  ];
}
