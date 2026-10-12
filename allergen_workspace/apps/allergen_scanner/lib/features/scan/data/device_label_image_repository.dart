import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../domain/label_image_repository.dart';

class DeviceLabelImageRepository implements LabelImageRepository {
  DeviceLabelImageRepository({ImagePicker? picker, ImageCropper? cropper})
      : _picker = picker ?? ImagePicker(),
        _cropper = cropper ?? ImageCropper();

  static const _maxSide = 2048.0;
  static const _quality = 90;

  final ImagePicker _picker;
  final ImageCropper _cropper;

  @override
  Future<String?> pickFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: _maxSide,
      maxHeight: _maxSide,
      imageQuality: _quality,
    );
    return file?.path;
  }

  @override
  Future<String?> crop(String imagePath, {required String title}) async {
    final cropped = await _cropper.cropImage(
      sourcePath: imagePath,
      maxWidth: _maxSide.toInt(),
      maxHeight: _maxSide.toInt(),
      compressQuality: _quality,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: title,
          lockAspectRatio: false,
          initAspectRatio: CropAspectRatioPreset.original,
        ),
        IOSUiSettings(title: title, aspectRatioLockEnabled: false),
      ],
    );
    return cropped?.path;
  }
}
