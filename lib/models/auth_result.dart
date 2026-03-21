import 'app_user.dart';

class AuthResult {
  const AuthResult({required this.token, required this.user});

  final String token;
  final AppUser user;
}
