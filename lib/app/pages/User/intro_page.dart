import 'package:flutter/material.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';

class IntroPage extends StatelessWidget {
  //making list of pages needed to pass in IntroViewsFlutter constructor.
  final pages = [
    PageViewModel(
        pageColor: const Color(0xFF03A9F4),
        // iconImageAssetPath: 'assets/air-hostess.png',
        // bubble: Image.asset('assets/picture/Game.jpeg'),
        bubble: Icon(Icons.list_alt),
        body: Text(
          'Create your own lists and swipe on the list to do quick actions',
        ),
        title: Text(
          'Lists',
        ),
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
      // iconImageAssetPath: 'assets/picture/Game.jpeg',
      body: Text(
        'Take time to learn the people you want to memorize',
      ),
      title: Text('Learn'),
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
      // iconImageAssetPath: 'assets/picture/Game.jpeg',
      body: Text(
        'Test your knowledge and get a score on your lists to track your improvements.',
      ),
      title: Text('Game'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // debugShowCheckedModeBanner: false,
      // title: 'IntroViews Flutter', //title of app
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      // ), //ThemeData
      // home:
      body: Builder(
        builder: (context) => IntroViewsFlutter(
          pages,
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
        ), //IntroViewsFlutter
      ), //Builder
    ); //Material App
  }
}
