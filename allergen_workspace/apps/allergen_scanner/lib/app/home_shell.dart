import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../l10n/generated/app_localizations.dart';
import 'theme.dart';

final currentTabProvider = NotifierProvider<CurrentTabController, int>(CurrentTabController.new);

class CurrentTabController extends Notifier<int> {
  @override
  int build() => 0;

  void set(int index) => state = index;
}

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({required this.shell, super.key});

  static const barHeight = 72.0;
  static const barMargin = 16.0;

  static double bottomInset(BuildContext context) => barHeight + barMargin * 2 + MediaQuery.paddingOf(context).bottom;

  final StatefulNavigationShell shell;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  @override
  void didUpdateWidget(HomeShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  void _sync() {
    if (!mounted) return;
    if (ref.read(currentTabProvider) != widget.shell.currentIndex) {
      ref.read(currentTabProvider.notifier).set(widget.shell.currentIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shell = widget.shell;

    return Scaffold(
      extendBody: true,
      body: shell,
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.all(HomeShell.barMargin),
        child: _FloatingTabBar(
          currentIndex: shell.currentIndex,
          onSelected: (index) {
            shell.goBranch(index, initialLocation: index == shell.currentIndex);
            ref.read(currentTabProvider.notifier).set(index);
          },
          items: [
            (LucideIcons.scan, l10n.navScan),
            (LucideIcons.history, l10n.navHistory),
            (LucideIcons.slidersHorizontal, l10n.navSettings),
          ],
        ),
      ),
    );
  }
}

class _FloatingTabBar extends StatelessWidget {
  const _FloatingTabBar({required this.currentIndex, required this.onSelected, required this.items});

  final int currentIndex;
  final ValueChanged<int> onSelected;
  final List<(IconData, String)> items;

  @override
  Widget build(BuildContext context) {
    final duration = SanoMotion.reduced(context) ? Duration.zero : const Duration(milliseconds: 220);

    return ClipRRect(
      borderRadius: BorderRadius.circular(36),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          height: HomeShell.barHeight,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: SanoColors.card.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: SanoColors.line),
          ),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: i == currentIndex,
                    label: items[i].$2,
                    excludeSemantics: true,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onSelected(i),
                      child: AnimatedContainer(
                        duration: duration,
                        decoration: BoxDecoration(
                          color: i == currentIndex ? SanoColors.orange.withValues(alpha: 0.16) : Colors.transparent,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                items[i].$1,
                                size: 22,
                                color: i == currentIndex ? SanoColors.tabActive : SanoColors.muted,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                items[i].$2,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: i == currentIndex ? SanoColors.tabActive : SanoColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
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
