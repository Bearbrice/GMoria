import 'package:gmoria/domain/models/Person.dart';
import 'package:gmoria/domain/models/UserList.dart';

abstract class UserListRepository {
  Future<void> addNewUserList(UserList userList);

  Future<void> deleteUserList(UserList userList);

  Future<void> deleteAllDataFromUser(List<UserList> userLists);

  Future<void> updateScore(List<Person> people);

  Future<void> updateUserList(UserList userList);

  Stream<List<UserList>> getUserLists();

  Stream<UserList> getUserListById(String userListId);

}
