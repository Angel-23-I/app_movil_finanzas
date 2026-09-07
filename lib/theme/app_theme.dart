import 'package:flutter/material.dart';

class AppColors {
  static const ingreso = Color(0xFF16A34A);
  static const ingresoSoft = Color(0xFFE7F6EC);
  static const egreso = Color(0xFFFF5A5F);
  static const egresoSoft = Color(0xFFFFE9EA);
  static const precaucion = Color(0xFFF59E0B);
  static const precaucionSoft = Color(0xFFFFF3D6);
  static const critica = Color(0xFFDC2626);
  static const criticaSoft = Color(0xFFFFE2E2);
  static const saludable = Color(0xFF16A34A);
  static const voz = Color(0xFF7C3AED);
  static const headerStart = Color(0xFF2563EB);
  static const headerEnd = Color(0xFF7C3AED);
}

class AppRadius {
  static const card = 22.0;
  static const input = 16.0;
}

class AppShadows {
  static List<BoxShadow> soft(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.18),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ];
  static List<BoxShadow> card(bool oscuro) => [
        BoxShadow(
          color: (oscuro ? Colors.black : const Color(0xFF1E2A5A))
              .withValues(alpha: oscuro ? 0.4 : 0.06),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];
}

class AppGradients {
  static const header = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.headerStart, AppColors.headerEnd],
  );
  static const balance = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1D4ED8), Color(0xFF7C3AED)],
  );
  static const ingresoCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
  );
  static const gastoCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF5A5F), Color(0xFFFF8A5C)],
  );
  static const vozCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
  );
}

class AppTheme {
  static ThemeData build(Color acento, bool oscuro) {
    final scheme = ColorScheme.fromSeed(
      seedColor: acento,
      brightness: oscuro ? Brightness.dark : Brightness.light,
    );
    final base = ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor:
          oscuro ? const Color(0xFF0B0E17) : const Color(0xFFF2F4FA),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          for (final p in TargetPlatform.values)
            p: const PredictiveBackPageTransitionsBuilder(),
        },
      ),
    );
    return base.copyWith(
      cardTheme: CardThemeData(
        elevation: oscuro ? 0 : 3,
        shadowColor:
            const Color(0xFF1E2A5A).withValues(alpha: 0.12),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(
            color: oscuro ? Colors.white10 : const Color(0xFFE6E9F2),
          ),
        ),
        color: oscuro ? const Color(0xFF141A2B) : Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: oscuro ? const Color(0xFF1C2338) : const Color(0xFFF1F3F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.critica),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18)),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: oscuro ? const Color(0xFF121829) : Colors.white,
        indicatorColor: scheme.primary.withValues(alpha: 0.16),
        labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        elevation: 8,
      ),
    );
  }
}
