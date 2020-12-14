import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gmoria/app/pages/Person/person_form_page.dart';
import 'package:gmoria/app/pages/User/sign_up_page.dart';
import 'package:gmoria/app/pages/User/user_page.dart';
import 'package:gmoria/app/pages/User/welcome_page.dart';
import 'package:gmoria/app/pages/list_person_page.dart';
import 'package:gmoria/data/firebase/authentication_service.dart';
import 'package:gmoria/data/repositories/DataPersonRepository.dart';
import 'package:gmoria/domain/blocs/person/PersonBloc.dart';
import 'package:gmoria/domain/blocs/person/PersonEvent.dart';
import 'package:provider/provider.dart';
import 'app/pages/AllContacts/all_contacts_page.dart';
import 'app/pages/AllContacts/import_from_all_contacts.dart';
import 'app/pages/Game/check_game_answers_page.dart';
import 'app/pages/Game/finish_game_page.dart';
import 'app/pages/Game/game_page.dart';
import 'app/pages/Person/person_view.dart';
import 'app/pages/User/agreement_page.dart';
import 'app/pages/home_page.dart';
import 'app/pages/learn_page.dart';
import 'app/utils/app_localizations.dart';
import 'data/repositories/DataUserListRepository.dart';
import 'domain/blocs/simple_bloc_observer.dart';
import 'domain/blocs/userlist/UserListBloc.dart';
import 'domain/blocs/userlist/UserListEvent.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = SimpleBlocObserver();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(FirebaseAuth.instance),
        ),
        StreamProvider(
          create: (context) =>
              context.read<AuthenticationService>().authStateChanges,
        )
      ],
      child: MaterialApp(
        title: 'GMoria',
        initialRoute: '/',
        routes: {
          '/signUp': (context) => SignUpPage(),
          '/checkanswers': (context) => CheckAnswersPage(),
          '/endgame': (context) => GameFinishedPage(),
          '/game': (context) => GamePage(),
          '/learn': (context) => LearnPage(),
          '/list': (context) => ListPage(),
          '/allContacts': (context) => AllContacts(),
          '/importFromAllContacts': (context) => ImportFromAllContacts(),
          '/personForm': (context) => PersonForm(),
          '/personDetails': (context) => PersonDetailsPage(),
          '/terms': (context) => Agreement(),
          '/userPage': (context) => UserPage(),
        },
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: AuthenticationWrapper(),
        supportedLocales: [
          const Locale('en', ''),
          const Locale('fr', ''),
        ],
        localizationsDelegates: [
          // A class which loads the translations from JSON files
          AppLocalizations.delegate,
          // Built-in localization of basic text for Material widgets
          GlobalMaterialLocalizations.delegate,
          // Built-in localization for text direction LTR/RTL
          GlobalWidgetsLocalizations.delegate,
        ],
        // Returns a locale which will be used by the app
        localeResolutionCallback: (locale, supportedLocales) {
          // Check if the current device locale is supported
          for (var supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
          // If the locale of the device is not supported, use the first one
          // from the list (English, in this case).
          return supportedLocales.first;
        },
      ),
    );
  }
}

class AuthenticationWrapper extends StatefulWidget {
  @override
  _AuthenticationWrapperState createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  bool isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();
    // final firebaseUser = context.watch<AuthenticationService>().getUser();

    if (firebaseUser != null) {
      if (isLoggedIn == false) {
        setState(() {
          isLoggedIn = true;
        });
      }
      return MultiBlocProvider(providers: [
        BlocProvider<UserListBloc>(create: (context) {
          return UserListBloc(
            userListRepository: DataUserListRepository(),
          )..add(LoadUserList());
        }),
        BlocProvider<PersonBloc>(create: (context) {
          return PersonBloc(
            personRepository: DataPersonRepository(),
          )..add(LoadPerson());
        }),
      ], child: MyHomePage());
    } else {
      if (isLoggedIn == true) {
        setState(() {
          isLoggedIn = false;
        });
      }
      return WelcomePage();
    }
  }
}
