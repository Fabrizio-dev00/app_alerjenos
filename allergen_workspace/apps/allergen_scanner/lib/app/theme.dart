import 'package:flutter/material.dart';

abstract final class SanoColors {
  static const orange = Color(0xFFEA6113);
  static const tangerine = Color(0xFFF88F22);
  static const amber = Color(0xFFFBB931);
  static const cream = Color(0xFFFFE3B3);
  static const coffee = Color(0xFF2A160A);
  static const contains = Color(0xFFC4161C);
  static const traces = Color(0xFFA55A00);

  static const paper = Color(0xFFFFF1DE);
  static const card = Color(0xFFFFFCF7);
  static const muted = Color(0xFF6B5546);
  static const line = Color(0xFFEADCC8);
  static const field = Color(0xFFF0E1C9);
  static const blush = Color(0xFFF4B6B0);

  static const brandGradient = LinearGradient(colors: [orange, tangerine, amber]);
}

class ResultColors extends ThemeExtension<ResultColors> {
  const ResultColors({
    required this.contains,
    required this.mayContain,
    required this.notDetected,
  });

  final Color contains;
  final Color mayContain;
  final Color notDetected;

  @override
  ResultColors copyWith({Color? contains, Color? mayContain, Color? notDetected}) {
    return ResultColors(
      contains: contains ?? this.contains,
      mayContain: mayContain ?? this.mayContain,
      notDetected: notDetected ?? this.notDetected,
    );
  }

  @override
  ResultColors lerp(ResultColors? other, double t) {
    if (other == null) return this;
    return ResultColors(
      contains: Color.lerp(contains, other.contains, t)!,
      mayContain: Color.lerp(mayContain, other.mayContain, t)!,
      notDetected: Color.lerp(notDetected, other.notDetected, t)!,
    );
  }
}

abstract final class AppTheme {
  static const fontFamily = 'Inter';

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: SanoColors.orange,
      onPrimary: SanoColors.coffee,
      primaryContainer: SanoColors.cream,
      onPrimaryContainer: SanoColors.coffee,
      secondary: SanoColors.tangerine,
      onSecondary: SanoColors.coffee,
      secondaryContainer: SanoColors.cream,
      onSecondaryContainer: SanoColors.coffee,
      tertiary: SanoColors.amber,
      onTertiary: SanoColors.coffee,
      error: SanoColors.contains,
      onError: Colors.white,
      errorContainer: Color(0xFFFBE1DF),
      onErrorContainer: Color(0xFF7A0D11),
      surface: SanoColors.paper,
      onSurface: SanoColors.coffee,
      onSurfaceVariant: SanoColors.muted,
      surfaceContainerLowest: SanoColors.card,
      surfaceContainerLow: SanoColors.card,
      surfaceContainer: SanoColors.card,
      surfaceContainerHigh: SanoColors.field,
      surfaceContainerHighest: SanoColors.field,
      outline: SanoColors.muted,
      outlineVariant: SanoColors.line,
    );

    final base = ThemeData(colorScheme: scheme, fontFamily: fontFamily);
    final text = base.textTheme.apply(bodyColor: SanoColors.coffee, displayColor: SanoColors.coffee);
    final pillShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(28));

    return base.copyWith(
      scaffoldBackgroundColor: SanoColors.paper,
      textTheme: text.copyWith(
        displaySmall: text.displaySmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -1),
        headlineLarge: text.headlineLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.8),
        headlineMedium: text.headlineMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.6),
        headlineSmall: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        bodyLarge: text.bodyLarge?.copyWith(fontSize: 16, height: 1.4),
        bodyMedium: text.bodyMedium?.copyWith(fontSize: 14, height: 1.4),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: SanoColors.paper,
        foregroundColor: SanoColors.coffee,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: SanoColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: SanoColors.line),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: pillShape,
          backgroundColor: SanoColors.orange,
          foregroundColor: SanoColors.coffee,
          textStyle: const TextStyle(fontFamily: fontFamily, fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: pillShape,
          backgroundColor: SanoColors.card,
          foregroundColor: SanoColors.coffee,
          side: const BorderSide(color: SanoColors.line),
          textStyle: const TextStyle(fontFamily: fontFamily, fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: SanoColors.traces),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SanoColors.field,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: SanoColors.card,
        indicatorColor: SanoColors.cream,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected) ? SanoColors.orange : SanoColors.muted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? SanoColors.orange : SanoColors.muted,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(color: SanoColors.line, space: 1),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? SanoColors.orange : SanoColors.line,
        ),
        thumbColor: const WidgetStatePropertyAll(Colors.white),
      ),
      snackBarTheme: const SnackBarThemeData(backgroundColor: SanoColors.coffee),
      extensions: const [
        ResultColors(
          contains: SanoColors.contains,
          mayContain: SanoColors.traces,
          notDetected: SanoColors.coffee,
        ),
      ],
    );
  }
}
