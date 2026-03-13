import '../../repositories/auth_repository.dart';

class RegisterUsecase {
  final AuthRepository repository;

  RegisterUsecase(this.repository);

  Future<bool> execute(String fullName, String email, String password) async {
    final result = await repository.register(fullName, email, password);
    return result != null;
  }
}