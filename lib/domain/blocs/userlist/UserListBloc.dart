import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:gmoria/domain/repositories/UserListRepository.dart';
import 'package:meta/meta.dart';

import 'UserListEvent.dart';
import 'UserListState.dart';


class UserListBloc extends Bloc<UserListEvent, UserListState> {
  final UserListRepository _userListRepository;
  StreamSubscription _userListSubscription;

  UserListBloc({@required UserListRepository userListRepository})
      : assert(userListRepository != null),
        _userListRepository = userListRepository,
        super(UserListLoading());

  @override
  Stream<UserListState> mapEventToState(UserListEvent event) async* {
    if (event is LoadUserList) {
      yield* _mapLoadUserListToState();
    } else if (event is AddUserList) {
      yield* _mapAddUserListToState(event);
    } else if (event is UpdateUserList) {
      yield* _mapUpdateUserListToState(event);
    } else if (event is DeleteUserList) {
      yield* _mapDeleteUserListToState(event);
    } else if (event is UserListUpdated) {
      yield* _mapUserListUpdateToState(event);
    }
  }

  Stream<UserListState> _mapLoadUserListToState() async* {
    _userListSubscription?.cancel();
    _userListSubscription = _userListRepository.getUserLists().listen(
          (userList) => add(UserListUpdated(userList)),
        );
  }

  Stream<UserListState> _mapAddUserListToState(AddUserList event) async* {
    _userListRepository.addNewUserList(event.userList);
  }

  Stream<UserListState> _mapUpdateUserListToState(UpdateUserList event) async* {
    _userListRepository.updateUserList(event.userList);
  }

  Stream<UserListState> _mapDeleteUserListToState(DeleteUserList event) async* {
    _userListRepository.deleteUserList(event.userList);
  }

  Stream<UserListState> _mapUserListUpdateToState(
      UserListUpdated event) async* {
    yield UserListLoaded(event.userList);
  }

  @override
  Future<void> close() {
    _userListSubscription?.cancel();
    return super.close();
  }
}
