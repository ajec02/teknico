// Testes de Interface para o Sistema Suporte OS

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../lib/main.dart';
import '../lib/providers/app_state.dart';

void main() {
  testWidgets('Carregamento do Sistema Suporte OS', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const SuporteApp(),
      ),
    );

    // Verificar se o ecrã de conexão é carregado com o título
    expect(find.text('SUPORTE OS'), findsOneWidget);
  });
}
