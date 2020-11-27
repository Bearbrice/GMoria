import 'package:equatable/equatable.dart';
import 'package:gmoria/domain/models/UserList.dart';

abstract class UserListEvent extends Equatable {
  const UserListEvent();

  @override
  List<Object> get props => [];
}

class LoadUserList extends UserListEvent {}

class AddUserList extends UserListEvent {
  final UserList userList;

  const AddUserList(this.userList);

  @override
  List<Object> get props => [userList];

  @override
  String toString() => 'UserListAdded { userList: $userList }';
}

class UpdateUserList extends UserListEvent {
  final UserList userList;

  const UpdateUserList(this.userList);

  @override
  List<Object> get props => [userList];

  @override
  String toString() => 'UserListUpdated { userList: $userList }';
}

class DeleteUserList extends UserListEvent {
  final UserList userList;

  const DeleteUserList(this.userList);

  @override
  List<Object> get props => [userList];

  @override
  String toString() => 'UserListDeleted { userList: $userList }';
}

class UserListUpdated extends UserListEvent {
  final List<UserList> userList;

  const UserListUpdated(this.userList);

  @override
  List<Object> get props => [userList];
}
