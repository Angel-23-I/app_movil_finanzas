import 'package:flutter_test/flutter_test.dart';
import 'package:app_movil_finanzas/models/movimiento.dart';
import 'package:app_movil_finanzas/services/budget_service.dart';

Movimiento mov(String id, double monto, TipoMovimiento tipo, DateTime fecha) =>
    Movimiento(
      id: id,
      descripcion: 'test',
      categoria: 'otro',
      monto: monto,
      fecha: fecha,
      tipo: tipo,
    );

void main() {
  final sep = DateTime(2026, 9, 5);
  const mes = '2026-09';

  test('saldo resta ingresos menos egresos y nunca negativo', () {
    final todos = [
      mov('1', 10000, TipoMovimiento.ingreso, sep),
      mov('2', 3000, TipoMovimiento.egreso, sep),
    ];
    expect(BudgetService.saldo(todos, mes), 7000);
    final exceso = [
      mov('1', 1000, TipoMovimiento.ingreso, sep),
      mov('2', 5000, TipoMovimiento.egreso, sep),
    ];
    expect(BudgetService.saldo(exceso, mes), 0);
  });

  test('estado precaucion al 30% y critica al 10%', () {
    final base = [mov('1', 10000, TipoMovimiento.ingreso, sep)];
    final pre = [...base, mov('2', 7000, TipoMovimiento.egreso, sep)];
    expect(BudgetService.estado(pre, mes), EstadoPresupuesto.precaucion);
    final cri = [...base, mov('2', 9500, TipoMovimiento.egreso, sep)];
    expect(BudgetService.estado(cri, mes), EstadoPresupuesto.critica);
    final ok = [...base, mov('2', 1000, TipoMovimiento.egreso, sep)];
    expect(BudgetService.estado(ok, mes), EstadoPresupuesto.saludable);
  });

  test('bloquea egreso que supera saldo y muestra maximo', () {
    final todos = [mov('1', 5000, TipoMovimiento.ingreso, sep)];
    final err = BudgetService.validarEgreso(
      todos: todos,
      monthKey: mes,
      descripcion: 'test',
      monto: 6000,
    );
    expect(err, isNotNull);
    expect(err!, contains('5000'));
    expect(
      BudgetService.validarEgreso(
        todos: todos,
        monthKey: mes,
        descripcion: 'test',
        monto: 5000,
      ),
      isNull,
    );
  });

  test('valida vacios y monto mayor que cero', () {
    expect(BudgetService.validarBase('', 100), isNotNull);
    expect(BudgetService.validarBase('x', 0), isNotNull);
    expect(BudgetService.validarBase('x', -5), isNotNull);
    expect(BudgetService.validarBase('x', 10), isNull);
  });

  test('filtra por mes', () {
    final todos = [
      mov('1', 1000, TipoMovimiento.ingreso, DateTime(2026, 8, 1)),
      mov('2', 2000, TipoMovimiento.ingreso, sep),
    ];
    expect(BudgetService.totalIngresos(todos, mes), 2000);
  });
}
