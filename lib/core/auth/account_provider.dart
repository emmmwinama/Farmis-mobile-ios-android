import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/profile/farm_profile_provider.dart';
import '../api/api_client.dart';
import '../onboarding/onboarding_provider.dart';
import 'account_models.dart';
import 'account_repository.dart';
import 'farm_context_models.dart';
import 'farm_context_repository.dart';
import 'secure_storage.dart';

final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => AccountRepository(ref.watch(apiClientProvider)),
);

final farmContextRepositoryProvider = Provider<FarmContextRepository>(
  (ref) => FarmContextRepository(ref.watch(apiClientProvider)),
);

class AccountState {
  final bool hydrated;
  final AccountUser? user;
  final FarmContext? farmContext;

  const AccountState({required this.hydrated, required this.user, required this.farmContext});
  const AccountState.initial() : hydrated = false, user = null, farmContext = null;

  bool get isLoggedIn => user != null;

  AccountState copyWith({bool? hydrated, AccountUser? user, FarmContext? farmContext}) => AccountState(
        hydrated: hydrated ?? this.hydrated,
        user: user ?? this.user,
        farmContext: farmContext ?? this.farmContext,
      );
}

/// Tracks the signed-in Ulimi account and its active farm. Unlike
/// [pinProvider] (a local device lock), this gates every screen — see the
/// router's redirect — because every data screen in the app now reads from
/// Ulimi's mobile API, which requires a signed-in session.
final accountProvider = StateNotifierProvider<AccountNotifier, AccountState>(
  (ref) => AccountNotifier(ref),
);

/// Resolves the cached session (if any) before the router's first redirect
/// decision, mirroring [pinHydrationProvider]'s cold-start role.
final accountHydrationProvider = FutureProvider<void>((ref) async {
  await ref.read(accountProvider.notifier).hydrate();
});

class AccountNotifier extends StateNotifier<AccountState> {
  final Ref _ref;
  AccountNotifier(this._ref) : super(const AccountState.initial());

  Future<void> hydrate() async {
    final loggedIn = await SecureStorage.isLoggedIn();
    if (!loggedIn) {
      state = state.copyWith(hydrated: true);
      return;
    }
    final userId = await SecureStorage.getUserId();
    final email = await SecureStorage.getUserEmail();
    // The access token survives app restarts in secure storage; re-fetching
    // farm context (rather than caching it) keeps role/farm membership
    // always current, and doubles as an early check that the session is
    // still valid before the user sees a stale, signed-in-looking screen.
    try {
      final farmContext = await _ref.read(farmContextRepositoryProvider).fetch();
      await SecureStorage.saveFarmId(farmContext.activeFarmId);
      state = AccountState(
        hydrated: true,
        user: AccountUser(id: userId ?? '', name: null, email: email ?? ''),
        farmContext: farmContext,
      );
    } catch (_) {
      // Couldn't reach the server (offline) or the session is dead — either
      // way, fall back to "signed out" rather than showing a farm-context-less
      // signed-in state the rest of the app can't actually use.
      await SecureStorage.clearAuth();
      state = state.copyWith(hydrated: true);
    }
  }

  Future<void> login({required String email, required String password}) async {
    final result = await _ref.read(accountRepositoryProvider).login(email: email, password: password);
    await _applyAuthResult(result);
  }

  Future<void> _applyAuthResult(AuthResult result) async {
    await SecureStorage.saveToken(result.accessToken);
    await SecureStorage.saveRefreshToken(result.refreshToken);
    await SecureStorage.saveUserId(result.user.id);
    await SecureStorage.saveUserEmail(result.user.email);

    final farmContext = await _ref.read(farmContextRepositoryProvider).fetch();
    await SecureStorage.saveFarmId(farmContext.activeFarmId);

    // Skip the local onboarding form entirely for a signed-in user — the
    // farm identity now comes from the server, not a manually-typed profile.
    final activeFarm = farmContext.activeFarm;
    if (activeFarm != null) {
      await _ref.read(farmProfileRepositoryProvider).saveProfile(
            name: activeFarm.name,
            location: activeFarm.location ?? '',
          );
      _ref.read(onboardingProvider.notifier).markComplete();
    }

    state = AccountState(hydrated: true, user: result.user, farmContext: farmContext);
  }

  Future<void> switchFarm(String farmId) async {
    await SecureStorage.saveFarmId(farmId);
    final farmContext = await _ref.read(farmContextRepositoryProvider).fetch();
    state = state.copyWith(farmContext: farmContext);
  }

  Future<void> logout() async {
    final refreshToken = await SecureStorage.getRefreshToken();
    try {
      await _ref.read(accountRepositoryProvider).logout(refreshToken);
    } catch (_) {
      // Best-effort server-side revoke — clearing the local session below is
      // what actually signs the device out either way.
    }
    await SecureStorage.clearAuth();
    state = const AccountState(hydrated: true, user: null, farmContext: null);
  }
}
