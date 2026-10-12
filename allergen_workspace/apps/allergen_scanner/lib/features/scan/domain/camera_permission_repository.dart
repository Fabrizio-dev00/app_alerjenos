enum CameraPermission { granted, denied, permanentlyDenied }

abstract interface class CameraPermissionRepository {
  Future<CameraPermission> request();

  Future<bool> openSettings();
}
