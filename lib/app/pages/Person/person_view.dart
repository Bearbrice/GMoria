import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gmoria/app/utils/ScreenArguments.dart';
import 'package:gmoria/data/repositories/DataPersonRepository.dart';
import 'package:gmoria/domain/blocs/person/PersonBloc.dart';
import 'package:gmoria/domain/blocs/person/PersonEvent.dart';
import 'package:gmoria/domain/blocs/person/PersonState.dart';
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

    return BlocProvider<PersonBloc>(
      create: (context) {
        print("ID A REFRESH dans la methode de chez person");
        //print(personsIdList);
        return PersonBloc(
          personRepository: DataPersonRepository(),
        )..add(LoadSinglePerson(person.id));
      },
      child: BlocBuilder<PersonBloc, PersonState>(builder: (context, state) {
        if(state is SinglePersonLoaded) {
          return Scaffold(
            appBar: AppBar(
              title: Text(state.person.firstname + " " + state.person.lastname),
            ),
            body: PersonInfo(
              person: state.person,
              idUserList: idUserList,
            ),
          );
        }else{
          return Container();
        }
      }),
    );
  }
}

class PersonInfo extends StatefulWidget {
  final Person person;
  final String idUserList;

  PersonInfo({Key key, this.person, this.idUserList}) : super(key: key);

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
                    : Container(
                        child: ExtendedImage.network(person.image_url,
                            fit: BoxFit.fill),
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
                      // padding: EdgeInsets.all(16.0),
                      alignment: Alignment.center,
                      width: halfMediaWidth,
                      child: MyText(
                        label: 'First name',
                        text: person.firstname,
                      )),
                  Container(
                      // padding: EdgeInsets.all(16.0),
                      alignment: Alignment.center,
                      width: halfMediaWidth,
                      child: MyText(
                        label: 'Last name',
                        text: person.lastname,
                      )),
                  // Container(
                  //     padding: EdgeInsets.all(16.0),
                  //     alignment: Alignment.center,
                  //     width: halfMediaWidth,
                  //     child: MyText(
                  //       text: person.lastname,
                  //     ))
                ],
              ),
            ),
            Container(
                // padding: EdgeInsets.all(16.0),
                alignment: Alignment.center,
                // width: halfMediaWidth,
                child: MyText(
                  label: 'Job',
                  text: person.job,
                )),

            // Text(
            //   person.job,
            //   style: TextStyle(
            //       fontWeight: FontWeight.w900,
            //       fontStyle: FontStyle.italic,
            //       fontFamily: 'Open Sans',
            //       fontSize: 40),
            // ),

            Container(
                padding: EdgeInsets.all(16.0),
                alignment: Alignment.center,
                // width: halfMediaWidth,
                child: MyText(
                  label: 'Description',
                  text: person.description,
                )),
            RaisedButton(
              color: Colors.blueAccent,
              child: Text("Edit", style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pushNamed(context, '/personForm',
                  arguments: new ScreenArguments(person, idUserList)),

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

// var text = new

class MyText extends StatelessWidget {
  final String text;
  final String label;

  MyText({this.text, this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(5.0),
        // child: Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: (label),
            // Note: Styles for TextSpans must be explicitly defined.
            // Child text spans will inherit styles from parent
            style: TextStyle(
              fontSize: 15.0,
              // fontFamily: 'Open Sans',
              color: Colors.black,
            ),

            children: <TextSpan>[
              TextSpan(
                  text: '\n$text',
                  style:
                      TextStyle(fontWeight: FontWeight.w700, fontSize: 20.0)),
            ],
          ),
        ));
  }
}

class MyTextLabel extends StatelessWidget {
  final String text;

  MyTextLabel({
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
              fontSize: 10)),
    );
  }
}
