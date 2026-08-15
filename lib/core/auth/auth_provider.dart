import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_repository.dart';
import '../../models/auth_result.dart';

final authRepositoryProvider = Provider<AuthRepository>(
      (_) => AuthRepository(),
);

// Holds the current AuthResult (null = logged out)
final authProvider = StateNotifierProvider<AuthNotifier, AuthResult?>(
      (ref) => AuthNotifier(ref.read(authRepositoryProvider)),
);

final authHydrationProvider = FutureProvider<AuthResult?>((ref) async {
  return ref.read(authProvider.notifier).hydrate();
});

class AuthNotifier extends StateNotifier<AuthResult?> {
  final AuthRepository _repo;
  AuthNotifier(this._repo) : super(null);

  Future<AuthResult?> hydrate() async {
    final stored = await _repo.loadStoredAuth();
    if (stored != null) {
      state = stored;
    }

    try {
      final refreshed = await _repo.refreshProfile();
      if (refreshed != null) {
        state = refreshed;
        return refreshed;
      }
    } catch (_) {
      // Keep the stored auth snapshot when the profile endpoint is unavailable.
    }

    return state;
  }

  Future<void> login(String email, String password) async {
    final result = await _repo.login(email, password);
    state = result;
    try {
      final refreshed = await _repo.refreshProfile();
      if (refreshed != null) {
        state = refreshed;
      }
    } catch (_) {
      // Login already succeeded; profile refresh is opportunistic.
    }
  }

  Future<void> refreshProfile() async {
    final result = await _repo.refreshProfile();
    if (result != null) {
      state = result;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = null;
  }

  /// Clears in-memory auth state without touching storage — storage is
  /// already cleared by the API client when a request comes back 401.
  void forceLogout() {
    state = null;
  }
}
