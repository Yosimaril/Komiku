import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _keyToken = 'JWT_TOKEN';

  final FlutterSecureStorage _storage;

  const SecureStorageService(this._storage);

  Future<void> saveToken(String token) async {
    await _storage.write(
      key: _keyToken,
      value: token,
    );
  }

  Future<String?> getToken() async {
    return _storage.read(key: _keyToken);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _keyToken);
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }
}