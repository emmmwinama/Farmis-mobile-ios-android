import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/account_provider.dart';
import '../db/app_database.dart';
import '../db/database_provider.dart';
import 'free_tier_limits.dart';
import 'upgrade_prompt_sheet.dart';

enum LimitResource { fields, activities, transactions, employees }

extension on LimitResource {
  String get label => switch (this) {
        LimitResource.fields => 'fields',
        LimitResource.activities => 'activities',
        LimitResource.transactions => 'transactions',
        LimitResource.employees => 'employees',
      };

  int get max => switch (this) {
        LimitResource.fields => FreeTierLimits.maxFields,
        LimitResource.activities => FreeTierLimits.maxActivities,
        LimitResource.transactions => FreeTierLimits.maxTransactions,
        LimitResource.employees => FreeTierLimits.maxEmployees,
      };
}

bool _isPremium(WidgetRef ref) => ref.read(accountProvider).account?.subscription?.isPaid ?? false;

Future<int> _count(AppDatabase db, LimitResource resource) async {
  switch (resource) {
    case LimitResource.fields:
      return (await db.select(db.fields).get()).length;
    case LimitResource.activities:
      return (await db.select(db.activities).get()).length;
    case LimitResource.transactions:
      return (await db.select(db.transactions).get()).length;
    case LimitResource.employees:
      return (await db.select(db.employees).get()).length;
  }
}

/// Returns true if the caller may proceed to create a new [resource] record.
/// Premium accounts always pass. Free accounts — including signed-out users,
/// since signing in isn't what unlocks limits, a paid plan is — are blocked
/// once local data hits [FreeTierLimits], and shown the upgrade sheet.
Future<bool> ensureCanAdd(BuildContext context, WidgetRef ref, LimitResource resource) async {
  if (_isPremium(ref)) return true;

  final count = await _count(ref.read(databaseProvider), resource);
  if (count < resource.max) return true;

  if (!context.mounted) return false;
  final wantsUpgrade = await showUpgradePromptSheet(context, resourceLabel: resource.label, limit: resource.max);
  if (wantsUpgrade && context.mounted) context.push('/profile');
  return false;
}

/// Crop-field creation is capped per season, and season is free text the
/// user types into the form rather than a resolvable "current season" —
/// call this from the crop form's submit handler once that value is known,
/// instead of gating the "add crop" button up front like [ensureCanAdd].
Future<bool> ensureCanAddCropForSeason(BuildContext context, WidgetRef ref, String season) async {
  if (_isPremium(ref)) return true;

  final db = ref.read(databaseProvider);
  final rows = await (db.select(db.cropFields)..where((t) => t.season.equals(season))).get();
  if (rows.length < FreeTierLimits.maxCropFieldsPerSeason) return true;

  if (!context.mounted) return false;
  final wantsUpgrade = await showUpgradePromptSheet(
    context,
    resourceLabel: 'crops in the $season season',
    limit: FreeTierLimits.maxCropFieldsPerSeason,
  );
  if (wantsUpgrade && context.mounted) context.push('/profile');
  return false;
}
