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
    // TODO: implement addNewUserList
    throw UnimplementedError();
  }

  @override
  Future<void> deleteUserList(UserList userList) {
    // TODO: implement deleteUserList
    throw UnimplementedError();
  }

  @override
  Future<void> updateUserList(UserList userList) {
    // TODO: implement updateUserList
    throw UnimplementedError();
  }

//   Stream<List<UserList>> getUsersLists() {
//     firestore.collection("lists").where('fk_user_id', isEqualTo: user.uid).get().then((querySnapshot) {
//       querySnapshot.docs.forEach((result) {
//         print(result.data());
//       });
//     });
//   }

//VERSION 2
// @override
// Future<List<UserList>> getUserLists() async {
//   List<UserList> lists = new List();
//    await firestore.collection("lists").where('fk_user_id', isEqualTo: user.uid).get()
//       .then((QuerySnapshot querySnapshot) => {
//         querySnapshot.docs.forEach((element) {
//           UserList list = new UserList(element["listname"], element["bestscore"],
//               element["creation_date"], element["persons"]);
//           lists.add(list);
//           print(lists.length);
//         })
//   });
//
//   print(" LONGUEUR ");
//   print(lists.length);
//
//   return lists;
//
// }

}
