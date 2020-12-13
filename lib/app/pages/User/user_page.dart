import 'package:flutter/material.dart';
import 'package:gmoria/app/utils/app_localizations.dart';
import 'package:gmoria/data/firebase/authentication_service.dart';
import 'package:provider/provider.dart';

class UserPage extends StatefulWidget {
  UserPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool readMode = false;

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
          border: Border.all(color: Colors.blue, width: 2),
        ),
        child: Text(
          'Logout',
          style: TextStyle(fontSize: 20, color: Colors.blue),
        ),
      ),
    );
  }

  Widget _linkToTerms() {
    return InkWell(
      onTap: () {
        // Navigator.pop(context);

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

  Widget _deleteAccountButton() {
    return InkWell(
      onTap: () {
        // Navigator.pushNamed(context, '/signUp', arguments: false);
      },
      child: Container(
        // width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          border: Border.all(color: Colors.blue, width: 2),
        ),
        child: Text(
          'Delete account',
          style: TextStyle(fontSize: 20, color: Colors.blue),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    // readMode = ModalRoute.of(context).settings.arguments;
    print('READMODE' + readMode.toString());
    String name = context.watch<AuthenticationService>().getUser().email;
    String name2 = context
        .watch<AuthenticationService>()
        .getUser()
        .providerData
        .first
        .providerId;
    String name3 = context
        .watch<AuthenticationService>()
        .getUser()
        .metadata
        .creationTime
        .toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('title')),
      ),
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
                  colors: [Colors.blue[50], Colors.blue[300]])),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _title(),
              SizedBox(
                height: 20,
              ),
              Text('Email: $name'),
              SizedBox(
                height: 20,
              ),
              Text('Connected with: $name2'),
              SizedBox(
                height: 20,
              ),
              Text('Created on: $name3'),
              SizedBox(
                height: 20,
              ),
              _logoutButton(),
              SizedBox(
                height: 20,
              ),
              _deleteAccountButton(),
              SizedBox(
                height: 20,
              ),
              _linkToTerms(),
            ],
          ),
        ),
      ),
    );
  }
}
