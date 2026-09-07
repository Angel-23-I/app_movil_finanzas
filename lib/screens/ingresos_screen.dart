import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/movimiento_tile.dart';
import '../widgets/empty_state.dart';
import 'ingreso_form_screen.dart';

class IngresosScreen extends StatelessWidget {
  const IngresosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final lista = app.ingresosMes;
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            decoration:
                const BoxDecoration(gradient: AppGradients.ingresoCard),
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
                        const Text('Ingresos',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900)),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 48),
                      child: Text('Tu dinero del mes',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 14)),
                    ),
                    const SizedBox(height: 12),
                    Text('\$${app.totalIngresos.toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w900)),
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
                    titulo: 'Sin ingresos',
                    subtitulo:
                        'Agrega tu mesada, beca o trabajo del mes.',
                    icono: Icons.savings_outlined,
                  )
                else
                  Card(
                    child: Column(
                      children: [
                        for (var i = 0; i < lista.length; i++) ...[
                          MovimientoTile(mov: lista[i]),
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
        label: const Text('Ingreso'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const IngresoFormScreen()),
        ),
      ),
    );
  }
}
