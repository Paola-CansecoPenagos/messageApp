import 'package:act/data/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _authRepository;

  RegisterUseCase(this._authRepository);

  Future<void> execute(String email, String password) {
    return _authRepository.createUserWithEmailAndPassword(email, password);
  }
}
