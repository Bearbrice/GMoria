import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gmoria/app/utils/app_localizations.dart';
import 'package:gmoria/domain/blocs/person/PersonBloc.dart';
import 'package:gmoria/domain/blocs/person/PersonEvent.dart';
import 'package:gmoria/domain/blocs/person/PersonState.dart';
import 'package:gmoria/domain/models/Person.dart';
import 'package:gmoria/domain/models/UserList.dart';

class ImportFromAllContacts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
  UserList userList = ModalRoute.of(context).settings.arguments as UserList;
    return Container(
        child: BlocBuilder<PersonBloc, PersonState>(builder: (context, state) {
          if (state is PersonLoading) {
            return CircularProgressIndicator();
          } else if(state is PersonLoaded){
            Map<Person, bool> personsList = new Map<Person, bool>();
            state.person.sort((a, b) {
              return a.firstname.compareTo(b.firstname);
            });
            state.person.forEach((element) {
              if(!userList.persons.contains(element.id)){
                personsList[element] = false;
              }
            });
            return AllContactsCheckboxes(personsList);
          }
          return Text(AppLocalizations.of(context).translate('unknown_error'));
        }),
      );
  }
}

class AllContactsCheckboxes extends StatefulWidget {
  final Map<Person, bool> personsList;

  AllContactsCheckboxes(this.personsList);

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    userList = ModalRoute.of(context).settings.arguments as UserList;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          AppLocalizations.of(context).translate('import_contacts_title'),
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: new ListView(
        children: personsList.keys.map((Person p) {
          return new CheckboxListTile(
            title: Text(p.firstname+" "+p.lastname),
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
                  BlocProvider.of<PersonBloc>(context).add(AddExistingPersonsToList(personsToAdd, userList));
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),


    );
  }
}
