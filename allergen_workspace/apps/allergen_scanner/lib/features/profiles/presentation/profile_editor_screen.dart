import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/brand/gradient_button.dart';
import '../domain/profile.dart';
import 'allergen_grid.dart';
import 'profiles_providers.dart';

class ProfileEditorScreen extends ConsumerStatefulWidget {
  const ProfileEditorScreen({this.profileId, super.key});

  final int? profileId;

  @override
  ConsumerState<ProfileEditorScreen> createState() => _ProfileEditorScreenState();
}

class _ProfileEditorScreenState extends ConsumerState<ProfileEditorScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  Set<String> _allergens = {};
  Profile? _original;
  bool _loaded = false;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _load(List<Profile> profiles) {
    if (_loaded) return;
    _loaded = true;
    for (final profile in profiles) {
      if (profile.id == widget.profileId) {
        _original = profile;
        _name.text = profile.name;
        _allergens = {...profile.allergenIds};
      }
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final repository = ref.read(profileRepositoryProvider);
    final original = _original;
    if (original == null) {
      final created = await repository.create(name: _name.text, allergenIds: _allergens);
      await ref.read(activeProfileIdProvider.notifier).select(created.id);
    } else {
      await repository.update(original.copyWith(name: _name.text.trim(), allergenIds: _allergens));
    }
    if (mounted) context.pop();
  }

  Future<void> _delete(Profile profile) async {
    final l10n = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteProfile),
        content: Text(l10n.deleteProfileConfirm(profile.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(material.cancelButtonLabel)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(material.deleteButtonTooltip)),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(profileRepositoryProvider).delete(profile.id);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profiles = ref.watch(profilesProvider).value;
    if (profiles != null) _load(profiles);
    final original = _original;
    final active = ref.watch(activeProfileProvider);
    final canDelete = original != null && (profiles?.length ?? 0) > 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(original == null ? l10n.newProfile : l10n.editProfile),
        actions: [
          if (canDelete)
            IconButton(
              onPressed: () => _delete(original),
              tooltip: l10n.deleteProfile,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            TextFormField(
              controller: _name,
              maxLength: ProfileLimits.maxNameLength,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: l10n.profileName, counterText: ''),
              validator: (value) => (value ?? '').trim().isEmpty ? l10n.profileNameRequired : null,
            ),
            const SizedBox(height: 20),
            Text(l10n.allergensQuestion, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            AllergenGrid(selected: _allergens, onChanged: (value) => setState(() => _allergens = value)),
            const SizedBox(height: 24),
            GradientButton(label: l10n.saveProfile, onPressed: _saving ? null : _save),
            if (original != null && active?.id != original.id) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () async {
                  await ref.read(activeProfileIdProvider.notifier).select(original.id);
                  if (context.mounted) context.pop();
                },
                child: Text(l10n.useProfile),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
