import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorageService {
  TokenStorageService._();
  static final TokenStorageService instance = TokenStorageService._();

  static const _tokenKey = 'auth_token_secure';
  static const _tokenRevalidateKey = 'token_needs_revalidation';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _secureStorage.read(key: _tokenKey);
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  Future<void> markNeedsRevalidation(bool value) async {
    await _secureStorage.write(
      key: _tokenRevalidateKey,
      value: value ? '1' : '0',
    );
  }

  Future<bool> needsRevalidation() async {
    return (await _secureStorage.read(key: _tokenRevalidateKey)) == '1';
  }

  Future<void> migrateFromLegacyPrefs() async {
    final token = await getToken();
    if (token != null && token.isNotEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final legacyToken = prefs.getString('token');
    if (legacyToken != null && legacyToken.isNotEmpty) {
      await saveToken(legacyToken);
      await prefs.remove('token');
    }
  }
}

