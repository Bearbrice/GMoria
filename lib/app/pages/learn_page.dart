import 'package:firebase_auth/firebase_auth.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:gmoria/app/utils/app_localizations.dart';
import 'package:gmoria/data/repositories/DataPersonRepository.dart';
import 'package:gmoria/domain/blocs/person/PersonBloc.dart';
import 'package:gmoria/domain/blocs/person/PersonEvent.dart';
import 'package:gmoria/domain/blocs/person/PersonState.dart';
import 'package:gmoria/domain/models/UserList.dart';

class LearnPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserList userList = ModalRoute.of(context).settings.arguments;
    var elementToRender;
    final cardHeight = 400.0;
    final cardWidth = 350.0;

    //Check the size of the person list and manage exceptions
    if (userList.persons == null) {
      elementToRender = Center(
          child: Text("Your list is empty", style: TextStyle(fontSize: 20)));
    } else if (userList.persons.length == 1) {
      elementToRender = Center(
          child: Container(
              height: cardHeight,
              width: cardWidth,
              child: PersonCard("1 person")));
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
            return Text("Loading !");
          } else if (state is PersonLoaded) {
            final personsList = state.person;
            return Swiper(
              index: 1,
              itemCount: personsList.length,
              itemBuilder: (BuildContext context, int index) {
                return PersonCard(personsList[index]);
              },
              viewportFraction: 0.8,
              scale: 0.9,
              layout: SwiperLayout.TINDER,
              itemWidth: cardWidth,
              itemHeight: cardHeight,
              loop: false,
            );
          } else {
            return Text("Problem :D");
          }
        }));
  }
}

class PersonCard extends StatelessWidget {
  final person;

  PersonCard(this.person);

  var user = FirebaseAuth.instance.currentUser;
  Image image;

  @override
  Widget build(BuildContext context) {
    /*final imageLink = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('persons')
        .child(user.uid)
        .child('lZBLynkQHxPP2nDISkva.jpg');
    final imageUrl = imageLink.getDownloadURL().then((url) => image = Image.network(url));*/
    return FlipCard(
      direction: FlipDirection.HORIZONTAL, // default
      front: Container(
        decoration: BoxDecoration(
            color: Colors.lightBlue,
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        child: Center(
            child: Text(
          person.description,
          style: TextStyle(color: Colors.white, fontSize: 20),
        )
            //image
            ),
      ),
      back: Container(
        child: Center(
          child: Text(
            person.firstname + " " + person.lastname,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        decoration: BoxDecoration(
          color: Colors.lightBlue,
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
      ),
    );
  }
}
