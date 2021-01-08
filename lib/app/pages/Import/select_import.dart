import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gmoria/app/utils/ImportArguments.dart';
import 'package:gmoria/app/utils/app_localizations.dart';
import 'package:gmoria/domain/models/Person.dart';
import 'package:gmoria/domain/models/UserList.dart';
import 'package:permission_handler/permission_handler.dart';


class ImportSelectionPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    UserList userList = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Choose import',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ButtonTheme(
              height: 70,
              minWidth: 240,
              child: RaisedButton.icon(
                  onPressed: () async {
                    final PermissionStatus permissionStatus = await _getPermission();
                    if (permissionStatus == PermissionStatus.granted) {
                      final Iterable<Contact> contactslist = await ContactsService.getContacts();
                      List<Person> persons = new List();
                      for(Contact contact in contactslist){
                        Person person = new Person(contact.givenName,contact.familyName,contact.jobTitle, "","");
                        persons.add(person);
                      }

                      Navigator.pushNamed(context, '/importSelectionContacts',
                          arguments: ImportArguments(persons,userList));
                      //We can now access our contacts here
                    } else {
                      //If permissions have been denied show standard cupertino alert dialog
                      showDialog(
                          context: context,
                          builder: (BuildContext context) => CupertinoAlertDialog(
                            title: Text('Permissions error'),
                            content: Text('Please enable contacts access '
                                'permission in system settings'),
                            actions: <Widget>[
                              CupertinoDialogAction(
                                child: Text('OK'),
                                onPressed: () => Navigator.of(context).pop(),
                              )
                            ],
                          ));
                    }
                  },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                label: Text('Import from phone',
                  style: TextStyle(color: Colors.white,fontSize: 20),),
                icon: Icon(Icons.smartphone, color:Colors.white,),
                textColor: Colors.white,
                splashColor: Colors.blueAccent,
                color: Colors.blue),
            ),
            SizedBox(height: 50),
            ButtonTheme(
              height: 70,
              minWidth: 240,
              child: RaisedButton.icon(
                onPressed: (){
                  Navigator.pushNamed(context, '/importVCard');
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                label: Text('Import from VCARD',
                  style: TextStyle(color: Colors.white,fontSize: 20),),
                icon: Icon(Icons.file_present, color:Colors.white,),
                textColor: Colors.white,
                splashColor: Colors.blueAccent,
                color: Colors.blue,),
            ),
            SizedBox(height: 50),
            ButtonTheme(
              height: 70,
              minWidth: 240,
              child: RaisedButton.icon(
                onPressed: (){ print('Button Clicked.'); },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                label: Text('Import from CSV',
                  style: TextStyle(color: Colors.white,fontSize: 20),),
                icon: Icon(Icons.upload_file, color:Colors.white,),
                textColor: Colors.white,
                splashColor: Colors.blueAccent,
                color: Colors.blue,),
            ),
          ],
        ),
      ),
    );
  }

  Future<PermissionStatus> _getPermission() async {
    final PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.denied) {
      final Map<Permission, PermissionStatus> permissionStatus =
      await [Permission.contacts].request();
      return permissionStatus[Permission.contacts] ??
          PermissionStatus.undetermined;
    } else {
      return permission;
    }
  }
}

