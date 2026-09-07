import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/movimiento.dart';
import '../state/app_state.dart';
import 'alerta_presupuesto.dart';
import 'category_icon.dart';

class VoiceResultSheet extends StatefulWidget {
  final String descripcion;
  final double? monto;
  final String categoriaEgreso;
  final String categoriaIngreso;
  final bool esIngreso;
  final String frase;
  const VoiceResultSheet({
    super.key,
    required this.descripcion,
    required this.monto,
    required this.categoriaEgreso,
    required this.categoriaIngreso,
    required this.esIngreso,
    required this.frase,
  });

  @override
  State<VoiceResultSheet> createState() => _VoiceResultSheetState();
}

class _VoiceResultSheetState extends State<VoiceResultSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descCtrl;
  late TextEditingController _montoCtrl;
  late bool _esIngreso;
  late String _categoria;
  final _catsIngreso = const ['mesada', 'beca', 'trabajo', 'ventas', 'otro'];

  @override
  void initState() {
    super.initState();
    _esIngreso = widget.esIngreso;
    _categoria =
        _esIngreso ? widget.categoriaIngreso : widget.categoriaEgreso;
    _descCtrl = TextEditingController(text: widget.descripcion);
    _montoCtrl = TextEditingController(
        text: widget.monto != null
            ? widget.monto!.toStringAsFixed(0)
            : '');
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _montoCtrl.dispose();
    super.dispose();
  }

  List<String> get _cats =>
      _esIngreso ? _catsIngreso : Movimiento.categoriasEgreso;

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final monto =
        double.tryParse(_montoCtrl.text.replaceAll(',', '.'));
    final app = context.read<AppState>();
    String? err;
    if (_esIngreso) {
      err = app.agregarIngreso(
        descripcion: _descCtrl.text,
        categoria: _categoria,
        monto: monto,
        fecha: DateTime.now(),
      );
    } else {
      err = app.agregarEgreso(
        descripcion: _descCtrl.text,
        categoria: _categoria,
        monto: monto,
        fecha: DateTime.now(),
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_esIngreso
            ? 'Ingreso guardado por voz.'
            : 'Gasto guardado por voz.')));
    if (!_esIngreso) {
      await mostrarAlertaSiNecesario(context, app);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.mic_rounded,
                        color: Color(0xFF7C3AED)),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('Revisa y confirma',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 18)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('Escuché: "${widget.frase}"',
                  style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                      fontSize: 13)),
              const SizedBox(height: 14),
              DropdownButtonFormField<bool>(
                initialValue: _esIngreso,
                decoration: const InputDecoration(
                  labelText: 'Tipo de movimiento',
                  prefixIcon: Icon(Icons.swap_vert_rounded),
                ),
                items: const [
                  DropdownMenuItem(
                      value: false, child: Text('Gasto')),
                  DropdownMenuItem(
                      value: true, child: Text('Ingreso')),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    _esIngreso = v;
                    _categoria = v
                        ? widget.categoriaIngreso
                        : widget.categoriaEgreso;
                    if (!_cats.contains(_categoria)) {
                      _categoria = _cats.first;
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: Icon(Icons.edit_outlined),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Escribe una descripción.'
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _montoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  prefixText: '\$ ',
                  prefixIcon: Icon(Icons.attach_money_rounded),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'[0-9.,]')),
                ],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Escribe un monto válido.';
                  }
                  final m =
                      double.tryParse(v.replaceAll(',', '.'));
                  if (m == null) {
                    return 'Escribe un monto válido.';
                  }
                  if (m <= 0) {
                    return 'El monto debe ser mayor que cero.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Categoría',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _cats.map((c) {
                  final sel = c == _categoria;
                  return FilterChip(
                    selected: sel,
                    showCheckmark: false,
                    avatar: Icon(
                        CategoryIcon.iconFor(
                            c,
                            _esIngreso
                                ? TipoMovimiento.ingreso
                                : TipoMovimiento.egreso),
                        size: 18,
                        color: sel
                            ? Theme.of(context)
                                .colorScheme
                                .onPrimary
                            : CategoryIcon.colorFor(c, null)),
                    label: Text(c),
                    onSelected: (_) =>
                        setState(() => _categoria = c),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.check_rounded),
                label: Text(_esIngreso
                    ? 'Guardar ingreso'
                    : 'Guardar gasto'),
                onPressed: _guardar,
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
