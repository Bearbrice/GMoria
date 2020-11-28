import 'package:equatable/equatable.dart';
import 'package:gmoria/domain/models/Person.dart';

abstract class PersonEvent extends Equatable {
  const PersonEvent();

  @override
  List<Object> get props => [];
}

class LoadPerson extends PersonEvent {}

class AddPerson extends PersonEvent {
  final Person person;

  const AddPerson(this.person);

  @override
  List<Object> get props => [person];

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
