import 'package:equatable/equatable.dart';
import 'package:gmoria/domain/models/Person.dart';
import 'package:gmoria/domain/models/UserList.dart';

abstract class PersonEvent extends Equatable {
  const PersonEvent();

  @override
  List<Object> get props => [];
}

class LoadPerson extends PersonEvent {}

class LoadSinglePerson extends PersonEvent {
  final String idPerson;
  const LoadSinglePerson(this.idPerson);

  @override
  List<Object> get props => [idPerson];
}

class LoadUserListPersons extends PersonEvent {
  final String idUserList;

  const LoadUserListPersons(this.idUserList);

  @override
  List<Object> get props => [idUserList];
}

class AddPerson extends PersonEvent {
  final Person person;
  final String idList;

  const AddPerson(this.person,this.idList);

  @override
  List<Object> get props => [person,idList];

  @override
  String toString() => 'PersonAdded { person: $person }';
}

class UpdatePerson extends PersonEvent {
  final Person person;

  const UpdatePerson(this.person);

  @override
  List<Object> get props => [person];

  @override
  String toString() => 'PersonUpdated { person: $person }';
}

class DeletePerson extends PersonEvent {
  final Person person;
  final String idList;

  const DeletePerson(this.person,this.idList);

  @override
  List<Object> get props => [person,idList];

  @override
  String toString() => 'PersonDeleted { person: $person }';
}

class ForceDeletePerson extends PersonEvent {
  final Person person;

  const ForceDeletePerson(this.person);

  @override
  List<Object> get props => [person];

  @override
  String toString() => 'ForceDeletePerson { person: $person }';
}

class PersonUpdated extends PersonEvent {
  final List<Person> person;

  const PersonUpdated(this.person);

  @override
  List<Object> get props => [person];
}

class UserListPersonUpdated extends PersonEvent {
  final List<Person> person;

  const UserListPersonUpdated(this.person);

  @override
  List<Object> get props => [person];
}

class SinglePersonUpdated extends PersonEvent {
  final Person person;

  const SinglePersonUpdated(this.person);

  @override
  List<Object> get props => [person];
}

class AddExistingPersonsToList extends PersonEvent {
  final List<Person> persons;
  final UserList userList;

  const AddExistingPersonsToList(this.persons, this.userList);

  @override
  List<Object> get props => [persons];
}
