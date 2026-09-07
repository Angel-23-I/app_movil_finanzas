import 'package:flutter/material.dart';
import '../services/budget_service.dart';
import '../services/notification_service.dart';
import '../state/app_state.dart';

Future<void> mostrarAlertaSiNecesario(BuildContext context, AppState app) async {
  if (app.estado == EstadoPresupuesto.precaucion) {
    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('PRECAUCIÓN'),
        content: Text(
            'Tu saldo llegó al ${app.porcentaje.toStringAsFixed(0)}% de tus ingresos. Controla tus gastos.'),
        actions: [
          FilledButton(
            child: const Text('Entendido'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  } else if (app.estado == EstadoPresupuesto.critica) {
    await NotificationService.alertaCritica(app.porcentaje, app.saldo);
    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ALERTA CRÍTICA'),
        content: Text(
            'Solo queda ${app.porcentaje.toStringAsFixed(0)}% (\$${app.saldo.toStringAsFixed(0)}). Se envió una notificación. Evita gastar.'),
        actions: [
          FilledButton(
            child: const Text('Entendido'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
