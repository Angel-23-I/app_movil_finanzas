import 'package:flutter/material.dart';
import '../services/budget_service.dart';

class EstadoBanner extends StatelessWidget {
  final EstadoPresupuesto estado;
  final double porcentaje;
  const EstadoBanner({super.key, required this.estado, required this.porcentaje});

  @override
  Widget build(BuildContext context) {
    late Color color;
    late String texto;
    late IconData icono;
    switch (estado) {
      case EstadoPresupuesto.sinIngresos:
        color = Colors.grey;
        texto = 'Registra tus ingresos del mes para empezar.';
        icono = Icons.info_outline;
        break;
      case EstadoPresupuesto.saludable:
        color = Colors.green;
        texto = 'Presupuesto saludable (${porcentaje.toStringAsFixed(0)}% disponible).';
        icono = Icons.check_circle_outline;
        break;
      case EstadoPresupuesto.precaucion:
        color = Colors.orange;
        texto = 'PRECAUCIÓN: solo queda ${porcentaje.toStringAsFixed(0)}% de tus ingresos.';
        icono = Icons.warning_amber_outlined;
        break;
      case EstadoPresupuesto.critica:
        color = Colors.red;
        texto = 'CRÍTICA: solo queda ${porcentaje.toStringAsFixed(0)}%. Evita gastar.';
        icono = Icons.error_outline;
        break;
    }
    return Card(
      color: color.withValues(alpha: 0.12),
      child: ListTile(
        leading: Icon(icono, color: color),
        title: Text(
          BudgetService.etiquetaEstado(estado),
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(texto),
      ),
    );
  }
}
