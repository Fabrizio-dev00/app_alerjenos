import 'package:flutter/material.dart';

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
  static const _seed = Color(0xFF1F6F5C);

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
    final isDark = brightness == Brightness.dark;
    final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));

    return ThemeData(
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56), shape: buttonShape),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56), shape: buttonShape),
      ),
      extensions: [
        ResultColors(
          contains: isDark ? const Color(0xFFFF8A80) : const Color(0xFFB3261E),
          mayContain: isDark ? const Color(0xFFFFCC80) : const Color(0xFF9A5B00),
          notDetected: isDark ? const Color(0xFFB0BEC5) : const Color(0xFF455A64),
        ),
      ],
    );
  }
}
