import 'package:firebase_auth/firebase_auth.dart';
import 'package:act/data/services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) {
    return _authService.signInWithEmailAndPassword(email, password);
  }

  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) {
    return _authService.createUserWithEmailAndPassword(email, password);
  }
}
