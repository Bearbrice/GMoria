import 'package:gmoria/domain/models/UserList.dart';

class InitialGameArguments {
  final UserList userList;
  final bool onlyMistakes;
  final int quantity;

  InitialGameArguments(this.userList,this.onlyMistakes,this.quantity);
}