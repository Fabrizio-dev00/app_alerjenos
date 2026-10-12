import 'package:permission_handler/permission_handler.dart';

import '../domain/camera_permission_repository.dart';

class PermissionHandlerCameraPermissionRepository implements CameraPermissionRepository {
  @override
  Future<CameraPermission> request() async {
    final status = await Permission.camera.request();
    if (status.isGranted || status.isLimited) return CameraPermission.granted;
    if (status.isPermanentlyDenied || status.isRestricted) return CameraPermission.permanentlyDenied;
    return CameraPermission.denied;
  }

  @override
  Future<bool> openSettings() => openAppSettings();
}
