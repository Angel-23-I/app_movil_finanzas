import 'package:flutter_test/flutter_test.dart';
import 'package:app_movil_finanzas/services/voice_parser.dart';

void main() {
  test('gaste ocho mil pesos en transporte', () {
    final r = VoiceParser.parse('gasté ocho mil pesos en transporte');
    expect(r.monto, 8000);
    expect(r.categoria, 'transporte');
    expect(r.descripcion, 'Transporte');
  });

  test('detecta digitos y categoria salud', () {
    final r = VoiceParser.parse('gaste 2500 en farmacia');
    expect(r.monto, 2500);
    expect(r.categoria, 'salud');
  });

  test('dos mil quinientos educacion', () {
    final r = VoiceParser.parse('gaste dos mil quinientos en libros universidad');
    expect(r.monto, 2500);
    expect(r.categoria, 'educación');
  });
}
