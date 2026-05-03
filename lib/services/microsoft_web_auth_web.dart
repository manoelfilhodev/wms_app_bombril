// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../core/config/app_config.dart';
import 'token_storage_service.dart';

class MicrosoftWebTokens {
  const MicrosoftWebTokens({
    required this.accessToken,
    required this.idToken,
  });

  final String accessToken;
  final String idToken;
}

const _pkceVerifierKey = 'microsoft_pkce_code_verifier';

bool hasMicrosoftWebRedirectResult() {
  return Uri.base.queryParameters.containsKey('code');
}

Future<MicrosoftWebTokens?> takeMicrosoftWebRedirectResult() async {
  final code = Uri.base.queryParameters['code'];

  if (code == null || code.isEmpty) {
    return null;
  }

  final codeVerifier = html.window.sessionStorage[_pkceVerifierKey];

  if (codeVerifier == null || codeVerifier.isEmpty) {
    throw Exception('PKCE code_verifier nao encontrado.');
  }

  final redirectUri = AppConfig.microsoftRedirectUri;

  final response = await html.HttpRequest.postFormData(
    AppConfig.microsoftTokenEndpoint,
    {
      'client_id': AppConfig.microsoftClientId,
      'grant_type': 'authorization_code',
      'code': code,
      'redirect_uri': redirectUri,
      'code_verifier': codeVerifier,
      'scope': AppConfig.microsoftScopes,
    },
  );

  html.window.sessionStorage.remove(_pkceVerifierKey);

  final data =
      jsonDecode(response.responseText ?? '{}') as Map<String, dynamic>;

  final accessToken = data['access_token']?.toString() ?? '';
  final idToken = data['id_token']?.toString() ?? '';

  if (accessToken.isEmpty || idToken.isEmpty) {
    throw Exception('Microsoft nao retornou access_token/id_token.');
  }

  final cleanUri = Uri.base.replace(query: '', fragment: '');
  html.window.history
      .replaceState(null, html.document.title, cleanUri.toString());

  return MicrosoftWebTokens(
    accessToken: accessToken,
    idToken: idToken,
  );
}

Future<void> startMicrosoftWebLogin() async {
  final nonce = _randomUrlSafe(24);
  final codeVerifier = _randomUrlSafe(64);
  final codeChallenge = _codeChallenge(codeVerifier);

  html.window.sessionStorage[_pkceVerifierKey] = codeVerifier;

  final redirectUri = AppConfig.microsoftRedirectUri;

  final authUri = Uri.parse(AppConfig.microsoftAuthorizationEndpoint).replace(
    queryParameters: {
      'client_id': AppConfig.microsoftClientId,
      'response_type': 'code',
      'redirect_uri': redirectUri,
      'response_mode': 'query',
      'scope': AppConfig.microsoftScopes,
      'nonce': nonce,

      // 🔥 FORÇA LOGIN REAL (não reaproveita sessão)
      'prompt': 'login',

      'code_challenge': codeChallenge,
      'code_challenge_method': 'S256',
    },
  );

  html.window.location.assign(authUri.toString());
}

Future<void> logoutMicrosoftWeb() async {
  // limpa token do app
  await TokenStorageService.instance.clearToken();

  // limpa PKCE se existir
  html.window.sessionStorage.remove(_pkceVerifierKey);

  final logoutUri = Uri.parse(
    'https://login.microsoftonline.com/${AppConfig.microsoftTenantId}/oauth2/v2.0/logout',
  ).replace(
    queryParameters: {
      'post_logout_redirect_uri': AppConfig.microsoftRedirectUri,
    },
  );

  html.window.location.assign(logoutUri.toString());
}

String _randomUrlSafe(int length) {
  final random = Random.secure();
  final bytes = Uint8List.fromList(
    List<int>.generate(length, (_) => random.nextInt(256)),
  );
  return base64UrlEncode(bytes).replaceAll('=', '');
}

String _codeChallenge(String verifier) {
  final bytes = utf8.encode(verifier);
  final digest = sha256.convert(bytes);
  return base64UrlEncode(digest.bytes).replaceAll('=', '');
}
