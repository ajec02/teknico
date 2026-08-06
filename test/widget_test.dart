// Testes de Interface para o Sistema Suporte

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:suporte/main.dart';
import 'package:suporte/providers/app_state.dart';

void main() {
  testWidgets('Carregamento do Sistema Suporte', (WidgetTester tester) async {
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
