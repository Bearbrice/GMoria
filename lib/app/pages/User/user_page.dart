import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gmoria/app/utils/MyTextFormField.dart';
import 'package:gmoria/app/utils/app_localizations.dart';
import 'package:gmoria/data/firebase/authentication_service.dart';
import 'package:gmoria/domain/blocs/userlist/UserListBloc.dart';
import 'package:gmoria/domain/blocs/userlist/UserListEvent.dart';
import 'package:gmoria/domain/models/UserList.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UserPage extends StatefulWidget {
  UserPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final TextEditingController passwordController = TextEditingController();
  AppLocalizations appLoc;

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
                  text: ' ' + appLoc.translate('logout'),
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
              ],
            ),
          )),
    );
  }

  Widget _linkToTerms() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/terms', arguments: true);
      },
      child: Container(
        padding: EdgeInsets.all(5),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              appLoc.translate('link_privacy_policy_text'),
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

  Widget _deleteAccountButton(List<UserList> userLists) {
    return InkWell(
      onTap: () {
        deleteAccountDialog(userLists);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 13, horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          border: Border.all(color: Colors.white70, width: 2),
        ),
        child: Text(
          appLoc.translate('delete_account'),
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
        padding: EdgeInsets.symmetric(vertical: 13, horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          border: Border.all(color: Colors.white70, width: 2),
        ),
        child: Text(
          appLoc.translate('change_email'),
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _subtitle() {
    return Text(
      appLoc.translate('account_info'),
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
          Text(appLoc.translate('signIn_email')),
          Text('$email', style: TextStyle(color: Colors.white, fontSize: 17)),
          SizedBox(
            height: 20,
          ),
          Text(appLoc.translate('connected_with')),
          Text(formatProvider(),
              style: TextStyle(color: Colors.white, fontSize: 17)),
          SizedBox(
            height: 20,
          ),
          Text(appLoc.translate('creation_date')),
          Text('$ct', style: TextStyle(color: Colors.white, fontSize: 17)),
        ]));
  }

  Future<void> deleteLists(userLists) async {
    for (UserList ul in userLists) {
      BlocProvider.of<UserListBloc>(context).add(DeleteUserList(ul));
    }
  }

  deleteAccountDialog(List<UserList> userLists) {
    final _formKey = GlobalKey<FormState>();

    String provider = context
        .read<AuthenticationService>()
        .getUser()
        .providerData
        .first
        .providerId;

    String message;
    String messageDelete;

    Future<String> reAuthenticate() async {
      String errorMessage = '';
      if (_formKey.currentState.validate()) {
        errorMessage = await context
            .read<AuthenticationService>()
            .reAuthenticateUser(passwordController.text.trim());
        passwordController.text = "";
      }
      return errorMessage;
    }

    return showDialog<bool>(
      context: context,
      builder: (context) {
        bool isSwitched = false;
        bool showError = false;

        bool showPwdError = false;

        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(appLoc.translate('delete_account')),
            content: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                //position
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    appLoc.translate('warning_delete'),
                    style:
                        TextStyle(fontSize: 15, color: Colors.deepOrange[900]),
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
                    title: new Text(appLoc.translate('read_accept_delete'),
                        style: TextStyle(fontSize: 14)),
                  ),
                  !showError
                      ? Container()
                      : Text(appLoc.translate('error_not_read'),
                          style: TextStyle(color: Colors.red, fontSize: 12),
                          textAlign: TextAlign.center),
                  provider == 'password'
                      ? MyTextFormField(
                          controller: passwordController,
                          isPassword: true,
                          hintText: appLoc.translate('signIn_password'),
                          maxLines: 1,
                          validator: (String value) {
                            if (value.isEmpty) {
                              return appLoc.translate('must_provide_pwd');
                            }
                            return null;
                          },
                        )
                      : Container(),
                  showPwdError
                      ? Text('Error: $message',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                          textAlign: TextAlign.center)
                      : Container()
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(appLoc.translate('abort')),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              FlatButton(
                child: Text(appLoc.translate('yes_delete')),
                onPressed: () async => {
                  if (isSwitched == true)
                    {
                      // If the user is logged in with email and password, re-authenticate him
                      if (provider == 'password')
                        {
                          message = await reAuthenticate(),
                        },
                      //If the user has been correctly re-authenticate (Email-password)
                      if (message == 'Success' || provider == 'google.com')
                        {
                          print("HERE THE MESSAGE" + message.toString()),

                          // Delete all data stored in cloud firestore for a user
                          BlocProvider.of<UserListBloc>(context)
                              .add(DeleteAllDataFromUser(userLists)),

                          // Email-password: delete the user because re-authentication has already been handled
                          // Google: re-authenticate and delete the user
                          messageDelete = await context
                              .read<AuthenticationService>()
                              .deleteUser(),

                          print('State of the deletion:' +
                              messageDelete.toString()),

                          // Pop dialog
                          Navigator.pop(context),
                          //Pop user page
                          Navigator.pop(context),

                          Fluttertoast.showToast(
                              msg: appLoc.translate('toast_confirmation'),
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                              fontSize: 16.0),
                        }
                      else
                        {
                          setState(() {
                            showPwdError = true;
                          }),
                          print('Error triggered / set state ' + message),
                          if (message == 'wrong-password')
                            {message = appLoc.translate('wrong_password')},
                          if (message == 'too-many-requests')
                            {message = appLoc.translate('error_unexpected')},
                        }
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
    TextEditingController emailController = new TextEditingController();
    String current = context.read<AuthenticationService>().getUser().email;

    return showDialog<String>(
      context: context,
      child: AlertDialog(
        title: Text(appLoc.translate('change_your_email')),
        content: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              //position
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(appLoc.translate('current_email')),
                Text('$current',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    )),
                TextFormField(
                  controller: emailController,
                  autofocus: true,
                  decoration: InputDecoration(
                      labelText: appLoc.translate('enter_new_email')),
                  validator: (email) {
                    if (email == current) {
                      return appLoc.translate('same_email');
                    }
                    if (!EmailValidator.validate(email)) {
                      return appLoc.translate('invalid_email');
                    }
                    return null;
                  },
                ),
              ],
            )),
        actions: <Widget>[
          FlatButton(
              child: Text(appLoc.translate('cancel')),
              onPressed: () {
                Navigator.pop(context);
              }),
          FlatButton(
              child: Text(appLoc.translate('change')),
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  print('FORM VALIDATED!!');
                  print(emailController.text);

                  var message = await context
                      .read<AuthenticationService>()
                      .updateEmail(emailController.text);
                  print(message);

                  Navigator.pop(context);
                }
              })
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    String provider = context
        .watch<AuthenticationService>()
        .getUser()
        .providerData
        .first
        .providerId;

    final List<UserList> userLists = ModalRoute.of(context).settings.arguments;

    appLoc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appLoc.translate('title')),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.grey.shade200,
                    offset: Offset(2, 4),
                    blurRadius: 5,
                    spreadRadius: 2)
              ],
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
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
              provider == 'password'
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                          _changeEmailButton(),
                          SizedBox(
                            height: 20,
                          ),
                          _deleteAccountButton(userLists),
                        ])
                  : _deleteAccountButton(userLists),
            ],
          ),
        ),
      ),
    );
  }
}
