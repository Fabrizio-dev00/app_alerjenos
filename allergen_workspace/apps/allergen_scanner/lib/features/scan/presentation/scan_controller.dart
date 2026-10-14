import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/device_label_image_repository.dart';
import '../data/permission_handler_camera_permission_repository.dart';
import '../domain/camera_permission_repository.dart';
import '../domain/label_image_repository.dart';

final cameraPermissionRepositoryProvider = Provider<CameraPermissionRepository>(
  (ref) => PermissionHandlerCameraPermissionRepository(),
);

final labelImageRepositoryProvider = Provider<LabelImageRepository>(
  (ref) => DeviceLabelImageRepository(),
);

final scanControllerProvider = NotifierProvider<ScanController, ScanStatus>(ScanController.new);

enum ScanStatus { idle, working, cameraDenied, cameraBlocked, galleryFailed, cropFailed }

class ScanController extends Notifier<ScanStatus> {
  @override
  ScanStatus build() => ScanStatus.idle;

  CameraPermissionRepository get _permissions => ref.read(cameraPermissionRepositoryProvider);

  LabelImageRepository get _images => ref.read(labelImageRepositoryProvider);

  Future<bool> ensureCameraPermission() async {
    state = ScanStatus.working;
    final permission = await _permissions.request();
    if (!ref.mounted) return false;
    state = switch (permission) {
      CameraPermission.granted => ScanStatus.idle,
      CameraPermission.denied => ScanStatus.cameraDenied,
      CameraPermission.permanentlyDenied => ScanStatus.cameraBlocked,
    };
    return permission == CameraPermission.granted;
  }

  Future<void> openSettings() => _permissions.openSettings();

  Future<String?> pickFromGallery({String? cropTitle}) async {
    state = ScanStatus.working;
    final String? picked;
    try {
      picked = await _images.pickFromGallery();
    } on Exception {
      if (ref.mounted) state = ScanStatus.galleryFailed;
      return null;
    }
    if (!ref.mounted) return null;
    if (picked == null || cropTitle == null) {
      state = ScanStatus.idle;
      return picked;
    }
    return crop(picked, title: cropTitle);
  }

  Future<String?> crop(String imagePath, {required String title}) async {
    state = ScanStatus.working;
    try {
      final cropped = await _images.crop(imagePath, title: title);
      if (ref.mounted) state = ScanStatus.idle;
      return cropped;
    } on Exception {
      if (ref.mounted) state = ScanStatus.cropFailed;
      return null;
    }
  }

  void dismissMessage() => state = ScanStatus.idle;
}
