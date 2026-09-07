import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../services/voice_parser.dart';
import '../state/app_state.dart';
import '../widgets/form_widgets.dart';

class IngresoFormScreen extends StatefulWidget {
  const IngresoFormScreen({super.key});

  @override
  State<IngresoFormScreen> createState() => _IngresoFormScreenState();
}

class _IngresoFormScreenState extends State<IngresoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descCtrl = TextEditingController();
  final _montoCtrl = TextEditingController();
  String _categoria = 'mesada';
  DateTime _fecha = DateTime.now();
  final _categorias = const ['mesada', 'beca', 'trabajo', 'ventas', 'otro'];
  final SpeechToText _speech = SpeechToText();
  bool _escuchando = false;

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
          final parsed = VoiceParser.parseIngreso(r.recognizedWords);
          setState(() {
            _descCtrl.text = parsed.descripcion;
            if (_categorias.contains(parsed.categoria)) {
              _categoria = parsed.categoria;
            }
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

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    final monto = double.tryParse(_montoCtrl.text.replaceAll(',', '.'));
    final app = context.read<AppState>();
    final err = app.agregarIngreso(
      descripcion: _descCtrl.text,
      categoria: _categoria,
      monto: monto,
      fecha: _fecha,
    );
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ingreso guardado. Saldo actualizado.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar ingreso')),
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
                    color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _escuchando ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: _escuchando
                        ? Theme.of(context).colorScheme.error
                        : const Color(0xFF16A34A),
                  ),
                ),
                title: Text(
                    _escuchando ? 'Escuchando...' : 'Dictar ingreso por voz',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text(
                    'Ej. "recibi ocho mil de mesada"'),
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
            MontoHeroField(
              controller: _montoCtrl,
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
            const SizedBox(height: 14),
            const Text('Descripción',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                hintText: 'Ej. Mesada septiembre',
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
              categorias: _categorias,
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
            label: const Text('Guardar ingreso'),
            onPressed: _guardar,
          ),
        ),
      ),
    );
  }
}
