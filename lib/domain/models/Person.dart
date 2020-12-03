import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gmoria/data/entities/PersonEntity.dart';
import 'package:meta/meta.dart';

@immutable
class Person {
  final String id;
  final String firstname;
  final String lastname;
  final String imported_from;
  final String job;
  final String description;
  final bool is_known;
  final String image_url;

  Person(
      this.firstname, this.lastname, this.job, this.description,this.image_url,{this.imported_from = 'App', this.is_known = false, String id})
      : this.id = id ?? null;

  Person copyWith(
      {String id, String firstname, String lastname, String job, String description, String imported_from,  bool is_known, String image_url}) {
    return Person(
      firstname ?? this.firstname,
      lastname ?? this.lastname,
      job ?? this.job,
      description ?? this.description,
      image_url ?? this.image_url,
      id: id ?? this.id,
      imported_from: imported_from ?? this.imported_from,
      is_known: is_known ?? this.is_known,
    );
  }

  @override
  int get hashCode =>
      firstname.hashCode ^
      lastname.hashCode ^
      job.hashCode ^
      description.hashCode ^
      image_url.hashCode ^
      imported_from.hashCode ^
      is_known.hashCode ^
      id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Person &&
              runtimeType == other.runtimeType &&
              firstname == other.firstname &&
              lastname == other.lastname &&
              job == other.job &&
              description == other.description &&
              image_url == other.image_url &&
              imported_from == other.imported_from &&
              is_known == other.is_known &&
              id == other.id;

  @override
  String toString() {
    return 'Person { id: $id, firstname: $firstname, lastname: $lastname, job: $job, description: $description , imported_from: $imported_from , is_known: $is_known}, image_url: $image_url';
  }

  PersonEntity toEntity() {
    return PersonEntity(id, firstname, lastname,imported_from, job,
        description, is_known, image_url);
  }

  static Person fromEntity(PersonEntity entity) {
    return Person(
      entity.firstname,
      entity.lastname,
      entity.job,
      entity.description,
      entity.image_url,
      imported_from: entity.imported_from ?? 'App',
      is_known: entity.is_known ?? false,
      id: entity.id,
    );
  }
}
