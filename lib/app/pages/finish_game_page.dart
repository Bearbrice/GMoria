import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gmoria/app/utils/GameArguments.dart';
import 'package:gmoria/domain/models/Person.dart';

class GameFinishedPage extends StatelessWidget {
  List<Person> persons;
  Map<int, dynamic> answers;
  GameArguments args;

  int correctAnswers;


  @override
  Widget build(BuildContext context){
    args = ModalRoute.of(context).settings.arguments;
    persons = args.persons;
    answers = args.answers;

    int correct = 0;
    this.answers.forEach((index,value){
      if(this.persons[index].firstname + " " + this.persons[index].lastname == value)
        correct++;
    });
    final TextStyle titleStyle = TextStyle(
        color: Colors.black87,
        fontSize: 16.0,
        fontWeight: FontWeight.w500
    );
    final TextStyle trailingStyle = TextStyle(
        color: Theme.of(context).primaryColor,
        fontSize: 20.0,
        fontWeight: FontWeight.bold
    );

    return WillPopScope(
        onWillPop: () {
          Navigator.pop(context);
          Navigator.pop(context);
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
            gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).accentColor
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter
            )
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  title: Text("Total Questions", style: titleStyle),
                  trailing: Text("${persons.length}", style: trailingStyle),
                ),
              ),
              SizedBox(height: 10.0),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  title: Text("Score", style: titleStyle),
                  trailing: Text("${correct/persons.length * 100}%", style: trailingStyle),
                ),
              ),
              SizedBox(height: 10.0),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  title: Text("Correct Answers", style: titleStyle),
                  trailing: Text("$correct/${persons.length}", style: trailingStyle),
                ),
              ),
              SizedBox(height: 10.0),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  title: Text("Incorrect Answers", style: titleStyle),
                  trailing: Text("${persons.length - correct}/${persons.length}", style: trailingStyle),
                ),
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  RaisedButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: Colors.white,
                    child: Text("Home"),
                    onPressed: () {
                      //TODO : Find a better solution to go back 2 times
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  ),
                  RaisedButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    color: Colors.white,
                    child: Text("Check Answers"),
                    onPressed: (){
                      Navigator.pushNamed(context, '/checkanswers', arguments: new GameArguments(persons, answers) );
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    )
    );
  }
}