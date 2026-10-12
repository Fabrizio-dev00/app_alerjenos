import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';

enum _CameraProblem { unavailable, failed }

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraDescription? _camera;
  CameraController? _controller;
  _CameraProblem? _problem;
  bool _capturing = false;
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      final controller = _controller;
      if (controller == null) return;
      setState(() => _controller = null);
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      final camera = _camera;
      if (_controller == null && camera != null && _problem == null) _initialize(camera);
    }
  }

  Future<void> _start() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _problem = _CameraProblem.unavailable);
        return;
      }
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      _camera = camera;
      await _initialize(camera);
    } on CameraException {
      if (mounted) setState(() => _problem = _CameraProblem.failed);
    }
  }

  Future<void> _initialize(CameraDescription camera) async {
    final controller = CameraController(
      camera,
      ResolutionPreset.veryHigh,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    try {
      await controller.initialize();
      await controller.setFlashMode(FlashMode.off);
    } on CameraException {
      await controller.dispose();
      if (mounted) setState(() => _problem = _CameraProblem.failed);
      return;
    }
    if (!mounted) {
      await controller.dispose();
      return;
    }
    setState(() {
      _controller = controller;
      _torchOn = false;
    });
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
      if (mounted) context.pop(file.path);
    } on CameraException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).cameraFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = _controller;
    final problem = _problem;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: switch (problem) {
                _CameraProblem.unavailable => _CameraMessage(l10n.cameraUnavailable),
                _CameraProblem.failed => _CameraMessage(l10n.cameraFailed),
                null when controller == null || !controller.value.isInitialized =>
                  const Center(child: CircularProgressIndicator(color: Colors.white)),
                null => Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Center(child: CameraPreview(controller!)),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(l10n.cameraHint, style: const TextStyle(color: Colors.white)),
                          ),
                        ),
                      ),
                    ],
                  ),
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  _ShutterButton(
                    label: l10n.scanTakePhoto,
                    busy: _capturing,
                    onPressed: controller == null ? null : _capture,
                  ),
                  IconButton(
                    onPressed: controller == null ? null : _toggleTorch,
                    tooltip: _torchOn ? l10n.torchOff : l10n.torchOn,
                    icon: Icon(_torchOn ? Icons.flashlight_off : Icons.flashlight_on, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraMessage extends StatelessWidget {
  const _CameraMessage(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 16),
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
      child: GestureDetector(
        onTap: busy ? null : onPressed,
        child: Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
          ),
          padding: const EdgeInsets.all(6),
          child: busy
              ? const CircularProgressIndicator(color: Colors.white)
              : DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: onPressed == null ? Colors.white38 : Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
