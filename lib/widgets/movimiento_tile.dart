import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/movimiento.dart';

class MovimientoTile extends StatelessWidget {
  final Movimiento mov;
  final VoidCallback? onTap;
  const MovimientoTile({super.key, required this.mov, this.onTap});

  @override
  Widget build(BuildContext context) {
    final esIngreso = mov.tipo == TipoMovimiento.ingreso;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor:
            (esIngreso ? Colors.green : Colors.red).withValues(alpha: 0.15),
        child: Icon(
          esIngreso ? Icons.arrow_downward : Icons.arrow_upward,
          color: esIngreso ? Colors.green : Colors.red,
        ),
      ),
      title: Text(mov.descripcion),
      subtitle: Text(
          '${mov.categoria} · ${DateFormat('dd/MM/yyyy').format(mov.fecha)}'),
      trailing: Text(
        '${esIngreso ? '+' : '-'}\$${mov.monto.toStringAsFixed(0)}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: esIngreso ? Colors.green : Colors.red,
        ),
      ),
      onTap: onTap,
    );
  }
}
