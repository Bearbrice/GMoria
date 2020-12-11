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
  final String image_url;
  final List lists;
  final String fk_user_id;

  PersonEntity(this.id, this.firstname, this.lastname, this.imported_from, this.job,
      this.description, this.is_known, this.image_url,this.lists, this.fk_user_id);

  static PersonEntity fromSnapshot(DocumentSnapshot snap) {
    return PersonEntity(
      snap.reference.id,
      snap.data()['firstname'],
      snap.data()['lastname'],
      snap.data()['imported_from'],
      snap.data()['job'],
      snap.data()['description'],
      snap.data()['is_known'],
      snap.data()['image_url'],
      snap.data()['lists'],
      snap.data()['fk_user_id']
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
      json['image_url'] as String,
      json['lists'] as List,
      json['fk_user_id'] as String
    );
  }

  @override
  List<Object> get props => [id, firstname, lastname, imported_from, job, description, is_known, image_url, lists, fk_user_id];

  Map<String, Object> toDocument() {
    return {
      'firstname': firstname,
      'lastname': lastname,
      'imported_from': imported_from,
      'job': job,
      'description': description,
      'is_known': is_known,
      'image_url': image_url,
      'lists' : lists,
      'fk_user_id' : fk_user_id
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
      'is_known': is_known,
      'image_url': image_url,
      'lists' : lists,
      'fk_user_id' : fk_user_id
    };
  }
}
