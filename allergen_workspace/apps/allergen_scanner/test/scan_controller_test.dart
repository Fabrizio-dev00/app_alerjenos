import 'package:allergen_scanner/features/scan/domain/camera_permission_repository.dart';
import 'package:allergen_scanner/features/scan/domain/label_image_repository.dart';
import 'package:allergen_scanner/features/scan/presentation/scan_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockPermissions extends Mock implements CameraPermissionRepository {}

class _MockImages extends Mock implements LabelImageRepository {}

void main() {
  late _MockPermissions permissions;
  late _MockImages images;
  late ProviderContainer container;

  ScanController controller() => container.read(scanControllerProvider.notifier);
  ScanStatus status() => container.read(scanControllerProvider);

  setUp(() {
    permissions = _MockPermissions();
    images = _MockImages();
    container = ProviderContainer.test(
      overrides: [
        cameraPermissionRepositoryProvider.overrideWithValue(permissions),
        labelImageRepositoryProvider.overrideWithValue(images),
      ],
    );
  });

  group('permiso de cámara', () {
    test('concedido deja la pantalla lista para abrir la cámara', () async {
      when(() => permissions.request()).thenAnswer((_) async => CameraPermission.granted);

      expect(await controller().ensureCameraPermission(), isTrue);
      expect(status(), ScanStatus.idle);
    });

    test('negado muestra el aviso con la alternativa de la galería', () async {
      when(() => permissions.request()).thenAnswer((_) async => CameraPermission.denied);

      expect(await controller().ensureCameraPermission(), isFalse);
      expect(status(), ScanStatus.cameraDenied);
    });

    test('bloqueado ofrece abrir los ajustes', () async {
      when(() => permissions.request()).thenAnswer((_) async => CameraPermission.permanentlyDenied);
      when(() => permissions.openSettings()).thenAnswer((_) async => true);

      expect(await controller().ensureCameraPermission(), isFalse);
      expect(status(), ScanStatus.cameraBlocked);

      await controller().openSettings();
      verify(() => permissions.openSettings()).called(1);
    });
  });

  group('galería y recorte', () {
    test('elegir y recortar devuelve la imagen recortada', () async {
      when(() => images.pickFromGallery()).thenAnswer((_) async => '/tmp/label.jpg');
      when(() => images.crop('/tmp/label.jpg', title: 'Recorta'))
          .thenAnswer((_) async => '/tmp/label_cropped.jpg');

      expect(await controller().pickFromGallery(cropTitle: 'Recorta'), '/tmp/label_cropped.jpg');
      expect(status(), ScanStatus.idle);
    });

    test('cancelar la galería vuelve al estado inicial sin recortar', () async {
      when(() => images.pickFromGallery()).thenAnswer((_) async => null);

      expect(await controller().pickFromGallery(cropTitle: 'Recorta'), isNull);
      expect(status(), ScanStatus.idle);
      verifyNever(() => images.crop(any(), title: any(named: 'title')));
    });

    test('cancelar el recorte no avanza', () async {
      when(() => images.crop('/tmp/photo.jpg', title: 'Recorta')).thenAnswer((_) async => null);

      expect(await controller().crop('/tmp/photo.jpg', title: 'Recorta'), isNull);
      expect(status(), ScanStatus.idle);
    });

    test('un fallo de la galería se muestra como error controlado', () async {
      when(() => images.pickFromGallery()).thenThrow(PlatformException(code: 'photo_access_denied'));

      expect(await controller().pickFromGallery(cropTitle: 'Recorta'), isNull);
      expect(status(), ScanStatus.galleryFailed);
    });

    test('un fallo del recorte se muestra como error controlado', () async {
      when(() => images.crop('/tmp/photo.jpg', title: 'Recorta'))
          .thenThrow(PlatformException(code: 'crop_error'));

      expect(await controller().crop('/tmp/photo.jpg', title: 'Recorta'), isNull);
      expect(status(), ScanStatus.cropFailed);
    });

    test('cerrar el mensaje vuelve al estado inicial', () async {
      when(() => images.pickFromGallery()).thenThrow(PlatformException(code: 'x'));
      await controller().pickFromGallery(cropTitle: 'Recorta');

      controller().dismissMessage();

      expect(status(), ScanStatus.idle);
    });
  });
}
