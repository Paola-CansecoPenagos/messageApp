import '../../domain/entities/user.dart';
import '../../domain/use_cases/get_users_use_case.dart';

class UserListViewModel {
  final GetUsersUseCase getUsersUseCase;

  UserListViewModel(this.getUsersUseCase);

  Future<List<User>> getUsers() {
    return getUsersUseCase();
  }
}
