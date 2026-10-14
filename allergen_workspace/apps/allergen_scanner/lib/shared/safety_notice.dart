import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../app/theme.dart';
import '../l10n/generated/app_localizations.dart';

class SafetyNotice extends StatelessWidget {
  const SafetyNotice({this.dark = false, super.key});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final foreground = dark ? SanoColors.card : SanoColors.coffee;

    return Semantics(
      container: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: BoxDecoration(
          color: dark ? SanoColors.coffee : SanoColors.card,
          borderRadius: BorderRadius.circular(22),
          border: dark ? null : Border.all(color: SanoColors.line),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(LucideIcons.info, color: foreground),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppLocalizations.of(context).safetyNotice,
                style: TextStyle(color: foreground, fontSize: 16, fontWeight: FontWeight.w600, height: 1.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
