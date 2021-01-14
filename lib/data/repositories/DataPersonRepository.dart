import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
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
    List<dynamic> numberOfPeople;
    int score = 0;
    person.fk_user_id = user.uid;
    return personCollection
        .add(person.toEntity().toDocument())
        .then((value) async => {
              await listsCollection.doc(idUserList).get().then((element) => { numberOfPeople = element.get("persons") as List<dynamic>, score= element.get("bestscore")}),
              listsCollection.doc(idUserList).update({
                'persons': FieldValue.arrayUnion([value.id]),
                'bestscore' : (((score * numberOfPeople.length) / (numberOfPeople.length+1))).round() ,
              })
            });
  }

  @override
  Future<void> deletePerson(Person person, String idUserList) async {
    int score = 0;
    List<dynamic> numberOfPeople;
    await listsCollection.doc(idUserList).get().then((element) => { numberOfPeople = element.get("persons") as List<dynamic>, score= element.get("bestscore")});
    listsCollection.doc(idUserList).update({
      'persons': FieldValue.arrayRemove([person.id]),
      'bestscore': numberOfPeople.length <=1 ? 0 : person.is_known ? (((((score/100) * numberOfPeople.length).round() -1) / (numberOfPeople.length-1))*100).round() : (((((score/100) * numberOfPeople.length).round()) / (numberOfPeople.length-1))*100).round() ,
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
  Future<void> forceDeletePerson(Person person) async {
    int score = 0;
    List<dynamic> numberOfPeople;
    //Remove person from lists
    person.lists.forEach((listId) async {
      await listsCollection.doc(listId).get().then((element) => { numberOfPeople = element.get("persons") as List<dynamic>, score= element.get("bestscore")});
      listsCollection.doc(listId).update({
        'persons': FieldValue.arrayRemove([person.id]),
        'bestscore': numberOfPeople.length <= 1 ? 0 : person.is_known ? (((((score/100) * numberOfPeople.length).round() -1) / (numberOfPeople.length-1))*100).round() : (((((score/100) * numberOfPeople.length).round()) / (numberOfPeople.length-1))*100).round() ,
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

  @override
  Future<void> addExistingPersonsToList(List<Person> persons, UserList userList) {
    int score = userList.bestScore;
    int numberOfPeople = userList.persons.length;
    int totalOfPeopleToAdd = persons.length;
    int numberKnownPeople = persons.where((element) => element.is_known== true).toList().length;

    persons.forEach((person) {
      personCollection.doc(person.id).update({
        'lists': FieldValue.arrayUnion([userList.id])
      });
      userList.persons.add(person.id);
    });

    return listsCollection.doc(userList.id).update({
      'persons': userList.persons,
      'bestscore': (((((score/100)*numberOfPeople).round()+numberKnownPeople) / (totalOfPeopleToAdd + numberOfPeople))*100).round()
    });
  }
}
