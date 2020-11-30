import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gmoria/data/entities/PersonEntity.dart';
import 'package:gmoria/domain/models/Person.dart';
import 'package:gmoria/domain/repositories/PersonRepository.dart';


class DataPersonRepository implements PersonRepository {
  final personCollection = FirebaseFirestore.instance.collection('persons');
  List<Person> currentPersons = new List<Person>();

  //TODO method to get only 1 person or get from the array of UserList
  @override
  Stream<List<Person>> getPersons() {
    return personCollection
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Person.fromEntity(PersonEntity.fromSnapshot(doc)))
          .toList();
    });
  }

  @override
  Stream<List<Person>> getUserListPersons(List<String> personsIdList) {
    return personCollection
        .where(FieldPath.documentId, whereIn: personsIdList)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Person.fromEntity(PersonEntity.fromSnapshot(doc)))
          .toList();
    });
  }

  @override
  Future<void> addNewPerson(Person person) {
    return personCollection.add(person.toEntity().toDocument());
  }

  @override
  Future<void> deletePerson(Person person) {
    return personCollection.doc(person.id).delete();
  }

  @override
  Future<void> updatePerson(Person person) {
    return personCollection
        .doc(person.id)
        .update(person.toEntity().toDocument());
  }

}
