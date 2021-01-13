import 'package:flutter/material.dart';
import 'package:gmoria/app/utils/InitialGameArguments.dart';
import 'package:gmoria/app/utils/app_localizations.dart';
import 'package:gmoria/domain/models/UserList.dart';

class GameOptions extends StatefulWidget {
  final UserList userList;
  final int number;

  const GameOptions({Key key, this.userList,this.number}) : super(key: key);

  @override
  _QuizOptionsDialogState createState() => _QuizOptionsDialogState();
}

class _QuizOptionsDialogState extends State<GameOptions> {
  int _noOfQuestions;
  bool processing;

  @override
  void initState() {
    super.initState();
    _noOfQuestions = widget.number;
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
          Text(AppLocalizations.of(context).translate('game_options_instructions_label')),
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              runSpacing: 16.0,
              spacing: 16.0,
              children: <Widget>[
                SizedBox(width: 0.0),
                widget.number>10 ? ActionChip(
                  label: Text(" ${(widget.number/4).round()}"),
                  labelStyle: TextStyle(color: Colors.white),
                  backgroundColor: _noOfQuestions == (widget.number/4).round() ? Colors.blue : Colors.grey.shade600,
                  onPressed: () => _selectNumberOfQuestions((widget.number/4).round()),
                ) : Container(),
                widget.number>3 ? ActionChip(
                  label: Text(" ${(widget.number/3).round()}"),
                  labelStyle: TextStyle(color: Colors.white),
                  backgroundColor: _noOfQuestions == (widget.number/3).round() ? Colors.blue : Colors.grey.shade600,
                  onPressed: () => _selectNumberOfQuestions((widget.number/3).round()),
                ) : SizedBox(width: 0.0),
                ActionChip(
                  label: Text(" ${(widget.number/2).round()}"),
                  labelStyle: TextStyle(color: Colors.white),
                  backgroundColor: _noOfQuestions == (widget.number/2).round() ? Colors.blue : Colors.grey.shade600,
                  onPressed: () => _selectNumberOfQuestions((widget.number/2).round()),
                ),
                ActionChip(
                  label: Text(AppLocalizations.of(context).translate('game_options_all_option')),
                  labelStyle: TextStyle(color: Colors.white),
                  backgroundColor: _noOfQuestions == widget.number ? Colors.blue : Colors.grey.shade600,
                  onPressed: () => _selectNumberOfQuestions(widget.number),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.0),
          processing ? CircularProgressIndicator() : RaisedButton(
            child: Text(AppLocalizations.of(context).translate('game_options_start_quiz_button')),
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