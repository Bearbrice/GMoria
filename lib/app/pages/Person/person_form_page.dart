import 'dart:io';

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
    }
    return BlocBuilder<PersonBloc, PersonState>(builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: TestForm(idUserList:idUserList, person: person),
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
  TestForm({Key key, this.person,this.idUserList}) : super(key: key);

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

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future native() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    File croppedFile = await ImageCropper.cropImage(
        sourcePath: pickedFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          // CropAspectRatioPreset.ratio3x2,
          // CropAspectRatioPreset.original,
          // CropAspectRatioPreset.ratio4x3,
          // CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
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
      } else {
        print('No image selected.');
      }
    });
  }

  Future takeImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
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
    await uploadTask.whenComplete(() =>  {
      print('File Uploaded')});
    String returnURL;
    await storageReference.getDownloadURL().then((fileURL) {
      returnURL = fileURL;
    });
    return returnURL;
  }

  // TextEditingController firstname;
  // TextEditingController lastname;
  // TextEditingController job;
  // TextEditingController description;

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
                child: _image == null
                    ? Text(
                        editMode ? 'No image available' : 'No image selected.')
                    : Image.file(_image, width: 280.0, height: 280.0),
              ),
            ),
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
              onPressed: getImage,
              // textColor: Colors.lightGreenAccent,
            ),
            RaisedButton(
              child: Text("Take a photo"),
              onPressed: takeImage,
              // textColor: Colors.lightGreenAccent,
            ),
            RaisedButton(
              child: Text("Native gallery crop"),
              onPressed: native,
              // textColor: Colors.lightGreenAccent,
            ),
            RaisedButton(
              color: Colors.blueAccent,
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  print(this.model.firstname);
                  String imageURL =await getImageURL();
                  Person p = new Person(model.firstname, model.lastname,
                      model.job, model.description, imageURL);

                  BlocProvider.of<PersonBloc>(context).add(AddPerson(p, idUserList));
                  //Navigator.pop(context);
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

  MyTextFormField({
    this.initialValue,
    this.controller,
    this.hintText,
    this.validator,
    this.onSaved,
    this.isPassword = false,
    this.isEmail = false,
  });

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
        controller: controller,
        obscureText: isPassword ? true : false,
        validator: validator,
        onSaved: onSaved,
        initialValue: initialValue,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      ),
    );
  }
}
