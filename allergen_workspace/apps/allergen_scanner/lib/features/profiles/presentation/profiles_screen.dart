import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/home_shell.dart';
import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/brand/verdict_pill.dart';
import '../../onboarding/presentation/onboarding_providers.dart';
import '../domain/profile.dart';
import 'allergen_labels.dart';
import 'profiles_providers.dart';

class ProfilesScreen extends ConsumerWidget {
  const ProfilesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final profiles = ref.watch(profilesProvider).value ?? const <Profile>[];
    final active = ref.watch(activeProfileProvider);
    final canAdd = ref.watch(canAddProfileProvider);
    final pro = ref.watch(isProProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: const Icon(LucideIcons.chevronLeft, size: 28),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, HomeShell.bottomInset(context)),
        children: [
          Text(l10n.profilesTitle, style: textTheme.displaySmall),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (pro) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(gradient: SanoColors.brandGradient, borderRadius: BorderRadius.circular(16)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.star, size: 18),
                      SizedBox(width: 4),
                      Text('PRO', style: TextStyle(fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  l10n.profilesIntro(profiles.length, pro ? ProfileLimits.pro : ProfileLimits.free),
                  style: textTheme.bodyLarge?.copyWith(color: SanoColors.muted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          for (final profile in profiles) ...[
            _ProfileTile(
              profile: profile,
              active: profile.id == active?.id,
              onTap: () => context.push(AppRoutes.profileEditor(profile.id)),
              onSelect: () => ref.read(activeProfileIdProvider.notifier).select(profile.id),
            ),
            const SizedBox(height: 14),
          ],
          const SizedBox(height: 4),
          DashedActionButton(
            label: l10n.addProfile,
            onPressed: () {
              if (!canAdd) {
                context.push(AppRoutes.pro);
                return;
              }
              ref.read(onboardingDraftProvider.notifier).reset();
              context.push(AppRoutes.onboardingVoice);
            },
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(LucideIcons.info, color: SanoColors.muted),
              const SizedBox(width: 12),
              Expanded(child: Text(l10n.profilesNote, style: textTheme.bodyMedium?.copyWith(color: SanoColors.muted))),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.profile, required this.active, required this.onTap, required this.onSelect});

  final Profile profile;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Material(
      color: SanoColors.card,
      borderRadius: BorderRadius.circular(28),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: active ? SanoColors.brandGradient : null,
                  color: active ? null : SanoColors.cream,
                ),
                child: Text(
                  profile.initial,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: active ? SanoColors.card : SanoColors.accent),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Semantics(
                      label: profile.summary(l10n),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final choice in profile.choices)
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFCE3D6)),
                              child: Icon(choice.icon, size: 22, color: SanoColors.accent),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Semantics(
                button: true,
                selected: active,
                label: l10n.useProfile,
                child: InkResponse(
                  onTap: onSelect,
                  radius: 28,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: active ? SanoColors.brandGradient : null,
                        border: active ? null : Border.all(color: SanoColors.line, width: 2),
                      ),
                      child: active ? const Icon(LucideIcons.check, color: SanoColors.coffee) : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
