import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:gmoria/domain/repositories/PersonRepository.dart';
import 'package:meta/meta.dart';

import 'PersonEvent.dart';
import 'PersonState.dart';


class PersonBloc extends Bloc<PersonEvent, PersonState> {
  final PersonRepository _personRepository;
  StreamSubscription _personSubscription;

  PersonBloc({@required PersonRepository personRepository})
      : assert(personRepository != null),
        _personRepository = personRepository,
        super(PersonLoading());

  @override
  Stream<PersonState> mapEventToState(PersonEvent event) async* {
    if (event is LoadPerson) {
      yield* _mapLoadPersonToState();
    } else if (event is AddPerson) {
      yield* _mapAddPersonToState(event);
    } else if (event is UpdatePerson) {
      yield* _mapUpdatePersonToState(event);
    } else if (event is DeletePerson) {
      yield* _mapDeletePersonToState(event);
    } else if (event is PersonUpdated) {
      yield* _mapPersonUpdateToState(event);
    }
  }

  Stream<PersonState> _mapLoadPersonToState() async* {
    _personSubscription?.cancel();
    _personSubscription = _personRepository.getPersons().listen(
          (person) => add(PersonUpdated(person)),
        );
  }

  Stream<PersonState> _mapAddPersonToState(AddPerson event) async* {
    _personRepository.addNewPerson(event.person);
  }

  Stream<PersonState> _mapUpdatePersonToState(UpdatePerson event) async* {
    _personRepository.updatePerson(event.person);
  }

  Stream<PersonState> _mapDeletePersonToState(DeletePerson event) async* {
    _personRepository.deletePerson(event.person);
  }

  Stream<PersonState> _mapPersonUpdateToState(
      PersonUpdated event) async* {
    yield PersonLoaded(event.person);
  }

  @override
  Future<void> close() {
    _personSubscription?.cancel();
    return super.close();
  }
}
