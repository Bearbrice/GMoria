import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:gmoria/domain/repositories/UserListRepository.dart';
import 'package:meta/meta.dart';

import 'UserListEvent.dart';
import 'UserListState.dart';


class UserListBloc extends Bloc<UserListEvent, UserListState> {
  final UserListRepository _userListRepository;
  StreamSubscription _userListSubscription;
  StreamSubscription _userListSubscriptionById;

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
    } else if(event is LoadUserListById){
      yield* _mapUserListByIdToState(event);
    } else if(event is UserListUpdatedById){
      yield* _mapUserListByIdUpdatedToState(event);
    }else if (event is DeleteAllDataFromUser) {
      yield* _mapDeleteAllDataFromUserToState(event);
    }else if (event is UpdateScore) {
      yield* _mapUserListUpdateScoreToState(event);
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

  Stream<UserListState> _mapUserListUpdateScoreToState(UpdateScore event) async* {
    _userListRepository.updateScore(event.people);
  }

  Stream<UserListState> _mapDeleteUserListToState(DeleteUserList event) async* {
    _userListRepository.deleteUserList(event.userList);
  }

  Stream<UserListState> _mapDeleteAllDataFromUserToState(DeleteAllDataFromUser event) async* {
    _userListRepository.deleteAllDataFromUser(event.userLists);
  }

  Stream<UserListState> _mapUserListUpdateToState(
      UserListUpdated event) async* {
    yield UserListLoaded(event.userList);
  }

  Stream<UserListState> _mapUserListByIdToState(LoadUserListById event) async* {
    _userListSubscriptionById?.cancel();
    _userListSubscriptionById = _userListRepository.getUserListById(event.userListId).listen(
          (userList) => add(UserListUpdatedById(userList)),
    );
  }

  Stream<UserListState> _mapUserListByIdUpdatedToState(
      UserListUpdatedById event) async* {
    yield UserListLoadedById(event.userList);
  }



  @override
  Future<void> close() {
    _userListSubscription?.cancel();
    return super.close();
  }
}
