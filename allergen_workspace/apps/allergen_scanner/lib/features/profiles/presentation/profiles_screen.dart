import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/profile.dart';
import 'allergen_labels.dart';
import 'profiles_providers.dart';

class ProfilesScreen extends ConsumerWidget {
  const ProfilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profiles = ref.watch(profilesProvider).value ?? const <Profile>[];
    final active = ref.watch(activeProfileProvider);
    final canAdd = ref.watch(canAddProfileProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profilesTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          for (final profile in profiles) ...[
            ProfileCard(
              profile: profile,
              active: profile.id == active?.id,
              onTap: () => context.push(AppRoutes.profileEditor(profile.id)),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => canAdd ? context.push(AppRoutes.newProfile) : context.push(AppRoutes.paywall),
            icon: Icon(canAdd ? Icons.add : Icons.star_outline),
            label: Text(l10n.addProfile),
          ),
          if (!canAdd) ...[
            const SizedBox(height: 12),
            Text(l10n.profilesProHint, textAlign: TextAlign.center, style: const TextStyle(color: SanoColors.muted)),
          ],
        ],
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({required this.profile, required this.active, required this.onTap, this.caption, super.key});

  final Profile profile;
  final bool active;
  final VoidCallback onTap;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final initial = profile.name.isEmpty ? '?' : profile.name.characters.first.toUpperCase();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: SanoColors.traces, width: 3),
                ),
                child: Text(
                  initial,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: SanoColors.traces),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (caption != null) Text(caption!, style: textTheme.bodyMedium?.copyWith(color: SanoColors.muted)),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile.name,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        if (active && caption == null) ...[
                          const SizedBox(width: 8),
                          Chip(
                            label: Text(l10n.profileActiveBadge),
                            visualDensity: VisualDensity.compact,
                            backgroundColor: SanoColors.cream,
                            side: BorderSide.none,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(profile.summary(l10n), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
