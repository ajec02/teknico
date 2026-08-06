// Testes de Interface para o Sistema Teknico

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import '../lib/main.dart';
import '../lib/providers/app_state.dart';

void main() {
  testWidgets('Carregamento do Sistema Teknico', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const TeknicoApp(),
      ),
    );

    // Verificar se o ecrã de conexão é carregado com o título
    expect(find.text('TEKNICO OS'), findsOneWidget);
  });
}
