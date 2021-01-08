import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gmoria/data/entities/UserListEntity.dart';
import 'package:gmoria/domain/models/Person.dart';
import 'package:gmoria/domain/models/UserList.dart';
import 'package:gmoria/domain/repositories/UserListRepository.dart';

class DataUserListRepository implements UserListRepository {
  var user = FirebaseAuth.instance.currentUser;
  final db = FirebaseFirestore.instance;
  final userListCollection = FirebaseFirestore.instance.collection('lists');
  final personCollection = FirebaseFirestore.instance.collection('persons');

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
    //Delete each person of UserList
    if (userList.persons != null) {
      for (int i = 0; i < userList.persons.length; i++) {
        //Get a new batch
        var batch = db.batch();
        DocumentReference documentReference =
            personCollection.doc(userList.persons[i]);
        List<dynamic> idList;
        Map<String, dynamic> data;
        documentReference.get().then((doc) {
          if (doc.exists) {
            data = doc.data();
            idList = data["lists"];
            //Check if the person is used in another list
            if (idList.length == 1) {
              //If used only in this list, delete it
              batch.delete(documentReference);
              //Delete person picture
              Reference photoRef = FirebaseStorage.instance
                  .ref()
                  .storage
                  .refFromURL(data["image_url"]);
              photoRef.delete();
            } else {
              //Update lists in person to remove the id of the deleted list
              idList.remove(userList.id);
              data["lists"] = idList;
              batch.update(documentReference, data);
            }
            batch.commit();
          }
        });
      }
    }
    return userListCollection.doc(userList.id).delete();
  }

  @override
  Future<void> deleteAllDataFromUser(List<UserList> userLists) async{
    for (UserList ul in userLists)
    {
      await deleteUserList(ul);
    }
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
