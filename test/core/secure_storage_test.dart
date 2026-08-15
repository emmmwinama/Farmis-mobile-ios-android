import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/auth/secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('clearAuth deletes only authentication keys', () async {
    await SecureStorage.clearAuth();

    expect(calls, hasLength(4));
    expect(calls.every((call) => call.method == 'delete'), isTrue);
    expect(calls.any((call) => call.method == 'deleteAll'), isFalse);

    final deletedKeys = calls
        .map((call) => (call.arguments as Map)['key'])
        .whereType<String>()
        .toSet();
    expect(
      deletedKeys,
      containsAll({'auth_token', 'user_id', 'farm_id', 'profile_json'}),
    );
    expect(deletedKeys, isNot(contains('agrivault.sync.queue')));
  });
}
