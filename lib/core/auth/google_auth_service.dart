import 'package:google_sign_in/google_sign_in.dart';

/// Thin wrapper around the native Google Sign-In flow — the only job is
/// getting an ID token to hand to the backend, which does the actual
/// verification (see Farmis' lib/googleAuth.ts). Requires OAuth client IDs
/// configured natively (google-services.json on Android, GIDClientID/URL
/// scheme on iOS) — signInAndGetIdToken() throws if that isn't set up yet.
class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: const ['email']);

  /// Returns null if the user closes the account picker without choosing
  /// one — not an error, just "they changed their mind."
  Future<String?> signInAndGetIdToken() async {
    final account = await _googleSignIn.signIn();
    if (account == null) return null;
    final auth = await account.authentication;
    return auth.idToken;
  }

  Future<void> signOut() => _googleSignIn.signOut();
}
