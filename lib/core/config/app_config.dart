class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://systex.com.br/wms/public/api',
  );

  static Uri apiUri(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$apiBaseUrl$normalizedPath');
    return queryParameters == null
        ? uri
        : uri.replace(queryParameters: queryParameters);
  }
}
