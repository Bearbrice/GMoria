import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:gmoria/app/pages/User/intro_page.dart';
import 'package:gmoria/app/utils/app_localizations.dart';
import 'package:gmoria/data/firebase/authentication_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Mode : signup (readmode = false), readonly (readmode = true), mandatory (mandatory=true)
class Agreement extends StatelessWidget {
  bool readMode;
  bool mandatoryMode = false;

  String agreed = "false";

  Widget _showMarkdown(ctx) {
    switch (AppLocalizations.of(ctx).locale.toString()) {
      case 'en':
        return TabBarView(children: [
          MyFutureBuilder(
              future: rootBundle.loadString("assets/text/PrivacyPolicy.md")),
          MyFutureBuilder(
              future: rootBundle.loadString("assets/text/TermsConditions.md"))
        ]);
        break;
      case 'fr':
        return TabBarView(children: [
          MyFutureBuilder(
              future: rootBundle.loadString("assets/text/PrivacyPolicy_FR.md")),
          MyFutureBuilder(
              future:
                  rootBundle.loadString("assets/text/TermsConditions_FR.md"))
        ]);
        break;
      default:
        return TabBarView(children: [
          MyFutureBuilder(
              future: rootBundle.loadString("assets/text/PrivacyPolicy.md")),
          MyFutureBuilder(
              future: rootBundle.loadString("assets/text/TermsConditions.md"))
        ]);
        break;
    }
  }

  Widget build(BuildContext context) {
    if (ModalRoute.of(context).settings.arguments != null) {
      readMode = ModalRoute.of(context).settings.arguments;
    } else {
      readMode = false;
      mandatoryMode = true;
    }

    BuildContext ctx = context;
    bool accepted = false;

    return WillPopScope(
      onWillPop: () async {
        if (mandatoryMode) {
          final value = await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: Text(
                      'Are you sure you want to exit? (you will need to recreate your account and the data will be lost)'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('No'),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                    FlatButton(
                      child: Text('Yes, exit '),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                        // Delete user
                        ctx.read<AuthenticationService>().deleteUser();
                      },
                    ),
                  ],
                );
              });
          return value == true;
        }
        return true;
      },
      child: DefaultTabController(
        length: 2,
        child: SafeArea(
            child: Scaffold(
                appBar: AppBar(
                    title: const Text('Terms and conditions'),
                    bottom: TabBar(
                      tabs: [
                        Tab(
                            icon: Icon(Icons.privacy_tip),
                            text: 'Privacy Policy'),
                        Tab(
                            icon: Icon(Icons.warning_amber_rounded),
                            text: 'Terms and conditions'),
                      ],
                    ),
                    actions: [
                      readMode
                          ? Container()
                          : FlatButton(
                              onPressed: () {
                                accepted = true;

                                Navigator.pushNamed(context, '/introPage');

                                print("POPED->" + accepted.toString());
                              },
                              child: Text('AGREE',
                                  style: TextStyle(color: Colors.white)))
                    ]),
                backgroundColor: Colors.white,
                body: _showMarkdown(context))),
      ),
    );
  }
}

class MyFutureBuilder extends StatelessWidget {
  final Future<String> future;

  MyFutureBuilder({Key key, this.future}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: future,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return Markdown(
              data: snapshot.data,
              onTapLink: (text, href, title) => {launch(href)},
              styleSheet: MarkdownStyleSheet(
                textAlign: WrapAlignment.start,
                h1: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                h2: TextStyle(
                  fontSize: 20,
                ),
                p: TextStyle(
                  fontSize: 15,
                ),
              ),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
