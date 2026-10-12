import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.paywallTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(l10n.paywallDescription, style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}
