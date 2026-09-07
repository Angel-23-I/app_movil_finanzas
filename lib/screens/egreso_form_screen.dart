import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../models/movimiento.dart';
import '../services/voice_parser.dart';
import '../state/app_state.dart';
import '../widgets/alerta_presupuesto.dart';

class EgresoFormScreen extends StatefulWidget {
  final Movimiento? editar;
  final String? descInicial;
  final String? catInicial;
  final double? montoInicial;
  const EgresoFormScreen({super.key, this.editar, this.descInicial, this.catInicial, this.montoInicial});

  @override
  State<EgresoFormScreen> createState() => _EgresoFormScreenState();
}

class _EgresoFormScreenState extends State<EgresoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descCtrl;
  late TextEditingController _montoCtrl;
  late String _categoria;
  late DateTime _fecha;
  final SpeechToText _speech = SpeechToText();
  bool _escuchando = false;

  @override
  void initState() {
    super.initState();
    final e = widget.editar;
    _descCtrl = TextEditingController(text: e?.descripcion ?? widget.descInicial ?? '');
    _montoCtrl = TextEditingController(
        text: e != null ? e.monto.toStringAsFixed(0) : (widget.montoInicial?.toStringAsFixed(0) ?? ''));
    final cat = (e?.categoria ?? widget.catInicial ?? 'otro').toLowerCase();
    _categoria = Movimiento.categoriasEgreso.contains(cat) ? cat : 'otro';
    _fecha = e?.fecha ?? DateTime.now();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _montoCtrl.dispose();
    super.dispose();
  }

  Future<void> _escuchar() async {
    final disponible = await _speech.initialize();
    if (!disponible) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Micrófono no disponible.')));
      return;
    }
    setState(() => _escuchando = true);
    await _speech.listen(
      listenOptions: SpeechListenOptions(localeId: 'es_ES'),
      onResult: (r) {
        if (r.finalResult) {
          final parsed = VoiceParser.parse(r.recognizedWords);
          setState(() {
            _descCtrl.text = parsed.descripcion;
            _categoria = parsed.categoria;
            if (parsed.monto != null) {
              _montoCtrl.text = parsed.monto!.toStringAsFixed(0);
            }
            _escuchando = false;
          });
          _speech.stop();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                    'Voz: "${r.recognizedWords}". Revisa y confirma.')));
          }
        }
      },
    );
  }

  Future<void> _elegirFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _fecha = picked);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final monto = double.tryParse(_montoCtrl.text.replaceAll(',', '.'));
    final app = context.read<AppState>();
    String? err;
    if (widget.editar == null) {
      err = app.agregarEgreso(
        descripcion: _descCtrl.text,
        categoria: _categoria,
        monto: monto,
        fecha: _fecha,
      );
    } else {
      err = app.editarEgreso(
        widget.editar!.id,
        descripcion: _descCtrl.text,
        categoria: _categoria,
        monto: monto,
        fecha: _fecha,
      );
    }
    if (err != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    Navigator.pop(context);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.editar == null ? 'Egreso guardado.' : 'Egreso actualizado.')),
    );
    await mostrarAlertaSiNecesario(context, app);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final esEdicion = widget.editar != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar egreso' : 'Agregar egreso'),
        actions: [
          IconButton(
            icon: Icon(_escuchando ? Icons.mic : Icons.mic_none),
            tooltip: 'Dictar gasto',
            onPressed: _escuchando ? () async => await _speech.stop().then((_) => setState(() => _escuchando = false)) : _escuchar,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: Text('Saldo disponible: \$${app.saldo.toStringAsFixed(0)}'),
                subtitle: Text('Máximo permitido: \$${app.saldo.toStringAsFixed(0)}'),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Ej. Almuerzo universidad',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Escribe una descripción.' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _categoria,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
              ),
              items: Movimiento.categoriasEgreso
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _categoria = v ?? 'otro'),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Elige una categoría.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _montoCtrl,
              decoration: const InputDecoration(
                labelText: 'Monto',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Escribe un monto válido.';
                final m = double.tryParse(v.replaceAll(',', '.'));
                if (m == null) return 'Escribe un monto válido.';
                if (m <= 0) return 'El monto debe ser mayor que cero.';
                return null;
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Fecha: ${DateFormat('dd/MM/yyyy').format(_fecha)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: _elegirFecha,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.save),
              label: Text(esEdicion ? 'Guardar cambios' : 'Guardar egreso'),
              onPressed: _guardar,
            ),
          ],
        ),
      ),
    );
  }
}
