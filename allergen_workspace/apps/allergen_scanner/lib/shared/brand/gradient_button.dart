import 'package:flutter/material.dart';

import '../../app/theme.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingArrow = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool trailingArrow;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    const style = TextStyle(
      fontFamily: AppTheme.fontFamily,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: SanoColors.coffee,
    );

    return Semantics(
      button: true,
      enabled: enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: SanoColors.brandGradient,
            borderRadius: BorderRadius.circular(32),
            boxShadow: enabled
                ? [BoxShadow(color: SanoColors.orange.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 6))]
                : null,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(32),
              child: SizedBox(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[Icon(icon, color: SanoColors.coffee), const SizedBox(width: 10)],
                    Flexible(child: Text(label, style: style, overflow: TextOverflow.ellipsis)),
                    if (trailingArrow) ...[
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_forward, color: SanoColors.coffee),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
