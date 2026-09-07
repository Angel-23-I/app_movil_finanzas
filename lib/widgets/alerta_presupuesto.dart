import 'package:flutter/material.dart';
import '../services/budget_service.dart';
import '../services/notification_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

Future<void> mostrarAlertaSiNecesario(BuildContext context, AppState app) async {
  if (app.estado == EstadoPresupuesto.precaucion) {
    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: const [
            Icon(Icons.warning_rounded, color: AppColors.precaucion),
            SizedBox(width: 8),
            Text('Precaución'),
          ],
        ),
        content: Text(
            'Has utilizado gran parte de tu presupuesto. Queda ${app.porcentaje.toStringAsFixed(0)}%.'),
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: const [
            Icon(Icons.error_rounded, color: AppColors.critica),
            SizedBox(width: 8),
            Text('Saldo por agotarse'),
          ],
        ),
        content: Text(
            'Tu saldo está cerca de agotarse. Queda ${app.porcentaje.toStringAsFixed(0)}% (\$${app.saldo.toStringAsFixed(0)}). Te enviamos una notificación.'),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.critica),
            child: const Text('Entendido'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
