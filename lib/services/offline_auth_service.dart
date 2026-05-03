import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/exceptions/auth_exception.dart';
import '../database/local_database_service.dart';
import '../services/api_service.dart';
import '../services/device_identity_service.dart';
import '../services/token_storage_service.dart';
import 'auth_login_result.dart';

class OfflineAuthService {
  OfflineAuthService({
    ApiService? apiService,
    LocalDatabaseService? localDatabaseService,
    DeviceIdentityService? deviceIdentityService,
  })  : _api = apiService ?? ApiService.instance,
        _db = localDatabaseService ?? LocalDatabaseService.instance,
        _deviceIdentity =
            deviceIdentityService ?? DeviceIdentityService.instance;

  final ApiService _api;
  final LocalDatabaseService _db;
  final DeviceIdentityService _deviceIdentity;

  Future<AuthLoginResult> login({
    required String username,
    required String password,
  }) async {
    final normalizedUsername = username.trim();
    final passwordHash = _hashPassword(password.trim());
    final deviceId = await _deviceIdentity.getOrCreateDeviceId();

    try {
      final data = await _api.login(
        username: normalizedUsername,
        password: password.trim(),
        deviceId: deviceId,
      );
      final token = data['token']?.toString() ?? '';
      final userRaw = data['user'];
      final user = userRaw is Map
          ? Map<String, dynamic>.from(userRaw)
          : <String, dynamic>{};
      if (token.isEmpty || user.isEmpty) {
        throw AuthException('Resposta invalida de autenticacao');
      }

      await TokenStorageService.instance.saveToken(token);
      await TokenStorageService.instance.markNeedsRevalidation(false);
      if (!kIsWeb) {
        await _db.upsertUser(
          idServer: _toInt(user['id_user'] ?? user['id']),
          username: normalizedUsername,
          nome: user['nome']?.toString() ?? '',
          nivel: user['nivel']?.toString(),
          tipo: user['tipo']?.toString(),
          unidade: _toIntOrNull(user['unidade']),
          passwordHash: passwordHash,
          token: token,
          tokenNeedsRevalidation: false,
        );
      }

      return AuthLoginResult(
        token: token,
        user: user,
        isOffline: false,
        permissions: _extractPermissions(data['permissions']),
      );
    } on DioException catch (e) {
      if (_isAuthError(e)) {
        throw AuthException(_resolveAuthMessage(e.response?.data));
      }

      if (_isServerError(e)) {
        try {
          return await _loginOffline(
            username: normalizedUsername,
            passwordHash: passwordHash,
          );
        } catch (_) {
          throw AuthException(
            'Servidor indisponivel no momento. Tente novamente em instantes.',
          );
        }
      }

      if (!_isRecoverableNetworkError(e)) rethrow;
      return _loginOffline(
        username: normalizedUsername,
        passwordHash: passwordHash,
      );
    }
  }

  Future<AuthLoginResult> _loginOffline({
    required String username,
    required String passwordHash,
  }) async {
    if (kIsWeb) {
      throw AuthException('Login offline nao disponivel no Web.');
    }

    if (!await _hasValidOfflineSession()) {
      throw AuthException('Sessao offline expirada. Conecte-se novamente.');
    }

    final user = await _db.findUserByUsernameAndPassword(
      username: username,
      passwordHash: passwordHash,
    );

    if (user == null) {
      throw AuthException('Sem internet e sem credencial offline valida.');
    }

    final token = user['token']?.toString() ??
        await TokenStorageService.instance.getToken() ??
        '';
    if (token.isNotEmpty) {
      await TokenStorageService.instance.saveToken(token);
    }

    return AuthLoginResult(
      token: token,
      user: {
        'id_user': user['id_server'],
        'nome': user['nome'],
        'nivel': user['nivel'],
        'tipo': user['tipo'],
        'unidade': user['unidade'],
      },
      isOffline: true,
    );
  }

  bool _isRecoverableNetworkError(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.response == null;
  }

  bool _isServerError(DioException e) {
    final status = e.response?.statusCode;
    return status != null && status >= 500;
  }

  bool _isAuthError(DioException e) {
    final status = e.response?.statusCode;
    return status == 401 || status == 403 || status == 422;
  }

  String _resolveAuthMessage(dynamic responseData) {
    if (responseData is Map) {
      final map = Map<String, dynamic>.from(responseData);
      final message = map['message']?.toString().trim();
      if (message != null && message.isNotEmpty) return message;
    }

    return 'Usuario, senha ou dispositivo nao autorizado.';
  }

  Future<bool> _hasValidOfflineSession() async {
    final prefs = await SharedPreferences.getInstance();
    final expiresAt = prefs.getInt('offline_session_valid_until');
    if (expiresAt == null) return false;
    return DateTime.now().millisecondsSinceEpoch <= expiresAt;
  }

  List<String> _extractPermissions(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList(growable: false);
    }
    return const <String>[];
  }

  String _hashPassword(String value) {
    final bytes = utf8.encode(value);
    return sha256.convert(bytes).toString();
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  int? _toIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
