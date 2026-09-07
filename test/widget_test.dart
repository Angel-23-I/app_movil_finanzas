import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_movil_finanzas/main.dart';

void main() {
  testWidgets('dashboard muestra alias y acciones', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.textContaining('Hola'), findsOneWidget);
    expect(find.text('Ingreso'), findsOneWidget);
    expect(find.text('Egreso'), findsOneWidget);
  });
}
