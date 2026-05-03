class AuthLoginResult {
  final String token;
  final Map<String, dynamic> user;
  final bool isOffline;
  final List<String> permissions;

  const AuthLoginResult({
    required this.token,
    required this.user,
    required this.isOffline,
    this.permissions = const <String>[],
  });
}
