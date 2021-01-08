import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:gmoria/domain/models/Person.dart';

class VCardPage extends StatefulWidget {
  @override
  _VCardPageState createState() => _VCardPageState();

  VCardPage({Key key}) : super(key: key);
}

class _VCardPageState extends State<VCardPage> {
  String _path = '-';
  bool _pickFileInProgress = false;
  Person p;

  setPerson(){

    File f = new File(_path);
    readCounter(f);

  }

  Future<void> readCounter(_file) async {

    String content;
    List<Person> people;

    try {
      final file = await _file;


      // Read the file.
      content = await file.readAsString();



      // print('------------------'+contents);
    } catch (e) {
      // If encountering an error, return 0.
      return;
    }

    Person p;
    int pos;
    String identifier;
    String data;
    LineSplitter.split(content).forEach((line) => {
      pos=line.indexOf(':'),
      identifier=line.substring(0, pos),
      data=line.substring(pos+1, line.length),

      print("ID->" + identifier),
      print("Data->" + data),

      // p=test(identifier, data);




  });




  }

  // test(identifier, data){
  //   Person p;
  //   switch (identifier) {
  //     case 'N':
  //       {
  //         p.firstname=data;
  //         p.lastname=data;
  //       }
  //       break;
  //
  //     case TWO:
  //       {
  //         statement(s);
  //       }
  //       break;
  //
  //     default:
  //       {
  //         statement(s);
  //       }
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Vcard (.vcf) importer'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.open_in_new),
              onPressed: _pickFileInProgress ? null : _pickDocument,
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
      ),
    );
  }

  _pickDocument() async {
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

    setPerson();
  }
}

