import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/auth/secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final store = <String, String>{};

  setUp(() {
    store.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      final args = call.arguments as Map?;
      final key = args?['key'] as String?;
      switch (call.method) {
        case 'write':
          store[key!] = args!['value'] as String;
          return null;
        case 'read':
          return store[key];
        case 'delete':
          store.remove(key);
          return null;
        case 'readAll':
          return store;
        default:
          return null;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('hasPin is false before a PIN is set', () async {
    expect(await SecureStorage.hasPin(), isFalse);
  });

  test('savePin then hasPin is true and verifyPin accepts the same PIN',
      () async {
    await SecureStorage.savePin('1234');

    expect(await SecureStorage.hasPin(), isTrue);
    expect(await SecureStorage.verifyPin('1234'), isTrue);
  });

  test('verifyPin rejects a wrong PIN', () async {
    await SecureStorage.savePin('1234');

    expect(await SecureStorage.verifyPin('4321'), isFalse);
  });

  test('two different devices/salts hash the same PIN differently',
      () async {
    await SecureStorage.savePin('1234');
    final firstHash = store['pin_hash'];

    await SecureStorage.clearPin();
    await SecureStorage.savePin('1234');
    final secondHash = store['pin_hash'];

    expect(firstHash, isNot(equals(secondHash)));
  });

  test('clearPin removes the stored PIN entirely', () async {
    await SecureStorage.savePin('1234');
    await SecureStorage.clearPin();

    expect(await SecureStorage.hasPin(), isFalse);
    expect(await SecureStorage.verifyPin('1234'), isFalse);
  });
}
