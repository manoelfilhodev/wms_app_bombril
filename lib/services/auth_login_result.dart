class AuthLoginResult {
  final String token;
  final Map<String, dynamic> user;
  final bool isOffline;

  const AuthLoginResult({
    required this.token,
    required this.user,
    required this.isOffline,
  });
}

