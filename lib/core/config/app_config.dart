class AppConfig {
  AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000/api',
  );

  static const String microsoftTenantId = String.fromEnvironment(
    'AZURE_TENANT_ID',
    defaultValue: '1e96a85e-cc04-44a2-a465-3ebcd9feb446',
  );

  static const String microsoftClientId = String.fromEnvironment(
    'AZURE_CLIENT_ID',
    defaultValue: '19f63dc1-2622-4354-b0f4-09bb6a879537',
  );

  static const String microsoftRedirectUri = String.fromEnvironment(
    'AZURE_REDIRECT_URI',
    defaultValue: 'http://localhost:8080',
  );

  static const String microsoftScopes = String.fromEnvironment(
    'AZURE_SCOPES',
    defaultValue: 'openid profile email offline_access User.Read',
  );

  static bool get isMicrosoftAuthConfigured =>
      microsoftTenantId.trim().isNotEmpty &&
      microsoftClientId.trim().isNotEmpty;

  static String get microsoftAuthorizationEndpoint =>''
      'https://login.microsoftonline.com/$microsoftTenantId/oauth2/v2.0/authorize';

  static String get microsoftTokenEndpoint =>
      'https://login.microsoftonline.com/$microsoftTenantId/oauth2/v2.0/token';

  static List<String> get microsoftScopeList => microsoftScopes
      .split(RegExp(r'\s+'))
      .map((scope) => scope.trim())
      .where((scope) => scope.isNotEmpty)
      .toList(growable: false);

  static Uri apiUri(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final normalizedBaseUrl = apiBaseUrl.endsWith('/')
        ? apiBaseUrl.substring(0, apiBaseUrl.length - 1)
        : apiBaseUrl;
    final uri = Uri.parse('$normalizedBaseUrl$normalizedPath');
    return queryParameters == null
        ? uri
        : uri.replace(queryParameters: queryParameters);
  }
}
