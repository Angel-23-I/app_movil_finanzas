import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../services/voice_parser.dart';
import 'voice_result_sheet.dart';

class VoiceEntryButton extends StatefulWidget {
  final double size;
  const VoiceEntryButton({super.key, this.size = 48});

  @override
  State<VoiceEntryButton> createState() => _VoiceEntryButtonState();
}

class _VoiceEntryButtonState extends State<VoiceEntryButton> {
  final SpeechToText _speech = SpeechToText();
  bool _escuchando = false;

  Future<void> _toggle() async {
    if (_escuchando) {
      await _speech.stop();
      if (mounted) setState(() => _escuchando = false);
      return;
    }
    final disponible = await _speech.initialize();
    if (!disponible) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Micrófono no disponible.')));
      return;
    }
    setState(() => _escuchando = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Escuchando... Di tu ingreso o gasto.'),
          duration: Duration(seconds: 2)));
    }
    await _speech.listen(
      listenOptions: SpeechListenOptions(localeId: 'es_ES'),
      onResult: (r) async {
        if (!r.finalResult) return;
        final frase = r.recognizedWords;
        await _speech.stop();
        if (!mounted) return;
        setState(() => _escuchando = false);
        if (frase.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('No te escuché, intenta de nuevo.')));
          return;
        }
        final gasto = VoiceParser.parse(frase);
        final ingreso = VoiceParser.parseIngreso(frase);
        final esIngreso =
            _pareceIngreso(frase.toLowerCase());
        final desc = esIngreso
            ? ingreso.descripcion
            : gasto.descripcion;
        final monto = esIngreso
            ? ingreso.monto ?? gasto.monto
            : gasto.monto ?? ingreso.monto;
        if (!mounted) return;
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) => VoiceResultSheet(
            descripcion: desc,
            monto: monto,
            categoriaEgreso: gasto.categoria,
            categoriaIngreso: ingreso.categoria,
            esIngreso: esIngreso,
            frase: frase,
          ),
        );
      },
    );
  }

  bool _pareceIngreso(String t) {
    return t.contains('ingreso') ||
        t.contains('recibi') ||
        t.contains('mesada') ||
        t.contains('beca') ||
        t.contains('sueldo') ||
        t.contains('salario') ||
        t.contains('cobro') ||
        t.contains('pagan') ||
        t.contains('venta');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: _escuchando
              ? Border.all(color: Colors.white, width: 2.5)
              : null,
        ),
        child: _escuchando
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor:
                      AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : const Icon(Icons.mic_rounded,
                color: Colors.white),
      ),
    );
  }
}
