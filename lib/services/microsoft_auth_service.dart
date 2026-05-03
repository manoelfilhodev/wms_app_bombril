import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

import '../core/config/app_config.dart';
import '../core/exceptions/auth_exception.dart';
import '../database/local_database_service.dart';
import '../services/api_service.dart';
import '../services/device_identity_service.dart';
import '../services/token_storage_service.dart';
import 'auth_login_result.dart';
import 'microsoft_web_auth.dart';

class MicrosoftAuthService {
  MicrosoftAuthService({
    FlutterAppAuth? appAuth,
    ApiService? apiService,
    DeviceIdentityService? deviceIdentityService,
    LocalDatabaseService? localDatabaseService,
  })  : _appAuth = appAuth ?? const FlutterAppAuth(),
        _api = apiService ?? ApiService.instance,
        _deviceIdentity =
            deviceIdentityService ?? DeviceIdentityService.instance,
        _db = localDatabaseService ?? LocalDatabaseService.instance;

  final FlutterAppAuth _appAuth;
  final ApiService _api;
  final DeviceIdentityService _deviceIdentity;
  final LocalDatabaseService _db;

  Future<AuthLoginResult> login() async {
    if (!AppConfig.isMicrosoftAuthConfigured) {
      throw AuthException(
        'Login Microsoft nao configurado. Informe AZURE_TENANT_ID e AZURE_CLIENT_ID.',
      );
    }

    final deviceId = await _deviceIdentity.getOrCreateDeviceId();

    try {
      final tokens = kIsWeb ? await _webTokens() : await _nativeTokens();

      if (tokens.accessToken.isEmpty) {
        throw AuthException('Login Microsoft cancelado ou sem access_token.');
      }
      if (tokens.idToken.isEmpty) {
        throw AuthException('Login Microsoft sem id_token.');
      }

      final data = await _api.loginMicrosoft(
        accessToken: tokens.accessToken,
        idToken: tokens.idToken,
        deviceId: deviceId,
        platform: _platformName(),
      );

      return _handleBackendSession(data);
    } on AuthException {
      rethrow;
    } on DioException catch (e) {
      throw AuthException(_resolveAuthMessage(e.response?.data));
    } catch (e) {
      throw AuthException('Nao foi possivel concluir o login Microsoft: $e');
    }
  }

  Future<_MicrosoftTokens> _nativeTokens() async {
    final microsoftResult = await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        AppConfig.microsoftClientId,
        AppConfig.microsoftRedirectUri,
        serviceConfiguration: AuthorizationServiceConfiguration(
          authorizationEndpoint: AppConfig.microsoftAuthorizationEndpoint,
          tokenEndpoint: AppConfig.microsoftTokenEndpoint,
        ),
        scopes: AppConfig.microsoftScopeList,
      ),
    );

    return _MicrosoftTokens(
      accessToken: microsoftResult.accessToken ?? '',
      idToken: microsoftResult.idToken ?? '',
    );
  }

  Future<_MicrosoftTokens> _webTokens() async {
    final redirectTokens = await takeMicrosoftWebRedirectResult();
    if (redirectTokens == null) {
      await startMicrosoftWebLogin();
      throw AuthException('Redirecionando para login Microsoft...');
    }

    return _MicrosoftTokens(
      accessToken: redirectTokens.accessToken,
      idToken: redirectTokens.idToken,
    );
  }

  Future<AuthLoginResult> _handleBackendSession(
      Map<String, dynamic> data) async {
    final token = data['token']?.toString() ?? '';
    final userRaw = data['user'];
    final user = userRaw is Map
        ? Map<String, dynamic>.from(userRaw)
        : <String, dynamic>{};

    if (token.isEmpty || user.isEmpty) {
      throw AuthException('Resposta invalida de autenticacao Microsoft.');
    }

    await TokenStorageService.instance.saveToken(token);
    await TokenStorageService.instance.markNeedsRevalidation(false);

    if (!kIsWeb) {
      await _db.upsertUser(
        idServer: _toInt(user['id_user'] ?? user['id']),
        username: _resolveUsername(user),
        nome: user['nome']?.toString() ?? user['name']?.toString() ?? '',
        nivel: user['nivel']?.toString(),
        tipo: user['tipo']?.toString(),
        unidade: _toIntOrNull(user['unidade']),
        passwordHash: '',
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
  }

  String _resolveAuthMessage(dynamic responseData) {
    if (responseData is Map) {
      final map = Map<String, dynamic>.from(responseData);
      final message = map['message']?.toString().trim();
      if (message != null && message.isNotEmpty) return message;
    }
    return 'Login Microsoft nao autorizado.';
  }

  String _resolveUsername(Map<String, dynamic> user) {
    return user['email']?.toString() ??
        user['upn']?.toString() ??
        user['username']?.toString() ??
        '';
  }

  List<String> _extractPermissions(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList(growable: false);
    }
    return const <String>[];
  }

  String _platformName() {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
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

class _MicrosoftTokens {
  const _MicrosoftTokens({
    required this.accessToken,
    required this.idToken,
  });

  final String accessToken;
  final String idToken;
}
