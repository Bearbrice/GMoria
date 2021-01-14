import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:gmoria/app/utils/InitialGameArguments.dart';
import 'package:gmoria/app/utils/app_localizations.dart';
import 'package:gmoria/data/repositories/DataPersonRepository.dart';
import 'package:gmoria/domain/blocs/person/PersonBloc.dart';
import 'package:gmoria/domain/blocs/person/PersonEvent.dart';
import 'package:gmoria/domain/blocs/person/PersonState.dart';
import 'package:gmoria/domain/models/Person.dart';
import 'package:gmoria/domain/models/UserList.dart';

class LearnPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserList userList = ModalRoute.of(context).settings.arguments;
    final cardHeight = 465.0;
    final cardWidth = 400.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          AppLocalizations.of(context).translate('learn_title') +
              userList.listName,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: PersonsList(
              userList: userList, cardHeight: cardHeight, cardWidth: cardWidth),
        ),
      ),
    );
  }
}

class PersonsList extends StatelessWidget {
  final UserList userList;
  final cardWidth;
  final cardHeight;

  PersonsList({Key key, this.userList, this.cardWidth, this.cardHeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<PersonBloc>(
            create: (context) {
              return PersonBloc(
                personRepository: DataPersonRepository(),
              )..add(LoadUserListPersons(userList.id));
            },
          )
        ],
        child: BlocBuilder<PersonBloc, PersonState>(builder: (context, state) {
          if (state is PersonLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is UserListPersonLoaded) {
            if (state.person.length == 1) {
              return Column(children: [
                Container(
                    margin: EdgeInsets.only(top: 20.0, bottom: 15.0),
                    padding: EdgeInsets.all(30.0),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.lightBlue),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            1.toString(),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            " /" + 1.toString(),
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ])),
                Center(
                    child: Container(
                        width: cardWidth * 0.9,
                        height: cardHeight * 1.1,
                        child: PersonCard(state.person.first))),
                RaisedButton(
                    onPressed: () {
                      Navigator.popAndPushNamed(context, '/game',
                          arguments: InitialGameArguments(
                              userList, false, userList.persons.length));
                    },
                    color: Colors.green,
                    padding: const EdgeInsets.all(10.0),
                    textColor: Colors.white,
                    child: Text(
                        AppLocalizations.of(context)
                            .translate('learn_gameButton'),
                        style: TextStyle(fontSize: 20)))
              ]);
            }
            List<Person> personsList = state.person;
            personsList.shuffle();
            return PeopleSwiper(personsList, userList);
          } else {
            return Text(AppLocalizations.of(context).translate("unknown_error"),
                style: TextStyle(fontSize: 20));
          }
        }));
  }
}

class PeopleSwiper extends StatefulWidget {
  final List<Person> personsList;
  final UserList userList;

  const PeopleSwiper(this.personsList, this.userList, {Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PeopleSwiperState();
}

class _PeopleSwiperState extends State<PeopleSwiper> {
  int _currentIndex = 0;
  bool displayGameButton = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            margin: EdgeInsets.only(top: 10.0),
            padding: EdgeInsets.all(30.0),
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Colors.lightBlue),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                _currentIndex.toString(),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                " /" + widget.personsList.length.toString(),
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ])),
        Swiper(
          layout: SwiperLayout.TINDER,
          itemCount: widget.personsList.length,
          index: -1,
          itemHeight: 463.0,
          itemWidth: 400.0,
          loop: true,
          onIndexChanged: (value) {
            _setCurrentIndex(widget.personsList.length - value);
          },
          itemBuilder: (BuildContext context, int index) {
            return PersonCard(widget.personsList[index]);
          },
        ),
        AnimatedContainer(
            width: displayGameButton ? 200 : 0.0,
            height: displayGameButton ? 60 : 0.0,
            curve: Curves.ease,
            duration: Duration(seconds: 1),
            child: Container(
                margin: EdgeInsets.only(top: 10.0),
                child: RaisedButton(
                    onPressed: () {
                      Navigator.popAndPushNamed(context, '/game',
                          arguments: InitialGameArguments(widget.userList,
                              false, widget.userList.persons.length));
                    },
                    color: Colors.green,
                    padding: const EdgeInsets.all(10.0),
                    textColor: Colors.white,
                    child: Text(
                        AppLocalizations.of(context)
                            .translate('learn_gameButton'),
                        style: TextStyle(fontSize: 20)))))
      ],
    );
  }

  void _setCurrentIndex(value) {
    setState(() {
      if (value == widget.personsList.length) {
        displayGameButton = true;
      } else {
        displayGameButton = false;
      }
      _currentIndex = value;
    });
  }
}

class PersonCard extends StatelessWidget {
  final Person person;

  PersonCard(this.person);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        child: Column(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0)),
                child: ExtendedImage.network(
                  person.image_url,
                  fit: BoxFit.fill,
                  enableMemoryCache: true,
                  handleLoadingProgress: false,
                )),
            Container(
              height: 70.0,
              width: 400.0,
              decoration: BoxDecoration(
                color: Colors.lightBlue,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0)),
              ),
              child: Center(
                child: Text(
                  person.firstname + " " + person.lastname,
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
            )
          ],
        ));
  }
}
