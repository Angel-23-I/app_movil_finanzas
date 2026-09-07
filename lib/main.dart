import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'screens/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(storage: StorageService())..init(),
      child: Consumer<AppState>(
        builder: (context, app, _) {
          final acento = Color(app.colorAcento);
          return MaterialApp(
            title: 'Finanzas Estudiante',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: acento,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: acento,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: app.temaOscuro ? ThemeMode.dark : ThemeMode.light,
            home: const DashboardScreen(),
          );
        },
      ),
    );
  }
}
