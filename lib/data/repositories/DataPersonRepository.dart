import 'dart:math';
import 'package:async/async.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gmoria/data/entities/PersonEntity.dart';
import 'package:gmoria/domain/models/Person.dart';
import 'package:gmoria/domain/repositories/PersonRepository.dart';

class DataPersonRepository implements PersonRepository {
  final personCollection = FirebaseFirestore.instance.collection('persons');
  final listsCollection = FirebaseFirestore.instance.collection('lists');
  List<Person> currentPersons = new List<Person>();

  //TODO method to get only 1 person or get from the array of UserList
  @override
  Stream<List<Person>> getPersons() {
    return personCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Person.fromEntity(PersonEntity.fromSnapshot(doc)))
          .toList();
    });
  }

  @override
  Stream<List<Person>> getUserListPersons(List<String> personsIdList) {
    //As the whereIn query only allows up to 10 equalities,
    //the following lines merge the results of multiple queries with max 10 ids

    List<Stream> results = [];
    if (personsIdList.length >= 10) {
      List<List<String>> listOfLists = new List<List<String>>();
      for (var i = 0; i < personsIdList.length; i += 10) {
        List<String> sub =
            personsIdList.sublist(i, min(personsIdList.length, i + 10));
        print("SUBLIST !!!!!!!!!!!!!!!!!     " + i.toString());
        print(sub);
        print(personsIdList);
        listOfLists.add(sub);
      }

      listOfLists.forEach((idsList) {
        results.add(
            personCollection
            .where(FieldPath.documentId, whereIn: idsList)
            .snapshots());
      });
      var controller = StreamController<List<Person>>();
      StreamZip(results).asBroadcastStream().listen((snapshots) {
        List<DocumentSnapshot> documents = List<DocumentSnapshot>();

        snapshots.forEach((snapshot) {
          documents.addAll(snapshot.documents);
        });

        final persons = documents.map((doc) {
          return Person.fromEntity(PersonEntity.fromSnapshot(doc));
        }).toList();

        controller.add(persons);
      });
      return controller.stream;
    }

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
  Future<void> addNewPerson(Person person, String idUserList) async {
    return personCollection
        .add(person.toEntity().toDocument())
        .then((value) => {
              listsCollection.doc(idUserList).update({
                'persons': FieldValue.arrayUnion([value.id])
              })
            });
  }

  Future<void> addNewPerson2(Person person) {
    return personCollection.add(person.toEntity().toDocument());
  }

  @override
  Future<void> deletePerson(Person person) {
    Reference photoRef =
        FirebaseStorage.instance.ref().storage.refFromURL(person.image_url);
    photoRef.delete();
    return personCollection.doc(person.id).delete();
  }

  @override
  Future<void> updatePerson(Person person) {
    return personCollection
        .doc(person.id)
        .update(person.toEntity().toDocument());
  }
}
