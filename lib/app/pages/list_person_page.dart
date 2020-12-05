import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gmoria/app/utils/ScreenArguments.dart';
import 'package:gmoria/app/utils/app_localizations.dart';
import 'package:gmoria/data/repositories/DataPersonRepository.dart';
import 'package:gmoria/domain/blocs/person/PersonBloc.dart';
import 'package:gmoria/domain/blocs/person/PersonEvent.dart';
import 'package:gmoria/domain/blocs/person/PersonState.dart';
import 'package:gmoria/domain/blocs/userlist/UserListBloc.dart';
import 'package:gmoria/domain/blocs/userlist/UserListState.dart';
import 'package:gmoria/domain/models/Person.dart';
import 'package:gmoria/domain/models/UserList.dart';

/// Page that display a specific list
class ListPage extends StatefulWidget {


  @override
  State<StatefulWidget> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage>{
  UserList userList;
  //List<String> personsIdList;
  bool change;
  @override
  Widget build(BuildContext context) {
    //final UserList userList = ModalRoute.of(context).settings.arguments;
    final _scaffoldKey = GlobalKey<ScaffoldState>();
    setState(() {
      userList = ModalRoute.of(context).settings.arguments;
      //personsIdList = userList.persons.map((personId) => personId as String).toList();
    });


    conditionalRendering() {
      if (userList.persons.isEmpty) {
        return Center(
            child: Text("Your list is empty", style: TextStyle(fontSize: 20)));
      } else {
        print("J?ESSAIE DE FAIRE çA EN DYNAMIQUQQUQUQUQUEW");
        print(userList.persons);
        // return BlocBuilder<UserListBloc, UserListState>(builder: (context, state) {
        //   if (state is UserListLoading) {
        //     return Text("Loading !");
        //   } else if (state is UserListLoaded) {
        //     //return Text(state.userList.toString());
        //     final userLists = state.userList;
        //     List<String> personsIdList = userLists.where((element) => element.id == userList.id).first.persons.map((personId) => personId as String).toList();
        //     print("ID A REFRESH");
        //     print(personsIdList);
            return BlocProvider<PersonBloc>(
              create: (context) {
                print("ID A REFRESH dans la methode de chez person");
                //print(personsIdList);
                return PersonBloc(
                  personRepository: DataPersonRepository(),
                )..add(LoadUserListPersons(userList.id));
              },
              child: MyUserPeople(userList.id),
            );
          // } else {
          //   return Text("Problem :D");
          // }
        //  });

      }
    }

    void _showSnackBar(BuildContext context, String text) {
      final snackBar = SnackBar(content: Text(text));
      _scaffoldKey.currentState.showSnackBar(snackBar); // edited line
    }

    /// Prevent learn and game to launch if the list is empty
    handleEmpty(action) {
      if (userList.persons == null) {
        return _showSnackBar(context, 'The list is empty');
      }

      if (action == 'Game') {
        _showSnackBar(context, 'Game');
      } else {
        Navigator.pushNamed(context, '/learn', arguments: userList);
      }
    }

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context).translate('list_title') +
                userList.listName,
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Center(child: conditionalRendering()
          //   OrientationBuilder(
          //   builder: (context, orientation) => _buildList(
          //       context,
          //       orientation == Orientation.portrait
          //           ? Axis.vertical
          //           : Axis.horizontal),
          // ),
        ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
              mini: true,
              backgroundColor: Colors.indigo,
              heroTag: null,
              onPressed: () {
                handleEmpty('Game');
                // Navigator.pushNamed(context, '/personForm');
              },
              child: Icon(Icons.videogame_asset)),
          SizedBox(height: 8.0),
          FloatingActionButton(
            mini: true,
            backgroundColor: Colors.green,
            heroTag: null,
            onPressed: () {
              handleEmpty('Learn');
              // Navigator.pushNamed(context, '/personForm');
            },
            child: Icon(Icons.school),
          ),
          SizedBox(height: 8.0),
          FloatingActionButton(
            backgroundColor: Colors.blue,
            heroTag: null,
            onPressed: () {
              Navigator.pushNamed(context, '/personForm',
                  arguments: new ScreenArguments(null, userList.id));
            },
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class MyUserPeople extends StatelessWidget {
  // MyUserPeople({Key key}) : super(key: key);
  //List<String> personsIdList;
  final String userListId;
  // MyUserPeople({Key key, this.userList}) : super(key: key);
  MyUserPeople(this.userListId,{Key key}) : super(key: key);
  Widget build(BuildContext context) {
    print("IDD QUE JE DOIS LOADER");
    return BlocBuilder<PersonBloc, PersonState>(
        builder: (context, state) {
      if (state is PersonLoading) {
        return Text("Loading !");
      } else if (state is UserListPersonLoaded) {
        final personsList = state.person;
        print("PERSONSSSSSSSSSSSSS");
        print(state.person.length);
        //List<Person> myList = personsList.where((i) => personsIdList.contains(i.id) ).toList();
        print("IDD QUE JE DOIS FILTRERRRRRR");
        return WidgetListElement(userListId, list: personsList);
        // return Swiper(
        //   index: 1,
        //   itemCount: personsList.length,
        //   itemBuilder: (BuildContext context, int index) {
        //     return PersonCard(personsList[index]);
        //   },
        //   viewportFraction: 0.8,
        //   scale: 0.9,
        //   layout: SwiperLayout.TINDER,
        //   itemWidth: cardWidth,
        //   itemHeight: cardHeight,
        //   loop: false,
        // );
      } else {
        return Text("Problem :D");
      }
    });
  }
}


class WidgetListElement extends StatefulWidget {
  final List<Person> list;
  final String idUserList;

  WidgetListElement(this.idUserList, {Key key, this.list}) : super(key: key);

  @override
  _WidgetListElementState createState() => _WidgetListElementState();
}

class _WidgetListElementState extends State<WidgetListElement> {
  SlidableController slidableController;

  @protected
  void initState() {
    slidableController = SlidableController();
    super.initState();
  }

  Widget _buildList(BuildContext context, Axis direction) {

    return ListView.builder(
      scrollDirection: direction,
      itemBuilder: (context, index) {
        final Axis slidableDirection =
            direction == Axis.horizontal ? Axis.vertical : Axis.horizontal;
        print("JJJJJJJJJJJJEEEEEEEEEEEEUPDATEEEEEEEEEE");
        print(widget.list.length);
        return _getSlidableWithDelegates(context, index, slidableDirection);
      },
      itemCount: widget.list.length,
    );
  }

  Widget _getSlidableWithDelegates(
      BuildContext context, int index, Axis direction) {
    final Person item = widget.list[index];

    deleteDialog() {
      return showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Delete'),
            content: Text('Item will be deleted'),
            actions: <Widget>[
              FlatButton(
                  child: Text('Cancel'),
                  onPressed: () => {
                        Navigator.of(context).pop(false),
                      }),
              FlatButton(
                child: Text('Ok'),
                onPressed: () => {
                  Navigator.of(context).pop(true),
                  BlocProvider.of<PersonBloc>(context).add(DeletePerson(item,widget.idUserList)),
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

        onDismissed: (actionType) {
          _showSnackBar(
              context,
              actionType == SlideActionType.primary
                  ? 'Dismiss Archive'
                  : 'Dismiss Delete');
          setState(() {
            widget.list.removeAt(index);
          });
        },
      ),
      actionPane: SlidableScrollActionPane(),
      actionExtentRatio: 0.25,
      child: direction == Axis.horizontal
          ? VerticalListItem(widget.list[index], widget.idUserList)
          : HorizontalListItem(widget.list[index]),
      secondaryActionDelegate: SlideActionBuilderDelegate(
          actionCount: 1,
          builder: (context, index, animation, renderingMode) {
            return IconSlideAction(
                caption: 'Delete',
                color: renderingMode == SlidableRenderingMode.slide
                    ? Colors.red.withOpacity(animation.value)
                    : Colors.red,
                icon: Icons.delete,
                onTap: () => deleteDialog());
          }),
    );
  }

  static Color _getAvatarColor(int index) {
    return Colors.blue;
    switch (index % 4) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.indigoAccent;
      default:
        return null;
    }
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
  VerticalListItem(this.item, this.idUserList);

  final String idUserList;
  final Person item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/personView',
          arguments: new ScreenArguments(item, idUserList)),
      child: Container(
        color: Colors.white,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue,
            //child: Text('${item.index}'),
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
              //child: Text('${item.index}'),
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
