abstract final class AppRoutes {
  static const onboarding = '/onboarding';
  static const scan = '/scan';
  static const history = '/history';
  static const settings = '/settings';
  static const scanLanguages = '/settings/languages';
  static const profiles = '/settings/profiles';
  static const newProfile = '/settings/profiles/new';
  static const paywall = '/paywall';
  static const camera = '/camera';
  static const preview = '/preview';
  static const ocr = '/ocr';

  static String profileEditor(int id) => '/settings/profiles/$id';
}

abstract final class AppInfo {
  static const version = '0.1.0';
}
