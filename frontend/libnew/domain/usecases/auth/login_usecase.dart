import '../../repositories/auth_repository.dart';
import '../../entities/auth_entity.dart';

class LoginUsecase {
  final AuthRepository repository;

  LoginUsecase(this.repository);

  Future<bool> execute(String email, String password) async {
    final result = await repository.login(email, password);
    return result != null;
  }

  Future<AuthEntity?> loginWithGoogle(String accessToken, {String? idToken}) async {
    return await repository.loginWithGoogle(accessToken, idToken: idToken);
  }
}