import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movimiento.dart';
import '../state/app_state.dart';

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  late TextEditingController _aliasCtrl;
  late TextEditingController _nombreMesCtrl;
  late bool _oscuro;
  late int _acento;
  late String _mes;
  bool _init = false;

  final _acentos = const [
    {'nombre': 'Azul', 'valor': 0xFF1565C0},
    {'nombre': 'Verde', 'valor': 0xFF16A34A},
    {'nombre': 'Morado', 'valor': 0xFF7C3AED},
    {'nombre': 'Naranja', 'valor': 0xFFEA580C},
  ];

  List<String> _ultimosMeses() {
    final ahora = DateTime.now();
    return List.generate(6, (i) {
      final d = DateTime(ahora.year, ahora.month - i, 1);
      return Movimiento.monthKeyFrom(d);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_init) {
      final app = context.read<AppState>();
      _aliasCtrl = TextEditingController(text: app.alias);
      _nombreMesCtrl = TextEditingController(text: app.nombreMes);
      _oscuro = app.temaOscuro;
      _acento = app.colorAcento;
      _mes = app.mesActivo;
      _init = true;
    }
  }

  @override
  void dispose() {
    _aliasCtrl.dispose();
    _nombreMesCtrl.dispose();
    super.dispose();
  }

  void _aplicar(AppState app) {
    app.actualizarAjustes(
      nuevoAlias: _aliasCtrl.text,
      oscuro: _oscuro,
      acento: _acento,
      nombreMesNuevo: _nombreMesCtrl.text,
    );
    if (_mes != app.mesActivo) app.cambiarMes(_mes);
  }

  Widget _seccion(String titulo, List<Widget> hijos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(titulo.toUpperCase(),
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.1,
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(children: hijos),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F172A), Color(0xFF334155)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.settings_rounded,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ajustes',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900)),
                            Text('Personaliza tu app',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Padding(
            padding:
                const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  children: [
                    _seccion('Perfil', [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.15),
                          child: Text(
                              _aliasCtrl.text.isEmpty
                                  ? 'E'
                                  : _aliasCtrl.text[0].toUpperCase(),
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary,
                                  fontWeight: FontWeight.w800)),
                        ),
                        title: const Text('Alias del estudiante',
                            style:
                                TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: TextField(
                          controller: _aliasCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Ej. David',
                            filled: false,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (_) {
                            setState(() {});
                            _aplicar(app);
                          },
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _seccion('Apariencia', [
                      SwitchListTile(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        title: const Text('Tema oscuro',
                            style:
                                TextStyle(fontWeight: FontWeight.w700)),
                        subtitle:
                            Text(_oscuro ? 'Activado' : 'Desactivado'),
                        secondary: Icon(_oscuro
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded),
                        value: _oscuro,
                        onChanged: (v) {
                          setState(() => _oscuro = v);
                          _aplicar(app);
                        },
                      ),
                      const Divider(indent: 16, endIndent: 16),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16, 8, 16, 12),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text('Color de acento',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 10),
                            Row(
                              children: _acentos.map((c) {
                                final valor = c['valor'] as int;
                                final sel = valor == _acento;
                                return GestureDetector(
                                  onTap: () {
                                    setState(
                                        () => _acento = valor);
                                    _aplicar(app);
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 12),
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: Color(valor),
                                      shape: BoxShape.circle,
                                      border: sel
                                          ? Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                              width: 2.5)
                                          : null,
                                      boxShadow: sel
                                          ? [
                                              BoxShadow(
                                                  color: Color(valor)
                                                      .withValues(
                                                          alpha: 0.4),
                                                  blurRadius: 10)
                                            ]
                                          : null,
                                    ),
                                    child: sel
                                        ? const Icon(
                                            Icons.check_rounded,
                                            color: Colors.white)
                                        : null,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _seccion('Mes activo', [
                      ListTile(
                        leading: const Icon(
                            Icons.calendar_month_rounded),
                        title: const Text('Mes',
                            style:
                                TextStyle(fontWeight: FontWeight.w700)),
                        trailing: DropdownButton<String>(
                          value: _ultimosMeses().contains(_mes)
                              ? _mes
                              : _ultimosMeses().first,
                          underline: const SizedBox(),
                          items: _ultimosMeses()
                              .map((m) => DropdownMenuItem(
                                  value: m, child: Text(m)))
                              .toList(),
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _mes = v);
                            _aplicar(app);
                          },
                        ),
                      ),
                      const Divider(indent: 16, endIndent: 16),
                      ListTile(
                        leading: const Icon(
                            Icons.celebration_rounded),
                        title: const Text('Nombre o emoji',
                            style:
                                TextStyle(fontWeight: FontWeight.w700)),
                        subtitle: TextField(
                          controller: _nombreMesCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Ej. Septiembre',
                            filled: false,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (_) => _aplicar(app),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                          'Los cambios se aplican al instante.',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 12)),
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
