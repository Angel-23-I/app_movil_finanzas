import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/movimiento.dart';
import 'category_icon.dart';

class MovimientoTile extends StatelessWidget {
  final Movimiento mov;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  const MovimientoTile(
      {super.key, required this.mov, this.onTap, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final esIngreso = mov.tipo == TipoMovimiento.ingreso;
    final montoColor = esIngreso
        ? const Color(0xFF16A34A)
        : Theme.of(context).colorScheme.onSurface;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap ?? onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            CategoryIcon(categoria: mov.categoria, tipo: mov.tipo),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mov.descripcion,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(
                    '${mov.categoria} · ${DateFormat('dd MMM', 'es').format(mov.fecha)}',
                    style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                        fontSize: 12.5),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${esIngreso ? '+' : '-'}\$${mov.monto.toStringAsFixed(0)}',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: montoColor),
                ),
                if (onDelete != null && mov.tipo == TipoMovimiento.egreso)
                  InkWell(
                    onTap: onDelete,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text('Eliminar',
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.error)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
