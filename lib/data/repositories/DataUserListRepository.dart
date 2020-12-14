import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gmoria/data/entities/UserListEntity.dart';
import 'package:gmoria/domain/models/UserList.dart';
import 'package:gmoria/domain/repositories/UserListRepository.dart';

class DataUserListRepository implements UserListRepository {
  final db = FirebaseFirestore.instance;
  final userListCollection = FirebaseFirestore.instance.collection('lists');
  final personCollection = FirebaseFirestore.instance.collection('persons');
  var user = FirebaseAuth.instance.currentUser;

  List<UserList> currentUserLists = new List<UserList>();

  @override
  Stream<List<UserList>> getUserLists() {
    return userListCollection
        .where('fk_user_id', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserList.fromEntity(UserListEntity.fromSnapshot(doc)))
          .toList();
    });
  }


  @override
  Future<void> addNewUserList(UserList userList) {
    Map<String, Object> newList = {
      'listname': userList.listName,
      'bestscore': userList.bestScore,
      'creation_date': userList.creation_date,
      'persons': userList.persons,
      'fk_user_id': user.uid
    };
    return userListCollection.add(newList);
  }

  @override
  Future<void> deleteUserList(UserList userList) {
    //Get a new batch
    var batch = db.batch();
    //Delete each person of UserList
    if (userList.persons != null) {
      for (int i = 0; i < userList.persons.length; i++) {
        DocumentReference documentReference =
            personCollection.doc(userList.persons[i]);
        batch.delete(documentReference);
      }
      batch.commit();
    }
    return userListCollection.doc(userList.id).delete();
  }

  @override
  Future<void> updateUserList(UserList userList) {
    return userListCollection
        .doc(userList.id)
        .update(userList.toEntity().toDocument());
  }

  @override
  Stream<UserList> getUserListById(String userListId) {
    return userListCollection.doc(userListId).snapshots().map((snapshot) {
      return UserList.fromEntity(UserListEntity.fromSnapshot(snapshot));
    });
  }
}
