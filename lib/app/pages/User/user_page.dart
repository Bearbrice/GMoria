import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gmoria/app/utils/app_localizations.dart';
import 'package:gmoria/data/firebase/authentication_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UserPage extends StatefulWidget {
  UserPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  // bool isSwitched = false;

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'G',
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white),
          children: [
            TextSpan(
              text: 'M',
              style: TextStyle(color: Colors.black, fontSize: 30),
            ),
            TextSpan(
              text: 'oria',
              style: TextStyle(color: Colors.white, fontSize: 30),
            ),
          ]),
    );
  }

  Widget _logoutButton() {
    return InkWell(
      onTap: () {
        // Navigator.pushNamed(context, '/signUp', arguments: false);
        context.read<AuthenticationService>().signOut();
        Navigator.pop(context);
      },
      child: Container(
          // width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(vertical: 13),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    // color: Color(0xffdf8e33).withAlpha(100),
                    color: Colors.lightBlueAccent,
                    offset: Offset(2, 4),
                    blurRadius: 8,
                    spreadRadius: 2)
              ],
              color: Colors.white),
          child: RichText(
            text: TextSpan(
              children: [
                WidgetSpan(
                  child: Icon(Icons.logout, size: 20),
                ),
                TextSpan(
                  text: ' Logout',
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
              ],
            ),
          )

          // Text(
          //
          // ),
          ),
    );
  }

  Widget _linkToTerms() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/terms', arguments: true);
      },
      child: Container(
        // margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(5),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Privacy policy & Terms and conditions',
              style: TextStyle(
                  color: Colors.indigo[800],
                  fontSize: 15,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.indigo,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // /// Update the switch if the terms are accepted
  // void updateIsSwitch(bool accepted) {
  //   setState(() => {isSwitched = accepted, showError = false});
  // }

  Widget _deleteAccountButton() {
    return InkWell(
      onTap: () {
        // Navigator.pushNamed(context, '/signUp', arguments: false);
        deleteAccountDialog();

        // showDialog(
        //     context: context,
        //     builder: (_) {
        //       return MyDialog();
        //     });
      },
      child: Container(
        // width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 13, horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          border: Border.all(color: Colors.white70, width: 2),
        ),
        child: Text(
          'Delete account',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _changeEmailButton() {
    return InkWell(
      onTap: () {
        changeEmailDialog();
      },
      child: Container(
        // width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 13, horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          border: Border.all(color: Colors.white70, width: 2),
        ),
        child: Text(
          'Change email',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _subtitle() {
    return Text(
      'Your account information',
      style: TextStyle(
          shadows: [Shadow(color: Colors.white, offset: Offset(0, -5))],
          color: Colors.transparent,
          decoration: TextDecoration.underline,
          decorationColor: Colors.cyanAccent,
          decorationThickness: 0.8,
          fontSize: 20,
          fontWeight: FontWeight.w700),
    );
  }

  Widget _userInfo() {
    String email = context.watch<AuthenticationService>().getUser().email;
    String provider = context
        .watch<AuthenticationService>()
        .getUser()
        .providerData
        .first
        .providerId;
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm");
    DateTime creationTime =
        context.watch<AuthenticationService>().getUser().metadata.creationTime;
    String ct = dateFormat.format(creationTime);

    formatProvider() {
      if (provider == 'password') {
        provider = 'email and password';
      }
      return provider;
    }

    return Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          Text('Email'),
          // style: TextStyle(color: Colors.white, fontSize: 17)),

          Text('$email', style: TextStyle(color: Colors.white, fontSize: 17)),
          SizedBox(
            height: 20,
          ),
          Text('Connected with'),
          Text(formatProvider(),
              style: TextStyle(color: Colors.white, fontSize: 17)),
          SizedBox(
            height: 20,
          ),
          Text('Creation date'),
          Text('$ct', style: TextStyle(color: Colors.white, fontSize: 17)),
        ]));
  }

  deleteAccountDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        bool isSwitched = false;
        bool showError = false;
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Delete account'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              //position
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Warning: your account and all the data will be lost if you confirm this action',
                  style: TextStyle(fontSize: 15, color: Colors.deepOrange[900]),
                ),
                SwitchListTile(
                  value: isSwitched,
                  onChanged: (value) {
                    setState(() {
                      isSwitched = value;
                      showError = !value;
                      print('Agree:' + isSwitched.toString());
                    });
                  },
                  activeColor: Colors.lightGreenAccent,
                  // secondary: new Icon(Icons.find_in_page_sharp),
                  title: new Text(
                      'I have read the warning and confirm I want to delete my account',
                      style: TextStyle(fontSize: 14)),
                  // subtitle: new Text('and I agree with the policy'),
                ),
                !showError
                    ? Container()
                    : Text('Error: you must confirm you have read the warning',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                        textAlign: TextAlign.center),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Abort'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              FlatButton(
                child: Text('Yes, delete'),
                onPressed: () => {
                  if (isSwitched == true)
                    {
                      //Pop dialog
                      Navigator.pop(context),
                      //Pop user page
                      Navigator.pop(context),
                      //DELETE ACCOUNT
                      context.read<AuthenticationService>().deleteUser()
                    }
                  else
                    {
                      setState(() {
                        showError = true;
                      })
                    }
                },
              ),
            ],
          );
        });
      },
    );
  }

  changeEmailDialog() {
    final _formKey = GlobalKey<FormState>();
    TextEditingController listController = new TextEditingController();
    String current = context.read<AuthenticationService>().getUser().email;
    return showDialog<String>(
      context: context,
      child: AlertDialog(
        title: Text('Change your email'),
        // contentPadding: const EdgeInsets.all(16.0),
        content: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              //position
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Current email:'),
                Text('$current',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    )),
                TextFormField(
                  controller: listController,
                  autofocus: true,
                  decoration:
                      InputDecoration(labelText: 'Enter your new email:'),
                  validator: (email) {
                    if (email == current) {
                      return 'Same email as current email';
                    }
                    if (EmailValidator.validate(email) != null) {
                      return "Invalid email address";
                    }
                    return null;
                  },
                  //           validator: (email) =>
                  //           if(email==null){
                  //
                  // }
                  //
                  //           EmailValidator.validate(email)
                  //               ? null
                  //               : "Invalid email address",
                ),
              ],
            )),
        actions: <Widget>[
          FlatButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              }),
          FlatButton(
              child: const Text('Change'),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  print('FORM VALIDATED!!');
                }
                // listController.text = "";
              })
        ],
      ),
    );

    //   return showDialog<bool>(
    //     context: context,
    //     builder: (context) {
    //       return AlertDialog(
    //         title: Text('Delete'),
    //         content: Text('The list selected will be deleted'),
    //         actions: <Widget>[
    //           FlatButton(
    //             child: Text('Cancel'),
    //             onPressed: () => Navigator.of(context).pop(false),
    //           ),
    //           FlatButton(
    //             child: Text('Ok'),
    //             onPressed: () => {
    //               // Navigator.of(context).pop(true),
    //               // print("NOM : " + item.listName),
    //               // BlocProvider.of<UserListBloc>(context)
    //               //     .add(DeleteUserList(item)),
    //             },
    //           ),
    //         ],
    //       );
    //     },
    //   );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('title')),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              // borderRadius: BorderRadius.all(Radius.circular(2)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey.shade200,
                    offset: Offset(2, 4),
                    blurRadius: 5,
                    spreadRadius: 2)
              ],
              gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  // colors: [Colors.blue[50], Colors.blue[300]])),
                  colors: [Colors.cyan[300], Colors.blueAccent])),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _title(),
              SizedBox(
                height: 20,
              ),
              _subtitle(),
              SizedBox(
                height: 20,
              ),
              _userInfo(),
              SizedBox(
                height: 20,
              ),
              _linkToTerms(),
              SizedBox(
                height: 20,
              ),
              _logoutButton(),
              SizedBox(
                height: 20,
              ),
              // Row(
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     // mainAxisAlignment: MainAxisAlignment.center,
              //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //     children: <Widget>[
              //       _changeEmailButton(),
              //       SizedBox(
              //         height: 20,
              //       ),
              //       _deleteAccountButton(),
              //     ]),
            ],
          ),
        ),
      ),
    );
  }
}
