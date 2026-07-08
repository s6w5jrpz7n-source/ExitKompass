import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'coach_engine.dart';
import 'gemini_coach_engine.dart';
import 'mock_coach_engine.dart';

/// Proxy endpoint for the Gemini-backed coach, injected at build time:
///   flutter build ... --dart-define=COACH_PROXY_ENDPOINT=https://…/coach
/// Empty by default → the app stays on the local preview coach. No key or
/// endpoint is ever hard-coded.
const String kCoachProxyEndpoint =
    String.fromEnvironment('COACH_PROXY_ENDPOINT');

/// Optional entitlement token forwarded to the proxy (e.g. the RevenueCat
/// app user id). In production this comes from the purchase SDK; for now it
/// can be supplied via --dart-define for testing.
const String kCoachEntitlementToken =
    String.fromEnvironment('COACH_ENTITLEMENT_TOKEN');

/// The active coaching engine. Uses the Gemini-backed engine (through the
/// premium proxy) when [kCoachProxyEndpoint] is configured, otherwise the
/// local, key-free preview coach.
final coachEngineProvider = Provider<CoachEngine>((ref) {
  if (kCoachProxyEndpoint.isEmpty) return MockCoachEngine();
  return GeminiCoachEngine(
    endpoint: kCoachProxyEndpoint,
    entitlementToken:
        kCoachEntitlementToken.isEmpty ? null : kCoachEntitlementToken,
  );
});
