import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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

  @override
  void dispose() {
    _descCtrl.dispose();
    _montoCtrl.dispose();
    super.dispose();
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
