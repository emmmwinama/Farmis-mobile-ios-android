import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/models/auth_result.dart';

void main() {
  final userJson = {
    'id': 'u1',
    'name': 'Ada',
    'email': 'ada@example.com',
    'role': 'owner',
  };

  group('AuthResult.fromJson', () {
    test('parses the token from the payload', () {
      final result = AuthResult.fromJson({'token': 'abc', 'user': userJson});

      expect(result.token, 'abc');
      expect(result.user.email, 'ada@example.com');
      expect(result.farm, isNull);
      expect(result.subscription, isNull);
    });

    test('parses an embedded farm when present', () {
      final result = AuthResult.fromJson({
        'token': 'abc',
        'user': userJson,
        'farm': {'id': 'f1', 'name': 'Kalekeni', 'location': 'Lilongwe'},
      });

      expect(result.farm?.name, 'Kalekeni');
    });
  });

  group('AuthResult.fromJsonWithToken', () {
    test('prefers a token embedded in the payload over the fallback', () {
      final result = AuthResult.fromJsonWithToken(
        {'token': 'from-payload', 'user': userJson},
        'fallback-token',
      );

      expect(result.token, 'from-payload');
    });

    test('falls back to the supplied token when the payload has none', () {
      final result = AuthResult.fromJsonWithToken(
        {'user': userJson},
        'fallback-token',
      );

      expect(result.token, 'fallback-token');
    });
  });

  test('toJson/fromJson round-trips', () {
    final original = AuthResult.fromJson({'token': 'abc', 'user': userJson});
    final restored = AuthResult.fromJson(original.toJson());

    expect(restored.token, original.token);
    expect(restored.user.id, original.user.id);
  });
}
