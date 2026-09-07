import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/movimiento_tile.dart';
import 'egreso_form_screen.dart';

class EgresosScreen extends StatelessWidget {
  const EgresosScreen({super.key});

  Future<void> _confirmarEliminar(BuildContext context, String id, String desc) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar egreso'),
        content: Text('¿Eliminar "$desc"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context, false),
          ),
          FilledButton(
            child: const Text('Eliminar'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<AppState>().eliminar(id);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Egreso eliminado.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final lista = app.egresosMes;
    return Scaffold(
      appBar: AppBar(title: const Text('Egresos del mes')),
      body: lista.isEmpty
          ? const Center(child: Text('Sin egresos este mes.'))
          : ListView(
              children: [
                ListTile(
                  title: Text('Total: \$${app.totalEgresos.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Saldo: \$${app.saldo.toStringAsFixed(0)}'),
                ),
                ...lista.map((m) => Dismissible(
                      key: ValueKey(m.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (_) async {
                        await _confirmarEliminar(context, m.id, m.descripcion);
                        return false;
                      },
                      child: MovimientoTile(
                        mov: m,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => EgresoFormScreen(editar: m)),
                        ),
                      ),
                    )),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EgresoFormScreen()),
        ),
      ),
    );
  }
}
