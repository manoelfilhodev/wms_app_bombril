import 'package:dio/dio.dart';

import '../core/config/app_config.dart';
import '../services/token_storage_service.dart';

class ApiService {
  ApiService._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 25),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorageService.instance.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Accept'] = 'application/json';
          handler.next(options);
        },
        onError: (e, handler) async {
          if (e.response?.statusCode == 401) {
            await TokenStorageService.instance.markNeedsRevalidation(true);
          }
          handler.next(e);
        },
      ),
    );
  }

  static final ApiService instance = ApiService._();
  static const String _baseUrl = AppConfig.apiBaseUrl;

  late final Dio _dio;
  Dio get dio => _dio;

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await _dio.post(
      '/login',
      data: {'username': username, 'password': password},
    );
    return _asMap(response.data);
  }

  Future<List<Map<String, dynamic>>> fetchFuncionarios() async {
    final response = await _dio.get('/funcionarios');
    return _extractList(response.data);
  }

  Future<Map<String, dynamic>> createFuncionario(Map<String, dynamic> payload) async {
    final response = await _dio.post('/funcionarios', data: payload);
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> createContagemLivre(Map<String, dynamic> payload) async {
    final response = await _dio.post('/contagem-livre/store', data: payload);
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> apontarKit(Map<String, dynamic> payload) async {
    try {
      final response = await _dio.post('/kits/apontar-etiqueta', data: payload);
      return _asMap(response.data);
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return _asMap(e.response!.data);
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> buscarDescricaoContagemLivrePorEan(String ean) async {
    final response = await _dio.get(
      '/contagem-livre/buscarDescricaoApi',
      queryParameters: {'ean': ean},
    );
    final map = _asMap(response.data);
    final data = map['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    return null;
  }

  Future<Map<String, dynamic>> updateFuncionario({
    required int idServer,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _dio.put('/funcionarios/$idServer', data: payload);
    return _asMap(response.data);
  }

  Future<void> deleteFuncionario(int idServer) async {
    await _dio.delete('/funcionarios/$idServer');
  }

  static Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {'data': data};
  }

  static List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }

    final map = _asMap(data);
    final nested = map['data'] ?? map['items'] ?? map['funcionarios'];
    if (nested is List) {
      return nested
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
  }
}
