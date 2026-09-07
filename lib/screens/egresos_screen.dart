import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/movimiento_tile.dart';
import '../widgets/empty_state.dart';
import 'egreso_form_screen.dart';

class EgresosScreen extends StatelessWidget {
  const EgresosScreen({super.key});

  Future<void> _confirmarEliminar(
      BuildContext context, String id, String desc) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Eliminar gasto'),
        content:
            Text('¿Eliminar "$desc"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context, false),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                minimumSize: const Size(120, 48)),
            child: const Text('Eliminar'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<AppState>().eliminar(id);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gasto eliminado.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final lista = app.egresosMes;
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            decoration:
                const BoxDecoration(gradient: AppGradients.gastoCard),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (Navigator.canPop(context))
                          IconButton(
                            icon: const Icon(Icons.arrow_back_rounded,
                                color: Colors.white),
                            tooltip: 'Volver al inicio',
                            onPressed: () =>
                                Navigator.pop(context),
                          ),
                        const Text('Gastos',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 48),
                      child: Text('Controla cada gasto',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 14)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text('GASTADO',
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800)),
                              Text(
                                  '\$${app.totalEgresos.toStringAsFixed(0)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              const Text('DISPONIBLE',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.grey)),
                              Text(
                                  '\$${app.saldo.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              children: [
                if (lista.isEmpty)
                  const EmptyState(
                    titulo: 'Sin gastos',
                    subtitulo: 'Registra tu primer gasto del mes.',
                    icono: Icons.receipt_long_outlined,
                  )
                else
                  Card(
                    child: Column(
                      children: [
                        for (var i = 0; i < lista.length; i++) ...[
                          Dismissible(
                            key: ValueKey(lista[i].id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).colorScheme.error,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              alignment: Alignment.centerRight,
                              padding:
                                  const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete_rounded,
                                  color: Colors.white),
                            ),
                            confirmDismiss: (_) async {
                              await _confirmarEliminar(context,
                                  lista[i].id, lista[i].descripcion);
                              return false;
                            },
                            child: MovimientoTile(
                              mov: lista[i],
                              onEdit: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => EgresoFormScreen(
                                        editar: lista[i])),
                              ),
                              onDelete: () => _confirmarEliminar(
                                  context,
                                  lista[i].id,
                                  lista[i].descripcion),
                            ),
                          ),
                          if (i != lista.length - 1)
                            const Divider(height: 1, indent: 68),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_rounded),
        label: const Text('Gasto'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EgresoFormScreen()),
        ),
      ),
    );
  }
}
