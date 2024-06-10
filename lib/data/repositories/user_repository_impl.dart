import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../../domain/entities/user.dart' as domain;  
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseAuth _firebaseAuth;

  UserRepositoryImpl(this._firebaseAuth);

  @override
  Future<List<domain.User>> getUsers() async {
    List<UserModel> userModels = []; 
    List<domain.User> users = userModels.map((userModel) => domain.User(
      uid: userModel.uid,
      email: userModel.email,
    )).toList();

    return users;
  }
}
