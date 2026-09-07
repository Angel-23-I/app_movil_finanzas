import 'package:flutter/material.dart';
import '../services/budget_service.dart';
import '../theme/app_theme.dart';

class EstadoBanner extends StatelessWidget {
  final EstadoPresupuesto estado;
  final double porcentaje;
  const EstadoBanner(
      {super.key, required this.estado, required this.porcentaje});

  @override
  Widget build(BuildContext context) {
    late Color color;
    late Color soft;
    late String titulo;
    late String texto;
    late String emoji;
    switch (estado) {
      case EstadoPresupuesto.sinIngresos:
        color = Theme.of(context).colorScheme.primary;
        soft = Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);
        titulo = 'Empieza tu mes';
        texto = 'Registra tus ingresos para activar tu presupuesto.';
        emoji = '💰';
        break;
      case EstadoPresupuesto.saludable:
        color = AppColors.saludable;
        soft = AppColors.ingresoSoft;
        titulo = 'Presupuesto saludable';
        texto = 'Vas muy bien, sigue así.';
        emoji = '🟢';
        break;
      case EstadoPresupuesto.precaucion:
        color = AppColors.precaucion;
        soft = AppColors.precaucionSoft;
        titulo = 'Presupuesto en precaución';
        texto = 'Has utilizado gran parte de tu presupuesto.';
        emoji = '🟡';
        break;
      case EstadoPresupuesto.critica:
        color = AppColors.critica;
        soft = AppColors.criticaSoft;
        titulo = 'Presupuesto crítico';
        texto = 'Tu saldo está cerca de agotarse.';
        emoji = '🔴';
        break;
    }
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: oscuro
            ? color.withValues(alpha: 0.16)
            : soft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: color.withValues(
                alpha: estado == EstadoPresupuesto.critica ? 0.5 : 0.25)),
        boxShadow: estado == EstadoPresupuesto.critica
            ? AppShadows.soft(color)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style: TextStyle(
                        color: oscuro ? Colors.white : color,
                        fontWeight: FontWeight.w800,
                        fontSize: 15)),
                Text(texto,
                    style: TextStyle(
                        fontSize: 13,
                        color: oscuro
                            ? Colors.white70
                            : Colors.black54)),
              ],
            ),
          ),
          if (estado != EstadoPresupuesto.sinIngresos)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12)),
              child: Text('${porcentaje.toStringAsFixed(0)}%',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800)),
            ),
        ],
      ),
    );
  }
}
