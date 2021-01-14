import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gmoria/app/utils/ScreenArguments.dart';
import 'package:gmoria/app/utils/app_localizations.dart';
import 'package:gmoria/domain/blocs/person/PersonBloc.dart';
import 'package:gmoria/domain/blocs/person/PersonEvent.dart';
import 'package:gmoria/domain/blocs/person/PersonState.dart';
import 'package:gmoria/domain/models/Person.dart';
import 'package:gmoria/domain/models/UserList.dart';

/// Page that display a specific list
class AllContacts extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AllContactsState();
}

class _AllContactsState extends State<AllContacts> {
  UserList userList;
  bool change;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: MyUserPeople()),
    );
  }
}

class MyUserPeople extends StatelessWidget {

  // MyUserPeople({Key key, this.userList}) : super(key: key);
  MyUserPeople({Key key}) : super(key: key);

  Widget build(BuildContext context) {
    return BlocBuilder<PersonBloc, PersonState>(builder: (context, state) {
      if (state is PersonLoading) {
        return CircularProgressIndicator(backgroundColor: Colors.blue,);
      } else if (state is PersonLoaded) {
        if (state.person.isNotEmpty) {
          //If the list is not empty
          final personsList = state.person;
          return WidgetListElement(list: personsList);
        } else {
          //If the list is empty
          return Center(
              child:
              Text(AppLocalizations.of(context).translate("empty_list"),
                  style: TextStyle(fontSize: 20)));
        }
      } else {
        return Text(AppLocalizations.of(context).translate("unknown_error"));
      }
    });
  }
}

class WidgetListElement extends StatefulWidget {
  final List<Person> list;

  WidgetListElement({Key key, this.list}) : super(key: key);

  @override
  _WidgetListElementState createState() => _WidgetListElementState();
}

class _WidgetListElementState extends State<WidgetListElement> {
  SlidableController slidableController;
  List<Person> peopleToShow;
  List<Person> currentAllPeople;

  bool compareLists(List<Person> list1, List<Person> list2){
    if(list1.length!=list2.length){
      return false;
    }
    for(Person p in list1){
      if(!list2.contains(p)){
        return false;
      }
    }
    return true;
  }

  setPeopleToShow(){
    // Sort the list of person by first names and lastnames
    widget.list.sort((a, b) {
      String firstnameLastnameA = a.firstname + a.lastname;
      String firstnameLastnameB = b.firstname + b.lastname;
      return firstnameLastnameA.toLowerCase().compareTo(firstnameLastnameB.toLowerCase());
    });
    peopleToShow = widget.list;
    currentAllPeople = widget.list;
  }

  @protected
  void initState() {
    slidableController = SlidableController();
    widget.list.sort((a, b) {
      String firstnameLastnameA = a.firstname + a.lastname;
      String firstnameLastnameB = b.firstname + b.lastname;
      return firstnameLastnameA.toLowerCase().compareTo(firstnameLastnameB.toLowerCase());
    });
    peopleToShow = widget.list;
    currentAllPeople = widget.list;
    super.initState();
  }

  Widget _buildList(BuildContext context, Axis direction) {
    if(!compareLists(currentAllPeople, widget.list)){
      setPeopleToShow();
    }
    return ListView.builder(
      scrollDirection: direction,
      itemBuilder: (context, index) {
        final Axis slidableDirection =
        direction == Axis.horizontal ? Axis.vertical : Axis.horizontal;
        if(index==0){
          return _searchBar(context, index, slidableDirection);
        }else{
          return _getSlidableWithDelegates(context, index-1, slidableDirection);
        }
      },
      itemCount: peopleToShow.length+1,
    );
  }
  _searchBar(BuildContext context, int index, Axis slidableDirection){
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.lightBlue, width: 2.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.lightBlue, width: 2.0),
              ),
              fillColor: Colors.white,
              filled: true,
              hintText: AppLocalizations.of(context).translate("search")
          ),
          onChanged: (text){
            text = text.toLowerCase();
            setState(() {
              peopleToShow = widget.list.where((person){
                var firstname = person.firstname.toLowerCase();
                var lastname = person.lastname.toLowerCase();
                var firstnameLastname = firstname+" "+lastname;
                var lastnameFirstname = lastname+" "+firstname;
                return firstname.contains(text) || lastname.contains(text) || firstnameLastname.contains(text) || lastnameFirstname.contains(text);
              }).toList();
            });
          },
        )
    );
  }

  Widget _getSlidableWithDelegates(
      BuildContext context, int index, Axis direction) {
    final Person item = peopleToShow[index];

    deleteDialog() {
      return showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context).translate('delete_dialog_title'), style: TextStyle(color: Colors.red),),
            content: Text(AppLocalizations.of(context).translate('delete_dialog_permanently')),
            actions: <Widget>[
              FlatButton(
                  child: Text(AppLocalizations.of(context).translate('cancel')),
                  onPressed: () => {
                    Navigator.of(context).pop(false),
                  }),
              FlatButton(
                child: Text(AppLocalizations.of(context).translate('ok')),
                onPressed: () => {
                  Navigator.of(context).pop(true),
                  BlocProvider.of<PersonBloc>(context)
                      .add(ForceDeletePerson(item)),
                },
              ),
            ],
          );
        },
      );
    }

    return Slidable.builder(
      key: Key(item.id),
      controller: slidableController,
      direction: direction,
      dismissal: SlidableDismissal(
        child: SlidableDrawerDismissal(),
        closeOnCanceled: true,

        // Allow only right side (delete) to be full slided
        dismissThresholds: <SlideActionType, double>{
          SlideActionType.primary: 1.0
        },
        onWillDismiss: (item == null)
            ? null
            : (actionType) {
          return deleteDialog();
        },
      ),
      actionPane: SlidableScrollActionPane(),
      actionExtentRatio: 0.25,
      child: direction == Axis.horizontal
          ? VerticalListItem(peopleToShow[index])
          : HorizontalListItem(peopleToShow[index]),
      secondaryActionDelegate: SlideActionBuilderDelegate(
          actionCount: 1,
          builder: (context, index, animation, renderingMode) {
            return IconSlideAction(
                caption: AppLocalizations.of(context).translate("delete"),
                color: Colors.red,
                icon: Icons.delete,
                onTap: () => deleteDialog());
          }),
    );
  }

  void _showSnackBar(BuildContext context, String text) {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) => _buildList(
          context,
          orientation == Orientation.portrait
              ? Axis.vertical
              : Axis.horizontal),
    );
  }
}

class VerticalListItem extends StatelessWidget {
  VerticalListItem(this.item);

  final Person item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/personDetails', arguments: new ScreenArguments(item, "allContacts")),
      child: Container(
        color: Colors.white,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue,
            backgroundImage: ExtendedImage.network(item.image_url).image,
            foregroundColor: Colors.white,
          ),
          title: Text(item.firstname + " " + item.lastname),
        ),
      ),
    );
  }
}

class HorizontalListItem extends StatelessWidget {
  HorizontalListItem(this.item);

  final Person item;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: 160.0,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: CircleAvatar(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                item.firstname,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
