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

import 'Game/game_options.dart';

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
    //setState(() {
      userList = ModalRoute.of(context).settings.arguments;
    //});

    void _showSnackBar(BuildContext context, String text) {
      final snackBar = SnackBar(content: Text(text));
      _scaffoldKey.currentState.showSnackBar(snackBar); // edited line
    }

    /// Prevent learn and game to launch if the list is empty
    handleEmpty(action, size) {
      if (size == 0) {
        return _showSnackBar(context, AppLocalizations.of(context).translate("list_person_snackbar_message"));
      }

      if (action == 'Game') {
        if (size == 1) {
          Navigator.pushNamed(context, '/game',
              arguments: InitialGameArguments(userList, false, 1));
        } else {
          showModalBottomSheet(
            context: context,
            builder: (sheetContext) => BottomSheet(
              builder: (_) => GameOptions(
                userList: userList,
                number: size,
              ),
              onClosing: () {},
            ),
          );
        }
      } else {
        Navigator.pushNamed(context, '/learn', arguments: userList);
      }
    }

    var childButtons = List<UnicornButton>();

    childButtons.add(UnicornButton(
      hasLabel: true,
      labelText: AppLocalizations.of(context).translate("list_person_create_contact"),
      currentButton: FloatingActionButton(
        mini: true,
        backgroundColor: Colors.blue,
        heroTag: "add",
        onPressed: () {
          Navigator.pushNamed(context, '/personForm',
              arguments: new ScreenArguments(null, userList.id));
        },
        child: Icon(Icons.add),
      ),
    ));

    childButtons.add(UnicornButton(
        hasLabel: true,
        labelText: AppLocalizations.of(context).translate("list_person_internal_import"),
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

    childButtons.add(UnicornButton(
      hasLabel: true,
      labelText: AppLocalizations.of(context).translate("list_person_external_import"),
      currentButton: FloatingActionButton(
        mini: true,
        backgroundColor: Colors.blue,
        heroTag: "external",
        onPressed: () {
          Navigator.pushNamed(context, '/importSelectionScreen',
              arguments:  userList);
        },
        child: Icon(Icons.smartphone),
      ),
    ));

    return BlocBuilder<PersonBloc, PersonState>(builder: (context, state) {
      if (state is PersonLoaded) {
        size = state.person
           .where((element) => element.lists.contains(userList.id)).length;
      }

      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
                userList.listName,
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Center(
            child: BlocProvider<PersonBloc>(
          create: (context) {
            return PersonBloc(
              personRepository: DataPersonRepository(),
            )..add(LoadUserListPersons(userList.id));
          },
          child:MyUserPeople(defineSize : (int size) {
                this.size = size;
          },userListId: userList.id)                     //MyUserPeople(userList.id),
        )),
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: -10,
          clipBehavior: Clip.antiAlias,
          color: Colors.blue,
          child: BottomNavigationBar(
            elevation: 0.0,
            backgroundColor: Colors.blue,
            currentIndex: 0,
            unselectedItemColor: Colors.white,
            selectedItemColor: Colors.white,
            onTap: (int index) {
              switch (index) {
                case 0:
                  handleEmpty("Game", size);
                  break;
                case 1:
                  handleEmpty("Learn", size);
                  break;
              }
            },
            items: [
              BottomNavigationBarItem(
                icon: new Icon(Icons.videogame_asset),
                backgroundColor: Colors.blue,
                label: AppLocalizations.of(context).translate("game"),
              ),
              BottomNavigationBarItem(
                icon: new Icon(Icons.school),
                label: AppLocalizations.of(context).translate("learn"),
              ),
            ],
          ),
        ),
        floatingActionButton: Container(
          width: 95.0,
          height: 300.0,
          child: UnicornDialer(
              backgroundColor: Colors.transparent,
              //hasBackground: false,
              hasNotch: true,
              parentButtonBackground: Colors.lightBlueAccent,
              orientation: UnicornOrientation.VERTICAL,
              parentButton: Icon(Icons.add),
              childButtons: childButtons),
        ),
      );
    });
  }
}

class MyUserPeople extends StatelessWidget {
  MyUserPeople({this.defineSize, this.userListId});
  final SizeCallback defineSize;
  final String userListId;

  Widget build(BuildContext context) {
    return BlocBuilder<PersonBloc, PersonState>(builder: (context, state) {
      if (state is PersonLoading) {
        return Text(AppLocalizations.of(context).translate("list_person_loading"));
      } else if (state is UserListPersonLoaded) {
        defineSize(state.person.length);
        if (state.person.isNotEmpty) {
          //If the list is not empty
          return WidgetListElement(userListId, list: state.person);
        } else {
          //If the list is empty
          return Center(
              child: Text(AppLocalizations.of(context).translate("empty_list"))
          );
        }
      } else {
        return Text(AppLocalizations.of(context).translate("unknown_error"));
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
  List<Person> peopleToShow;
  List<Person> currentAllPeople;

  @protected
  void initState() {
    slidableController = SlidableController();
    setPeopleToShow();
    super.initState();
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

  Widget _buildList(BuildContext context, Axis direction) {
    if(!compareLists(currentAllPeople, widget.list)){
      setPeopleToShow();
    }
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 100),
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
            peopleToShow.removeAt(index);
            currentAllPeople.remove(item);
            widget.list.remove(item);
          });
        },
      ),
      actionPane: SlidableScrollActionPane(),
      actionExtentRatio: 0.25,
      child: direction == Axis.horizontal
          ? VerticalListItem(peopleToShow[index], widget.idUserList)
          : HorizontalListItem(peopleToShow[index]),
      secondaryActionDelegate: SlideActionBuilderDelegate(
          actionCount: 1,
          builder: (context, index, animation, renderingMode) {
            return IconSlideAction(
                caption: AppLocalizations.of(context).translate("delete"),
                color: renderingMode == SlidableRenderingMode.slide
                    ? Colors.red.withOpacity(animation.value)
                    : Colors.red,
                icon: Icons.delete,
                onTap: () => item.lists.length == 1 ? deleteDialog() : {
                    peopleToShow.remove(item),
                    currentAllPeople.remove(item),
                    widget.list.remove(item),
                    BlocProvider.of<PersonBloc>(context).add(DeletePerson(item, widget.idUserList))
                }
            );
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
      onTap: () => Navigator.pushNamed(context, '/personDetails',
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

typedef SizeCallback = void Function(int size);
