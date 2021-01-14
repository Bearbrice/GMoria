import 'package:flutter/material.dart';

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
  final int maxLength;

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
        this.textInputType = TextInputType.text,
      this.maxLength});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: hintText,
          labelStyle: TextStyle(
            fontSize: 17,
          ),
          hintText: hintText,
          contentPadding: EdgeInsets.all(15.0),
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        maxLength: maxLength,
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
