import 'dart:async';

import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'billing_service.dart';

class RevenueCatBillingService implements BillingService {
  RevenueCatBillingService({required this.apiKey, this.entitlementId = 'pro', this.offeringId});

  final String apiKey;
  final String entitlementId;
  final String? offeringId;

  final _pro = StreamController<bool>.broadcast();
  bool _configured = false;

  @override
  bool get isConfigured => apiKey.isNotEmpty;

  bool _hasPro(CustomerInfo info) => info.entitlements.active.containsKey(entitlementId);

  @override
  Future<void> configure() async {
    if (_configured || !isConfigured) return;
    await Purchases.configure(PurchasesConfiguration(apiKey));
    Purchases.addCustomerInfoUpdateListener((info) => _pro.add(_hasPro(info)));
    _configured = true;
  }

  @override
  Future<bool> isPro() async {
    await configure();
    return _hasPro(await Purchases.getCustomerInfo());
  }

  @override
  Stream<bool> watchPro() => _pro.stream;

  Future<Package?> _proPackage() async {
    final offerings = await Purchases.getOfferings();
    final offering = offeringId == null ? offerings.current : offerings.getOffering(offeringId!);
    if (offering == null) return null;
    return offering.lifetime ?? (offering.availablePackages.isEmpty ? null : offering.availablePackages.first);
  }

  @override
  Future<ProOffer?> loadOffer() async {
    if (!isConfigured) return null;
    await configure();
    final package = await _proPackage();
    return package == null ? null : ProOffer(priceString: package.storeProduct.priceString);
  }

  @override
  Future<PurchaseOutcome> purchasePro() async {
    if (!isConfigured) return PurchaseOutcome.notConfigured;
    try {
      await configure();
      final package = await _proPackage();
      if (package == null) return PurchaseOutcome.failed;
      final result = await Purchases.purchase(PurchaseParams.package(package));
      final pro = _hasPro(result.customerInfo);
      _pro.add(pro);
      return pro ? PurchaseOutcome.purchased : PurchaseOutcome.pending;
    } on PlatformException catch (error) {
      return switch (PurchasesErrorHelper.getErrorCode(error)) {
        PurchasesErrorCode.purchaseCancelledError => PurchaseOutcome.cancelled,
        PurchasesErrorCode.paymentPendingError => PurchaseOutcome.pending,
        PurchasesErrorCode.purchaseNotAllowedError => PurchaseOutcome.notAllowed,
        _ => PurchaseOutcome.failed,
      };
    }
  }

  @override
  Future<RestoreOutcome> restore() async {
    if (!isConfigured) return RestoreOutcome.notConfigured;
    try {
      await configure();
      final pro = _hasPro(await Purchases.restorePurchases());
      _pro.add(pro);
      return pro ? RestoreOutcome.restored : RestoreOutcome.nothingToRestore;
    } on PlatformException {
      return RestoreOutcome.failed;
    }
  }
}
