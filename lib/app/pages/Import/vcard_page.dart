import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:gmoria/app/utils/ImportArguments.dart';
import 'package:gmoria/domain/models/Person.dart';
import 'package:gmoria/domain/models/UserList.dart';
import 'package:vcard_parser/vcard_parser.dart';

class VCardPage extends StatefulWidget {
  @override
  _VCardPageState createState() => _VCardPageState();

  VCardPage({Key key}) : super(key: key);
}

class _VCardPageState extends State<VCardPage> {
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
      // If encountering an error, return 0.
      return;
    }

    int pos;
    String identifier;
    String data = "";
    bool keepReading = false;

    VcardParser vcp;


    LineSplitter.split(content).forEach((line) =>
    {
      pos = line.indexOf(':'),

      //add line
      data += line + '\n',

      //keep reading next line
      if (pos == -1)
        {
          // data+=line,
          keepReading = true,
        }
      //Else: Means it is a new line
      else
        {
          //If keepReading was true we save the data and the identifier
          if (keepReading = true)
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
    UserList userList = ModalRoute
        .of(context)
        .settings
        .arguments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vcard (.vcf) importer'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.open_in_new),
            onPressed: _pickFileInProgress
                ? null
                : () async {
              await _pickDocument().then((value) =>
                  Navigator.popAndPushNamed(
                      context, '/importSelectionContacts',
                      arguments: new ImportArguments(people, userList)));
              // Timer(Duration(milliseconds: 500), () {
              // print('people' + people.toString());

              // });
              // print('people' + people.toString());
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Picked file path:',
              ),
              Text('$_path'),
              _pickFileInProgress ? CircularProgressIndicator() : Container(),
            ],
          ),
        ),
      ),
    );
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
