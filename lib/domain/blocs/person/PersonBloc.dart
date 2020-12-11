import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:gmoria/domain/models/UserList.dart';
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
    } else if (event is LoadUserListPersons) {
      yield* _mapLoadUserListPersonsToState(event);
    } else if (event is AddPerson) {
      yield* _mapAddPersonToState(event);
    } else if (event is UpdatePerson) {
      yield* _mapUpdatePersonToState(event);
    } else if (event is DeletePerson) {
      yield* _mapDeletePersonToState(event);
    } else if (event is PersonUpdated) {
      yield* _mapPersonUpdateToState(event);
    } else if(event is UserListPersonUpdated) {
      yield* _mapUserListPersonUpdateToState(event);
    } else if(event is LoadSinglePerson){
      yield* _mapLoadSinglePersonToState(event);
    } else if(event is SinglePersonUpdated){
      yield* _mapSinglePersonUpdateToState(event);
    }else if(event is ForceDeletePerson){
      yield* _mapForceDeletePersonToState(event);
    }
  }

  Stream<PersonState> _mapLoadPersonToState() async* {
    _personSubscription?.cancel();
    _personSubscription = _personRepository.getPersons().listen(
          (person) => add(PersonUpdated(person)),
        );
  }

  Stream<PersonState> _mapLoadUserListPersonsToState(LoadUserListPersons event) async* {
    _personSubscription?.cancel();
    // _userListSubscription?.cancel();

    // _userListSubscription = _personRepository.getUserListPersonsById(event.idUserList).listen((lecture)  {
      _personSubscription =  _personRepository.getUserListPersons(event.idUserList).listen(
            (person) => add(UserListPersonUpdated(person)),
      );
    // });

  }

  Stream<PersonState> _mapLoadSinglePersonToState(LoadSinglePerson event) async* {
    _personSubscription?.cancel();
    _personSubscription =  _personRepository.getSinglePerson(event.idPerson).listen(
          (person) => add(SinglePersonUpdated(person)),
    );
  }

  Stream<PersonState> _mapAddPersonToState(AddPerson event) async* {
    await _personRepository.addNewPerson(event.person,event.idList);
  }

  Stream<PersonState> _mapUpdatePersonToState(UpdatePerson event) async* {
    _personRepository.updatePerson(event.person);
  }

  Stream<PersonState> _mapDeletePersonToState(DeletePerson event) async* {
    _personRepository.deletePerson(event.person, event.idList);
  }

  Stream<PersonState> _mapPersonUpdateToState(
      PersonUpdated event) async* {
    yield PersonLoaded(event.person);
  }

  Stream<PersonState> _mapUserListPersonUpdateToState(
      UserListPersonUpdated event) async* {
    yield UserListPersonLoaded(event.person);
  }

  Stream<PersonState> _mapSinglePersonUpdateToState(
      SinglePersonUpdated event) async* {
    yield SinglePersonLoaded(event.person);
  }

  Stream<PersonState> _mapForceDeletePersonToState(ForceDeletePerson event) async* {
    _personRepository.forceDeletePerson(event.person);
  }

  @override
  Future<void> close() {
    _personSubscription?.cancel();
    return super.close();
  }
}
