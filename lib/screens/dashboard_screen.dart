import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/resumen_card.dart';
import '../widgets/estado_banner.dart';
import '../widgets/movimiento_tile.dart';
import 'ingreso_form_screen.dart';
import 'egreso_form_screen.dart';
import 'ingresos_screen.dart';
import 'egresos_screen.dart';
import 'ajustes_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _mesTitulo(AppState app) {
    if (app.nombreMes.trim().isNotEmpty) return app.nombreMes.trim();
    final partes = app.mesActivo.split('-');
    if (partes.length == 2) return '${partes[1]}/${partes[0]}';
    return app.mesActivo;
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    if (app.cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final ultimos = app.movimientosMes.take(5).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('Hola, ${app.alias}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic),
            tooltip: 'Dictar gasto',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EgresoFormScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AjustesScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Text('Mes activo: ${_mesTitulo(app)}',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ResumenCard(
              ingresos: app.totalIngresos,
              egresos: app.totalEgresos,
              saldo: app.saldo,
              porcentaje: app.porcentaje,
            ),
            const SizedBox(height: 8),
            EstadoBanner(estado: app.estado, porcentaje: app.porcentaje),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Ingreso'),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const IngresoFormScreen()),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.remove),
                    label: const Text('Egreso'),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EgresoFormScreen()),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Últimos movimientos',
                    style: Theme.of(context).textTheme.titleMedium),
                Row(
                  children: [
                    TextButton(
                      child: const Text('Ingresos'),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const IngresosScreen()),
                      ),
                    ),
                    TextButton(
                      child: const Text('Egresos'),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EgresosScreen()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (ultimos.isEmpty)
              const Card(
                child: ListTile(
                  title: Text('Sin movimientos este mes.'),
                  subtitle: Text('Agrega tu primer ingreso o egreso.'),
                ),
              )
            else
              Card(
                child: Column(
                  children: ultimos
                      .map((m) => MovimientoTile(mov: m))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
