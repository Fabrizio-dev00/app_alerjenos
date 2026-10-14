import 'package:allergen_scanner/features/scan/domain/camera_permission_repository.dart';
import 'package:allergen_scanner/features/scan/domain/label_image_repository.dart';
import 'package:allergen_scanner/features/scan/presentation/scan_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers/pump_app.dart';

class _MockPermissions extends Mock implements CameraPermissionRepository {}

class _MockImages extends Mock implements LabelImageRepository {}

void main() {
  late _MockPermissions permissions;

  Future<void> pumpScan(WidgetTester tester) => pumpApp(
        tester,
        overrides: [
          cameraPermissionRepositoryProvider.overrideWithValue(permissions),
          labelImageRepositoryProvider.overrideWithValue(_MockImages()),
        ],
      );

  setUp(() => permissions = _MockPermissions());

  testWidgets('con la cámara negada sugiere usar la galería', (tester) async {
    when(() => permissions.request()).thenAnswer((_) async => CameraPermission.denied);
    await pumpScan(tester);

    await tester.tap(find.text('Tomar foto'));
    await tester.pumpAndSettle();

    expect(find.textContaining('elegir una foto de la galería'), findsOneWidget);
    expect(find.text('Abrir ajustes'), findsNothing);
  });

  testWidgets('con la cámara bloqueada ofrece abrir ajustes', (tester) async {
    when(() => permissions.request()).thenAnswer((_) async => CameraPermission.permanentlyDenied);
    when(() => permissions.openSettings()).thenAnswer((_) async => true);
    await pumpScan(tester);

    await tester.tap(find.text('Tomar foto'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abrir ajustes'));

    verify(() => permissions.openSettings()).called(1);
  });
}
