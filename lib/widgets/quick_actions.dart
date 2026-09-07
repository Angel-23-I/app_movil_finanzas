import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class QuickActionCard extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icono;
  final Gradient gradiente;
  final VoidCallback onTap;
  final bool pulsing;
  const QuickActionCard({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.gradiente,
    required this.onTap,
    this.pulsing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: gradiente,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppShadows.soft(const Color(0xFF1E2A5A)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: pulsing
                    ? TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.9, end: 1.1),
                        duration: const Duration(milliseconds: 800),
                        builder: (c, v, child) =>
                            Transform.scale(scale: v, child: child),
                        child: Icon(icono, color: Colors.white, size: 24),
                      )
                    : Icon(icono, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 10),
              Text(titulo,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14)),
              Text(subtitulo,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 11.5)),
            ],
          ),
        ),
      ),
    );
  }
}
