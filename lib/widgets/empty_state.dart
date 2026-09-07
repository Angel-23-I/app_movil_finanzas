import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icono;
  const EmptyState(
      {super.key,
      required this.titulo,
      required this.subtitulo,
      this.icono = Icons.receipt_long_rounded});

  @override
  Widget build(BuildContext context) {
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: oscuro ? Colors.white10 : const Color(0xFFE6E9F2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E2A5A)
                .withValues(alpha: oscuro ? 0.3 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icono,
                size: 32, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 12),
          Text(titulo,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 4),
          Text(subtitulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
