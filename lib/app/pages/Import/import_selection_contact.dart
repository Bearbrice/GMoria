import 'package:flutter/material.dart';

import 'package:gmoria/app/utils/app_localizations.dart';
import 'package:gmoria/app/utils/arguments/ImportArguments.dart';
import 'package:gmoria/domain/models/Person.dart';
import 'package:gmoria/domain/models/UserList.dart';

class ImportSelectionContacts extends StatelessWidget {
  ImportArguments args;

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context).settings.arguments;
    List<Person> contacts = args.persons;
    UserList userList = args.userList;

    Map<Person, bool> personsList = new Map<Person, bool>();

    contacts.forEach((element) {
        personsList[element] = false;
      });


    return Container(
      child : AllContactsCheckboxes(personsList,userList),
      );
  }
}

class AllContactsCheckboxes extends StatefulWidget {
  final Map<Person, bool> personsList;
  final UserList userList;

  AllContactsCheckboxes(this.personsList, this.userList);

  @override
  State<StatefulWidget> createState() => _AllContactsCheckboxesState();
}

class _AllContactsCheckboxesState extends State<AllContactsCheckboxes> {
  UserList userList;
  Map<Person, bool> personsList = new Map<Person, bool>();
  Person personToPrint;

  @override
  void initState() {
    personsList = widget.personsList;
    userList = widget.userList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          AppLocalizations.of(context).translate("import_selection_title"),
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: new ListView(
        children: personsList.keys.map((Person p) {
          return new CheckboxListTile(
            title: p.lastname==null ?
            p.firstname==null ?
            Text(AppLocalizations.of(context).translate("import_selection_no_name_found")) : Text(p.firstname)
                : p.firstname==null ?
            Text(p.lastname) : Text(p.firstname + " " + p.lastname),
            value: personsList[p],
            onChanged: (bool selected){
              setState(() {
                personsList[p] = selected;
                personToPrint = p;
              });
            },
          );
        }).toList(),
      ),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaisedButton(
              color: Colors.green,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(Icons.group_add, color: Colors.white,),
                    Text(
                      " "
                          +AppLocalizations.of(context).translate('import_contacts_button_label')
                          +" ("
                          + personsList.keys.where((element) => personsList[element] == true).toList().length.toString()
                          +")",
                      style: TextStyle(color: Colors.white)
                      ,)
                  ]),
              onPressed: personsList.keys.firstWhere((element) => personsList[element] == true, orElse: () => null)==null? null:(){
                List<Person> personsToAdd = personsList.keys.where((element) => personsList[element] == true).toList();

                Navigator.popAndPushNamed(context, '/createImportContacts',
                    arguments: ImportArguments(personsToAdd,userList));
              },
            ),
          ],
        ),
      ),


    );
  }
}