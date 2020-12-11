import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:gmoria/app/pages/User/welcome.dart';
import 'package:gmoria/app/utils/app_localizations.dart';
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
  final TextEditingController password2Controller = TextEditingController();

  var AppContext;

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
            Text('Back',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white))
          ],
        ),
      ),
    );
  }

  Widget _entryField(String title, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
              obscureText: isPassword,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  // Widget _submitButton() {
  //   return Container(
  //     width: MediaQuery.of(context).size.width,
  //     padding: EdgeInsets.symmetric(vertical: 15),
  //     alignment: Alignment.center,
  //     decoration: BoxDecoration(
  //         borderRadius: BorderRadius.all(Radius.circular(5)),
  //         boxShadow: <BoxShadow>[
  //           BoxShadow(
  //               color: Colors.grey.shade200,
  //               offset: Offset(2, 4),
  //               blurRadius: 5,
  //               spreadRadius: 2)
  //         ],
  //         gradient: LinearGradient(
  //             begin: Alignment.centerLeft,
  //             end: Alignment.centerRight,
  //             colors: [Color(0xfffbb448), Color(0xfff7892b)])),
  //     child: Text(
  //       'Register Now',
  //       style: TextStyle(fontSize: 20, color: Colors.white),
  //     ),
  //   );
  // }

  Widget _submitButton() {
    return InkWell(
      onTap: () {
        if (_formKey.currentState.validate()) {
          if (passwordController.text == password2Controller.text) {
            print(true);
          } else {
            print(false);
            return;
          }

          context
              .read<AuthenticationService>()
              .signUp(
                email: emailController.text.trim(),
                password: password2Controller.text.trim(),
              )
              .then((value) => {print(value), Navigator.pop(context)});
        }

        // print(show);
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
          'Register now',
          // style: TextStyle(fontSize: 20, color: Color(0xfff7892b)),
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ),
    );
  }

  Widget _loginAccountLabel() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        // Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => LoginPage()));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Already have an account ?',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              'Login',
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

  Widget _signInForm() {
    return Form(
      key: _formKey,
      // child: SingleChildScrollView(
      child: Column(
        // return Column(
        children: [
          SizedBox(
            height: 20,
          ),
          MyTextField(
            controller: emailController,
            labelText: AppContext.translate('signIn_email'),
            obscure: false,
            validator: (email) =>
                EmailValidator.validate(email) ? null : "Invalid email address",
          ),
          SizedBox(
            height: 10,
          ),
          MyTextField(
            controller: passwordController,
            labelText: AppContext.translate('signIn_password'),
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
            labelText: 'Confirm password',
            obscure: true,
            validator: (String value) {
              if (passwordController.text != password2Controller.text) {
                return 'The confirmed password does not match the first one';
              }
              // if (value.isEmpty) {
              //   return 'You must provide a password (minimum length: 6)';
              // }
              // if (value.length < 6) {
              //   return 'The password must have a minimum length of 6)';
              // }
              return null;
            },
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
    // return RichText(
    // textAlign: TextAlign.center,
    return Text(
      'Register',

      style: TextStyle(
          shadows: [Shadow(color: Colors.white, offset: Offset(0, -5))],
          color: Colors.transparent,
          decoration: TextDecoration.underline,
          decorationColor: Colors.cyanAccent,
          decorationThickness: 0.8,
          // decorationStyle: TextDecorationStyle.dashed,
          fontSize: 20,
          fontWeight: FontWeight.w700),
      // style: TextStyle(
      //     shadows: [
      //       Shadow(
      //           color: Colors.black,
      //           offset: Offset(0, -5))
      //     ],
      //     decoration: TextDecoration.underline,
      //     decorationThickness: 2,
      //     decorationColor: Colors.cyan,
      //       fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white
      //   ),
    );

    // return Text(
    //
    //     text: 'Register',
    //     style: TextStyle(
    //         fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white
    //     ),
    //     // children: [
    //     //   TextSpan(
    //     //     text: 'M',
    //     //     style: TextStyle(color: Colors.black, fontSize: 30),
    //     //   ),
    //     //   TextSpan(
    //     //     text: 'oria',
    //     //     style: TextStyle(color: Colors.white, fontSize: 30),
    //     //   ),
    //     // ]
    // );
    // ,
    // );
  }

  // Widget _emailPasswordWidget() {
  //   return Column(
  //     children: <Widget>[
  //       _entryField("Username"),
  //       _entryField("Email id"),
  //       _entryField("Password", isPassword: true),
  //     ],
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    AppContext = AppLocalizations.of(context);
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
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      // colors: [Color(0xfffbb448), Color(0xffe46b10)])),
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
                    height: 20,
                  ),
                  // _signInButton(),
                  // _submitButton(),
                  SizedBox(
                    height: 20,
                  ),
                  _submitButton(),
                  // SizedBox(height: height * .14),
                  _loginAccountLabel(),
                  // _signUpButton(),
                  // SizedBox(
                  //   height: 20,
                  // ),
                  // _label()
                ],
              ),
            ),
          ),
          Positioned(top: 40, left: 0, child: _backButton()),
        ],
      ),
    );
  }

  // @override
  Widget Z(BuildContext context) {
    AppContext = AppLocalizations.of(context);
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SingleChildScrollView(
        // child: Stack(
        //     children: <Widget>[
        child: Container(
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
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  // colors: [Color(0xfffbb448), Color(0xffe46b10)])),
                  colors: [Colors.cyan, Colors.blueAccent])),
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: height * .2),
                _title(),
                SizedBox(
                  height: 50,
                ),
                // _emailPasswordWidget(),
                _signInForm(),
                SizedBox(
                  height: 50,
                ),
                _submitButton(),
                SizedBox(height: height * .14),
                _loginAccountLabel(),
              ],
            ),
          ),
        ),
        // Positioned(top: 40, left: 0, child: _backButton()),
        // ],
        //
        // child: Container(
        //   padding: EdgeInsets.symmetric(horizontal: 20),
        //   height: MediaQuery.of(context).size.height,
        //   decoration: BoxDecoration(
        //       borderRadius: BorderRadius.all(Radius.circular(5)),
        //       boxShadow: <BoxShadow>[
        //         BoxShadow(
        //             color: Colors.grey.shade200,
        //             offset: Offset(2, 4),
        //             blurRadius: 5,
        //             spreadRadius: 2)
        //       ],
        //       gradient: LinearGradient(
        //           begin: Alignment.topCenter, end: Alignment.bottomCenter,
        //           // colors: [Color(0xfffbb448), Color(0xffe46b10)])),
        //           colors: [Colors.blue, Colors.lightBlueAccent])),
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: <Widget>[
        //       _title(),
        //       SizedBox(
        //         height: 80,
        //       ),
        //       _signInForm(),
        //       SizedBox(
        //         height: 20,
        //       ),
        //       _signInButton(),
        //       // _submitButton(),
        //       SizedBox(
        //         height: 20,
        //       ),
        //       _signUpButton(),
        //       // SizedBox(
        //       //   height: 20,
        //       // ),
        //       // _label()
        //     ],
        //   ),
        // ),
      ),
    );

    // );
  }

  // @override
  Widget X(BuildContext context) {
    AppContext = AppLocalizations.of(context);
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        height: height,
        child: Stack(
          children: <Widget>[
            // Positioned(
            //   top: -MediaQuery.of(context).size.height * .15,
            //   right: -MediaQuery.of(context).size.width * .4,
            //   // child: BezierContainer(),
            // ),
            Container(
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
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      // colors: [Color(0xfffbb448), Color(0xffe46b10)])),
                      colors: [Colors.cyan, Colors.blueAccent])),
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: height * .2),
                    _title(),
                    SizedBox(
                      height: 50,
                    ),
                    // _emailPasswordWidget(),
                    _signInForm(),
                    SizedBox(
                      height: 50,
                    ),
                    _submitButton(),
                    SizedBox(height: height * .14),
                    _loginAccountLabel(),
                  ],
                ),
              ),
            ),
            Positioned(top: 40, left: 0, child: _backButton()),
          ],
        ),
      ),
    );
  }
}

// class MyTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String labelText;
//   final bool obscure;
//   final Function validator;
//
//   MyTextField({this.controller, this.labelText, this.obscure, this.validator});
//
//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       obscureText: obscure,
//       controller: controller,
//       validator: validator,
//       keyboardType: isEmail ? TextInputType.emailAddress : textInputType,
//       cursorColor: Colors.black,
//       style: TextStyle(color: Colors.white),
//       decoration: InputDecoration(
//         labelText: labelText,
//         labelStyle: TextStyle(color: Colors.white),
//         enabledBorder: UnderlineInputBorder(
//           borderSide: BorderSide(color: Colors.white),
//         ),
//         focusedBorder: UnderlineInputBorder(
//           borderSide: BorderSide(color: Colors.white70),
//         ),
//       ),
//     );
//   }
// }
