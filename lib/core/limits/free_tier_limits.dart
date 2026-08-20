/// Mirrors the "Mobile Free" tier seeded server-side in
/// Farmis/prisma/seedProduction.ts (maxFields, maxCrops, maxActivities,
/// maxTransactions, maxEmployees) — kept in sync manually since the two
/// repos don't share code. These are enforced locally (against this
/// device's SQLite data) regardless of whether the user is signed in; only
/// a paid account (see AccountSubscription.isPaid) lifts them.
class FreeTierLimits {
  const FreeTierLimits._();

  static const int maxFields = 2;
  static const int maxCropFieldsPerSeason = 3;
  static const int maxActivities = 30;
  static const int maxTransactions = 30;
  static const int maxEmployees = 2;
}
