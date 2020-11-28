import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gmoria/data/entities/UserListEntity.dart';
import 'package:gmoria/domain/models/UserList.dart';
import 'package:gmoria/domain/repositories/UserListRepository.dart';

var user = FirebaseAuth.instance.currentUser;

class DataUserListRepository implements UserListRepository {
  final userListCollection = FirebaseFirestore.instance.collection('lists');
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
    return userListCollection.add(userList.toEntity().toDocument());
  }

  @override
  Future<void> deleteUserList(UserList userList) {
    return userListCollection.doc(userList.id).delete();
  }

  @override
  Future<void> updateUserList(UserList userList) {
    return userListCollection
        .doc(userList.id)
        .update(userList.toEntity().toDocument());
  }

}
