import 'package:flutter/material.dart';
import '../models/movimiento.dart';

class CategoryIcon extends StatelessWidget {
  final String categoria;
  final TipoMovimiento? tipo;
  final double size;
  const CategoryIcon(
      {super.key, required this.categoria, this.tipo, this.size = 44});

  static IconData iconFor(String categoria, TipoMovimiento? tipo) {
    if (tipo == TipoMovimiento.ingreso) return Icons.south_west_rounded;
    final c = categoria.toLowerCase();
    if (c.contains('aliment')) return Icons.restaurant_rounded;
    if (c.contains('transport')) return Icons.directions_bus_rounded;
    if (c.contains('entreten')) return Icons.movie_rounded;
    if (c.contains('salud')) return Icons.favorite_rounded;
    if (c.contains('educac')) return Icons.school_rounded;
    if (c.contains('mesada') || c.contains('beca')) return Icons.card_giftcard_rounded;
    if (c.contains('trabajo')) return Icons.work_rounded;
    if (c.contains('ventas')) return Icons.store_rounded;
    return Icons.receipt_long_rounded;
  }

  static Color colorFor(String categoria, TipoMovimiento? tipo) {
    if (tipo == TipoMovimiento.ingreso) return const Color(0xFF16A34A);
    final c = categoria.toLowerCase();
    if (c.contains('aliment')) return const Color(0xFFF59E0B);
    if (c.contains('transport')) return const Color(0xFF0EA5E9);
    if (c.contains('entreten')) return const Color(0xFF8B5CF6);
    if (c.contains('salud')) return const Color(0xFFEC4899);
    if (c.contains('educac')) return const Color(0xFF6366F1);
    return const Color(0xFF64748B);
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFor(categoria, tipo);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(iconFor(categoria, tipo), color: color, size: 22),
    );
  }
}
