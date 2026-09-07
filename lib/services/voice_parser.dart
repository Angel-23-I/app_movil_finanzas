class VoiceResult {
  final String descripcion;
  final String categoria;
  final double? monto;
  VoiceResult({required this.descripcion, required this.categoria, required this.monto});
}

class VoiceParser {
  static const _unidades = {
    'cero': 0, 'uno': 1, 'un': 1, 'una': 1, 'dos': 2, 'tres': 3,
    'cuatro': 4, 'cinco': 5, 'seis': 6, 'siete': 7, 'ocho': 8,
    'nueve': 9, 'diez': 10, 'once': 11, 'doce': 12, 'trece': 13,
    'catorce': 14, 'quince': 15, 'dieciseis': 16, 'diecisiete': 17,
    'dieciocho': 18, 'diecinueve': 19, 'veinte': 20, 'veintiuno': 21,
    'veintidos': 22, 'veintitres': 23, 'veinticuatro': 24,
    'veinticinco': 25, 'veintiseis': 26, 'veintisiete': 27,
    'veintiocho': 28, 'veintinueve': 29,
  };

  static const _decenas = {
    'treinta': 30, 'cuarenta': 40, 'cincuenta': 50, 'sesenta': 60,
    'setenta': 70, 'ochenta': 80, 'noventa': 90,
  };

  static const _centenas = {
    'cien': 100, 'ciento': 100, 'doscientos': 200, 'doscientas': 200,
    'trescientos': 300, 'cuatrocientos': 400, 'quinientos': 500,
    'seiscientos': 600, 'setecientos': 700, 'ochocientos': 800,
    'novecientos': 900, 'mil': 1000,
  };

  static String _norm(String s) {
    var t = s.toLowerCase();
    const accents = {'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u', 'ñ': 'n'};
    accents.forEach((k, v) => t = t.replaceAll(k, v));
    return t;
  }

  static String detectarCategoria(String texto) {
    final t = _norm(texto);
    if (t.contains('aliment') || t.contains('comida') || t.contains('restaurante') || t.contains('almuerzo') || t.contains('cena')) {
      return 'alimentación';
    }
    if (t.contains('transport') || t.contains('bus') || t.contains('taxi') || t.contains('metro') || t.contains('pasaje') || t.contains('uber')) {
      return 'transporte';
    }
    if (t.contains('entreten') || t.contains('cine') || t.contains('fiesta') || t.contains('juego') || t.contains('netflix')) {
      return 'entretenimiento';
    }
    if (t.contains('salud') || t.contains('medico') || t.contains('farmacia') || t.contains('doctor')) {
      return 'salud';
    }
    if (t.contains('educac') || t.contains('colegio') || t.contains('universidad') || t.contains('libro') || t.contains('curso') || t.contains('escuela')) {
      return 'educación';
    }
    return 'otro';
  }

  static double? _palabrasANumero(String texto) {
    final t = _norm(texto).replaceAll(RegExp(r'[^a-z ]'), ' ');
    final tokens = t.split(RegExp(r'\s+')).where((e) => e.isNotEmpty && e != 'y' && e != 'de' && e != 'en' && e != 'pesos' && e != 'peso').toList();
    double total = 0;
    double actual = 0;
    bool encontrado = false;
    for (final w in tokens) {
      if (w == 'millon' || w == 'millones') {
        actual = (actual == 0 ? 1 : actual) * 1000000;
        total += actual;
        actual = 0;
        encontrado = true;
      } else if (w == 'mil') {
        actual = (actual == 0 ? 1 : actual) * 1000;
        total += actual;
        actual = 0;
        encontrado = true;
      } else if (_unidades.containsKey(w)) {
        actual += _unidades[w]!;
        encontrado = true;
      } else if (_decenas.containsKey(w)) {
        actual += _decenas[w]!;
        encontrado = true;
      } else if (_centenas.containsKey(w)) {
        actual += _centenas[w]!;
        encontrado = true;
      }
    }
    total += actual;
    if (!encontrado) return null;
    return total > 0 ? total : null;
  }

  static VoiceResult parse(String frase) {
    final categoria = detectarCategoria(frase);
    double? monto;
    final digitos = RegExp(r'\d[\d.,]*').firstMatch(frase.replaceAll(' ', ''));
    final digitosEsp = RegExp(r'(\d[\d.,]*)').firstMatch(frase);
    if (digitosEsp != null) {
      monto = double.tryParse(digitosEsp.group(1)!.replaceAll(',', ''));
    }
    digitos;
    monto ??= _palabrasANumero(frase);
    final desc = categoria[0].toUpperCase() + categoria.substring(1);
    return VoiceResult(descripcion: desc, categoria: categoria, monto: monto);
  }
}
