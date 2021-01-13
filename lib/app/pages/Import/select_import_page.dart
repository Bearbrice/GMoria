import 'dart:io';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:gmoria/app/pages/Import/vcard_import.dart';
import 'package:gmoria/app/utils/ImportArguments.dart';
import 'package:gmoria/app/utils/app_localizations.dart';
import 'package:gmoria/domain/models/Person.dart';
import 'package:gmoria/domain/models/UserList.dart';
import 'package:permission_handler/permission_handler.dart';

class ImportSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserList userList = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          AppLocalizations.of(context).translate("select_import_title"),
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
                    final PermissionStatus permissionStatus =
                        await _getPermission();
                    if (permissionStatus == PermissionStatus.granted) {
                      final Iterable<Contact> contactsList =
                          await ContactsService.getContacts();
                      List<Person> persons = new List();
                      for (Contact contact in contactsList) {
                        Person person = new Person(contact.givenName,
                            contact.familyName, contact.jobTitle, "", "");
                        persons.add(person);
                      }

                      Navigator.pushNamed(context, '/importSelectionContacts',
                          arguments: ImportArguments(persons, userList));
                      //We can now access our contacts here
                    } else {
                      //If permissions have been denied show an alert dialog
                      showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                                title: Text(AppLocalizations.of(context).translate("permissions_error")),
                                content: Text(AppLocalizations.of(context).translate("select_import_permissions_error")),
                                actions: <Widget>[
                                  FlatButton(
                                      child: Text(AppLocalizations.of(context).translate("ok")),
                                      onPressed: () =>
                                          Navigator.of(context).pop())
                                ],
                              ));
                    }
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  label: Text(
                    AppLocalizations.of(context).translate("select_import_phone"),
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  icon: Icon(
                    Icons.smartphone,
                    color: Colors.white,
                  ),
                  textColor: Colors.white,
                  splashColor: Colors.blueAccent,
                  color: Colors.blue),
            ),
            SizedBox(height: 50),
            ButtonTheme(height: 70, minWidth: 240, child: VCardPage()),
            SizedBox(height: 50),
            ButtonTheme(
              height: 70,
              minWidth: 240,
              child: RaisedButton.icon(
                onPressed: () async {
                  //Get the persons from a csv file
                  var persons = await _getCSV();
                  if (persons.isEmpty) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                              title: Text(AppLocalizations.of(context).translate("select_import_csv_error"),
                                style: TextStyle(color: Colors.red),),
                              content: Text(
                                  AppLocalizations.of(context).translate("select_import_csv_error_message")),
                              actions: <Widget>[
                                FlatButton(
                                    child: Text(AppLocalizations.of(context).translate("ok")),
                                    onPressed: () =>
                                        Navigator.of(context).pop())
                              ],
                            ));
                  } else {
                    Navigator.pushNamed(context, '/importSelectionContacts',
                        arguments: ImportArguments(persons, userList));
                  }
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                label: Text(
                  AppLocalizations.of(context).translate("select_import_csv"),
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                icon: Icon(
                  Icons.upload_file,
                  color: Colors.white,
                ),
                textColor: Colors.white,
                splashColor: Colors.blueAccent,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Get the CSV file and generate the people list from it
  Future<List<Person>> _getCSV() async {
    String result;
    try {
      FlutterDocumentPickerParams params = FlutterDocumentPickerParams(
        allowedFileExtensions: ['csv'],
      );
      result = await FlutterDocumentPicker.openDocument(params: params);

      File myFile = await File(result);

      List<String> lines = await myFile.readAsLines();
      List<List<String>> contacts = new List<List<String>>();
      for (var line in lines) {
        contacts.add(line.split(";"));
      }
      //Verify that the columns match our pattern
      List<String> titlesLine = contacts.first;
      if (titlesLine[0] != "Firstname" &&
          titlesLine[1] != "Lastname" &&
          titlesLine[2] != "Job" &&
          titlesLine[3] != "Description") {
        throw new Exception(
            "The columns must be : Firstname, Lastname, Job and Description");
      }

      //Remove the column titles line
      contacts.removeAt(0);
      //Transform lines into a list of people
      List<Person> persons = new List<Person>();
      for (var contact in contacts) {
        Person person = new Person(contact[0] ?? "", contact[1] ?? "",
            contact[2] ?? "", contact[3] ?? "", "");
        persons.add(person);
      }
      return persons;
    } catch (e) {
      print(e);
      result = 'Error: $e';
      return new List<Person>();
    }
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
