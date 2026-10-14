abstract final class AppRoutes {
  static const welcome = '/welcome';
  static const onboardingVoice = '/onboarding/voice';
  static const onboardingConfirm = '/onboarding/confirm';
  static const onboardingManual = '/onboarding/manual';
  static const scan = '/scan';
  static const processing = '/processing';
  static const result = '/result';
  static const history = '/history';
  static const settings = '/settings';
  static const scanLanguages = '/settings/languages';
  static const privacy = '/settings/privacy';
  static const profiles = '/settings/profiles';
  static const pro = '/pro';

  static String profileEditor(int id) => '/settings/profiles/$id';
}

abstract final class AppInfo {
  static const version = '0.1.0';
}
