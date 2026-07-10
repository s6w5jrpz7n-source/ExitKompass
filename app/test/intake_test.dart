import 'package:exitkompass_app/main.dart';
import 'package:exitkompass_app/screens/start_hub_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the intake collects situation/goal/data, then the hub reflects it',
      (tester) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ProviderScope(child: ExitKompassApp()));
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Loslegen'));
    await tester.pumpAndSettle();

    // Step 1: why here.
    await tester.tap(find.text('Aufhebungsvertrag angeboten'));
    await tester.pumpAndSettle();
    // Step 2: goal.
    await tester.tap(find.text('Eine faire Abfindung verhandeln'));
    await tester.pumpAndSettle();
    // Step 3: key data.
    await tester.enterText(
      find.ancestor(
          of: find.text('Bruttomonatsgehalt (€)'),
          matching: find.byType(TextField)),
      '6000',
    );
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.ancestor(
          of: find.text('Angebotene Abfindung brutto (€)'),
          matching: find.byType(TextField)),
      '40000',
    );
    await tester.ensureVisible(find.text('Fertig – zur Übersicht'));
    await tester.tap(find.text('Fertig – zur Übersicht'));
    await tester.pumpAndSettle();

    // Landed on the hub, and the situation strip shows the real input.
    expect(find.byType(StartHubScreen), findsOneWidget);
    expect(find.text('Aufhebungsvertrag angeboten'), findsOneWidget);
    expect(find.textContaining('Abfindung verhandeln'), findsWidgets);
  });
}
