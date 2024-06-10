import 'package:act/data/repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository _authRepository;

  SignInUseCase(this._authRepository);

  Future<void> execute(String email, String password) {
    return _authRepository.signInWithEmailAndPassword(email, password);
  }
}
