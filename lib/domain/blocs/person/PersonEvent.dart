import 'package:equatable/equatable.dart';
import 'package:gmoria/domain/models/Person.dart';

abstract class PersonEvent extends Equatable {
  const PersonEvent();

  @override
  List<Object> get props => [];
}

class LoadPerson extends PersonEvent {}

class LoadUserListPersons extends PersonEvent {
  final List<String> personsIdList;

  const LoadUserListPersons(this.personsIdList);

  @override
  List<Object> get props => [personsIdList];
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

  const DeletePerson(this.person);

  @override
  List<Object> get props => [person];

  @override
  String toString() => 'PersonDeleted { person: $person }';
}

class PersonUpdated extends PersonEvent {
  final List<Person> person;

  const PersonUpdated(this.person);

  @override
  List<Object> get props => [person];
}
