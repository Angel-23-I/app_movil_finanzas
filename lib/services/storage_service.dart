import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movimiento.dart';

class StorageService {
  static const _kMovs = 'movimientos_json';
  static const _kAlias = 'alias';
  static const _kOscuro = 'tema_oscuro';
  static const _kAcento = 'color_acento';
  static const _kMes = 'mes_activo';
  static const _kNombreMes = 'nombre_mes';

  Future<List<Movimiento>> loadMovimientos() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kMovs);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Movimiento.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveMovimientos(List<Movimiento> movs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kMovs, jsonEncode(movs.map((m) => m.toJson()).toList()));
  }

  Future<Map<String, dynamic>> loadAjustes(String mesDefecto) async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'alias': prefs.getString(_kAlias) ?? 'Estudiante',
      'oscuro': prefs.getBool(_kOscuro) ?? false,
      'acento': prefs.getInt(_kAcento) ?? 0xFF1565C0,
      'mes': prefs.getString(_kMes) ?? mesDefecto,
      'nombreMes': prefs.getString(_kNombreMes) ?? '',
    };
  }

  Future<void> saveAjustes({
    required String alias,
    required bool oscuro,
    required int acento,
    required String mes,
    required String nombreMes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAlias, alias);
    await prefs.setBool(_kOscuro, oscuro);
    await prefs.setInt(_kAcento, acento);
    await prefs.setString(_kMes, mes);
    await prefs.setString(_kNombreMes, nombreMes);
  }
}
