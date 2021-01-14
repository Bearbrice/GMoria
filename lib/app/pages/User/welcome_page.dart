import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:gmoria/app/utils/app_localizations.dart';
import 'package:gmoria/app/utils/widgets/MyTextField.dart';
import 'package:gmoria/app/utils/widgets/Title.dart';
import 'package:gmoria/data/firebase/authentication_service.dart';
import 'package:provider/provider.dart';

import 'agreement_page.dart';

class WelcomePage extends StatefulWidget {
  WelcomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  AppLocalizations appLoc;

  bool error = false;
  String errorMessage = "";

  bool accepted = false;

  Widget _linkToTerms() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/terms', arguments: true);
      },
      child: Container(
        padding: EdgeInsets.all(5),
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              appLoc.translate('google_agree'),
              style: TextStyle(
                  color: Colors.indigo[900],
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
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

  Widget _signInButton() {
    return InkWell(
      onTap: () {
        if (_formKey.currentState.validate()) {
          context
              .read<AuthenticationService>()
              .signIn(
                  email: emailController.text.trim(),
                  password: passwordController.text.trim())
              .then((value) => {
                    if (value == 'user-not-found' || value == 'wrong-password')
                      {
                        setState(() {
                          error = true;
                          errorMessage = appLoc.translate('error_signin');
                        }),
                      }
                  });
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
          appLoc.translate('signIn_button'),
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ),
    );
  }

  Widget _googleButton() {
    return InkWell(
      child: Container(
          width: MediaQuery.of(context).size.width / 1.5,
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5), color: Colors.black),
          child: Center(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Container(
                height: 30.0,
                width: 30.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/picture/google.jpg'),
                      fit: BoxFit.cover),
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                appLoc.translate('signIn_google'),
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ))),
      onTap: () async {
        context
            .read<AuthenticationService>()
            .signInWithGoogle()
            .then((value) => {
                  if (value.additionalUserInfo.isNewUser)
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Agreement()),
                    )
                });
      },
    );
  }

  Widget _signInForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          MyTextField(
            controller: emailController,
            labelText: appLoc.translate('signIn_email'),
            obscure: false,
            isEmail: true,
            validator: (email) => EmailValidator.validate(email)
                ? null
                : appLoc.translate('invalid_email'),
          ),
          MyTextField(
            controller: passwordController,
            labelText: appLoc.translate('signIn_password'),
            obscure: true,
            validator: (String value) {
              if (value.isEmpty) {
                return appLoc.translate('must_provide_pwd');
              }
              return null;
            },
          ),
          SizedBox(
            height: 10,
          ),
          error
              ? Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                )
              : Container()
        ],
      ),
    );
  }

  Widget _signUpButton() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/signUp', arguments: false);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Text(
          appLoc.translate('register_now'),
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    appLoc = AppLocalizations.of(context);
    return Scaffold(
      body: SingleChildScrollView(
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
                  colors: [Colors.blue, Colors.lightBlueAccent])),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              title(),
              SizedBox(
                height: 80,
              ),
              _signInForm(),
              SizedBox(
                height: 10,
              ),
              _signInButton(),
              SizedBox(
                height: 20,
              ),
              _signUpButton(),
              SizedBox(
                height: 20,
              ),
              _googleButton(),
              _linkToTerms(),
            ],
          ),
        ),
      ),
    );
  }
}

