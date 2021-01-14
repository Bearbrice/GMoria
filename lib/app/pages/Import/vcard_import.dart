import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gmoria/app/utils/app_localizations.dart';
import 'package:gmoria/app/utils/arguments/ImportArguments.dart';
import 'package:gmoria/domain/models/Person.dart';
import 'package:gmoria/domain/models/UserList.dart';
import 'package:vcard_parser/vcard_parser.dart';

class VCardPage extends StatefulWidget {
  @override
  _VCardPageState createState() => _VCardPageState();

  VCardPage({Key key}) : super(key: key);
}

class _VCardPageState extends State<VCardPage> {
  AppLocalizations appLoc;
  String _path = '-';
  bool _pickFileInProgress = false;
  List<Person> people = new List<Person>();

  Future<void> setPerson() async {
    File f = new File(_path);
    await readFile(f);
  }

  Future<void> readFile(_file) async {
    String content;

    try {
      final file = await _file;

      // Read the file
      content = await file.readAsString();
    } catch (e) {
      // If encountering an error, return.
      return;
    }

    int pos;
    String identifier;
    String data = "";
    bool keepReading = false;
    VcardParser vcp;

    LineSplitter.split(content).forEach((line) => {
          pos = line.indexOf(':'),

          //Add line
          data += line + '\n',

          //Keep reading next line
          if (pos == -1)
            {
              keepReading = true,
            }
          //Else: Means it is a new line
          else
            {
              //If keepReading was true we save the data and the identifier
              if (keepReading == true)
                {
                  keepReading = false,
                },

              identifier = line.substring(0, pos),

              if (identifier == 'END')
                {
                  print('-----------END SPOTTED--------------------'),
                  vcp = VcardParser(data),
                  data = "",
                  people.add(getPerson(vcp)),
                }
            }
        });
  }

  Person getPerson(VcardParser vcp) {
    print('-----------GET PERSON--------------------');
    Map<String, Object> tags = vcp.parse();

    String name = tags['N'];
    var arr = name.split(';');

    print('LENGTH' + arr.length.toString());

    print('-----COMPLETE PERSON----');
    Person p = new Person(arr[1], arr[0], tags['ORG'], tags['NOTE'], "");
    print(p.firstname);
    print(p.lastname);
    print(p.job);
    print(p.description);

    return p;
  }

  @override
  Widget build(BuildContext context) {
    UserList userList = ModalRoute.of(context).settings.arguments;
    appLoc = AppLocalizations.of(context);

    return _pickFileInProgress == false
        ? RaisedButton.icon(
            onPressed: _pickFileInProgress
                ? null
                : () async {
                    await _pickDocument().then((value) => {
                          if (people.isEmpty)
                            {
                              Fluttertoast.showToast(
                                  msg: appLoc.translate('only_vcf'),
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0),
                              //If fails it automatically pops so we need to push the page
                              Navigator.pushNamed(
                                  context, '/importSelectionScreen',
                                  arguments: userList),
                            }
                          else
                            {
                              Navigator.pushNamed(
                                  context, '/importSelectionContacts',
                                  arguments:
                                      new ImportArguments(people, userList)),
                            }
                        });
                  },
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            label: Text(
              appLoc.translate('import_vcard'),
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            icon: Icon(
              Icons.file_present,
              color: Colors.white,
            ),
            textColor: Colors.white,
            splashColor: Colors.blueAccent,
            color: Colors.blue,
          )
        : CircularProgressIndicator();
  }

  Future<void> _pickDocument() async {
    String result;
    try {
      setState(() {
        _path = '-';
        _pickFileInProgress = true;
      });

      FlutterDocumentPickerParams params = FlutterDocumentPickerParams(
        allowedFileExtensions: ['vcf'],
      );

      result = await FlutterDocumentPicker.openDocument(params: params);
    } catch (e) {
      print(e);
      result = 'Error: $e';
      Navigator.pop(context);
    } finally {
      setState(() {
        _pickFileInProgress = false;
      });
    }

    setState(() {
      _path = result;
    });

    await setPerson();
  }
}
