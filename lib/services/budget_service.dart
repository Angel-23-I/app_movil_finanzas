import 'dart:math';
import '../models/movimiento.dart';

enum EstadoPresupuesto { sinIngresos, saludable, precaucion, critica }

class BudgetService {
  static List<Movimiento> porMes(List<Movimiento> todos, String monthKey) =>
      todos.where((m) => m.monthKey == monthKey).toList();

  static double totalIngresos(List<Movimiento> todos, String monthKey) =>
      porMes(todos, monthKey)
          .where((m) => m.tipo == TipoMovimiento.ingreso)
          .fold(0.0, (s, m) => s + m.monto);

  static double totalEgresos(List<Movimiento> todos, String monthKey) =>
      porMes(todos, monthKey)
          .where((m) => m.tipo == TipoMovimiento.egreso)
          .fold(0.0, (s, m) => s + m.monto);

  static double saldo(List<Movimiento> todos, String monthKey) =>
      max(0.0, totalIngresos(todos, monthKey) - totalEgresos(todos, monthKey));

  static double porcentajeDisponible(List<Movimiento> todos, String monthKey) {
    final ingresos = totalIngresos(todos, monthKey);
    if (ingresos <= 0) return 0.0;
    return saldo(todos, monthKey) / ingresos * 100;
  }

  static EstadoPresupuesto estado(List<Movimiento> todos, String monthKey) {
    final ingresos = totalIngresos(todos, monthKey);
    if (ingresos <= 0) return EstadoPresupuesto.sinIngresos;
    final p = porcentajeDisponible(todos, monthKey);
    if (p <= 10) return EstadoPresupuesto.critica;
    if (p <= 30) return EstadoPresupuesto.precaucion;
    return EstadoPresupuesto.saludable;
  }

  static double maxPermitido(List<Movimiento> todos, String monthKey) =>
      saldo(todos, monthKey);

  static String? validarBase(String descripcion, double? monto) {
    if (descripcion.trim().isEmpty) return 'Escribe una descripción.';
    if (monto == null) return 'Escribe un monto válido.';
    if (monto <= 0) return 'El monto debe ser mayor que cero.';
    return null;
  }

  static String? validarEgreso({
    required List<Movimiento> todos,
    required String monthKey,
    required String descripcion,
    required double? monto,
    String? excluirId,
  }) {
    final base = validarBase(descripcion, monto);
    if (base != null) return base;
    final egresos = totalEgresos(todos, monthKey);
    final ingresos = totalIngresos(todos, monthKey);
    double egresosAjustados = egresos;
    if (excluirId != null) {
      final previo = porMes(todos, monthKey).where((m) =>
          m.tipo == TipoMovimiento.egreso && m.id == excluirId);
      if (previo.isNotEmpty) egresosAjustados -= previo.first.monto;
    }
    final disponible = max(0.0, ingresos - egresosAjustados);
    if (monto! > disponible) {
      return 'Saldo insuficiente. Máximo permitido: \$${disponible.toStringAsFixed(0)}.';
    }
    return null;
  }

  static String etiquetaEstado(EstadoPresupuesto e) {
    switch (e) {
      case EstadoPresupuesto.sinIngresos:
        return 'Sin ingresos';
      case EstadoPresupuesto.saludable:
        return 'Saludable';
      case EstadoPresupuesto.precaucion:
        return 'Precaución';
      case EstadoPresupuesto.critica:
        return 'Crítica';
    }
  }
}
