import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/movimiento_tile.dart';
import 'ingreso_form_screen.dart';

class IngresosScreen extends StatelessWidget {
  const IngresosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final lista = app.ingresosMes;
    return Scaffold(
      appBar: AppBar(title: const Text('Ingresos del mes')),
      body: lista.isEmpty
          ? const Center(child: Text('Sin ingresos este mes.'))
          : ListView(
              children: [
                ListTile(
                  title: Text('Total: \$${app.totalIngresos.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                ...lista.map((m) => MovimientoTile(mov: m)),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const IngresoFormScreen()),
        ),
      ),
    );
  }
}
