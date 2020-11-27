import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:gmoria/app/utils/app_localizations.dart';
import 'package:flip_card/flip_card.dart';



class LearnPage extends StatelessWidget {

  var people = [{
    "firstname":"Tiago",
    "lastname":"Castanheiro",
    "description":"Test1"
  },{
    "firstname":"Mickaël",
    "lastname":"Puglisi",
    "description":"Test2"
  },{
    "firstname":"Brice",
    "lastname":"Berclaz",
    "description":"Test3"
  },{
    "firstname":"Alexandre",
    "lastname":"Cotting",
    "description":"Test4"
  },{
    "firstname":"Gaetano",
    "lastname":"Manzo",
    "description":"Test 5"
  },{
    "firstname":"Michael",
    "lastname":"Schumacher",
    "description":"Test6"
  }];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          AppLocalizations.of(context).translate('learn_title'),
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        child: Swiper(
          itemCount: people.length,
          itemBuilder: (BuildContext context, int index){
            return PersonCard(people[index]);
          },
          viewportFraction: 0.8,
          scale: 0.9,
          layout: SwiperLayout.TINDER,
          itemWidth: 350.0,
          itemHeight: 400.0,
          loop: false,

        ),
      ),

    );
  }
}

class PersonCard extends StatelessWidget{
  var person;

  PersonCard(person){
    this.person = person;
  }
  @override
  Widget build(BuildContext context) {
    return FlipCard(
      direction: FlipDirection.HORIZONTAL, // default
      front: Container(
        decoration: BoxDecoration(
            color: Colors.lightBlue,
            borderRadius: BorderRadius.all(Radius.circular(20.0))
        ),
        child: Center(
            child : Text(
              person["firstname"]+" "+person["lastname"],
              style: TextStyle(color: Colors.white, fontSize: 20),
            )
        ),
      ),
      back: Container(
        child: Center(
            child: Text(
              person["description"],
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
