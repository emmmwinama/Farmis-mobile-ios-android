import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import 'account_models.dart';
import 'account_repository.dart';
import 'secure_storage.dart';

final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => AccountRepository(ref.watch(apiClientProvider)),
);

class AccountState {
  final bool hydrated;
  final Account? account;

  const AccountState({required this.hydrated, required this.account});
  const AccountState.initial() : hydrated = false, account = null;

  bool get isLoggedIn => account != null;

  AccountState copyWith({bool? hydrated, Account? account}) => AccountState(
        hydrated: hydrated ?? this.hydrated,
        account: account,
      );
}

/// Tracks the signed-in account, if any. Signing in is entirely optional —
/// unlike [pinProvider] this never gates navigation; it only unlocks the
/// cloud backup/restore actions surfaced from the Profile screen.
final accountProvider = StateNotifierProvider<AccountNotifier, AccountState>(
  (ref) => AccountNotifier(ref),
);

/// Resolves the cached account (if any) before the Profile screen first
/// renders, mirroring [pinHydrationProvider]'s cold-start role.
final accountHydrationProvider = FutureProvider<void>((ref) async {
  await ref.read(accountProvider.notifier).hydrate();
});

class AccountNotifier extends StateNotifier<AccountState> {
  final Ref _ref;
  AccountNotifier(this._ref) : super(const AccountState.initial());

  Future<void> hydrate() async {
    final cached = await SecureStorage.getProfileJson();
    final loggedIn = await SecureStorage.isLoggedIn();
    if (loggedIn && cached != null && cached.isNotEmpty) {
      try {
        state = AccountState(
          hydrated: true,
          account: Account.fromJson(jsonDecode(cached) as Map<String, dynamic>),
        );
      } catch (_) {
        state = state.copyWith(hydrated: true);
      }
    } else {
      state = state.copyWith(hydrated: true);
    }
  }

  Future<void> login({required String email, required String password}) async {
    final result = await _ref.read(accountRepositoryProvider).login(email: email, password: password);
    await _applyAuthResult(result);
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? farmName,
  }) async {
    final result = await _ref
        .read(accountRepositoryProvider)
        .register(name: name, email: email, password: password, farmName: farmName);
    await _applyAuthResult(result);
  }

  Future<void> _applyAuthResult(AuthResult result) async {
    await SecureStorage.saveToken(result.token);
    await SecureStorage.saveUserId(result.account.user.id);
    if (result.account.farm != null) await SecureStorage.saveFarmId(result.account.farm!.id);
    await SecureStorage.saveProfileJson(jsonEncode(result.account.toJson()));
    state = state.copyWith(hydrated: true, account: result.account);
  }

  /// Re-fetches plan/farm info from the server — call after a purchase, or
  /// whenever the Profile screen wants a fresh read rather than the cache.
  Future<void> refresh() async {
    if (!state.isLoggedIn) return;
    final account = await _ref.read(accountRepositoryProvider).fetchProfile();
    await SecureStorage.saveProfileJson(jsonEncode(account.toJson()));
    state = state.copyWith(hydrated: true, account: account);
  }

  Future<void> logout() async {
    await SecureStorage.clearAuth();
    state = const AccountState(hydrated: true, account: null);
  }
}
