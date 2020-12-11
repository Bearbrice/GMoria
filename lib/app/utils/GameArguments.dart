import 'package:gmoria/domain/models/Person.dart';

class GameArguments {
  final List<Person> persons;
  final Map<int, dynamic> answers;

  GameArguments(this.persons, this.answers);
}