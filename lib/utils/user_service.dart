import 'dart:convert';

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
    List<String> permissions = const <String>[],
    bool refreshOfflineSession = true,
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
    await prefs.setString('permissions', jsonEncode(permissions));
    if (refreshOfflineSession) {
      await prefs.setInt(
        'offline_session_valid_until',
        DateTime.now().add(const Duration(hours: 12)).millisecondsSinceEpoch,
      );
    }
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

  static Future<List<String>> getPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('permissions');
    if (raw == null || raw.isEmpty) return const <String>[];

    final decoded = jsonDecode(raw);
    if (decoded is List) {
      return decoded.map((item) => item.toString()).toList(growable: false);
    }
    return const <String>[];
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
    final deviceId = prefs.getString('systex_wms_device_id');
    final legacyDeviceId = prefs.getString('stretch_device_id');

    await prefs.clear();

    if (deviceId != null && deviceId.isNotEmpty) {
      await prefs.setString('systex_wms_device_id', deviceId);
    }
    if (legacyDeviceId != null && legacyDeviceId.isNotEmpty) {
      await prefs.setString('stretch_device_id', legacyDeviceId);
    }

    await TokenStorageService.instance.clearToken();
  }
}
