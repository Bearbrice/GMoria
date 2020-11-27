import 'package:flutter/material.dart';
import 'package:gmoria/app/utils/app_localizations.dart';
import 'package:gmoria/data/firebase/authentication_service.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  var AppContext;

  @override
  Widget build(BuildContext context) {
    AppContext = AppLocalizations.of(context);
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(25.0),
        child : Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: AppContext.translate('signIn_email'),
              ),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: AppContext.translate('signIn_password'),
              ),
            ),
            RaisedButton(
              onPressed: () {
                context.read<AuthenticationService>().signIn(
                  email: emailController.text.trim(),
                  password: passwordController.text.trim(),
                );
              },
              child: Text(AppContext.translate('signIn_button')),
            )
          ],
      ),
      ),
    );
  }
}