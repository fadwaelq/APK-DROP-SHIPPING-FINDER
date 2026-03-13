import '../../repositories/auth_repository.dart';

class LogoutUsecase {
  final AuthRepository repository;

  LogoutUsecase(this.repository);

  Future<bool> execute() async {
    return await repository.logout();
  }
}