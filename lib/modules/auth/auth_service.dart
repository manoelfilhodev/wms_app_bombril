import 'package:dio/dio.dart';

import '../../core/api_client.dart';
import '../../core/config/app_config.dart';
import '../../core/exceptions/auth_exception.dart';

class AuthService {
  static const String _baseUrl = AppConfig.apiBaseUrl;
  final ApiClient _apiClient;

  AuthService({ApiClient? apiClient})
    : _apiClient =
          apiClient ??
          ApiClient(
            baseUrl: _baseUrl,
            getToken: () async => null,
            handleUnauthorized: false,
          );

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/login',
        data: {'username': username, 'password': password},
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      throw Exception('Resposta inválida do servidor');
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401 || status == 403 || status == 422) {
        throw AuthException(_resolveAuthMessage(e.response?.data));
      }
      rethrow;
    }
  }

  String _resolveAuthMessage(dynamic responseData) {
    if (responseData is Map) {
      final map = Map<String, dynamic>.from(responseData);
      final message = map['message']?.toString().trim();
      if (message != null && message.isNotEmpty) {
        return message;
      }

      final errors = map['errors'];
      if (errors is Map) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) {
            final first = value.first?.toString().trim();
            if (first != null && first.isNotEmpty) {
              return first;
            }
          }
        }
      }
    }

    return 'Usuário ou senha inválidos';
  }
}
