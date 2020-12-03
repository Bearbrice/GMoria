import 'package:equatable/equatable.dart';
import 'package:gmoria/domain/models/UserList.dart';

abstract class UserListState extends Equatable {
  const UserListState();

  @override
  List<Object> get props => [];
}

class UserListLoading extends UserListState {}

class UserListLoaded extends UserListState {
  final List<UserList> userList;

  const UserListLoaded([this.userList = const []]);

  @override
  List<Object> get props => [userList];

  @override
  String toString() => 'UserListLoaded { userList: $userList }';
}

class UserListLoadedById extends UserListState {
  final UserList userList;

  const UserListLoadedById(this.userList);

  @override
  List<Object> get props => [userList];

  @override
  String toString() => 'UserListLoaded { userList: $userList }';
}

class UserListLoadNotLoaded extends UserListState {}
