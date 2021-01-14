import 'dart:async';
import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gmoria/app/utils/app_localizations.dart';
import 'package:gmoria/app/utils/arguments/GameArguments.dart';
import 'package:gmoria/app/utils/arguments/InitialGameArguments.dart';
import 'package:gmoria/data/repositories/DataPersonRepository.dart';
import 'package:gmoria/domain/blocs/person/PersonBloc.dart';
import 'package:gmoria/domain/blocs/person/PersonEvent.dart';
import 'package:gmoria/domain/blocs/person/PersonState.dart';
import 'package:gmoria/domain/models/Person.dart';
import 'package:gmoria/domain/models/UserList.dart';

class GamePage extends StatelessWidget {
  InitialGameArguments args;

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context).settings.arguments;
    final UserList userList = args.userList;
    final bool onlyMistakes = args.onlyMistakes;
    final int quantity = args.quantity;

    var elementToRender;
    return MultiBlocProvider(
        providers: [
          BlocProvider<PersonBloc>(
            create: (context) {
              return PersonBloc(
                personRepository: DataPersonRepository(),
              )..add(LoadUserListPersons(userList.id));
            },
          )
        ],
        child: BlocBuilder<PersonBloc, PersonState>(builder: (context, state) {
          if (state is PersonLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is UserListPersonLoaded) {
            //Check the size of the person list and manage exceptions
            if (state.person.isEmpty) {
              elementToRender = Center(
                  child: Text(
                      AppLocalizations.of(context).translate('game_empty_list'),
                      style: TextStyle(fontSize: 20)));
            } else {
              List<Person> persons;
              if (onlyMistakes) {
                persons = new List<Person>();
                for (int i = 0; i < state.person.length; i++) {
                  if (!state.person[i].is_known) persons.add(state.person[i]);
                }
              } else {
                List<Person> tempList = state.person;
                tempList.shuffle();
                persons = new List<Person>();
                for (int i = 0; i < quantity; i++) {
                   persons.add(tempList[i]);
                }
              }
              persons.shuffle();
              elementToRender = QuizPage(
                  persons: persons,
                  userList: userList);
            }
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.blue,
                title: Text(
                  AppLocalizations.of(context).translate('game_title') +
                      userList.listName,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              body: Container(
                child: elementToRender,
              ),
            );
          } else {
            return Text(AppLocalizations.of(context).translate('game_error'),
                style: TextStyle(fontSize: 20));
          }
        }));
  }
}

class QuizPage extends StatefulWidget {
  final List<Person> persons;
  final UserList userList;

  const QuizPage({Key key, @required this.persons, this.userList})
      : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  TextEditingController nameController = new TextEditingController();
  Image _image;
  bool activeBtn = true;
  bool showAnswer = false;
  final TextStyle _personstyle = TextStyle(
      fontSize: 18.0, fontWeight: FontWeight.w500, color: Colors.white);

  int _currentIndex = 0;
  final Map<int, dynamic> _answers = {};
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Person person = widget.persons[_currentIndex];
    _image = Image.network(widget.persons[_currentIndex].image_url);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _key,
        body: Stack(
          children: <Widget>[
            ClipPath(
              clipper: WaveClipperTwo(),
              child: Container(
                decoration:
                    BoxDecoration(color: Theme.of(context).primaryColor),
                height: 100,
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          CircleAvatar(
                            backgroundColor: Colors.white70,
                            child: Text("${_currentIndex + 1}"),
                          ),
                          SizedBox(width: 16.0),
                          Container(
                            child: Text(
                              AppLocalizations.of(context).translate('game_question'),
                              softWrap: true,
                              style: MediaQuery.of(context).size.width > 800
                                  ? _personstyle.copyWith(fontSize: 30.0)
                                  : _personstyle,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 50.0),
                      Container(
                        child: Center(
                          child: _image == null
                              ? Text(
                              AppLocalizations.of(context).translate('game_image_load_error'))
                              : Container(
                                  child:
                                      ExtendedImage.network(person.image_url),
                                  width: 250,
                                  height: 250,
                                ),
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 30),
                          alignment: Alignment.center,
                          width: 200,
                          child: TextField(
                              controller: nameController,
                              decoration: new InputDecoration(
                                  focusColor: Colors.blue,
                                  border: OutlineInputBorder(),
                                  labelText: AppLocalizations.of(context).translate('game_label_input_answer')))),
                      Container(
                        child: Column(
                          children: [
                            showAnswer
                                ? Container(
                                    margin: EdgeInsets.only(top: 20),
                                    child: Text(
                                        widget.persons[_currentIndex]
                                                .firstname +
                                            " " +
                                            widget.persons[_currentIndex]
                                                .lastname,
                                        style: TextStyle(
                                            fontSize: 30.0,
                                            color: Colors.green)),
                                  )
                                : Container(),
                            Container(
                              margin: EdgeInsets.only(top: 30),
                              alignment: Alignment.bottomCenter,
                              child: RaisedButton(
                                color: Colors.blue,
                                padding: MediaQuery.of(context).size.width > 800
                                    ? const EdgeInsets.symmetric(
                                        vertical: 20.0, horizontal: 64.0)
                                    : null,
                                child: Text(
                                  _currentIndex == (widget.persons.length - 1)
                                      ? AppLocalizations.of(context).translate('game_submit_button')
                                      : AppLocalizations.of(context).translate('game_next_button'),
                                  style: MediaQuery.of(context).size.width > 800
                                      ? TextStyle(
                                          fontSize: 30.0, color: Colors.white)
                                      : TextStyle(color: Colors.white),
                                ),
                                onPressed: activeBtn ? _nextSubmit : null,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }

  void _nextSubmit() {
    _answers[_currentIndex] = nameController.text;
    if (_answers[_currentIndex] == "") {
      Fluttertoast.showToast(
          msg: AppLocalizations.of(context).translate('game_empty_answer_message'),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

    if(nameController.text.toLowerCase() !=
        widget.persons[_currentIndex].firstname.toLowerCase() +
            " " +
            widget.persons[_currentIndex].lastname.toLowerCase()){
      setState(() {
        showAnswer = true;
      });
    }

    Fluttertoast.showToast(
        msg: nameController.text.toLowerCase() ==
                widget.persons[_currentIndex].firstname.toLowerCase() +
                    " " +
                    widget.persons[_currentIndex].lastname.toLowerCase()
            ? AppLocalizations.of(context).translate('game_good_answer_message')
            : AppLocalizations.of(context).translate('game_bad_answer_message'),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: nameController.text.toLowerCase() ==
                widget.persons[_currentIndex].firstname.toLowerCase() +
                    " " +
                    widget.persons[_currentIndex].lastname.toLowerCase()
            ? Colors.green
            : Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);

    if (_currentIndex < (widget.persons.length - 1)) {
      setState(() {
        activeBtn = false;
      });

      Timer(Duration(seconds: 2), () {
        // 2s over, navigate to a new page
        setState(() {
          _currentIndex++;
          activeBtn = true;
          showAnswer = false;
        });
      });

      nameController.text = "";
    } else {
      setState(() {
        activeBtn = false;
      });
      Timer(Duration(seconds: 2), () {
        Navigator.pushNamed(context, '/endgame',
            arguments:
                new GameArguments(widget.persons, _answers, widget.userList));
      });
    }
  }

  Future<bool> _onWillPop() async {
    return showDialog<bool>(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: Text(
                AppLocalizations.of(context).translate('game_exit_before_end_message')),
            title: Text(AppLocalizations.of(context).translate('game_alert_box_exit_title')),
            actions: <Widget>[
              FlatButton(
                child: Text(AppLocalizations.of(context).translate('game_alert_box_yes_answer')),
                onPressed: () {
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                },
              ),
              FlatButton(
                child: Text(AppLocalizations.of(context).translate('game_alert_box_no_answer')),
                onPressed: () {
                  Navigator.pop(context, false);
                },
              ),
            ],
          );
        });
  }
}
