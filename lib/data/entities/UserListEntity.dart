import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserListEntity extends Equatable{
  final String listName;
  final int bestScore;
  final Timestamp creation_date;
  final List persons;

  UserListEntity(this.listName,this.bestScore,this.creation_date,this.persons);

  static UserListEntity fromSnapshot(DocumentSnapshot snap) {
    return UserListEntity(
      snap.data()['listname'],
      snap.data()['bestscore'],
      snap.data()['creation_date'],
      snap.data()['persons'],
    );
  }

  static UserListEntity fromJson(Map<String, Object> json) {
    return UserListEntity(
      json['listname'] as String,
      json['bestscore'] as int,
      json['creation_date'] as Timestamp,
      json['persons'] as List,
    );
  }

  @override
  List<Object> get props => [listName,bestScore,creation_date,persons];

  Map<String, Object> toDocument() {
    return {
      'listname': listName,
      'bestscore': bestScore,
      'creation_date': creation_date,
      'persons': persons,
    };
  }

  Map<String, Object> toJson() {
    return {
      'listname': listName,
      'bestscore': bestScore,
      'creation_date': creation_date,
      'persons': persons,
    };
  }

}