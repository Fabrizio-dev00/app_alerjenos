import 'dart:async';

import 'package:core_billing/core_billing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/preferences_provider.dart';
import '../../../core/telemetry/telemetry.dart';

const _revenueCatKey = String.fromEnvironment('REVENUECAT_ANDROID_KEY');

final billingServiceProvider = Provider<BillingService>(
  (ref) => _revenueCatKey.isEmpty ? const UnavailableBillingService() : RevenueCatBillingService(apiKey: _revenueCatKey),
);

class ProState {
  const ProState({required this.isPro, this.price, this.busy = false});

  final bool isPro;
  final String? price;
  final bool busy;

  ProState copyWith({bool? isPro, String? price, bool? busy}) =>
      ProState(isPro: isPro ?? this.isPro, price: price ?? this.price, busy: busy ?? this.busy);
}

final proControllerProvider = NotifierProvider<ProController, ProState>(ProController.new);

class ProController extends Notifier<ProState> {
  static const _cacheKey = 'pro_entitlement_cached';

  StreamSubscription<bool>? _subscription;

  BillingService get _billing => ref.read(billingServiceProvider);

  @override
  ProState build() {
    ref.onDispose(() => _subscription?.cancel());
    final cached = ref.read(sharedPreferencesProvider).getBool(_cacheKey) ?? false;
    Future.microtask(_refresh);
    return ProState(isPro: cached);
  }

  Future<void> _setPro(bool value) async {
    await ref.read(sharedPreferencesProvider).setBool(_cacheKey, value);
    if (ref.mounted) state = state.copyWith(isPro: value);
  }

  Future<void> _refresh() async {
    if (!_billing.isConfigured) return;
    try {
      await _billing.configure();
      _subscription ??= _billing.watchPro().listen(_setPro);
      await _setPro(await _billing.isPro());
      final offer = await _billing.loadOffer();
      if (offer != null && ref.mounted) state = state.copyWith(price: offer.priceString);
    } on Exception {
      return;
    }
  }

  Future<PurchaseOutcome> purchase() async {
    state = state.copyWith(busy: true);
    try {
      final outcome = await _billing.purchasePro();
      if (outcome == PurchaseOutcome.purchased) {
        await _setPro(true);
        ref.read(telemetryProvider).log(TelemetryEvent.proPurchased);
      }
      return outcome;
    } on Exception {
      return PurchaseOutcome.failed;
    } finally {
      if (ref.mounted) state = state.copyWith(busy: false);
    }
  }

  Future<RestoreOutcome> restore() async {
    state = state.copyWith(busy: true);
    try {
      final outcome = await _billing.restore();
      if (outcome == RestoreOutcome.restored) {
        await _setPro(true);
        ref.read(telemetryProvider).log(TelemetryEvent.proRestored);
      }
      return outcome;
    } on Exception {
      return RestoreOutcome.failed;
    } finally {
      if (ref.mounted) state = state.copyWith(busy: false);
    }
  }
}
