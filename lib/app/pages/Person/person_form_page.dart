import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gmoria/app/utils/MyTextFormField.dart';
import 'package:gmoria/app/utils/ScreenArguments.dart';
import 'package:gmoria/app/utils/app_localizations.dart';
import 'package:gmoria/domain/blocs/person/PersonBloc.dart';
import 'package:gmoria/domain/blocs/person/PersonEvent.dart';
import 'package:gmoria/domain/blocs/person/PersonState.dart';
import 'package:gmoria/domain/models/Person.dart';
import 'package:gmoria/domain/models/PersonFormModel.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

bool editMode = false;

class PersonForm extends StatelessWidget {
  AppLocalizations appLoc;
  Person person;
  String idUserList;
  String title;
  ScreenArguments args;

  @override
  Widget build(BuildContext context) {
    appLoc = AppLocalizations.of(context);
    args = ModalRoute.of(context).settings.arguments;
    person = args.person;
    idUserList = args.idUserList;
    title = appLoc.translate('add_person');

    if (person != null) {
      editMode = true;
      title = "Edit: " + person.firstname + " " + person.lastname;
    } else {
      editMode = false;
    }
    return BlocBuilder<PersonBloc, PersonState>(builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: TestForm(idUserList: idUserList, person: person),
      );
    });
  }
}

class TestForm extends StatefulWidget {
  final Person person;
  final String idUserList;

  TestForm({Key key, this.person, this.idUserList}) : super(key: key);

  @override
  _TestFormState createState() => _TestFormState();
}

class _TestFormState extends State<TestForm> {
  AppLocalizations appLoc;
  final _formKey = GlobalKey<FormState>();
  var person;
  String idUserList;

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
        imageError = false;
      } else {
        print('No image selected.');
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
    appLoc = AppLocalizations.of(context);
    final halfMediaWidth = MediaQuery.of(context).size.width / 2.0;
    person = widget.person;
    idUserList = widget.idUserList;
    if (person == null) {
      person = new PersonM();
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            GestureDetector(
                onTap: () {
                  getG();
                },
                child: !editMode
                    ? _image == null
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
                            ))
                        : Image.file(_image, width: 280, height: 280)
                    : _image == null
                        ? ExtendedImage.network(person.image_url,
                            fit: BoxFit.fill, width: 280, height: 280)
                        : Image.file(_image, width: 280, height: 280)),
            Container(
                child: Center(
                    child: _image == null && !editMode
                        ? Text(
                            appLoc.translate('provide_image'),
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
                      initialValue: person.firstname,
                      hintText: appLoc.translate('firstname'),
                      validator: (String value) {
                        if (value.length > 30) {
                          return appLoc.translate("validator_length");
                        }
                        if (value.isEmpty) {
                          return appLoc.translate('firstname_validator');
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
                      hintText: appLoc.translate('lastname'),
                      initialValue: person.lastname,
                      validator: (String value) {
                        if (value.length > 30) {
                          return appLoc.translate("validator_length");
                        }
                        if (value.isEmpty) {
                          return appLoc.translate('lastname_validator');
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
              hintText: appLoc.translate('job'),
              initialValue: person.job,
              isEmail: false,
              validator: (String value) {
                if (value.length > 30) {
                  return appLoc.translate("validator_length");
                }
                return null;
              },
              onSaved: (String value) {
                model.job = value;
              },
            ),
            MyTextFormField(
              hintText: appLoc.translate('description'),
              initialValue: person.description,
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
                    tooltip: appLoc.translate('from_gallery'),
                    onPressed: getG,
                  ),
                  Text(appLoc.translate('from_gallery'))
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
                    tooltip: appLoc.translate('take_photo'),
                    onPressed: getC,
                  ),
                  Text(appLoc.translate('take_photo'))
                ],
              ),
            ]),
            RaisedButton(
              color: Colors.blueAccent,
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  if (_image == null && !editMode) {
                    Fluttertoast.showToast(
                        textColor: Colors.white,
                        backgroundColor: Colors.red,
                        msg: appLoc.translate('provide_image'));
                    print('No image stop');
                    imageError = true;
                    return;
                  }
                  print('Image OK - GO');
                  _formKey.currentState.save();
                  print(this.model.firstname);

                  if (editMode) {
                    String imageURL;
                    if (_image != null) {
                      Reference photoRef = FirebaseStorage.instance
                          .ref()
                          .storage
                          .refFromURL(person.image_url);
                      photoRef.delete();
                      imageURL = await getImageURL();
                    } else {
                      imageURL = person.image_url;
                    }
                    Person p = new Person(model.firstname, model.lastname,
                        model.job, model.description, imageURL,
                        is_known: person.is_known,
                        imported_from: person.imported_from,
                        id: person.id,
                        lists: person.lists,
                        fk_user_id: person.fk_user_id);
                    BlocProvider.of<PersonBloc>(context).add(UpdatePerson(p));
                    Navigator.pop(context);
                    Navigator.popAndPushNamed(context, '/personDetails',
                        arguments:
                            new ScreenArguments(widget.person, idUserList));
                  } else {
                    String imageURL = await getImageURL();
                    Person p = new Person(model.firstname, model.lastname,
                        model.job, model.description, imageURL,
                        lists: [idUserList]);
                    BlocProvider.of<PersonBloc>(context)
                        .add(AddPerson(p, idUserList));
                    Navigator.of(context).pop();
                  }
                }
              },
              child: Text(
                appLoc.translate('save'),
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
