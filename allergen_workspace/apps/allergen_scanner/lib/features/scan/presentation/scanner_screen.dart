import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/home_shell.dart';
import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/brand/sano_mascot.dart';
import '../../../shared/state_card.dart';
import '../../profiles/domain/profile.dart';
import '../../profiles/presentation/allergen_labels.dart';
import '../../profiles/presentation/profiles_providers.dart';
import 'scan_controller.dart';
import 'scan_quota.dart';

enum _CameraState { starting, ready, unavailable, failed }

final cameraListProvider = Provider<Future<List<CameraDescription>> Function()>((ref) => availableCameras);

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  CameraController? _controller;
  CameraDescription? _camera;
  _CameraState _cameraState = _CameraState.starting;
  bool _navigating = false;
  bool _capturing = false;
  bool _torchOn = false;
  bool _resuming = false;
  late final AnimationController _scanLine = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  bool get _tabActive => ref.read(currentTabProvider) == 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _resume());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (SanoMotion.reduced(context)) {
      _scanLine
        ..stop()
        ..value = 0.5;
    } else if (!_scanLine.isAnimating) {
      _scanLine.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanLine.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _pause();
    } else if (state == AppLifecycleState.resumed) {
      if (ref.read(scanControllerProvider) == ScanStatus.cameraBlocked) {
        ref.read(scanControllerProvider.notifier).dismissMessage();
      }
      _resume();
    }
  }

  bool get _blocked {
    final profile = ref.read(activeProfileProvider);
    return profile == null || profile.allergenIds.isEmpty || ref.read(scanQuotaProvider).exhausted;
  }

  Future<void> _resume() async {
    if (!mounted || _resuming || _navigating || !_tabActive || _controller != null || _blocked) return;
    final status = ref.read(scanControllerProvider);
    if (status == ScanStatus.cameraDenied || status == ScanStatus.cameraBlocked) return;
    _resuming = true;
    try {
      if (!await ref.read(scanControllerProvider.notifier).ensureCameraPermission() || !mounted) return;
      await _startCamera();
    } finally {
      _resuming = false;
    }
  }

  Future<void> _startCamera() async {
    setState(() => _cameraState = _CameraState.starting);
    try {
      final camera = _camera ?? await _pickCamera();
      if (camera == null) {
        if (mounted) setState(() => _cameraState = _CameraState.unavailable);
        return;
      }
      _camera = camera;
      final controller = CameraController(
        camera,
        ResolutionPreset.veryHigh,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      await controller.setFlashMode(FlashMode.off);
      if (!mounted || _navigating || !_tabActive) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _torchOn = false;
        _cameraState = _CameraState.ready;
      });
    } on Exception {
      if (mounted) setState(() => _cameraState = _CameraState.failed);
    }
  }

  Future<CameraDescription?> _pickCamera() async {
    final cameras = await ref.read(cameraListProvider)();
    if (cameras.isEmpty) return null;
    return cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => cameras.first);
  }

  void _pause() {
    final controller = _controller;
    if (controller == null) return;
    if (mounted) setState(() => _controller = null);
    controller.dispose();
  }

  Future<void> _toggleTorch() async {
    final controller = _controller;
    if (controller == null) return;
    final next = !_torchOn;
    try {
      await controller.setFlashMode(next ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() => _torchOn = next);
    } on CameraException {
      return;
    }
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || _capturing || controller.value.isTakingPicture) return;
    setState(() => _capturing = true);
    try {
      final file = await controller.takePicture();
      if (_torchOn) await controller.setFlashMode(FlashMode.off);
      await _openProcessing(file.path);
    } on CameraException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).cameraFailed)));
      }
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<void> _pickFromGallery() async {
    final path = await ref.read(scanControllerProvider.notifier).pickFromGallery();
    if (path != null && mounted) await _openProcessing(path);
  }

  Future<void> _openProcessing(String path) async {
    _navigating = true;
    _pause();
    final result = await context.push<String>(AppRoutes.processing, extra: path);
    _navigating = false;
    if (!mounted) return;
    if (result == ProcessingExit.gallery) {
      await _pickFromGallery();
    } else {
      await _resume();
    }
  }

  void _showProfiles(List<Profile> profiles, Profile active) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final profile in profiles)
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: SanoColors.cream,
                  child: Text(
                    profile.initial,
                    style: const TextStyle(fontWeight: FontWeight.w800, color: SanoColors.accent),
                  ),
                ),
                title: Text(profile.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(profile.summary(l10n)),
                trailing: profile.id == active.id ? const Icon(LucideIcons.check, color: SanoColors.accent) : null,
                onTap: () {
                  ref.read(activeProfileIdProvider.notifier).select(profile.id);
                  Navigator.pop(sheetContext);
                },
              ),
            ListTile(
              leading: const Icon(LucideIcons.pencil),
              title: Text(l10n.editMyAllergens),
              onTap: () {
                Navigator.pop(sheetContext);
                context.push(AppRoutes.profileEditor(active.id));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = ref.watch(activeProfileProvider);
    final profiles = ref.watch(profilesProvider).value ?? const <Profile>[];
    final quota = ref.watch(scanQuotaProvider);
    final status = ref.watch(scanControllerProvider);
    final controller = _controller;

    ref.listen(currentTabProvider, (previous, index) => index == 0 ? _resume() : _pause());
    ref.listen(scanQuotaProvider, (previous, next) => next.exhausted ? _pause() : _resume());
    ref.listen(activeProfileProvider, (previous, next) => _blocked ? _pause() : _resume());

    final blocker = _blocker(l10n, profile, quota, status);
    final bottomInset = HomeShell.bottomInset(context);

    return Scaffold(
      backgroundColor: SanoColors.coffee,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: SanoColors.darkBackground),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (controller != null && controller.value.isInitialized && blocker == null)
              ClipRect(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller.value.previewSize?.height ?? 1080,
                    height: controller.value.previewSize?.width ?? 1920,
                    child: CameraPreview(controller),
                  ),
                ),
              ),
            if (controller != null) Container(color: SanoColors.coffee.withValues(alpha: 0.25)),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 12, 20, bottomInset - MediaQuery.paddingOf(context).bottom + 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (profile != null)
                          Flexible(
                            child: _GlassPill(
                              onTap: () => _showProfiles(profiles, profile),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: SanoColors.cream,
                                    child: Text(
                                      profile.initial,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: SanoColors.accent,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Text(
                                      l10n.scanProfile(profile.name),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: SanoColors.card,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 17,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(LucideIcons.chevronDown, color: SanoColors.card, size: 20),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(width: 12),
                        _GlassCircle(
                          tooltip: _torchOn ? l10n.torchOff : l10n.torchOn,
                          icon: _torchOn ? LucideIcons.zapOff : LucideIcons.zap,
                          onTap: controller == null ? null : _toggleTorch,
                        ),
                      ],
                    ),
                    if (!quota.unlimited) ...[
                      const SizedBox(height: 12),
                      _QuotaPill(quota: quota, onPro: () => context.push(AppRoutes.pro)),
                    ],
                    const SizedBox(height: 16),
                    Expanded(
                      child: blocker != null
                          ? Center(child: SingleChildScrollView(child: blocker))
                          : _Viewfinder(
                              scanLine: _scanLine,
                              state: _cameraState,
                              hint: l10n.scannerHint,
                              problem: switch (_cameraState) {
                                _CameraState.unavailable => l10n.cameraUnavailable,
                                _CameraState.failed => l10n.cameraFailed,
                                _ => null,
                              },
                            ),
                    ),
                    if (blocker == null) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _GlassCircle(
                            size: 64,
                            tooltip: l10n.scanFromGallery,
                            icon: LucideIcons.image,
                            onTap: status == ScanStatus.working ? null : _pickFromGallery,
                          ),
                          _ShutterButton(
                            label: l10n.scanTakePhoto,
                            busy: _capturing,
                            onPressed: controller == null ? null : _capture,
                          ),
                          const SizedBox(width: 64),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _blocker(AppLocalizations l10n, Profile? profile, ScanQuota quota, ScanStatus status) {
    final crowned = ref.watch(isProProvider);
    if (profile != null && profile.allergenIds.isEmpty) {
      return StateCard(
        mood: SanoMood.attentive,
        crowned: crowned,
        title: l10n.noAllergensTitle,
        body: l10n.noAllergensBody,
        primaryLabel: l10n.editMyAllergens,
        onPrimary: () => context.push(AppRoutes.profileEditor(profile.id)),
      );
    }
    if (quota.exhausted) {
      return StateCard(
        mood: SanoMood.sleepy,
        title: l10n.limitTitle(ScanQuota.dailyLimit),
        body: l10n.limitBody,
        primaryLabel: l10n.seePro,
        onPrimary: () => context.push(AppRoutes.pro),
        secondaryLabel: l10n.seeHistory,
        onSecondary: () => context.go(AppRoutes.history),
      );
    }
    if (status == ScanStatus.cameraDenied || status == ScanStatus.cameraBlocked) {
      return StateCard(
        mood: SanoMood.surprised,
        crowned: crowned,
        title: l10n.cameraNeededTitle,
        body: l10n.cameraNeededBody,
        primaryLabel: l10n.cameraGrant,
        onPrimary: () async {
          final scan = ref.read(scanControllerProvider.notifier);
          if (status == ScanStatus.cameraBlocked) {
            await scan.openSettings();
          } else {
            scan.dismissMessage();
            await _resume();
          }
        },
        secondaryLabel: l10n.scanFromGallery,
        onSecondary: _pickFromGallery,
      );
    }
    return null;
  }
}

abstract final class ProcessingExit {
  static const gallery = 'gallery';
}

class _Viewfinder extends StatelessWidget {
  const _Viewfinder({required this.scanLine, required this.state, required this.hint, this.problem});

  final Animation<double> scanLine;
  final _CameraState state;
  final String hint;
  final String? problem;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Positioned.fill(child: CustomPaint(painter: _CornersPainter())),
                  if (problem != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          problem!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: SanoColors.card, fontSize: 16),
                        ),
                      ),
                    )
                  else if (state == _CameraState.starting)
                    const Center(child: CircularProgressIndicator(color: SanoColors.cream))
                  else
                    AnimatedBuilder(
                      animation: scanLine,
                      builder: (context, child) => Positioned(
                        left: 8,
                        right: 8,
                        top: 20 + (constraints.maxHeight - 40) * Curves.easeInOut.transform(scanLine.value),
                        child: child!,
                      ),
                      child: Container(
                        height: 5,
                        decoration: BoxDecoration(
                          color: SanoColors.tangerine,
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(color: SanoColors.amber.withValues(alpha: 0.7), blurRadius: 18, spreadRadius: 4),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 22, 10),
          decoration: BoxDecoration(color: SanoColors.paper, borderRadius: BorderRadius.circular(32)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(gradient: SanoColors.brandGradient, borderRadius: BorderRadius.circular(12)),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: FittedBox(child: SanoMascot(mood: SanoMood.attentive, size: 40)),
                ),
              ),
              const SizedBox(width: 14),
              Flexible(
                child: Text(hint, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CornersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SanoColors.card
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    const arm = 48.0;
    const radius = 24.0;
    final w = size.width;
    final h = size.height;
    final corners = [
      Path()
        ..moveTo(0, arm + radius)
        ..lineTo(0, radius)
        ..arcToPoint(const Offset(radius, 0), radius: const Radius.circular(radius))
        ..lineTo(radius + arm, 0),
      Path()
        ..moveTo(w - radius - arm, 0)
        ..lineTo(w - radius, 0)
        ..arcToPoint(Offset(w, radius), radius: const Radius.circular(radius))
        ..lineTo(w, radius + arm),
      Path()
        ..moveTo(w, h - radius - arm)
        ..lineTo(w, h - radius)
        ..arcToPoint(Offset(w - radius, h), radius: const Radius.circular(radius))
        ..lineTo(w - radius - arm, h),
      Path()
        ..moveTo(radius + arm, h)
        ..lineTo(radius, h)
        ..arcToPoint(Offset(0, h - radius), radius: const Radius.circular(radius))
        ..lineTo(0, h - radius - arm),
    ];
    for (final corner in corners) {
      canvas.drawPath(corner, paint);
    }
  }

  @override
  bool shouldRepaint(_CornersPainter oldDelegate) => false;
}

class _QuotaPill extends StatelessWidget {
  const _QuotaPill({required this.quota, required this.onPro});

  final ScanQuota quota;
  final VoidCallback onPro;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _GlassPill(
      onTap: onPro,
      child: Row(
        children: [
          for (var i = 0; i < ScanQuota.dailyLimit; i++)
            Container(
              margin: const EdgeInsets.only(right: 5),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < quota.remaining ? SanoColors.amber : SanoColors.card.withValues(alpha: 0.3),
              ),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.quotaRemaining(quota.remaining, ScanQuota.dailyLimit),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: SanoColors.card, fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
          Text(
            'Pro',
            style: const TextStyle(
              color: SanoColors.amber,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              decoration: TextDecoration.underline,
              decorationColor: SanoColors.amber,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SanoColors.card.withValues(alpha: 0.14),
      shape: StadiumBorder(side: BorderSide(color: SanoColors.card.withValues(alpha: 0.25))),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.fromLTRB(8, 8, 16, 8), child: child),
      ),
    );
  }
}

class _GlassCircle extends StatelessWidget {
  const _GlassCircle({required this.icon, required this.tooltip, this.onTap, this.size = 52});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: SanoColors.card.withValues(alpha: 0.14),
        shape: CircleBorder(side: BorderSide(color: SanoColors.card.withValues(alpha: 0.25))),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox.square(
            dimension: size,
            child: Icon(icon, color: SanoColors.card, size: size * 0.42),
          ),
        ),
      ),
    );
  }
}

class _ShutterButton extends StatelessWidget {
  const _ShutterButton({required this.label, required this.busy, required this.onPressed});

  final String label;
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      enabled: onPressed != null,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: busy ? null : onPressed,
        child: Container(
          width: 88,
          height: 88,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: SanoColors.cream, width: 4),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: onPressed == null ? null : SanoColors.brandGradient,
              color: onPressed == null ? SanoColors.card.withValues(alpha: 0.3) : null,
            ),
            child: busy
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: SanoColors.coffee),
                  )
                : const Icon(LucideIcons.scan, color: SanoColors.coffee, size: 32),
          ),
        ),
      ),
    );
  }
}
