import 'dart:io';

import 'package:extended_image/extended_image.dart';
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
  Image _image;

  @override
  Widget build(BuildContext context) {
    final halfMediaWidth = MediaQuery.of(context).size.width / 2.0;
    person = widget.person;
    idUserList = widget.idUserList;
    _image = Image.network(person.image_url);
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              child: Center(
                child: _image == null
                    ? Text('Error, could not load image or a problem occured.')
                    : Container (
                  child : ExtendedImage.network(person.image_url,fit: BoxFit.fill),
                  width: 300,
                  height: 300,
            ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.all(16.0),
                      alignment: Alignment.center,
                      width: halfMediaWidth,
                      child: MyText(
                        text: person.firstname,
                      )),
                  Container(
                      padding: EdgeInsets.all(16.0),
                      alignment: Alignment.center,
                      width: halfMediaWidth,
                      child: MyText(
                        text: person.lastname,
                      ))
                ],
              ),
            ),
            Container(
                padding: EdgeInsets.all(16.0),
                alignment: Alignment.center,
                // width: halfMediaWidth,
                child: MyText(
                  text: person.job,
                )
                // Text(
                //   person.job,
                //   style: TextStyle(
                //       fontWeight: FontWeight.w900,
                //       fontStyle: FontStyle.italic,
                //       fontFamily: 'Open Sans',
                //       fontSize: 40),
                // ),
                ),
            Container(
                padding: EdgeInsets.all(16.0),
                alignment: Alignment.center,
                // width: halfMediaWidth,
                child: MyText(
                  text: person.description,
                )),
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

class MyText extends StatelessWidget {
  final String text;

  MyText({
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(text,
          style: TextStyle(
              fontWeight: FontWeight.w900,
              fontFamily: 'Open Sans',
              fontSize: 20)),
    );
  }
}
