import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../models/movimiento.dart';
import '../services/voice_parser.dart';
import '../state/app_state.dart';
import '../widgets/alerta_presupuesto.dart';
import '../widgets/form_widgets.dart';

class EgresoFormScreen extends StatefulWidget {
  final Movimiento? editar;
  final String? descInicial;
  final String? catInicial;
  final double? montoInicial;
  const EgresoFormScreen(
      {super.key,
      this.editar,
      this.descInicial,
      this.catInicial,
      this.montoInicial});

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
    _descCtrl =
        TextEditingController(text: e?.descripcion ?? widget.descInicial ?? '');
    _montoCtrl = TextEditingController(
        text: e != null
            ? e.monto.toStringAsFixed(0)
            : (widget.montoInicial?.toStringAsFixed(0) ?? ''));
    final cat = (e?.categoria ?? widget.catInicial ?? 'otro').toLowerCase();
    _categoria =
        Movimiento.categoriasEgreso.contains(cat) ? cat : 'otro';
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    Navigator.pop(context);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(widget.editar == null
              ? 'Gasto guardado.'
              : 'Gasto actualizado.')),
    );
    await mostrarAlertaSiNecesario(context, app);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final esEdicion = widget.editar != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar gasto' : 'Agregar gasto'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _escuchando ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: _escuchando
                        ? Theme.of(context).colorScheme.error
                        : const Color(0xFF7C3AED),
                  ),
                ),
                title: Text(
                    _escuchando ? 'Escuchando...' : 'Dictar gasto por voz',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text(
                    'Ej. "gaste ocho mil en transporte"'),
                trailing: _escuchando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : const Icon(Icons.chevron_right_rounded),
                onTap: _escuchando
                    ? () async => await _speech.stop().then((_) =>
                        setState(() => _escuchando = false))
                    : _escuchar,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text(
                      'Disponible \$${app.saldo.toStringAsFixed(0)} · Máx \$${app.saldo.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            MontoHeroField(
              controller: _montoCtrl,
              onChanged: (_) => setState(() {}),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Escribe un monto válido.';
                }
                final m = double.tryParse(v.replaceAll(',', '.'));
                if (m == null) return 'Escribe un monto válido.';
                if (m <= 0) return 'El monto debe ser mayor que cero.';
                return null;
              },
            ),
            Builder(
              builder: (context) {
                final m = double.tryParse(
                    _montoCtrl.text.replaceAll(',', '.'));
                double limite = app.saldo;
                if (widget.editar != null) {
                  limite += widget.editar!.monto;
                }
                if (m != null && m > limite) {
                  return Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE2E2),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: const Color(0xFFDC2626), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Text('⚠️',
                            style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text('Saldo insuficiente',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFDC2626),
                                      fontSize: 16)),
                              Text(
                                  'Puedes gastar máximo:\n\$${limite.toStringAsFixed(0)}. Este gasto será bloqueado.',
                                  style: const TextStyle(
                                      color: Color(0xFF7F1D1D))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 14),
            const Text('Descripción',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                hintText: 'Ej. Almuerzo universidad',
                prefixIcon: Icon(Icons.edit_outlined),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Escribe una descripción.'
                  : null,
            ),
            const SizedBox(height: 14),
            const Text('Categoría',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            CategoriaChips(
              categorias: Movimiento.categoriasEgreso,
              actual: _categoria,
              onSelect: (c) => setState(() => _categoria = c),
            ),
            const SizedBox(height: 14),
            const Text('Fecha',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_month_rounded),
                title: Text(DateFormat('dd MMM yyyy', 'es').format(_fecha),
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: _elegirFecha,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton.icon(
            icon: const Icon(Icons.check_rounded),
            label: Text(esEdicion ? 'Guardar cambios' : 'Guardar gasto'),
            onPressed: _guardar,
          ),
        ),
      ),
    );
  }
}
