import 'package:gmoria/domain/models/Person.dart';
import 'package:gmoria/domain/models/UserList.dart';

abstract class PersonRepository {
  Future<void> addNewPerson(Person person,String idUserList);

  Future<void> addExistingPersonsToList(List<Person> persons,UserList userList);

  Future<void> deletePerson(Person person, String idUserList);

  Future<void> forceDeletePerson(Person person);

  Future<void> updatePerson(Person person);

  Stream<List<Person>> getPersons();

  Stream<UserList> getUserListPersonsById(String idUserList);

  Stream<List<Person>> getUserListPersons(String idUserList);

  Stream<Person> getSinglePerson(String idPerson);
}
