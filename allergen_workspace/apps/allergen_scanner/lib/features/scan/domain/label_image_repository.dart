abstract interface class LabelImageRepository {
  Future<String?> pickFromGallery();

  Future<String?> crop(String imagePath, {required String title});
}
