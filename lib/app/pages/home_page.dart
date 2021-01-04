import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gmoria/app/pages/AllContacts/all_contacts_page.dart';
import 'package:gmoria/app/utils/InitialGameArguments.dart';
import 'package:gmoria/app/utils/app_localizations.dart';
import 'package:gmoria/domain/blocs/userlist/UserListBloc.dart';
import 'package:gmoria/domain/blocs/userlist/UserListEvent.dart';
import 'package:gmoria/domain/blocs/userlist/UserListState.dart';
import 'package:gmoria/domain/models/UserList.dart';

import 'Game/game_options.dart';

/// Page with all the lists of the user
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex;

  @override
  void initState() {
    setState(() {
      _currentIndex = 0;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserListBloc, UserListState>(builder: (context, state) {
      TextEditingController listController = new TextEditingController();
      _showDialog() async {
        await showDialog<String>(
          context: context,
          child: new AlertDialog(
            contentPadding: const EdgeInsets.all(16.0),
            content: new Row(
              children: <Widget>[
                new Expanded(
                  child: new TextField(
                    controller: listController,
                    autofocus: true,
                    decoration: new InputDecoration(
                        labelText: 'List name', hintText: 'eg. Football team'),
                  ),
                )
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new FlatButton(
                  child: const Text('Add'),
                  onPressed: () {
                    if (state is UserListLoading) {
                      return Text("Loading !");
                    } else if (state is UserListLoaded) {
                      if (state.userList
                              .where((element) =>
                                  element.listName.toLowerCase() ==
                                  listController.text.toLowerCase())
                              .length ==
                          0) {
                        var item = UserList(listController.text);
                        BlocProvider.of<UserListBloc>(context)
                            .add(AddUserList(item));
                        // Do not display the dialog anymore
                        Navigator.pop(context);
                        // Reset the TextField input
                        listController.text = "";
                      } else {
                        Fluttertoast.showToast(
                            msg: "List name already exists !",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      }
                    } else {
                      return Text("Problem :D");
                    }
                  })
            ],
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).translate("title")),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'My account',
              onPressed: () {
                Navigator.pushNamed(context, '/userPage');
              },
            ),
          ],
        ),
        body: _currentIndex == 0
            ? Center(
                child: (() {
                  if (state is UserListLoading) {
                    return Text("Loading !");
                  } else if (state is UserListLoaded) {
                    if (state.userList.isEmpty) {
                      return Center(
                          child: Text("Create a list to begin",
                              style: TextStyle(fontSize: 20)));
                    }
                    //return Text(state.userList.toString());
                    final userLists = state.userList;
                    return WidgetListElement(list: userLists);
                  } else {
                    return Text("Problem :D");
                  }
                }()),
              )
            : AllContacts(),
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          color: Colors.blue,
          notchMargin: 4,
          clipBehavior: Clip.antiAlias,
          child: BottomNavigationBar(
            elevation: 0,
            backgroundColor: Colors.blue,
            currentIndex: _currentIndex,
            unselectedItemColor: Colors.grey[350],
            selectedItemColor: Colors.white,
            onTap: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: new Icon(Icons.home),
                backgroundColor: Colors.white,
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: new Icon(Icons.people_alt),
                label: "My contacts",
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _currentIndex == 0
            ? FloatingActionButton(
                backgroundColor: Colors.blue,
                onPressed: _showDialog,
                child: Icon(Icons.add),
                // backgroundColor: Colors.indigo,
                heroTag: null,
              )
            : null,
      );
    });
  }
}

class WidgetListElement extends StatefulWidget {
  final List<UserList> list;

  WidgetListElement({Key key, this.list}) : super(key: key);

  @override
  _WidgetListElementState createState() => _WidgetListElementState();
}

class _WidgetListElementState extends State<WidgetListElement> {
  SlidableController slidableController;
  List<UserList> userlists;

  @protected
  void initState() {
    slidableController = SlidableController();
    super.initState();
  }

  Widget _buildList(BuildContext context, Axis direction) {
    // Sort the list of person by list name
    widget.list.sort((a, b) {
      return a.listName.compareTo(b.listName);
    });

    return ListView.builder(
      padding: EdgeInsets.only(bottom: 30.0),
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
    final UserList item = userlists[index];

    deleteDialog() {
      return showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Delete', style: TextStyle(color: Colors.red)),
            content: Text('The list selected will be deleted'),
            actions: <Widget>[
              FlatButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              FlatButton(
                child: Text('Ok'),
                onPressed: () => {
                  Navigator.of(context).pop(true),
                  print("NOM : " + item.listName),
                  BlocProvider.of<UserListBloc>(context)
                      .add(DeleteUserList(item)),
                },
              ),
            ],
          );
        },
      );
    }

    /// Prevent learn and game to launch if the list is empty
    handleEmpty(action) {
      if (item.persons.isEmpty) {
        return _showSnackBar(context, 'The list is empty');
      }

      if (action == 'Game') {
        if(item.persons.length==1){
            Navigator.pushNamed(context, '/game',
            arguments: InitialGameArguments(item, false,1));
        }else{
          showModalBottomSheet(
            context: context,
            builder: (sheetContext) => BottomSheet(
              builder: (_) => GameOptions(
                userList: item,
              ),
              onClosing: () {},
            ),
          );
        }

      } else {
        Navigator.pushNamed(context, '/learn', arguments: item);
      }
    }

    return BlocBuilder<UserListBloc, UserListState>(builder: (context, state) {
      TextEditingController listController = new TextEditingController();
      editDialog(UserList list) async {
        listController.text = list.listName;
        await showDialog<String>(
          context: context,
          child: new AlertDialog(
            contentPadding: const EdgeInsets.all(16.0),
            content: new Row(
              children: <Widget>[
                new Expanded(
                  child: new TextField(
                    controller: listController,
                    autofocus: true,
                    decoration: new InputDecoration(
                        labelText: 'List name', hintText: list.listName),
                  ),
                )
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new FlatButton(
                  child: const Text('Edit'),
                  onPressed: () {
                    if (state is UserListLoading) {
                      return Text("Loading !");
                    } else if (state is UserListLoaded) {
                      if (state.userList
                          .where((element) =>
                      element.listName.toLowerCase() ==
                          listController.text.toLowerCase())
                          .length ==
                          0) {
                        UserList updatedUserList = new UserList(listController.text,
                            bestScore: list.bestScore,
                            creation_date: list.creation_date,
                            id: list.id,
                            persons: list.persons);
                        BlocProvider.of<UserListBloc>(context)
                            .add(UpdateUserList(updatedUserList));
                        // Do not display the dialog anymore
                        Navigator.pop(context);
                        // Reset the TextField input
                        listController.text = "";
                      } else {
                        Fluttertoast.showToast(
                            msg: "List name already exists !",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      }
                    } else {
                      return Text("Problem :D");
                    }


                  })
            ],
          ),
        );
      }
      return Slidable.builder(
        key: Key(item.listName),
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
              userlists.removeAt(index);
            });
          },
        ),
        actionPane: SlidableScrollActionPane(),
        actionExtentRatio: 0.25,
        child: direction == Axis.horizontal
            ? VerticalListItem(userlists[index])
            : HorizontalListItem(userlists[index]),
        actionDelegate: SlideActionBuilderDelegate(
            actionCount: 2,
            builder: (context, index, animation, renderingMode) {
              if (index == 0) {
                return IconSlideAction(
                  caption: 'Game',
                  color: Colors.indigo,
                  icon: Icons.videogame_asset,
                  onTap: () => handleEmpty('Game'),
                );
              } else {
                return IconSlideAction(
                  caption: 'Learn',
                  color: Colors.green,
                  icon: Icons.school,
                  onTap: () => handleEmpty('Learn'),
                );
              }
            }),
        secondaryActionDelegate: SlideActionBuilderDelegate(
            actionCount: 2,
            builder: (context, index, animation, renderingMode) {
              if (index == 0) {
                return IconSlideAction(
                  caption: 'Edit',
                  color: Colors.blue,
                  icon: Icons.edit,
                  onTap: () => editDialog(item),
                );
              } else {
                return IconSlideAction(
                    caption: 'Delete',
                    color: Colors.red,
                    icon: Icons.delete,
                    onTap: () => deleteDialog());
              }
            }),
      );
    });
  }

  static Color _getAvatarColor(int index) {
    return Colors.red;
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
    userlists = widget.list;
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

  final UserList item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/list', arguments: item),
      child: Container(
        color: Color(15658734),
        height: 80,
        child: Card(
            shape:
                BeveledRectangleBorder(borderRadius: BorderRadius.circular(2)),
            child: Center(
              child: new Column(
                children: <Widget>[
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Text('${item.persons.length}'),
                      foregroundColor: Colors.white,
                    ),
                    title: Text(item.listName),
                    subtitle: item.bestScore > 0
                        ? Text("Best score : ${item.bestScore}%")
                        : Text(""),
                  )
                ],
              ),
            )),
      ),
    );
  }
}

class HorizontalListItem extends StatelessWidget {
  HorizontalListItem(this.item);

  final UserList item;

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
                item.listName,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
