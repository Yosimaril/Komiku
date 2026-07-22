import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _keyToken = 'JWT_TOKEN';
  static const _keyUser = 'USER_DATA';

  final FlutterSecureStorage _storage;

  const SecureStorageService(this._storage);

  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: _keyToken);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _keyToken);
  }

  Future<void> saveUser(String userJson) async {
    await _storage.write(key: _keyUser, value: userJson);
  }

  Future<String?> getUser() async {
    return _storage.read(key: _keyUser);
  }

  Future<void> deleteUser() async {
    await _storage.delete(key: _keyUser);
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }
}
