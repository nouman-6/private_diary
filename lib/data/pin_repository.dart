import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinRepository {
  final _storage = const FlutterSecureStorage();
  static const _pinKey = 'user_pin';

  Future<void> setPin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
  }

  Future<String?> getPin() async {
    return await _storage.read(key: _pinKey);
  }

  Future<bool> hasPin() async {
    final pin = await getPin();
    return pin != null && pin.isNotEmpty;
  }

  Future<bool> verifyPin(String pin) async {
    final savedPin = await getPin();
    return savedPin == pin;
  }

  Future<void> removePin() async {
    await _storage.delete(key: _pinKey);
  }
}