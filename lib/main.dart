import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gmoria/app/pages/Person/person_form_page.dart';
import 'package:gmoria/app/pages/list_person_page.dart';
import 'package:gmoria/data/repositories/DataPersonRepository.dart';
import 'package:gmoria/domain/blocs/person/PersonBloc.dart';
import 'package:gmoria/domain/blocs/person/PersonEvent.dart';
import 'app/pages/Person/person_view.dart';
import 'package:gmoria/data/firebase/authentication_service.dart';
import 'package:provider/provider.dart';
import 'app/pages/Person/person_view.dart';
import 'app/pages/home_page.dart';
import 'app/pages/learn_page.dart';
import 'app/pages/sign_in_page.dart';
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
    return MultiBlocProvider(
        providers: [
          BlocProvider<UserListBloc>(
            create: (context) {
              return UserListBloc(
                userListRepository: DataUserListRepository(),
              )..add(LoadUserList());
            },
          ),
          BlocProvider<PersonBloc>(
            create: (context) {
              return PersonBloc(
                personRepository: DataPersonRepository(),
              )..add(LoadPerson());
            },
          )
        ],
        child: MultiProvider(
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
              '/learn': (context) => LearnPage(),
              '/list': (context) => ListPage(),
              '/personForm': (context) => PersonForm(),
              '/personView': (context) => PersonView(),
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
        ));
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();
    // final firebaseUser = context.watch<AuthenticationService>().getUser();

    if (firebaseUser != null) {
      return MyHomePage();
    }
    return SignInPage();
  }
}
