import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gmoria/app/utils/ImportArguments.dart';
import 'package:gmoria/app/utils/MyTextFormField.dart';
import 'package:gmoria/app/utils/app_localizations.dart';
import 'package:gmoria/domain/blocs/person/PersonBloc.dart';
import 'package:gmoria/domain/blocs/person/PersonEvent.dart';
import 'package:gmoria/domain/blocs/person/PersonState.dart';
import 'package:gmoria/domain/models/Person.dart';
import 'package:gmoria/domain/models/PersonFormModel.dart';
import 'package:gmoria/domain/models/UserList.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';


class CreationImportContact extends StatelessWidget {
  List<Person> persons;
  UserList userList;
  ImportArguments args;

  @override
  Widget build(BuildContext context) {
    args = ModalRoute.of(context).settings.arguments;
    persons = args.persons;
    userList = args.userList;

    return BlocBuilder<PersonBloc, PersonState>(builder: (context, state) {
      return WillPopScope(
        onWillPop: () {
          return showDialog<bool>(
              context: context,
              builder: (_) {
                return AlertDialog(
                  content: Text(AppLocalizations.of(context).translate("creation_import_warning")),
                  title: Text(
                    AppLocalizations.of(context).translate("creation_import_warning_title"),
                    style: TextStyle(color: Colors.red),),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(AppLocalizations.of(context).translate("yes")),
                      onPressed: () {
                        Navigator.popUntil(context, ModalRoute.withName('/list'));
                      },
                    ),
                    FlatButton(
                      child: Text(AppLocalizations.of(context).translate("no")),
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                    ),
                  ],
                );
              });
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context).translate("creation_import_title")),
          ),
          body: TestForm(userList: userList, persons: persons),
        ),
      );
    });
  }
}

class TestForm extends StatefulWidget {
  final List<Person> persons;
  final UserList userList;


  TestForm({Key key, this.persons, this.userList}) : super(key: key);

  @override
  _TestFormState createState() => _TestFormState();
}

class _TestFormState extends State<TestForm> {
  int _currentIndex = 0;
  final _formKey = GlobalKey<FormState>();
  UserList userList;

  PersonM model = PersonM();

  File _image;
  final picker = ImagePicker();

  bool imageError = false;

  Future getG() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    native(pickedFile);
  }

  Future getC() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    native(pickedFile);
  }

  Future native(pickedFile) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarColor: Colors.cyan,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));


    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _image = croppedFile;
        // _image = compressedFile;
        imageError = false;
      } else {
        imageError = true;
      }
    });
  }


  getImageURL() async {
    Reference storageReference = FirebaseStorage.instance.ref().child(
        'persons/${FirebaseAuth.instance.currentUser.uid}/${basename(_image.path)}');
    print(basename(_image.path));
    UploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.whenComplete(() => {print('File Uploaded')});
    String returnURL;
    await storageReference.getDownloadURL().then((fileURL) {
      returnURL = fileURL;
    });
    return returnURL;
  }

  @override
  Widget build(BuildContext context) {
    final _firstnameEditingController = TextEditingController();
    final _lastnameEditingController = TextEditingController();
    final _jobEditingController = TextEditingController();
    final _descriptionEditingController = TextEditingController();

    final halfMediaWidth = MediaQuery.of(context).size.width / 2.0;
    userList = widget.userList;
    _firstnameEditingController.text = widget.persons[_currentIndex].firstname;
    _lastnameEditingController.text = widget.persons[_currentIndex].lastname;
    _jobEditingController.text = widget.persons[_currentIndex].job;
    _descriptionEditingController.text = widget.persons[_currentIndex].description;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            GestureDetector(
                onTap: () {
                  getG();
                },
                child: _image == null
                    ? Container(
                    margin: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.black26),
                      borderRadius:
                      BorderRadius.all(Radius.circular(5.0)),
                    ),
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      color: Colors.blue,
                      size: 200.0,
                      semanticLabel:
                      'Text to announce in accessibility modes', //TODO ?????????????
                    ))
                    : Image.file(_image, width: 280, height: 280)),
            Container(
                child: Center(
                    child: _image == null
                        ? Text(
                      AppLocalizations.of(context).translate("creation_import_image_error"),
                      style: TextStyle(
                        color: Colors.red[900],
                      ),
                    )
                        : null)),
            Container(
              alignment: Alignment.topCenter,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    alignment: Alignment.topCenter,
                    width: halfMediaWidth,
                    child: MyTextFormField(
                      controller: _firstnameEditingController,
                      hintText: AppLocalizations.of(context).translate("firstname"),
                      validator: (String value) {
                        if (value.isEmpty) {
                          return AppLocalizations.of(context).translate("firstname_validator");
                        }
                        return null;
                      },
                      onSaved: (String value) {
                        model.firstname = value;
                      },
                    ),
                  ),
                  Container(
                    alignment: Alignment.topCenter,
                    width: halfMediaWidth,
                    child: MyTextFormField(
                      hintText: AppLocalizations.of(context).translate("lastname"),
                      controller: _lastnameEditingController,
                      validator: (String value) {
                        if (value.isEmpty) {
                          return AppLocalizations.of(context).translate("lastname_validator");
                        }
                        return null;
                      },
                      onSaved: (String value) {
                        model.lastname = value;
                      },
                    ),
                  )
                ],
              ),
            ),
            MyTextFormField(
              hintText: AppLocalizations.of(context).translate("job"),
              controller: _jobEditingController,
              isEmail: false,
              onSaved: (String value) {
                model.job = value;
              },
            ),
            MyTextFormField(
              hintText: AppLocalizations.of(context).translate("description"),
              controller: _descriptionEditingController,
              isEmail: false,
              isLong: true,
              textInputType: TextInputType.multiline,
              onSaved: (String value) {
                model.description = value;
              },
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.add_photo_alternate_outlined),
                    iconSize: 40,
                    tooltip: AppLocalizations.of(context).translate("creation_import_from_gallery"),
                    onPressed: getG,
                  ),
                  Text(AppLocalizations.of(context).translate("creation_import_from_gallery"))
                ],
              ),
              SizedBox(
                height: 100,
                width: 50,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    iconSize: 40,
                    icon: Icon(Icons.add_a_photo_outlined),
                    tooltip: AppLocalizations.of(context).translate("creation_import_from_camera"),
                    onPressed: getC,
                  ),
                  Text(AppLocalizations.of(context).translate("creation_import_from_camera"))
                ],
              ),
            ]),
            RaisedButton(
              color: Colors.blueAccent,
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  if (_image == null) {
                    Fluttertoast.showToast(
                        textColor: Colors.white,
                        backgroundColor: Colors.red,
                        msg: AppLocalizations.of(context).translate("creation_import_image_error"));
                    imageError = true;
                    return;
                  }
                  _formKey.currentState.save();

                    String imageURL = await getImageURL();
                    Person p = new Person(model.firstname, model.lastname,
                        model.job, model.description, imageURL,
                        lists: [userList.id]);
                    BlocProvider.of<PersonBloc>(context)
                        .add(AddPerson(p, userList.id));
                    if(_currentIndex<widget.persons.length -1){
                      setState(() {
                        _currentIndex++;
                        _image = null;
                      });
                    }else{
                      Navigator.popUntil(context,ModalRoute.withName('/list'));
                    }
                }
              },
              child: Text(
                AppLocalizations.of(context).translate("save"),
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );


  }
}

// class MyTextFormField extends StatelessWidget {
//   final String hintText;
//   final String initialValue;
//   final Function validator;
//   final TextEditingController controller;
//   final Function onSaved;
//   final bool isPassword;
//   final bool isEmail;
//   final bool isLong;
//   final int maxLines;
//   final TextInputType textInputType;
//
//   MyTextFormField(
//       {this.initialValue,
//         this.controller,
//         this.hintText,
//         this.validator,
//         this.onSaved,
//         this.isPassword = false,
//         this.isEmail = false,
//         this.isLong = false,
//         this.maxLines,
//         this.textInputType = TextInputType.text});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.all(8.0),
//       child: TextFormField(
//         decoration: InputDecoration(
//           hintText: hintText,
//           contentPadding: EdgeInsets.all(15.0),
//           border: InputBorder.none,
//           filled: true,
//           fillColor: Colors.grey[200],
//         ),
//         minLines: isLong ? 3 : 1,
//         controller: controller,
//         obscureText: isPassword ? true : false,
//         validator: validator,
//         maxLines: maxLines,
//         onSaved: onSaved,
//         initialValue: initialValue,
//         keyboardType: isEmail ? TextInputType.emailAddress : textInputType,
//       ),
//     );
//   }
// }
