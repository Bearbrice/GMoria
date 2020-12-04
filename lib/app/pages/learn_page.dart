import 'package:extended_image/extended_image.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
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
    var elementToRender;
    final cardHeight = 400.0;
    final cardWidth = 400.0;

    //Check the size of the person list and manage exceptions
    if (userList.persons.isEmpty) {
      elementToRender = Center(
          child: Text(AppLocalizations.of(context).translate('learn_emptyList'),
              style: TextStyle(fontSize: 20)));
    } else {
      List<String> personsIdList =
          userList.persons.map((personId) => personId as String).toList();
      elementToRender = PersonsList(
          personsIdList: personsIdList,
          cardHeight: cardHeight,
          cardWidth: cardWidth);
    }
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
      body: Container(
        child: elementToRender,
      ),
    );
  }
}

class PersonsList extends StatelessWidget {
  final personsIdList;
  final cardWidth;
  final cardHeight;

  PersonsList({Key key, this.personsIdList, this.cardWidth, this.cardHeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<PersonBloc>(
            create: (context) {
              return PersonBloc(
                personRepository: DataPersonRepository(),
              )..add(LoadUserListPersons(personsIdList));
            },
          )
        ],
        child: BlocBuilder<PersonBloc, PersonState>(builder: (context, state) {
          if (state is PersonLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is PersonLoaded) {
            if (state.person.length == 1) {
              return Column(children: [
                Container(
                    margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
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
                        width: cardWidth * 0.8,
                        height: cardHeight * 0.8,
                        child: PersonCard(state.person.first)))
              ]);
            }
            List<Person> personsList = state.person;
            personsList.shuffle();
            return PeopleSwiper(personsList);
          } else {
            return Text(AppLocalizations.of(context).translate('learn_error'),
                style: TextStyle(fontSize: 20));
          }
        }));
  }
}

class PeopleSwiper extends StatefulWidget {
  final List<Person> personsList;

  const PeopleSwiper(this.personsList, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PeopleSwiperState();
}

class _PeopleSwiperState extends State<PeopleSwiper> {
  bool _loop = true;
  int _currentIndex = 0;
  bool displayGameButton = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
            margin: EdgeInsets.only(top: 20.0),
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
          viewportFraction: 0.8,
          itemCount: widget.personsList.length,
          index: -1,
          itemHeight: 400.0,
          itemWidth: 400.0,
          loop: _loop,
          onIndexChanged: (value) {
            _setCurrentIndex(widget.personsList.length - value);
            if (value == widget.personsList.length) {
              //print("toggleLoop");
              _toggleLoop();
            }
          },
          itemBuilder: (BuildContext context, int index) {
            return PersonCard(widget.personsList[index]);
          },
        ),
         AnimatedContainer(
             width: displayGameButton ? 200: 0.0,
             height: displayGameButton ? 100: 0.0,
             curve: Curves.ease,
             duration: Duration(seconds: 1),
             child:Container(
                margin: EdgeInsets.only(top: 35.0),
                child: RaisedButton(
                    onPressed: () {
                      //TODO navigate to Play Game
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

  void _toggleLoop() {
    setState(() {
      _loop = false;
    });
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
    return FlipCard(
      direction: FlipDirection.HORIZONTAL,
      speed: 450, // default
      front: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              child: ExtendedImage.network(
                person.image_url,
                fit: BoxFit.fill,
                enableMemoryCache: true,
                handleLoadingProgress: false,
              ))),
      back: Container(
        height: 400.0,
        width: 400.0,
        child: Center(
          child: Text(
            person.firstname + " " + person.lastname,
            style: TextStyle(color: Colors.white, fontSize: 30),
          ),
        ),
        decoration: BoxDecoration(
          color: Colors.cyan,
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
      ),
    );
  }
}
