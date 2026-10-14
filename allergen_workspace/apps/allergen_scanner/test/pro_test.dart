import 'package:allergen_scanner/core/preferences_provider.dart';
import 'package:allergen_scanner/features/paywall/presentation/pro_controller.dart';
import 'package:core_billing/core_billing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/pump_app.dart';

void main() {
  group('ProController', () {
    Future<ProviderContainer> container(BillingService billing, {Map<String, Object> values = const {}}) async {
      SharedPreferences.setMockInitialValues(values);
      final preferences = await SharedPreferences.getInstance();
      return ProviderContainer.test(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          billingServiceProvider.overrideWithValue(billing),
        ],
      );
    }

    test('sin internet usa el entitlement guardado', () async {
      final c = await container(const UnavailableBillingService(), values: {'pro_entitlement_cached': true});

      expect(c.read(proControllerProvider).isPro, isTrue);
    });

    test('al arrancar confirma con la tienda, guarda el resultado y trae el precio local', () async {
      final c = await container(FakeBilling(owned: true));
      c.read(proControllerProvider);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final state = c.read(proControllerProvider);
      expect(state.isPro, isTrue);
      expect(state.price, 'S/ 14.90');
      expect(c.read(sharedPreferencesProvider).getBool('pro_entitlement_cached'), isTrue);
    });

    test('una compra exitosa activa Pro y lo deja guardado', () async {
      final c = await container(FakeBilling());

      final outcome = await c.read(proControllerProvider.notifier).purchase();

      expect(outcome, PurchaseOutcome.purchased);
      expect(c.read(proControllerProvider).isPro, isTrue);
      expect(c.read(proControllerProvider).busy, isFalse);
      expect(c.read(sharedPreferencesProvider).getBool('pro_entitlement_cached'), isTrue);
    });

    test('cancelar la compra no cambia nada', () async {
      final c = await container(FakeBilling(purchaseOutcome: PurchaseOutcome.cancelled));

      expect(await c.read(proControllerProvider.notifier).purchase(), PurchaseOutcome.cancelled);
      expect(c.read(proControllerProvider).isPro, isFalse);
    });

    test('restaurar activa Pro si la cuenta lo compró antes', () async {
      final c = await container(FakeBilling(restoreOutcome: RestoreOutcome.restored));

      expect(await c.read(proControllerProvider.notifier).restore(), RestoreOutcome.restored);
      expect(c.read(proControllerProvider).isPro, isTrue);
    });

    test('si la tienda ya no reconoce Pro, se desactiva aunque estuviera guardado', () async {
      final c = await container(FakeBilling(), values: {'pro_entitlement_cached': true});
      expect(c.read(proControllerProvider).isPro, isTrue);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(c.read(proControllerProvider).isPro, isFalse);
    });
  });

  group('pantalla Pro', () {
    testWidgets('comprar pone la corona, cierra y Ajustes muestra Pro activo', (tester) async {
      final billing = FakeBilling();
      await pumpApp(tester, pro: null, billing: billing);
      await tester.tap(find.text('Ajustes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('SanoScan Pro'));
      await tester.pumpAndSettle();

      expect(find.text('Desbloquear Pro por S/ 14.90'), findsOneWidget);
      await tester.tap(find.text('Desbloquear Pro por S/ 14.90'));
      await tester.pump();
      expect(find.text('¡Listo! Ya tienes SanoScan Pro.'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('Activo'), findsOneWidget);
      expect(find.text('Perfiles'), findsOneWidget);
    });

    testWidgets('sin RevenueCat configurado avisa en vez de fallar', (tester) async {
      await pumpApp(tester, pro: null);
      await tester.tap(find.text('Ajustes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('SanoScan Pro'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Desbloquear Pro por USD 3.99'));
      await tester.pumpAndSettle();

      expect(find.text('Las compras se activan antes del lanzamiento.'), findsOneWidget);
    });

    testWidgets('restaurar sin compras previas lo explica', (tester) async {
      await pumpApp(tester, pro: null, billing: FakeBilling());
      await tester.tap(find.text('Ajustes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('SanoScan Pro'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Restaurar compra'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Restaurar compra'));
      await tester.pumpAndSettle();

      expect(find.textContaining('No encontramos una compra de Pro'), findsOneWidget);
    });

    testWidgets('con Pro, el escáner no muestra el contador ni el límite', (tester) async {
      await pumpApp(
        tester,
        pro: null,
        billing: FakeBilling(owned: true),
        preferences: {'quota_day': '2026-10-13', 'quota_count': 5, 'pro_entitlement_cached': true},
      );

      expect(find.textContaining('escaneos hoy'), findsNothing);
      expect(find.text('Llegaste a 5 escaneos hoy'), findsNothing);
    });
  });

  group('Acerca de y privacidad', () {
    testWidgets('muestra el aviso médico, los enlaces legales y las licencias', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Ajustes'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Acerca de'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Acerca de'));
      await tester.pumpAndSettle();

      expect(find.text('SanoScan no reemplaza a un profesional'), findsOneWidget);
      expect(find.text('Política de privacidad'), findsOneWidget);
      expect(find.text('Términos de uso'), findsOneWidget);
      expect(find.text('Licencias de código abierto'), findsOneWidget);
    });

    testWidgets('se pueden desactivar los diagnósticos anónimos', (tester) async {
      final preferences = await pumpApp(tester);
      await tester.tap(find.text('Ajustes'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Privacidad'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Privacidad'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Enviar diagnósticos anónimos'), 200);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enviar diagnósticos anónimos'));
      await tester.pumpAndSettle();

      expect(preferences.getBool('share_diagnostics'), isFalse);
    });
  });
}
