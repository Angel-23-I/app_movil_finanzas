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
    {'nombre': 'Verde', 'valor': 0xFF2E7D32},
    {'nombre': 'Morado', 'valor': 0xFF6A1B9A},
    {'nombre': 'Naranja', 'valor': 0xFFEF6C00},
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

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Alias del estudiante'),
          const SizedBox(height: 4),
          TextField(
            controller: _aliasCtrl,
            decoration: const InputDecoration(
              hintText: 'Ej. Angel',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _aplicar(app),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Tema oscuro'),
            value: _oscuro,
            onChanged: (v) {
              setState(() => _oscuro = v);
              _aplicar(app);
            },
          ),
          const SizedBox(height: 8),
          const Text('Color de acento'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _acentos.map((c) {
              final valor = c['valor'] as int;
              final sel = valor == _acento;
              return ChoiceChip(
                label: Text(c['nombre'] as String),
                selected: sel,
                onSelected: (_) {
                  setState(() => _acento = valor);
                  _aplicar(app);
                },
                avatar: CircleAvatar(backgroundColor: Color(valor), radius: 10),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('Mes activo'),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            initialValue: _ultimosMeses().contains(_mes) ? _mes : _ultimosMeses().first,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: _ultimosMeses()
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            onChanged: (v) {
              if (v == null) return;
              setState(() => _mes = v);
              _aplicar(app);
            },
          ),
          const SizedBox(height: 12),
          const Text('Nombre o emoji del mes'),
          const SizedBox(height: 4),
          TextField(
            controller: _nombreMesCtrl,
            decoration: const InputDecoration(
              hintText: 'Ej. Septiembre 🎓',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _aplicar(app),
          ),
          const SizedBox(height: 16),
          const Text('Los cambios se aplican y guardan al instante.'),
        ],
      ),
    );
  }
}
