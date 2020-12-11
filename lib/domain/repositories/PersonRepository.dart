import 'package:gmoria/domain/models/Person.dart';
import 'package:gmoria/domain/models/UserList.dart';

abstract class PersonRepository {
  Future<void> addNewPerson(Person userList,String idUserList);

  Future<void> deletePerson(Person userList, String idUserList);

  Future<void> forceDeletePerson(Person userList);

  Future<void> updatePerson(Person userList);

  Stream<List<Person>> getPersons();

  Stream<UserList> getUserListPersonsById(String idUserList);

  Stream<List<Person>> getUserListPersons(String idUserList);

  Stream<Person> getSinglePerson(String idPerson);
}
