import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:gmoria/app/utils/app_localizations.dart';
import 'package:gmoria/data/firebase/authentication_service.dart';
import 'package:provider/provider.dart';

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

  var AppContext;

  bool error = false;
  String errorMessage = "";

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
                          errorMessage =
                              'No user found for that email or wrong password provided';
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
                  // color: Color(0xffdf8e33).withAlpha(100),
                  color: Colors.lightBlueAccent,
                  offset: Offset(2, 4),
                  blurRadius: 8,
                  spreadRadius: 2)
            ],
            color: Colors.white),
        child: Text(
          'Sign in',
          // style: TextStyle(fontSize: 20, color: Color(0xfff7892b)),
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ),
    );
  }

  Widget _googleButton(){
    return InkWell(
      child: Container(

          // width: deviceSize
              // .width/2,
          // height: deviceSize.height/18,
          width: MediaQuery.of(context).size.width/1.5,
          padding: EdgeInsets.symmetric(vertical: 10),

          // margin: EdgeInsets.only(top: 25),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color:Colors.black
          ),
          child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    height: 30.0,
                    width: 30.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image:
                          AssetImage('assets/picture/google.jpg'),
                          fit: BoxFit.cover),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text('Sign in with Google',
                    style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),
                  ),
                ],
              )
          )
      ),
      onTap: ()
      async{
        context
            .read<AuthenticationService>()
            .signInWithGoogle();
        //   Navigator.of(context).pushNamedAndRemoveUntil
        //     (RouteName.Home, (Route<dynamic> route) => false
        //   );}
        // ).catchError((e) => print(e));
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
            labelText: AppContext.translate('signIn_email'),
            obscure: false,
            isEmail: true,
            validator: (email) =>
                EmailValidator.validate(email) ? null : "Invalid email address",
          ),
          MyTextField(
            controller: passwordController,
            labelText: AppContext.translate('signIn_password'),
            obscure: true,
            validator: (String value) {
              if (value.isEmpty) {
                return 'You must provide a password';
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
          'Register now',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
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

  @override
  Widget build(BuildContext context) {
    AppContext = AppLocalizations.of(context);
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
              _title(),
              SizedBox(
                height: 80,
              ),

              _signInForm(),
              // SizedBox(
              //   height: 10,
              // ),
              SizedBox(
                height: 10,
              ),
              _signInButton(),
              // _submitButton(),
              SizedBox(
                height: 20,
              ),
              _signUpButton(),
              SizedBox(
                height: 20,
              ),
              _googleButton(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reused in sign_up_page.dart
class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscure;
  final Function validator;
  final bool isEmail;

  MyTextField(
      {this.controller,
      this.labelText,
      this.obscure = false,
      this.validator,
      this.isEmail = false});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscure,
      controller: controller,
      validator: validator,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      cursorColor: Colors.black,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white70),
        ),
      ),
    );
  }
}
