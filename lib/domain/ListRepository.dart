import 'package:gmoria/data/entities/UserList.dart';
import 'package:gmoria/data/repositories/ListRepository.dart';

class Listrepository {
  ListRepository listRepository = new ListRepository();
  List<UserList> getLists() {
    listRepository.getLists();
  }
}