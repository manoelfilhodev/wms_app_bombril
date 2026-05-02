import 'package:shared_preferences/shared_preferences.dart';

import '../services/token_storage_service.dart';

class UserService {
  static Future<void> saveUser({
    required String token,
    required int id,
    required String nome,
    required String nivel,
    required String tipo,
    required int unidade,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await TokenStorageService.instance.saveToken(token);
    await TokenStorageService.instance.markNeedsRevalidation(false);
    await prefs.setInt('usuario_id', id);
    await prefs.setString('nome', nome);
    await prefs.setString('nivel', nivel);

    // Novos campos
    await prefs.setString('tipo', tipo);
    await prefs.setInt('unidade', unidade);
  }

  // ===============================
  // GETTERS
  // ===============================

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('usuario_id');
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nome');
  }

  static Future<String?> getUserNivel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('nivel');
  }

  static Future<String?> getUserTipo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('tipo');
  }

  static Future<int?> getUserUnidade() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('unidade');
  }

  static Future<String?> getToken() async {
    final secureToken = await TokenStorageService.instance.getToken();
    if (secureToken != null && secureToken.isNotEmpty) return secureToken;

    final prefs = await SharedPreferences.getInstance();
    final legacyToken = prefs.getString('token');
    if (legacyToken != null && legacyToken.isNotEmpty) {
      await TokenStorageService.instance.saveToken(legacyToken);
      await prefs.remove('token');
      return legacyToken;
    }
    return null;
  }

  // ===============================
  // LOGOUT
  // ===============================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await TokenStorageService.instance.clearToken();
  }
}
