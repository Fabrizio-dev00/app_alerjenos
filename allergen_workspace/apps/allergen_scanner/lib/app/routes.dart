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
  static const about = '/settings/about';
  static const profiles = '/settings/profiles';
  static const pro = '/pro';

  static String profileEditor(int id) => '/settings/profiles/$id';
}

abstract final class AppInfo {
  static const version = '1.0.0';
  static const supportEmail = String.fromEnvironment('SUPPORT_EMAIL');

  static const _site = 'https://fabrizio-dev00.github.io/app_alerjenos';
  static const privacyUrlEs = '$_site/privacidad.html';
  static const privacyUrlEn = '$_site/privacidad.html#en';
  static const termsUrlEs = '$_site/terminos.html';
  static const termsUrlEn = '$_site/terminos.html#en';
}
