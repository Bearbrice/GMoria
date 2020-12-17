import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gmoria/app/utils/InitialGameArguments.dart';
import 'package:gmoria/app/utils/ScreenArguments.dart';
import 'package:gmoria/app/utils/app_localizations.dart';
import 'package:gmoria/data/repositories/DataPersonRepository.dart';
import 'package:gmoria/domain/blocs/person/PersonBloc.dart';
import 'package:gmoria/domain/blocs/person/PersonEvent.dart';
import 'package:gmoria/domain/blocs/person/PersonState.dart';
import 'package:gmoria/domain/models/Person.dart';
import 'package:gmoria/domain/models/UserList.dart';
import 'package:unicorndial/unicorndial.dart';

/// Page that display a specific list
class ListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  UserList userList;
  bool change;
  int size = 0;

  @override
  Widget build(BuildContext context) {
    final _scaffoldKey = GlobalKey<ScaffoldState>();
    setState(() {
      userList = ModalRoute.of(context).settings.arguments;
    });

    conditionalRendering() {
      return BlocProvider<PersonBloc>(
        create: (context) {
          return PersonBloc(
            personRepository: DataPersonRepository(),
          )..add(LoadUserListPersons(userList.id));
        },
        child: MyUserPeople(userList.id),
      );
    }

    void _showSnackBar(BuildContext context, String text) {
      final snackBar = SnackBar(content: Text(text));
      _scaffoldKey.currentState.showSnackBar(snackBar); // edited line
    }

    /// Prevent learn and game to launch if the list is empty
    handleEmpty(action,size) {
      print("SIZEEEEE : ${size}");
      if (size==0) {
        return _showSnackBar(context, 'The list is empty');
      }

      if (action == 'Game') {
        Navigator.pushNamed(context, '/game',
            arguments: InitialGameArguments(userList, false));
      } else {
        Navigator.pushNamed(context, '/learn', arguments: userList);
      }
    }




    var childButtons = List<UnicornButton>();

    childButtons.add(UnicornButton(
      hasLabel: true,
      labelText: "New contact",
        currentButton: FloatingActionButton(
          mini: true,
          backgroundColor: Colors.blue,
          heroTag: "add",
          onPressed: () {
            Navigator.pushNamed(context, '/personForm',
                arguments: new ScreenArguments(null, userList.id));
          },
          child: Icon(Icons.add),
        ),));

    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: "Import contacts",
        currentButton: FloatingActionButton(
          heroTag: "phone",
          backgroundColor: Colors.blue,
          mini: true,
          child: Icon(Icons.group_add),
          onPressed: () {
            Navigator.pushNamed(context, '/importFromAllContacts',
                arguments: userList);
          },
        )));




    return BlocBuilder<PersonBloc, PersonState>(builder: (context, state) {
      if(state is PersonLoaded){
        var numbers = state.person.where((element) => element.lists.contains(userList.id));
        size = numbers.length;
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
        body: Center(child: conditionalRendering()),



        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: -10,
          clipBehavior: Clip.antiAlias,
          color: Colors.grey,
          child: Container(
            color: Colors.blue,
            height: 60,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    handleEmpty('Learn',size);
                    // Navigator.pushNamed(context, '/personForm');
                  },
                  padding: EdgeInsets.all(10.0),
                  child: Column( // Replace with a Row for horizontal icon + text
                    children: <Widget>[
                      Icon(Icons.school, color: Colors.white,),
                      Text("Learn", style: TextStyle(color: Colors.white))
                    ],
                  ),
                ),
                FlatButton(
                    onPressed: () {
                      handleEmpty('Game',size);
                      // Navigator.pushNamed(context, '/personForm');
                    },
                  padding: EdgeInsets.all(10.0),
                  child: Column( // Replace with a Row for horizontal icon + text
                    children: <Widget>[
                      Icon(Icons.videogame_asset, color: Colors.white,),
                      Text("Game", style: TextStyle(color: Colors.white))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        floatingActionButton:
        Container(
          width: 95.0,
          height: 200.0,
         child:
          UnicornDialer(

            backgroundColor: Colors.transparent,
            //hasBackground: false,
            hasNotch: true,
            parentButtonBackground: Colors.lightBlueAccent,
            orientation: UnicornOrientation.VERTICAL,
            parentButton: Icon(Icons.add),
            childButtons : childButtons),
       ),
      );
    });
  }
}


class MyUserPeople extends StatelessWidget {
  final String userListId;

  // MyUserPeople({Key key, this.userList}) : super(key: key);
  MyUserPeople(this.userListId, {Key key}) : super(key: key);

  Widget build(BuildContext context) {
    return BlocBuilder<PersonBloc, PersonState>(builder: (context, state) {
      if (state is PersonLoading) {
        return Text("Loading !");
      } else if (state is UserListPersonLoaded) {
        if (state.person.isNotEmpty) {
          //If the list is not empty
          return WidgetListElement(userListId, list: state.person);
        } else {
          //If the list is empty
          return Center(
              child:
                  Text("Your list is empty", style: TextStyle(fontSize: 20)));
        }
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
    // Sort the list of person by first names
    widget.list.sort((a, b) {
      return a.firstname.toLowerCase().compareTo(b.firstname.toLowerCase());
    });

    return ListView.builder(
      padding: EdgeInsets.only(bottom: kFloatingActionButtonMargin + 30),
      scrollDirection: direction,
      itemBuilder: (context, index) {
        final Axis slidableDirection =
            direction == Axis.horizontal ? Axis.vertical : Axis.horizontal;
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
            content: Text('This person will be deleted'),
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
                  BlocProvider.of<PersonBloc>(context)
                      .add(DeletePerson(item, widget.idUserList)),
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
      onTap: () => Navigator.pushNamed(
          context, '/personDetails',
          arguments: new ScreenArguments(item, idUserList)),
      child: Container(
        color: Colors.white,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.transparent,
            backgroundImage: ExtendedImage.network(
              item.image_url,
              isAntiAlias: true,
              enableMemoryCache: true,
            ).image,
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
