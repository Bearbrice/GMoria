import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gmoria/app/utils/GameArguments.dart';
import 'package:gmoria/app/utils/InitialGameArguments.dart';
import 'package:gmoria/domain/blocs/person/PersonBloc.dart';
import 'package:gmoria/domain/blocs/person/PersonEvent.dart';
import 'package:gmoria/domain/blocs/userlist/UserListBloc.dart';
import 'package:gmoria/domain/blocs/userlist/UserListEvent.dart';
import 'package:gmoria/domain/models/Person.dart';
import 'package:gmoria/domain/models/UserList.dart';
import 'package:pie_chart/pie_chart.dart';

class GameFinishedPage extends StatelessWidget {
  List<Person> persons;
  Map<int, dynamic> answers;
  UserList userList;
  GameArguments args;
  Map<String, double> dataMap;
  List<Color> colorList;

  int correctAnswers;
  int bestScore;

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context).settings.arguments;
    persons = args.persons;
    answers = args.answers;
    userList = args.userList;

    int correct = 0;
    int bad = 0;
    this.answers.forEach((index, value) {
      Person personToUpdate;
      if (this.persons[index].firstname.toLowerCase() +
              " " +
              this.persons[index].lastname.toLowerCase() ==
          value.toLowerCase()){
        correct++;
        personToUpdate = new Person(
            this.persons[index].firstname,
            this.persons[index].lastname,
            this.persons[index].job,
            this.persons[index].description,
            this.persons[index].image_url,
            imported_from : this.persons[index].imported_from,
            is_known: true,
            id: this.persons[index].id,
            lists: this.persons[index].lists,
            fk_user_id: this.persons[index].fk_user_id
        );
      }else{
        bad++;
        personToUpdate = new Person(
            this.persons[index].firstname,
            this.persons[index].lastname,
            this.persons[index].job,
            this.persons[index].description,
            this.persons[index].image_url,
            imported_from : this.persons[index].imported_from,
            is_known: false,
            id: this.persons[index].id,
            lists: this.persons[index].lists,
            fk_user_id: this.persons[index].fk_user_id
        );
      }

      BlocProvider.of<PersonBloc>(context).add(UpdatePerson(personToUpdate));

    });
    colorList = [
      Colors.green,
      Colors.red,
    ];
    dataMap = {
    "Correct": correct.toDouble(),
    "Bad": (persons.length-correct).toDouble(),
    };

    final TextStyle titleStyle = TextStyle(
        color: Colors.black87, fontSize: 16.0, fontWeight: FontWeight.w500);
    final TextStyle trailingStyle = TextStyle(
        color: Theme.of(context).primaryColor,
        fontSize: 20.0,
        fontWeight: FontWeight.bold);

    return WillPopScope(
        onWillPop: () {
          Navigator.popUntil(context,ModalRoute.withName('/'));
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('Result'),
            elevation: 0,
          ),
          body: Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).accentColor
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  PieChart(dataMap: dataMap,colorList: colorList),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      title: Text("Total Questions", style: titleStyle),
                      trailing: Text("${persons.length}", style: trailingStyle),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      title: Text("Score", style: titleStyle),
                      trailing: Text("${correct / persons.length * 100}%",
                          style: trailingStyle),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      title: Text("Correct Answers", style: titleStyle),
                      trailing: Text("$correct/${persons.length}",
                          style: trailingStyle),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      title: Text("Incorrect Answers", style: titleStyle),
                      trailing: Text(
                          "${persons.length - correct}/${persons.length}",
                          style: trailingStyle),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      RaisedButton(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 20.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        color: Colors.white,
                        child: Text("Check Answers"),
                        onPressed: () {
                          Navigator.pushNamed(context, '/checkanswers',
                              arguments: new GameArguments(persons, answers,userList));
                        },
                      ),
                      RaisedButton(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 20.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        color: Colors.white,
                        child: Text("Home"),
                        onPressed: () {
                          bestScore = (correct / persons.length * 100).toInt();
                          UserList updatedUserList = new UserList(
                            userList.listName,
                            id: userList.id,
                            bestScore: bestScore,
                            creation_date: userList.creation_date,
                            persons: userList.persons
                          );
                          BlocProvider.of<UserListBloc>(context).add(UpdateUserList(updatedUserList));
                          Navigator.popUntil(context,ModalRoute.withName('/'));
                        },
                      ),
                    ],
                  ),
                  new Container(
                    margin: const EdgeInsets.only(top: 35.0),
                    child: bad>0 ? RaisedButton(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 20.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      color: Colors.white,
                      child: Text("Restart"),
                      onPressed: () {
                        Navigator.popAndPushNamed(context, '/game',
                            arguments: InitialGameArguments(userList,true));
                      },
                    ) : Container(),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
