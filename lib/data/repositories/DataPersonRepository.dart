import 'dart:math';
import 'package:async/async.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gmoria/data/entities/PersonEntity.dart';
import 'package:gmoria/data/entities/UserListEntity.dart';
import 'package:gmoria/domain/models/Person.dart';
import 'package:gmoria/domain/models/UserList.dart';
import 'package:gmoria/domain/repositories/PersonRepository.dart';

class DataPersonRepository implements PersonRepository {
  final personCollection = FirebaseFirestore.instance.collection('persons');
  final listsCollection = FirebaseFirestore.instance.collection('lists');
  List<Person> currentPersons = new List<Person>();
  var user = FirebaseAuth.instance.currentUser;

  @override
  Stream<List<Person>> getPersons() {
    return personCollection
        .where('fk_user_id', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Person.fromEntity(PersonEntity.fromSnapshot(doc)))
          .toList();
    });
  }

  @override
  Stream<UserList> getUserListPersonsById(String idUserList) {
    return listsCollection.doc(idUserList).snapshots().map((snapshot) {
      return UserList.fromEntity(UserListEntity.fromSnapshot(snapshot));
    });
  }

  @override
  Stream<List<Person>> getUserListPersons(String idUserList) {
    //As the whereIn query only allows up to 10 equalities,
    //the following lines merge the results of multiple queries with max 10 ids
    return personCollection
        .where('lists', arrayContains: idUserList)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Person.fromEntity(PersonEntity.fromSnapshot(doc)))
          .toList();
    });

    // List<Stream> results = [];
    // if (personsIdList.length >= 10) {
    //   List<List<String>> listOfLists = new List<List<String>>();
    //   for (var i = 0; i < personsIdList.length; i += 10) {
    //     List<String> sub =
    //     personsIdList.sublist(i, min(personsIdList.length, i + 10));
    //     print("SUBLIST !!!!!!!!!!!!!!!!!     " + i.toString());
    //     print(sub);
    //     print(personsIdList);
    //     listOfLists.add(sub);
    //   }
    //
    //   listOfLists.forEach((idsList) {
    //     results.add(
    //         personCollection
    //             .where(FieldPath.documentId, whereIn: idsList)
    //             .snapshots());
    //   });
    //   var controller = StreamController<List<Person>>();
    //   StreamZip(results).asBroadcastStream().listen((snapshots) {
    //     List<DocumentSnapshot> documents = List<DocumentSnapshot>();
    //
    //     snapshots.forEach((snapshot) {
    //       documents.addAll(snapshot.documents);
    //     });
    //
    //     final persons = documents.map((doc) {
    //       return Person.fromEntity(PersonEntity.fromSnapshot(doc));
    //     }).toList();
    //
    //     controller.add(persons);
    //   });
    //   return controller.stream;
    // }
    //
    // return personCollection
    //     .where(FieldPath.documentId, whereIn: personsIdList)
    //     .snapshots()
    //     .map((snapshot) {
    //   return snapshot.docs
    //       .map((doc) => Person.fromEntity(PersonEntity.fromSnapshot(doc)))
    //       .toList();
    // });
  }

  @override
  Future<void> addNewPerson(Person person, String idUserList) async {
    person.fk_user_id = user.uid;
    return personCollection
        .add(person.toEntity().toDocument())
        .then((value) => {
              listsCollection.doc(idUserList).update({
                'persons': FieldValue.arrayUnion([value.id])
              })
            });
  }

  @override
  Future<void> deletePerson(Person person, String idUserList) {
    listsCollection.doc(idUserList).update({
      'persons': FieldValue.arrayRemove([person.id])
    });

    if (person.lists.map((p) => p as String).toList().length == 1) {
      Reference photoRef =
          FirebaseStorage.instance.ref().storage.refFromURL(person.image_url);
      photoRef.delete();
      return personCollection.doc(person.id).delete();
    }

    return personCollection.doc(person.id).update({
      'lists': FieldValue.arrayRemove([idUserList])
    });
  }

  @override
  Future<void> forceDeletePerson(Person person) {
    //Remove person from lists
    person.lists.forEach((listId) {
      listsCollection.doc(listId).update({
        'persons': FieldValue.arrayRemove([person.id])
      });
    });

    //Delete person
    Reference photoRef = FirebaseStorage.instance.ref()
        .storage.refFromURL(person.image_url);
    photoRef.delete();
    return personCollection.doc(person.id).delete();
  }

  @override
  Future<void> updatePerson(Person person) {
    return personCollection
        .doc(person.id)
        .update(person.toEntity().toDocument());
  }

  @override
  Stream<Person> getSinglePerson(String idPerson) {
    return personCollection.doc(idPerson).snapshots().map((event) {
      return Person.fromEntity(PersonEntity.fromSnapshot(event));
    });
  }
}
