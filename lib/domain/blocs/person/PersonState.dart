import 'package:equatable/equatable.dart';
import 'package:gmoria/domain/models/Person.dart';

abstract class PersonState extends Equatable {
  const PersonState();

  @override
  List<Object> get props => [];
}

class PersonLoading extends PersonState {}

class PersonLoaded extends PersonState {
  final List<Person> person;

  const PersonLoaded([this.person = const []]);

  @override
  List<Object> get props => [person];

  @override
  String toString() => 'PersonLoaded { person: $person }';
}

class PersonLoadNotLoaded extends PersonState {}
