import 'package:gmoria/domain/models/UserList.dart';

class InitialGameArguments {
  final UserList userList;
  final bool onlyMistakes;

  InitialGameArguments(this.userList,this.onlyMistakes);
}