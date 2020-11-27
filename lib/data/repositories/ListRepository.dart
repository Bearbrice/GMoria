import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gmoria/data/entities/UserList.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
var user = FirebaseAuth.instance.currentUser;

class ListRepository{
  Stream<List<UserList>> getLists() {
    firestore.collection("lists").where('fk_user_id', isEqualTo: user.uid).get().then((querySnapshot) {
      querySnapshot.docs.forEach((result) {
        print(result.data());
      });
    });
  }
}