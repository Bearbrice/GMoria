import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gmoria/data/entities/UserListEntity.dart';
import 'package:meta/meta.dart';

@immutable
class UserList{
  final String listName;
  final int bestScore;
  final Timestamp creation_date;
  final List persons;

  UserList(this.listName, {this.bestScore = 0, Timestamp creation_date, List persons})
    : this.creation_date = creation_date ?? Timestamp.now(),
      this.persons = persons;

  UserList copyWith({String listName, int bestScore, Timestamp creation_date, List persons}) {
    return UserList(
      listName ?? this.listName,
      bestScore: bestScore ?? this.bestScore,
      creation_date: creation_date ?? this.creation_date,
      persons: persons ?? this.persons,
    );
  }

  @override
  int get hashCode =>
      listName.hashCode ^ bestScore.hashCode ^ creation_date.hashCode ^ persons.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UserList &&
              runtimeType == other.runtimeType &&
              listName == other.listName &&
              bestScore == other.bestScore &&
              creation_date == other.creation_date &&
              persons == other.persons;

  @override
  String toString() {
    return 'List { listName: $listName, bestScore: $bestScore, creation_date: $creation_date, persons: $persons }';
  }

  UserListEntity toEntity() {
    return UserListEntity(listName, bestScore, creation_date, persons);
  }

  static UserList fromEntity(UserListEntity entity) {
    return UserList(
      entity.listName,
      bestScore: entity.bestScore ?? 0,
      creation_date: entity.creation_date,
      persons: entity.persons,
    );
  }

}