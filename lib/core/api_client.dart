import 'package:dio/dio.dart';

class ApiClient {
  static void Function()? _unauthorizedHandler;
  final Dio dio;

  static void setUnauthorizedHandler(void Function()? handler) {
    _unauthorizedHandler = handler;
  }

  ApiClient({
    required String baseUrl,
    required Future<String?> Function() getToken,
    bool handleUnauthorized = true,
    Duration connectTimeout = const Duration(seconds: 10),
    Duration receiveTimeout = const Duration(seconds: 25),
  }) : dio = Dio(
         BaseOptions(
           baseUrl: baseUrl,
           connectTimeout: connectTimeout,
           receiveTimeout: receiveTimeout,
         ),
       ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Accept'] = 'application/json';
          return handler.next(options);
        },
        onError: (e, handler) {
          if (handleUnauthorized && e.response?.statusCode == 401) {
            _unauthorizedHandler?.call();
          }
          return handler.next(e);
        },
      ),
    );
  }
}
