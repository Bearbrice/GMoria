import 'dart:math';
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
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class LearnPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserList userList = ModalRoute.of(context).settings.arguments;
    var elementToRender;
    final cardHeight = 400.0;
    final cardWidth = 400.0;

    //Check the size of the person list and manage exceptions
    if (userList.persons == null) {
      elementToRender = Center(
          child: Text("Your list is empty", style: TextStyle(fontSize: 20)));
    } else if (userList.persons.length == 1) {
      elementToRender = Center(
          child: Container(
              height: cardHeight, width: cardWidth, child: Text("1 person")));
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
            final personsList = shuffle(state.person);

            return PeopleSwiper(personsList);
          } else {
            return Text("Problem :D");
          }
        }));
  }

  List shuffle(List items) {
    var random = new Random();

    // Go through all elements.
    for (var i = items.length - 1; i > 0; i--) {

      // Pick a pseudorandom number according to the list length
      var n = random.nextInt(i + 1);

      var temp = items[i];
      items[i] = items[n];
      items[n] = temp;
    }

    return items;
  }

}

class PeopleSwiper extends StatefulWidget{
  final List<Person> personsList;

  const PeopleSwiper(this.personsList, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PeopleSwiperState();

}

class _PeopleSwiperState extends State<PeopleSwiper>{
  bool _loop = true;
  int _currentIndex = 0 ;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(_currentIndex.toString()+"/"+widget.personsList.length.toString()),
      Swiper(
      layout: SwiperLayout.TINDER,
      viewportFraction: 0.8,
      itemCount: widget.personsList.length,
      itemHeight: 400.0,
      itemWidth: 400.0,
      loop: _loop,
      onIndexChanged: (value) {
        _setCurrentIndex(value+1);
        if(value==1){
          print("toggleLoop");
          _toggleLoop();
        }
      },
      itemBuilder: (BuildContext context, int index) {
        //Load shown card, 2 previous cards and 2 next cards
        //getDownloadUrl(personsList[index].id);
        return PersonCard(widget.personsList[index]);
      },
    )],);
  }
  void _toggleLoop() {
    setState(() {
      _loop = false;
    });
  }

  void _setCurrentIndex(value){
    setState(() {
      _currentIndex += value;
    });
  }

/*
  Future<String> getDownloadUrl(String id) async{
    var url = await firebase_storage.FirebaseStorage.instance
        .ref()
        .child('persons')
        .child(FirebaseAuth.instance.currentUser.uid)
        .child(id+'.jpg')
        .getDownloadURL();
    print(id+"------------------------------------------------"+url);
    return url;
  }*/

}

class PersonCard extends StatelessWidget {
  final Person person;

  PersonCard(this.person);

  @override
  Widget build(BuildContext context) {
    return FlipCard(
      direction: FlipDirection.HORIZONTAL, // default
      front: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              child: Image.network(person.image_url, fit: BoxFit.fill)
          )
      ),
      back: Container(
        height: 400.0,
        width: 400.0,
        child: Center(
          child: Text(
            person.firstname + " " + person.lastname,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
      ),
    );
  }
}