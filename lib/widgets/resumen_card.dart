import 'package:flutter/material.dart';

class ResumenCard extends StatelessWidget {
  final double ingresos;
  final double egresos;
  final double saldo;
  final double porcentaje;
  const ResumenCard({
    super.key,
    required this.ingresos,
    required this.egresos,
    required this.saldo,
    required this.porcentaje,
  });

  String _fmt(double v) => '\$${v.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _dato('Ingresos', _fmt(ingresos), Colors.green),
                _dato('Egresos', _fmt(egresos), Colors.red),
              ],
            ),
            const SizedBox(height: 12),
            Text('Saldo disponible', style: Theme.of(context).textTheme.labelLarge),
            Text(
              _fmt(saldo),
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (porcentaje / 100).clamp(0.0, 1.0),
              minHeight: 8,
            ),
            const SizedBox(height: 4),
            Text('${porcentaje.toStringAsFixed(0)}% disponible'),
          ],
        ),
      ),
    );
  }

  Widget _dato(String titulo, String valor, Color color) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo),
          Text(valor,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      );
}
