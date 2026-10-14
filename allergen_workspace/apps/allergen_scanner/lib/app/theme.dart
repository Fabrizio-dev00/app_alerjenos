import 'package:flutter/material.dart';

abstract final class SanoColors {
  static const orange = Color(0xFFEA6113);
  static const tangerine = Color(0xFFF88F22);
  static const amber = Color(0xFFFBB931);
  static const cream = Color(0xFFFFE3B3);
  static const coffee = Color(0xFF2A160A);
  static const contains = Color(0xFFC4161C);
  static const traces = Color(0xFFA55A00);
  static const tracesBg = Color(0xFFFFF0D6);

  static const paper = Color(0xFFFFF1D9);
  static const card = Color(0xFFFFFDF8);
  static const muted = Color(0xFF5B4A40);
  static const accent = Color(0xFFA83F00);
  static const tabActive = Color(0xFFA83F00);
  static const line = Color(0x242A160A);
  static const field = Color(0xFFEFDDC2);
  static const blush = Color(0xFFF4B6B0);
  static const darkGlow = Color(0xFF3A2F2A);
  static const proGlow = Color(0xFF7A3A12);

  static const brandGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [orange, tangerine, amber],
  );

  static const darkBackground = RadialGradient(
    center: Alignment.topCenter,
    radius: 1.2,
    colors: [darkGlow, coffee],
  );

  static const proBackground = RadialGradient(
    center: Alignment(-0.4, -0.7),
    radius: 1.1,
    colors: [proGlow, coffee],
  );
}

abstract final class SanoShadows {
  static const soft = [
    BoxShadow(color: Color(0x0F2A160A), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x1A2A160A), blurRadius: 24, offset: Offset(0, 8)),
  ];

  static const brand = [
    BoxShadow(color: Color(0x59EA6113), blurRadius: 24, offset: Offset(0, 8)),
  ];
}

abstract final class SanoMotion {
  static const sheet = Cubic(.22, 1, .36, 1);
  static const pop = Cubic(.34, 1.56, .64, 1);

  static bool reduced(BuildContext context) => MediaQuery.maybeDisableAnimationsOf(context) ?? false;
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

    final base = ThemeData(colorScheme: scheme);
    final text = base.textTheme.apply(bodyColor: SanoColors.coffee, displayColor: SanoColors.coffee);
    final pillShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(28));
    const buttonText = TextStyle(fontSize: 17, fontWeight: FontWeight.w700);

    return base.copyWith(
      scaffoldBackgroundColor: SanoColors.paper,
      textTheme: text.copyWith(
        displaySmall: text.displaySmall?.copyWith(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -0.7),
        headlineLarge: text.headlineLarge?.copyWith(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -0.7),
        headlineMedium: text.headlineMedium?.copyWith(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        headlineSmall: text.headlineSmall?.copyWith(fontSize: 22, fontWeight: FontWeight.w800),
        titleLarge: text.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
        titleMedium: text.titleMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
        titleSmall: text.titleSmall?.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
        bodyLarge: text.bodyLarge?.copyWith(fontSize: 17, height: 1.4),
        bodyMedium: text.bodyMedium?.copyWith(fontSize: 15, height: 1.4),
        bodySmall: text.bodySmall?.copyWith(fontSize: 14, height: 1.4, color: SanoColors.muted),
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
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          shape: pillShape,
          backgroundColor: SanoColors.card,
          foregroundColor: SanoColors.coffee,
          side: const BorderSide(color: SanoColors.line),
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: SanoColors.accent,
          minimumSize: const Size(48, 48),
          textStyle: buttonText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SanoColors.field,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: const TextStyle(color: SanoColors.muted, fontSize: 17),
      ),
      dividerTheme: const DividerThemeData(color: SanoColors.line, space: 1, thickness: 1),
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? SanoColors.orange : SanoColors.field,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        thumbColor: const WidgetStatePropertyAll(Colors.white),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: SanoColors.coffee,
        behavior: SnackBarBehavior.floating,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: SanoColors.paper,
        showDragHandle: true,
        dragHandleColor: Color(0x552A160A),
        dragHandleSize: Size(44, 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(36))),
      ),
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
