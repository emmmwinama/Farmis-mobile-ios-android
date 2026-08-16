import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'secure_storage.dart';

class PinLockState {
  final bool hasPin;
  final bool isUnlocked;

  const PinLockState({required this.hasPin, required this.isUnlocked});

  const PinLockState.initial() : hasPin = false, isUnlocked = false;

  PinLockState copyWith({bool? hasPin, bool? isUnlocked}) => PinLockState(
        hasPin: hasPin ?? this.hasPin,
        isUnlocked: isUnlocked ?? this.isUnlocked,
      );
}

final pinProvider = StateNotifierProvider<PinNotifier, PinLockState>(
  (ref) => PinNotifier(),
);

/// Loads whether a PIN has already been set on this device before the
/// router makes its first redirect decision — mirrors the old
/// `authHydrationProvider`'s role of resolving stored state on cold start.
final pinHydrationProvider = FutureProvider<bool>((ref) async {
  final notifier = ref.read(pinProvider.notifier);
  await notifier.hydrate();
  return ref.read(pinProvider).hasPin;
});

/// Local app-lock replacing server-based JWT auth. `isUnlocked` starts
/// false on every cold app start and stays true for the process lifetime
/// once the correct PIN is entered — mirroring how the old JWT-in-memory
/// session behaved.
class PinNotifier extends StateNotifier<PinLockState> {
  PinNotifier() : super(const PinLockState.initial());

  Future<void> hydrate() async {
    final hasPin = await SecureStorage.hasPin();
    state = state.copyWith(hasPin: hasPin);
  }

  Future<void> setPin(String pin) async {
    await SecureStorage.savePin(pin);
    state = state.copyWith(hasPin: true, isUnlocked: true);
  }

  Future<bool> unlock(String pin) async {
    final ok = await SecureStorage.verifyPin(pin);
    if (ok) {
      state = state.copyWith(isUnlocked: true);
    }
    return ok;
  }

  void lock() {
    state = state.copyWith(isUnlocked: false);
  }

  Future<void> resetPin() async {
    await SecureStorage.clearPin();
    state = const PinLockState.initial();
  }
}
