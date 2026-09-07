import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'category_icon.dart';

class MontoHeroField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  const MontoHeroField(
      {super.key,
      required this.controller,
      required this.validator,
      this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Monto',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600)),
          TextFormField(
            controller: controller,
            validator: validator,
            onChanged: onChanged,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            style: const TextStyle(
                fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -1),
            decoration: const InputDecoration(
              prefixText: '\$ ',
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              hintText: '0',
            ),
          ),
        ],
      ),
    );
  }
}

class CategoriaChips extends StatelessWidget {
  final List<String> categorias;
  final String actual;
  final ValueChanged<String> onSelect;
  const CategoriaChips(
      {super.key,
      required this.categorias,
      required this.actual,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categorias.map((c) {
        final sel = c == actual;
        return FilterChip(
          selected: sel,
          showCheckmark: false,
          avatar: Icon(CategoryIcon.iconFor(c, null),
              size: 18,
              color: sel
                  ? Theme.of(context).colorScheme.onPrimary
                  : CategoryIcon.colorFor(c, null)),
          label: Text(c),
          onSelected: (_) => onSelect(c),
        );
      }).toList(),
    );
  }
}
