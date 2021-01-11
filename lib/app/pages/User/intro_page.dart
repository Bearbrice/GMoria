import 'package:flutter/material.dart';
import 'package:gmoria/app/utils/app_localizations.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';

class IntroPage extends StatelessWidget {
  AppLocalizations appLoc;

  setAppLoc(context) {
    appLoc = AppLocalizations.of(context);
  }

  //making list of pages needed to pass in IntroViewsFlutter constructor.
  listPages() {
    return [
      PageViewModel(
          pageColor: const Color(0xFF03A9F4),
          bubble: Icon(Icons.list_alt),
          body: Text(appLoc.translate("intro_list")),
          title: Text(appLoc.translate("lists")),
          titleTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
          bodyTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
          mainImage: Image.asset(
            'assets/picture/List.jpeg',
            height: 285.0,
            width: 285.0,
            alignment: Alignment.center,
          )),
      PageViewModel(
        pageColor: const Color(0xFF8BC34A),
        bubble: Icon(Icons.school),
        body: Text(appLoc.translate("intro_learn")),
        title: Text(appLoc.translate("learn")),
        mainImage: Image.asset(
          'assets/picture/Learn.jpeg',
          height: 285.0,
          width: 285.0,
          alignment: Alignment.center,
        ),
        titleTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
        bodyTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
      ),
      PageViewModel(
        pageColor: const Color(0xFF607D8B),
        bubble: Icon(Icons.videogame_asset),
        body: Text(appLoc.translate("intro_game")),
        title: Text(appLoc.translate("game")),
        mainImage: Image.asset(
          'assets/picture/Game.jpeg',
          height: 285.0,
          width: 285.0,
          alignment: Alignment.center,
        ),
        titleTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
        bodyTextStyle: TextStyle(fontFamily: 'MyFont', color: Colors.white),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    setAppLoc(context);

    return Scaffold(
      body:
          // Builder(
          //
          // builder: (context) =>
          IntroViewsFlutter(
        listPages(),
        showNextButton: true,
        showBackButton: true,
        onTapDoneButton: () {
          //Pop to agreeement
          Navigator.pop(context);
          //As agreeement has already been accepted pop the page agreement page as well
          Navigator.pop(context);
        },
        pageButtonTextStyles: TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        ),
      ),
    ); //IntroViewsFlutter
    // ), //Builder
    // ); //Material App
  }
}
