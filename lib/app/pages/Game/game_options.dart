import 'package:flutter/material.dart';
import 'package:gmoria/app/utils/InitialGameArguments.dart';
import 'package:gmoria/domain/models/UserList.dart';

class GameOptions extends StatefulWidget {
  final UserList userList;

  const GameOptions({Key key, this.userList}) : super(key: key);

  @override
  _QuizOptionsDialogState createState() => _QuizOptionsDialogState();
}

class _QuizOptionsDialogState extends State<GameOptions> {
  int _noOfQuestions;
  String _difficulty;
  bool processing;

  @override
  void initState() {
    super.initState();
    _noOfQuestions = widget.userList.persons.length;
    _difficulty = "easy";
    processing = false;
  }

  @override
  Widget build(BuildContext context){
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey.shade200,
            child: Text(widget.userList.listName, style: Theme.of(context).textTheme.title.copyWith(),),
          ),
          SizedBox(height: 10.0),
          Text("Select Total Number of Questions"),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              runSpacing: 16.0,
              spacing: 16.0,
              children: <Widget>[
                SizedBox(width: 0.0),
                widget.userList.persons.length>10 ? ActionChip(
                  label: Text(" ${(widget.userList.persons.length/4).round()}"),
                  labelStyle: TextStyle(color: Colors.white),
                  backgroundColor: _noOfQuestions == (widget.userList.persons.length/4).round() ? Colors.blue : Colors.grey.shade600,
                  onPressed: () => _selectNumberOfQuestions((widget.userList.persons.length/4).round()),
                ) : Container(),
                widget.userList.persons.length>3 ? ActionChip(
                  label: Text(" ${(widget.userList.persons.length/3).round()}"),
                  labelStyle: TextStyle(color: Colors.white),
                  backgroundColor: _noOfQuestions == (widget.userList.persons.length/3).round() ? Colors.blue : Colors.grey.shade600,
                  onPressed: () => _selectNumberOfQuestions((widget.userList.persons.length/3).round()),
                ) : SizedBox(width: 0.0),
                ActionChip(
                  label: Text(" ${(widget.userList.persons.length/2).round()}"),
                  labelStyle: TextStyle(color: Colors.white),
                  backgroundColor: _noOfQuestions == (widget.userList.persons.length/2).round() ? Colors.blue : Colors.grey.shade600,
                  onPressed: () => _selectNumberOfQuestions((widget.userList.persons.length/2).round()),
                ),
                ActionChip(
                  label: Text("All"),
                  labelStyle: TextStyle(color: Colors.white),
                  backgroundColor: _noOfQuestions == widget.userList.persons.length ? Colors.blue : Colors.grey.shade600,
                  onPressed: () => _selectNumberOfQuestions(widget.userList.persons.length),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.0),
          processing ? CircularProgressIndicator() : RaisedButton(
            child: Text("Start Quiz"),
            onPressed: _startQuiz,
          ),
          SizedBox(height: 20.0),
        ],
      ),
    );
  }

  _selectNumberOfQuestions(int i) {
    setState(() {
      _noOfQuestions = i;
    });
  }

  void _startQuiz()  {
    Navigator.pushNamed(context, '/game', arguments: InitialGameArguments(widget.userList, false,_noOfQuestions));
  }
}