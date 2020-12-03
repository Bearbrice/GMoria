import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gmoria/app/utils/ScreenArguments.dart';
import 'package:gmoria/domain/models/Person.dart';
import 'package:gmoria/domain/models/PersonFormModel.dart';

class PersonView extends StatelessWidget {
  Person person;
  String idUserList;
  ScreenArguments args;
  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context).settings.arguments;
    person = args.person;
    idUserList = args.idUserList;

    // print("-------------->" + person.toString());

    return Scaffold(
      appBar: AppBar(
        title: Text(person.firstname + " " + person.lastname),
      ),
      body: PersonInfo(
        person: person,
        idUserList:idUserList,
      ),
    );
  }
}

class PersonInfo extends StatefulWidget {
  final Person person;
  final String idUserList;

  PersonInfo({Key key, this.person,this.idUserList}) : super(key: key);

  @override
  _PersonInfoState createState() => _PersonInfoState();
}

class _PersonInfoState extends State<PersonInfo> {
  Person person;
  String idUserList;
  // _PersonInfoState({Key key, this.person}) : super(key: key);

  PersonM model = PersonM();

  //TODO: Load image from firebase
  File _image = null;

  @override
  Widget build(BuildContext context) {
    final halfMediaWidth = MediaQuery.of(context).size.width / 2.0;
    person = widget.person;
    idUserList = widget.idUserList;
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              child: Center(
                child: _image == null
                    ? Text('No image selected.')
                    : Image.file(_image, width: 280.0, height: 280.0),
              ),
            ),
            Container(
              alignment: Alignment.topCenter,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    alignment: Alignment.topCenter,
                    width: halfMediaWidth,
                    child: Text(person.firstname),
                  ),
                  Container(
                    alignment: Alignment.topCenter,
                    width: halfMediaWidth,
                    child: Text(person.lastname),
                  )
                ],
              ),
            ),
            Text(person.job),
            Text(person.description),
            RaisedButton(
              color: Colors.blueAccent,
              child: Text("Edit", style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pushNamed(context, '/personForm',
                  arguments:  new ScreenArguments(person, idUserList)),

              // textColor: Colors.lightGreenAccent,
            ),
            RaisedButton(
              color: Colors.red,
              onPressed: () => "",
              // onPressed: () {
              // if (_formKey.currentState.validate()) {
              //   _formKey.currentState.save();
              //   Navigator.pushNamed(context, '/list');
              //   // Navigator.push(
              //   //     context,
              //   //     MaterialPageRoute(
              //   //         builder: (context) => Result(model: this.model)));
              // }
              // },
              child: Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
