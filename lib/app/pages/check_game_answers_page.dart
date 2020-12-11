import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:gmoria/app/utils/GameArguments.dart';
import 'package:gmoria/domain/models/Person.dart';

class CheckAnswersPage extends StatelessWidget {
  List<Person> persons;
  Map<int,dynamic> answers;
  GameArguments args;
  Image _image;

  @override
  Widget build(BuildContext context){
    args = ModalRoute.of(context).settings.arguments;
    persons = args.persons;
    answers = args.answers;

    return Scaffold(
      appBar: AppBar(
        title: Text('Check Answers'),
        elevation: 0,
      ),
      body: Stack(
        children: <Widget>[
          ClipPath(
            clipper: WaveClipperTwo(),
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor
              ),
              height: 200,
            ),
          ),
          ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: persons.length+1,
            itemBuilder: _buildItem,

          )
        ],
      ),
    );
  }
  Widget _buildItem(BuildContext context, int index) {
    if(index == persons.length) {
      return RaisedButton(
        child: Text("Done"),
        onPressed: (){
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
        },
      );
    }
    Person person = persons[index];
    bool correct = person.firstname + " " + person.lastname == answers[index];
    _image = Image.network(person.image_url);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _image == null
                ? Text(
                'Error, could not load image or a problem occured.')
                : Container(
              child:
              ExtendedImage.network(person.image_url),
              width: 100,
              height: 100,
            ),
            SizedBox(height: 5.0),
            Text("${answers[index]}", style: TextStyle(
                color: correct ? Colors.green : Colors.red,
                fontSize: 18.0,
                fontWeight: FontWeight.bold
            ),),
            SizedBox(height: 5.0),
            correct ? Container(): Text.rich(TextSpan(
                children: [
                  TextSpan(text: "Answer: "),
                  TextSpan(text: person.firstname + " " + person.lastname , style: TextStyle(
                      fontWeight: FontWeight.w500
                  ))
                ]
            ),style: TextStyle(
                fontSize: 16.0
            ),)
          ],
        ),
      ),
    );
  }
}