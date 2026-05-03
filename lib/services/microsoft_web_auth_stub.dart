import '../core/config/app_config.dart';

class MicrosoftWebTokens {
  const MicrosoftWebTokens({
    required this.accessToken,
    required this.idToken,
  });

  final String accessToken;
  final String idToken;
}

bool hasMicrosoftWebRedirectResult() => false;

Future<MicrosoftWebTokens?> takeMicrosoftWebRedirectResult() async => null;

Future<void> startMicrosoftWebLogin() async {
  throw UnsupportedError(
    'Login Microsoft via navegador indisponivel nesta plataforma. '
    'Use o redirect ${AppConfig.microsoftRedirectUri}.',
  );
}
