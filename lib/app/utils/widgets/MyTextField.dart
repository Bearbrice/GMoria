import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscure;
  final Function validator;
  final bool isEmail;

  MyTextField(
      {this.controller,
        this.labelText,
        this.obscure = false,
        this.validator,
        this.isEmail = false});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscure,
      controller: controller,
      validator: validator,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      cursorColor: Colors.black,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.white),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white70),
        ),
      ),
    );
  }
}