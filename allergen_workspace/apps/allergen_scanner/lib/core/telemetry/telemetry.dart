import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TelemetryEvent { onboardingCompleted, scanCompleted, scanUnreadable, proPurchased, proRestored }

abstract interface class Telemetry {
  bool get available;

  Future<void> setEnabled(bool enabled);

  Future<void> log(TelemetryEvent event, [Map<String, Object> parameters = const {}]);

  Future<void> recordError(Object error, StackTrace stack, {bool fatal = false});
}

class NoopTelemetry implements Telemetry {
  const NoopTelemetry();

  @override
  bool get available => false;

  @override
  Future<void> setEnabled(bool enabled) async {}

  @override
  Future<void> log(TelemetryEvent event, [Map<String, Object> parameters = const {}]) async {}

  @override
  Future<void> recordError(Object error, StackTrace stack, {bool fatal = false}) async {}
}

class FirebaseTelemetry implements Telemetry {
  FirebaseTelemetry._();

  static const _eventNames = {
    TelemetryEvent.onboardingCompleted: 'onboarding_completed',
    TelemetryEvent.scanCompleted: 'scan_completed',
    TelemetryEvent.scanUnreadable: 'scan_unreadable',
    TelemetryEvent.proPurchased: 'pro_purchased',
    TelemetryEvent.proRestored: 'pro_restored',
  };

  static Future<Telemetry> start({required bool enabled}) async {
    if (kDebugMode) return const NoopTelemetry();
    try {
      await Firebase.initializeApp();
    } catch (_) {
      return const NoopTelemetry();
    }
    final telemetry = FirebaseTelemetry._();
    await telemetry.setEnabled(enabled);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    return telemetry;
  }

  @override
  bool get available => true;

  @override
  Future<void> setEnabled(bool enabled) async {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(enabled);
    final analytics = FirebaseAnalytics.instance;
    await analytics.setAnalyticsCollectionEnabled(enabled);
    await analytics.setConsent(
      analyticsStorageConsentGranted: enabled,
      adStorageConsentGranted: false,
      adUserDataConsentGranted: false,
      adPersonalizationSignalsConsentGranted: false,
    );
  }

  @override
  Future<void> log(TelemetryEvent event, [Map<String, Object> parameters = const {}]) async {
    try {
      await FirebaseAnalytics.instance.logEvent(name: _eventNames[event]!, parameters: parameters);
    } on Exception {
      return;
    }
  }

  @override
  Future<void> recordError(Object error, StackTrace stack, {bool fatal = false}) =>
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: fatal);
}

final telemetryProvider = Provider<Telemetry>((ref) => const NoopTelemetry());
