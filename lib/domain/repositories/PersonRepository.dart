import 'package:gmoria/domain/models/Person.dart';

abstract class PersonRepository {
  Future<void> addNewPerson(Person userList);

  Future<void> deletePerson(Person userList);

  Future<void> updatePerson(Person userList);

  Stream<List<Person>> getPersons();

  Stream<List<Person>> getUserListPersons(List<String> personsIdList);
}
