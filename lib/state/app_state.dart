import 'package:flutter/material.dart';
import '../models/movimiento.dart';
import '../services/budget_service.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  final StorageService storage;
  List<Movimiento> _movs = [];
  bool cargando = true;

  String alias = 'Estudiante';
  bool temaOscuro = false;
  int colorAcento = 0xFF1565C0;
  String mesActivo;
  String nombreMes = '';

  AppState({required this.storage})
      : mesActivo = Movimiento.monthKeyFrom(DateTime.now());

  List<Movimiento> get movimientos => List.unmodifiable(_movs);

  List<Movimiento> get movimientosMes {
    final lista = BudgetService.porMes(_movs, mesActivo);
    lista.sort((a, b) => b.fecha.compareTo(a.fecha));
    return lista;
  }

  List<Movimiento> get ingresosMes => movimientosMes
      .where((m) => m.tipo == TipoMovimiento.ingreso)
      .toList();

  List<Movimiento> get egresosMes => movimientosMes
      .where((m) => m.tipo == TipoMovimiento.egreso)
      .toList();

  double get totalIngresos => BudgetService.totalIngresos(_movs, mesActivo);
  double get totalEgresos => BudgetService.totalEgresos(_movs, mesActivo);
  double get saldo => BudgetService.saldo(_movs, mesActivo);
  double get porcentaje => BudgetService.porcentajeDisponible(_movs, mesActivo);
  EstadoPresupuesto get estado => BudgetService.estado(_movs, mesActivo);

  Future<void> init() async {
    _movs = await storage.loadMovimientos();
    final a = await storage.loadAjustes(mesActivo);
    alias = a['alias'] as String;
    temaOscuro = a['oscuro'] as bool;
    colorAcento = a['acento'] as int;
    mesActivo = a['mes'] as String;
    nombreMes = a['nombreMes'] as String;
    cargando = false;
    notifyListeners();
  }

  Future<void> _persist() => storage.saveMovimientos(_movs);

  Future<void> _persistAjustes() => storage.saveAjustes(
        alias: alias,
        oscuro: temaOscuro,
        acento: colorAcento,
        mes: mesActivo,
        nombreMes: nombreMes,
      );

  String? agregarIngreso({
    required String descripcion,
    required String categoria,
    required double? monto,
    required DateTime fecha,
  }) {
    final err = BudgetService.validarBase(descripcion, monto);
    if (err != null) return err;
    if (categoria.trim().isEmpty) return 'Elige una categoría.';
    _movs.add(Movimiento(
      id: Movimiento.newId(),
      descripcion: descripcion.trim(),
      categoria: categoria.trim(),
      monto: monto!,
      fecha: fecha,
      tipo: TipoMovimiento.ingreso,
    ));
    _persist();
    notifyListeners();
    return null;
  }

  String? agregarEgreso({
    required String descripcion,
    required String categoria,
    required double? monto,
    required DateTime fecha,
  }) {
    final err = BudgetService.validarEgreso(
      todos: _movs,
      monthKey: Movimiento.monthKeyFrom(fecha),
      descripcion: descripcion,
      monto: monto,
    );
    if (err != null) return err;
    _movs.add(Movimiento(
      id: Movimiento.newId(),
      descripcion: descripcion.trim(),
      categoria: categoria.trim().toLowerCase(),
      monto: monto!,
      fecha: fecha,
      tipo: TipoMovimiento.egreso,
    ));
    _persist();
    notifyListeners();
    return null;
  }

  String? editarEgreso(
    String id, {
    required String descripcion,
    required String categoria,
    required double? monto,
    required DateTime fecha,
  }) {
    final err = BudgetService.validarEgreso(
      todos: _movs,
      monthKey: Movimiento.monthKeyFrom(fecha),
      descripcion: descripcion,
      monto: monto,
      excluirId: id,
    );
    if (err != null) return err;
    final i = _movs.indexWhere((m) => m.id == id);
    if (i == -1) return 'Movimiento no encontrado.';
    _movs[i] = Movimiento(
      id: id,
      descripcion: descripcion.trim(),
      categoria: categoria.trim().toLowerCase(),
      monto: monto!,
      fecha: fecha,
      tipo: TipoMovimiento.egreso,
    );
    _persist();
    notifyListeners();
    return null;
  }

  void eliminar(String id) {
    _movs.removeWhere((m) => m.id == id);
    _persist();
    notifyListeners();
  }

  void cambiarMes(String monthKey) {
    mesActivo = monthKey;
    _persistAjustes();
    notifyListeners();
  }

  void actualizarAjustes({
    required String nuevoAlias,
    required bool oscuro,
    required int acento,
    required String nombreMesNuevo,
  }) {
    alias = nuevoAlias.trim().isEmpty ? 'Estudiante' : nuevoAlias.trim();
    temaOscuro = oscuro;
    colorAcento = acento;
    nombreMes = nombreMesNuevo.trim();
    _persistAjustes();
    notifyListeners();
  }
}
