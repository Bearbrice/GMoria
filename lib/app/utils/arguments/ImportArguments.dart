import 'package:gmoria/domain/models/Person.dart';
import 'package:gmoria/domain/models/UserList.dart';

class ImportArguments {
  final List<Person> persons;
  final UserList userList;

  ImportArguments(this.persons,this.userList);
}