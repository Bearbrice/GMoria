import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class Agreement extends StatelessWidget {
  bool readMode;

  Widget build(BuildContext context) {
    readMode = ModalRoute.of(context).settings.arguments;
    print('READMODE' + readMode.toString());

    bool accepted = false;
    return DefaultTabController(
      length: 2,
      child: SafeArea(
          child: Scaffold(
        appBar: AppBar(
            title: const Text('Terms and conditions'),
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.privacy_tip), text: 'Privacy Policy'),
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
                        // Navigator.of(context).pop(accepted);
                        Navigator.pop(context, accepted);
                        print("POPED->" + accepted.toString());
                      },
                      child:
                          Text('AGREE', style: TextStyle(color: Colors.white)))
            ]),
        backgroundColor: Colors.white,
        body: TabBarView(children: [
          // TO IMPLEMENT AppLocalizations.of(context).locale=='en'
          MyFutureBuilder(
              future: rootBundle.loadString("assets/text/PrivacyPolicy.md")),
          MyFutureBuilder(
              future: rootBundle.loadString("assets/text/TermsConditions.md"))
        ]),
      )),
    );
    // );
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
