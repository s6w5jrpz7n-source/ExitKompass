import 'package:drift/native.dart';
import 'package:exit_engine/exit_engine.dart';
import 'package:exitkompass_app/data/app_database.dart';
import 'package:exitkompass_app/data/wizard_repository.dart';
import 'package:exitkompass_app/state/wizard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late WizardRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = WizardRepository(db);
  });

  tearDown(() => db.close());

  test('load() returns null when nothing has been saved', () async {
    expect(await repo.load(), isNull);
  });

  test('save() then load() round-trips every field', () async {
    final original = WizardData(
      situation: Situation.aufhebungAngeboten,
      birthYear: 1979,
      taxClass: TaxClass.iii,
      childAllowanceFactor: 2,
      childrenUnder25: 2,
      hasChildForAlg: true,
      churchMember: true,
      state: Bundesland.bayern,
      healthAdditionalRatePercent: 1.7,
      grossMonthEuro: 7500,
      annualExtrasEuro: 5000,
      entryDate: DateTime(2011, 3, 1),
      regularEndDate: DateTime(2026, 9, 30),
      severanceGrossEuro: 90000,
      exitDate: DateTime(2026, 6, 30),
      paidRelease: true,
      settlementsEuro: 3000,
      horizonMonths: 36,
      noticeDate: DateTime(2026, 4, 15),
    );

    await repo.save(original);
    final loaded = await repo.load();

    expect(loaded, isNotNull);
    expect(loaded!.situation, original.situation);
    expect(loaded.birthYear, original.birthYear);
    expect(loaded.taxClass, original.taxClass);
    expect(loaded.childAllowanceFactor, original.childAllowanceFactor);
    expect(loaded.childrenUnder25, original.childrenUnder25);
    expect(loaded.hasChildForAlg, original.hasChildForAlg);
    expect(loaded.churchMember, original.churchMember);
    expect(loaded.state, original.state);
    expect(loaded.healthAdditionalRatePercent, original.healthAdditionalRatePercent);
    expect(loaded.grossMonthEuro, original.grossMonthEuro);
    expect(loaded.annualExtrasEuro, original.annualExtrasEuro);
    expect(loaded.entryDate, original.entryDate);
    expect(loaded.regularEndDate, original.regularEndDate);
    expect(loaded.severanceGrossEuro, original.severanceGrossEuro);
    expect(loaded.exitDate, original.exitDate);
    expect(loaded.paidRelease, original.paidRelease);
    expect(loaded.settlementsEuro, original.settlementsEuro);
    expect(loaded.horizonMonths, original.horizonMonths);
    expect(loaded.noticeDate, original.noticeDate);
  });

  test('save() upserts the single row (no duplicates)', () async {
    await repo.save(WizardData(grossMonthEuro: 4000));
    await repo.save(WizardData(grossMonthEuro: 6000));
    final rows = await db.select(db.wizardStates).get();
    expect(rows, hasLength(1));
    expect((await repo.load())!.grossMonthEuro, 6000);
  });

  test('clear() removes the saved state', () async {
    await repo.save(WizardData(grossMonthEuro: 5000));
    await repo.clear();
    expect(await repo.load(), isNull);
  });

  test('a controller with a repository persists updates', () async {
    final controller = WizardController(repository: repo);
    controller.update((d) => d.copyWith(severanceGrossEuro: 42000));
    // Give the async save a chance to complete.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect((await repo.load())!.severanceGrossEuro, 42000);

    await controller.clearSaved();
    expect(await repo.load(), isNull);
  });
}
