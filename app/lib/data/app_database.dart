import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Single-row table holding the persisted wizard inputs (spec §6:
/// UserProfile + EmploymentData + OfferData). ScenarioResult is never
/// persisted – it is recomputed on the fly.
class WizardStates extends Table {
  /// Always 0 – there is exactly one saved state.
  IntColumn get id => integer().withDefault(const Constant(0))();

  IntColumn get situation => integer()();
  IntColumn get birthYear => integer()();
  IntColumn get taxClass => integer()();
  RealColumn get childAllowanceFactor => real()();
  IntColumn get childrenUnder25 => integer()();
  BoolColumn get hasChildForAlg => boolean()();
  BoolColumn get churchMember => boolean()();
  TextColumn get state => text()();
  RealColumn get healthAdditionalRatePercent => real()();
  IntColumn get grossMonthEuro => integer()();
  IntColumn get annualExtrasEuro => integer()();
  DateTimeColumn get entryDate => dateTime()();
  DateTimeColumn get regularEndDate => dateTime()();
  IntColumn get severanceGrossEuro => integer()();
  DateTimeColumn get exitDate => dateTime()();
  BoolColumn get paidRelease => boolean()();
  IntColumn get settlementsEuro => integer()();
  IntColumn get horizonMonths => integer()();
  DateTimeColumn get noticeDate => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [WizardStates])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'exitkompass'));

  @override
  int get schemaVersion => 1;
}
