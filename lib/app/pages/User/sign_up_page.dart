import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gmoria/app/utils/app_localizations.dart';
import 'package:gmoria/app/utils/widgets/MyTextField.dart';
import 'package:gmoria/data/firebase/authentication_service.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  /// The confirmation password
  final TextEditingController password2Controller = TextEditingController();
  /// The switch button
  bool isSwitched = false;
  bool showError = false;
  bool showAlreadyExists = false;

  AppLocalizations appLoc;

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.white),
            ),
            Text(appLoc.translate("back"),
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white))
          ],
        ),
      ),
    );
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () {
        if (isSwitched) {
          if (_formKey.currentState.validate()) {
            if (passwordController.text == password2Controller.text) {
              print(true);
            } else {
              print(false);
              return;
            }

            // Sign up the new user
            context
                .read<AuthenticationService>()
                .signUp(
                  email: emailController.text.trim(),
                  password: password2Controller.text.trim(),
                )
                .then((value) => {
                      if (value.toString() == 'email-already-in-use')
                        {
                          setState(() {
                            showAlreadyExists = true;
                          }),
                        }
                      else
                        {
                          setState(() {
                            showAlreadyExists = false;
                          }),

                          // The user is sign up and login, pop the page
                          Navigator.pushNamed(context, '/introPage'),
                        }
                    });
          }
        } else {
          setState(() {
            showError = true;
          });
          print(
              'The privacy policy and terms and conditions have not been accepted');
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
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
        child: Text(
          appLoc.translate("register_now"),
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ),
    );
  }

  Widget _loginAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              appLoc.translate("already_have"),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              appLoc.translate("login"),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linkToTerms() {
    return InkWell(
      onTap: () {
        moveToAgreement();
      },
      child: Container(
        padding: EdgeInsets.all(5),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              appLoc.translate("link_privacy_policy_text"),
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

  Widget _signInForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          MyTextField(
            controller: emailController,
            labelText: appLoc.translate('signIn_email'),
            obscure: false,
            validator: (email) =>
                EmailValidator.validate(email) ? null : "Invalid email address",
          ),
          SizedBox(
            height: 10,
          ),
          MyTextField(
            controller: passwordController,
            labelText: appLoc.translate('signIn_password'),
            obscure: true,
            validator: (String value) {
              if (value.isEmpty) {
                return 'You must provide a password (minimum length: 6)';
              }
              if (value.length < 6) {
                return 'The password must have a minimum length of 6)';
              }
              return null;
            },
          ),
          SizedBox(
            height: 10,
          ),
          MyTextField(
            controller: password2Controller,
            labelText: appLoc.translate('confirm_pwd'),
            obscure: true,
            validator: (String value) {
              if (passwordController.text != password2Controller.text) {
                return appLoc.translate('error_match_pwd');
              }
              return null;
            },
          ),
          SizedBox(
            height: 10,
          ),
          _linkToTerms(),
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
            title: new Text(appLoc.translate('read_privacy')),
          ),
          !showError
              ? Container()
              : Center(
                  child: Container(
                    width: 280.0,
                    height: 42.0,
                    alignment: Alignment(0.0, 0.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.blue[200],
                    ),
                    child: Text(
                      appLoc.translate('must_accept'),
                      style: new TextStyle(
                        color: Colors.red,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
          !showAlreadyExists
              ? Container()
              : Center(
                  child: Container(
                    width: 280.0,
                    height: 42.0,
                    alignment: Alignment(0.0, 0.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Colors.blue[200],
                    ),
                    child: Text(
                      appLoc.translate('already_exists'),
                      style: new TextStyle(
                        color: Colors.red,
                        height: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

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

  Widget _subtitle() {
    return Text(
      appLoc.translate('register'),
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

  /// Update the switch if the terms are accepted
  void updateIsSwitch(bool accepted) {
    setState(() => {isSwitched = accepted, showError = false});
  }

  /// Move to terms page and wait to get if the terms are accepted
  void moveToAgreement() async {
    final accepted =
        await Navigator.pushNamed(context, '/terms', arguments: false);

    if (accepted != null) {
      updateIsSwitch(accepted);
    } else {
      updateIsSwitch(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    appLoc = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
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
                      colors: [Colors.cyan, Colors.blueAccent])),
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
                    height: 10,
                  ),
                  _signInForm(),
                  SizedBox(
                    height: 10,
                  ),
                  _submitButton(),
                  _loginAccountLabel(),
                ],
              ),
            ),
          ),
          Positioned(top: 40, left: 0, child: _backButton()),
        ],
      ),
    );
  }
}
