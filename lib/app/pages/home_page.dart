import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gmoria/app/utils/app_localizations.dart';
import 'package:gmoria/domain/blocs/userlist/UserListEvent.dart';
import 'package:gmoria/domain/blocs/userlist/UserListState.dart';
import 'package:gmoria/domain/blocs/userlist/UserListBloc.dart';
import 'package:gmoria/domain/models/UserList.dart';

/// Page with all the lists of the user
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                  BlocProvider.of<UserListBloc>(context).add(
                      AddUserList(UserList(listController.text )));
                  Navigator.pushNamed(context, '/list');
                  // Navigator.pop(context);
                })
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('title')),
      ),
      body: Center(
        child: MyUserLists(),
        //   OrientationBuilder(
        //   builder: (context, orientation) => _buildList(
        //       context,
        //       orientation == Orientation.portrait
        //           ? Axis.vertical
        //           : Axis.horizontal),
        // ),
      ),
      /** Add button */
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: _showDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}

class MyUserLists extends StatelessWidget {
  MyUserLists({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserListBloc, UserListState>(builder: (context, state) {
      if (state is UserListLoading) {
        return Text("Loading !");
      } else if (state is UserListLoaded) {
        //return Text(state.userList.toString());
        final userLists = state.userList;
        return WidgetListElement(list: userLists);
      } else {
        return Text("Problem :D");
      }
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
    return ListView.builder(
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
            title: Text('Delete'),
            content: Text('Item will be deleted'),
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
                  BlocProvider.of<UserListBloc>(context).add(DeleteUserList(item)),
                },
              ),
            ],
          );
        },
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
                color: renderingMode == SlidableRenderingMode.slide
                    ? Colors.indigo.withOpacity(animation.value)
                    : Colors.indigo,
                icon: Icons.videogame_asset,
                onTap: () => _showSnackBar(context, 'Game'),
              );
            } else {
              return IconSlideAction(
                caption: 'Learn',
                color: renderingMode == SlidableRenderingMode.slide
                    ? Colors.green.withOpacity(animation.value)
                    : Colors.green,
                icon: Icons.school,
                onTap: () => Navigator.pushNamed(context, '/learn', arguments: item),
              );
            }
          }),
      secondaryActionDelegate: SlideActionBuilderDelegate(
          actionCount: 1,
          builder: (context, index, animation, renderingMode) {
            return IconSlideAction(
                caption: 'Delete',
                color: renderingMode == SlidableRenderingMode.slide
                    ? Colors.red.withOpacity(animation.value)
                    : Colors.red,
                icon: Icons.delete,
                /*TODO: do not work, to correct*/
                onTap: () => deleteDialog());
          }),
    );
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
        color: Colors.white,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.red,
            //child: Text('${item.index}'),
            foregroundColor: Colors.white,
          ),
          title: Text(item.listName),
        ),
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
