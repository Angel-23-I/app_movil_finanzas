import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/budget_service.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/hero_balance_card.dart';
import '../widgets/estado_banner.dart';
import '../widgets/movimiento_tile.dart';
import '../widgets/empty_state.dart';
import '../widgets/quick_actions.dart';
import '../widgets/voice_entry_button.dart';
import 'ingreso_form_screen.dart';
import 'egreso_form_screen.dart';
import 'ingresos_screen.dart';
import 'egresos_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _mesTitulo(AppState app) {
    if (app.nombreMes.trim().isNotEmpty) return app.nombreMes.trim();
    final partes = app.mesActivo.split('-');
    if (partes.length == 2) return '${partes[1]} / ${partes[0]}';
    return app.mesActivo;
  }

  String _frase(EstadoPresupuesto e) {
    switch (e) {
      case EstadoPresupuesto.sinIngresos:
        return 'Empieza con tu primer ingreso';
      case EstadoPresupuesto.saludable:
        return 'Vas excelente, sigue ahorrando';
      case EstadoPresupuesto.precaucion:
        return 'Cuida tus gastos esta semana';
      case EstadoPresupuesto.critica:
        return 'Evita gastos innecesarios hoy';
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    if (app.cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final ultimos = app.movimientosMes.take(5).toList();
    final esCritico = app.estado == EstadoPresupuesto.critica;
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppGradients.header),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Hola, ${app.alias}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900)),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                    _mesTitulo(app),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        const VoiceEntryButton(),
                        const SizedBox(width: 8),
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.notifications_rounded,
                                  color: Colors.white),
                            ),
                            if (esCritico)
                              Positioned(
                                right: 10,
                                top: 10,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: AppColors.critica,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_frase(app.estado),
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              children: [
                HeroBalanceCard(
                  saldo: app.saldo,
                  ingresos: app.totalIngresos,
                  egresos: app.totalEgresos,
                  porcentaje: app.porcentaje,
                ),
                const SizedBox(height: 12),
                EstadoBanner(
                    estado: app.estado, porcentaje: app.porcentaje),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: QuickActionCard(
                        titulo: 'Agregar ingreso',
                        subtitulo: '+ Ingreso',
                        icono: Icons.add_rounded,
                        gradiente: AppGradients.ingresoCard,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const IngresoFormScreen()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: QuickActionCard(
                        titulo: 'Agregar gasto',
                        subtitulo: '- Gasto',
                        icono: Icons.remove_rounded,
                        gradiente: AppGradients.gastoCard,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const EgresoFormScreen()),
                        ),
                      ),
                    ),

                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Movimientos recientes',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900)),
                    TextButton(
                      child: const Text('Ver todos'),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EgresosScreen()),
                      ),
                    ),
                  ],
                ),
                if (ultimos.isEmpty)
                  const EmptyState(
                    titulo: 'Sin movimientos',
                    subtitulo:
                        'Agrega tu primer ingreso o gasto para ver tu resumen.',
                  )
                else
                  Card(
                    child: Column(
                      children: [
                        for (var i = 0;
                            i < ultimos.length;
                            i++) ...[
                          MovimientoTile(mov: ultimos[i]),
                          if (i != ultimos.length - 1)
                            const Divider(height: 1, indent: 68),
                        ],
                      ],
                    ),
                  ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const IngresosScreen()),
                  ),
                  child: const Text('Ver ingresos'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
