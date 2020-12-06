import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gmoria/app/utils/ScreenArguments.dart';
import 'package:gmoria/data/repositories/DataUserListRepository.dart';
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
  Person person;
  String idUserList;
  String title = "Add a new person";
  ScreenArguments args;

  @override
  Widget build(BuildContext context) {
    //person = ModalRoute.of(context).settings.arguments;
    args = ModalRoute.of(context).settings.arguments;
    person = args.person;
    idUserList = args.idUserList;

    // print("-------------->" + person.toString());
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

// StatefulWidget getFunction() {
//   if (person == null) {
//     return TestForm();
//   } else {
//     return TestForm(person);
//   }
// }

}

class TestForm extends StatefulWidget {
  final Person person;
  final String idUserList;

  TestForm({Key key, this.person, this.idUserList}) : super(key: key);

  @override
  _TestFormState createState() => _TestFormState();
}

class _TestFormState extends State<TestForm> {
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
          //   // CropAspectRatioPreset.ratio3x2,
          //   // CropAspectRatioPreset.original,
          //   // CropAspectRatioPreset.ratio4x3,
          //   // CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            // toolbarTitle: 'Cropper',
            toolbarColor: Colors.cyan,
            toolbarWidgetColor: Colors.white,
            // initAspectRatio: CropAspectRatioPreset.square,
            //
            //     // initAspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
            lockAspectRatio: true),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));

    // ImageProperties properties = await FlutterNativeImage.getImageProperties(pickedFile.path);
    // File compressedFile = await FlutterNativeImage.compressImage(pickedFile.path, quality: 80,
    //     targetWidth: 600, targetHeight: 300);
    // File croppedFile = await FlutterNativeImage.cropImage(pickedFile.path, originX, originY, width, height);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        _image = croppedFile;
        // _image = compressedFile;
        imageError = false;
      } else {
        print('No image selected.');
        imageError = true;
      }
    });
  }

  getImageURL() async {
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('persons/${user.uid}/${basename(_image.path)}');
    print("PATHHHHHHHHHHHHHH");
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
            Container(
              child: Center(
                child: GestureDetector(
                    onTap: () {
                      getG();
                    },
                    child: !editMode
                        ? _image == null
                            ? Image.asset(
                                'assets/picture/unknown.jpg',
                                width: 200.0,
                                height: 200.0,
                              )
                            : Image.file(_image, width: 280, height: 280)
                        // Text(
                        //         editMode ? 'No image available' : 'No image selected.')
                        : _image == null
                            ? ExtendedImage.network(person.image_url,
                                fit: BoxFit.fill, width: 280, height: 280)
                            : Image.file(_image, width: 280, height: 280)),
              ),
            ),
            Container(
                child: Center(
                    child: _image == null && !editMode
                        ? Text(
                            'Please provide an image',
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
                      hintText: 'First Name',
                      // controller: firstname,
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Enter the first name';
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
                      hintText: 'Last Name',
                      initialValue: person.lastname,
                      // controller: lastname,
                      validator: (String value) {
                        if (value.isEmpty) {
                          return 'Enter the last name';
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
              hintText: 'Job (optional)',
              initialValue: person.job,
              // controller: job,
              isEmail: false,
              // validator: (String value) {
              //   // if (value.isEmpty) {
              //   //   return 'Please enter a valid email';
              //   // }
              //   // return null;
              // },
              onSaved: (String value) {
                model.job = value;
              },
            ),
            MyTextFormField(
              hintText: 'Description (optional)',
              initialValue: person.description,
              isEmail: false,
              isLong: true,
              // maxLines: 10,
              // maxLines: 30,
              textInputType: TextInputType.multiline,
              // controller: description,

              // validator: (String value) {
              //   if (value.isEmpty) {
              //     return 'Please enter a valid email';
              //   }
              //   return null;
              // },
              onSaved: (String value) {
                model.description = value;
              },
            ),
            // RaisedButton(
            //   child: Text("Take Photo"),
            //   onPressed: uploadPhoto,
            //   textColor: Colors.lightGreenAccent,
            // ),
            RaisedButton(
              child: Text("From gallery"),
              onPressed: getG,
              // textColor: Colors.lightGreenAccent,
            ),
            RaisedButton(
              child: Text("Take a photo"),
              onPressed: getC,
              // textColor: Colors.lightGreenAccent,
            ),
            // RaisedButton(
            //   child: Text("Native gallery crop"),
            //   onPressed: native,
            //   // textColor: Colors.lightGreenAccent,
            // ),
            RaisedButton(
              color: Colors.blueAccent,
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  if (_image == null && !editMode) {
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
                        lists: person.lists);
                    print("FIRSTNAME");
                    BlocProvider.of<PersonBloc>(context).add(UpdatePerson(p));
                  } else {
                    String imageURL = await getImageURL();
                    Person p = new Person(model.firstname, model.lastname,
                        model.job, model.description, imageURL,
                        lists: [idUserList]);
                    BlocProvider.of<PersonBloc>(context)
                        .add(AddPerson(p, idUserList));
                  }
                  Navigator.of(context).pop();
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => Result(model: this.model)));
                }
              },
              child: Text(
                'Save',
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

class MyTextFormField extends StatelessWidget {
  final String hintText;
  final String initialValue;
  final Function validator;
  final TextEditingController controller;
  final Function onSaved;
  final bool isPassword;
  final bool isEmail;
  final bool isLong;
  final int maxLines;
  final TextInputType textInputType;

  MyTextFormField(
      {this.initialValue,
      this.controller,
      this.hintText,
      this.validator,
      this.onSaved,
      this.isPassword = false,
      this.isEmail = false,
      this.isLong = false,
      this.maxLines,
      this.textInputType = TextInputType.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: EdgeInsets.all(15.0),
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.grey[200],
        ),
        minLines: isLong ? 3 : 1,
        controller: controller,
        obscureText: isPassword ? true : false,
        validator: validator,
        maxLines: maxLines,
        onSaved: onSaved,
        initialValue: initialValue,
        keyboardType: isEmail ? TextInputType.emailAddress : textInputType,
      ),
    );
  }
}
