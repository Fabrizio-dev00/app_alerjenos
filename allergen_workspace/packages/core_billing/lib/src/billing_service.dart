enum PurchaseOutcome { purchased, cancelled, pending, notConfigured, notAllowed, failed }

enum RestoreOutcome { restored, nothingToRestore, notConfigured, failed }

class ProOffer {
  const ProOffer({required this.priceString});

  final String priceString;
}

abstract interface class BillingService {
  bool get isConfigured;

  Future<void> configure();

  Future<bool> isPro();

  Stream<bool> watchPro();

  Future<ProOffer?> loadOffer();

  Future<PurchaseOutcome> purchasePro();

  Future<RestoreOutcome> restore();
}

class UnavailableBillingService implements BillingService {
  const UnavailableBillingService();

  @override
  bool get isConfigured => false;

  @override
  Future<void> configure() async {}

  @override
  Future<bool> isPro() async => false;

  @override
  Stream<bool> watchPro() => const Stream.empty();

  @override
  Future<ProOffer?> loadOffer() async => null;

  @override
  Future<PurchaseOutcome> purchasePro() async => PurchaseOutcome.notConfigured;

  @override
  Future<RestoreOutcome> restore() async => RestoreOutcome.notConfigured;
}
