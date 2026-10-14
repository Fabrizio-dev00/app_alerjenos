import 'package:flutter/material.dart';

import '../../app/theme.dart';

class GradientButton extends StatefulWidget {
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
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (widget.onPressed != null && !SanoMotion.reduced(context)) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    const style = TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: SanoColors.coffee);

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      excludeSemantics: true,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        child: Opacity(
          opacity: enabled ? 1 : 0.45,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: SanoColors.brandGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: enabled ? SanoShadows.brand : null,
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: widget.onPressed,
                onTapDown: (_) => _setPressed(true),
                onTapUp: (_) => _setPressed(false),
                onTapCancel: () => _setPressed(false),
                borderRadius: BorderRadius.circular(28),
                child: SizedBox(
                  height: 56,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, color: SanoColors.coffee),
                          const SizedBox(width: 10),
                        ],
                        Flexible(child: Text(widget.label, style: style, overflow: TextOverflow.ellipsis)),
                        if (widget.trailingArrow) ...[
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
        ),
      ),
    );
  }
}
