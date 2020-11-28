import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PersonEntity extends Equatable{
  final String id;
  final String firstname;
  final String lastname;
  final String imported_from;
  final String job;
  final String description;
  final bool is_known;

  PersonEntity(this.id, this.firstname, this.lastname, this.imported_from, this.job,
      this.description, this.is_known);

  static PersonEntity fromSnapshot(DocumentSnapshot snap) {
    return PersonEntity(
      snap.reference.id,
      snap.data()['firstname'],
      snap.data()['lastname'],
      snap.data()['imported_from'],
      snap.data()['job'],
      snap.data()['description'],
      snap.data()['is_known']
    );
  }

  static PersonEntity fromJson(Map<String, Object> json) {
    return PersonEntity(
      json['id'] as String,
      json['firstname'] as String,
      json['lastname'] as String,
      json['imported_from'] as String,
      json['job'] as String,
      json['description'] as String,
      json['is_known'] as bool,
    );
  }

  @override
  List<Object> get props => [id, firstname, lastname, imported_from, job,description,is_known];

  Map<String, Object> toDocument() {
    return {
      'listname': firstname,
      'bestscore': lastname,
      'creation_date': imported_from,
      'job': job,
      'description': description,
      'is_known': is_known
    };
  }

  Map<String, Object> toJson() {
    return {
      'id': id,
      'firstname': firstname,
      'lastname': lastname,
      'imported_from': imported_from,
      'job': job,
      'description': description,
      'is_known': is_known
    };
  }
}
