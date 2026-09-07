import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _ready = false;

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const windows = WindowsInitializationSettings(
      appName: 'Finanzas Estudiante',
      appUserModelId: 'com.examen.app_movil_finanzas',
      guid: '7b9f2c3a-4d1e-4f5a-9c8b-1a2b3c4d5e6f',
    );
    const linux = LinuxInitializationSettings(defaultActionName: 'Abrir');
    const settings = InitializationSettings(
      android: android,
      windows: windows,
      linux: linux,
    );
    await _plugin.initialize(settings);
    const channel = AndroidNotificationChannel(
      'presupuesto_critico',
      'Presupuesto crítico',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    _ready = true;
  }

  static Future<void> alertaCritica(double porcentaje, double saldo) async {
    if (!_ready) return;
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'presupuesto_critico',
        'Presupuesto crítico',
        importance: Importance.high,
        priority: Priority.high,
      ),
      windows: WindowsNotificationDetails(),
      linux: LinuxNotificationDetails(),
    );
    await _plugin.show(
      1,
      'Presupuesto en estado CRÍTICO',
      'Solo queda ${porcentaje.toStringAsFixed(0)}% (\$${saldo.toStringAsFixed(0)}). Evita gastar.',
      details,
    );
  }
}
