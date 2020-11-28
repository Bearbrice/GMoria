import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gmoria/domain/models/PersonFormModel.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class PersonForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create new person'),
      ),
      body: TestForm(),
    );
  }
}

class TestForm extends StatefulWidget {
  @override
  _TestFormState createState() => _TestFormState();
}

class _TestFormState extends State<TestForm> {
  final _formKey = GlobalKey<FormState>();
  Person model = Person();

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

  @override
  Widget build(BuildContext context) {
    final halfMediaWidth = MediaQuery.of(context).size.width / 2.0;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              child: Center(
                child: _image == null
                    ? Text('No image selected.')
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
                      hintText: 'First Name',
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
              isEmail: true,
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
              isEmail: true,
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
              child: Text("Get image"),
              onPressed: getImage,
              // textColor: Colors.lightGreenAccent,
            ),
            RaisedButton(
              child: Text("Take a photo"),
              onPressed: takeImage,
              // textColor: Colors.lightGreenAccent,
            ),
            RaisedButton(
              child: Text("Test"),
              onPressed: native,
              // textColor: Colors.lightGreenAccent,
            ),
            RaisedButton(
              color: Colors.blueAccent,
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  Navigator.pushNamed(context, '/list');
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => Result(model: this.model)));
                }
              },
              child: Text(
                'Sign Up',
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
  final Function validator;
  final Function onSaved;
  final bool isPassword;
  final bool isEmail;

  MyTextFormField({
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
        obscureText: isPassword ? true : false,
        validator: validator,
        onSaved: onSaved,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      ),
    );
  }
}
