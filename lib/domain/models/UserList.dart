import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gmoria/data/entities/UserListEntity.dart';
import 'package:meta/meta.dart';

@immutable
class UserList {
  final String id;
  final String listName;
  final int bestScore;
  final Timestamp creation_date;
  final List persons;

  UserList(this.listName,
      {this.bestScore = 0, Timestamp creation_date, List persons, String id})
      : this.creation_date = creation_date ?? Timestamp.now(),
        this.persons = persons ?? new List(),
        this.id = id;

  UserList copyWith(
      {String id, String listName, int bestScore, Timestamp creation_date, List persons}) {
    return UserList(
      listName ?? this.listName,
      id : id ?? this.id,
      bestScore: bestScore ?? this.bestScore,
      creation_date: creation_date ?? this.creation_date,
      persons: persons ?? new List(),
    );
  }

  @override
  int get hashCode =>
      listName.hashCode ^
      bestScore.hashCode ^
      creation_date.hashCode ^
      persons.hashCode ^
      id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserList &&
          runtimeType == other.runtimeType &&
          listName == other.listName &&
          bestScore == other.bestScore &&
          creation_date == other.creation_date &&
          persons == other.persons &&
          id == other.id;

  @override
  String toString() {
    return 'List { id: $id, listName: $listName, bestScore: $bestScore, creation_date: $creation_date, persons: $persons }';
  }

  UserListEntity toEntity() {
    return UserListEntity(id, listName, bestScore, creation_date, persons);
  }

  static UserList fromEntity(UserListEntity entity) {
    return UserList(
      entity.listName,
      bestScore: entity.bestScore ?? 0,
      creation_date: entity.creation_date,
      persons: entity.persons,
      id: entity.id,
    );
  }
}
