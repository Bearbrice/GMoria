import 'package:gmoria/domain/models/Person.dart';
import 'package:gmoria/domain/models/UserList.dart';

class GameArguments {
  final List<Person> persons;
  final Map<int, dynamic> answers;
  final UserList userList;

  GameArguments(this.persons, this.answers,this.userList);
}