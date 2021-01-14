import 'package:flutter/material.dart';

/// A nice title for GMoria mobile application
Widget title() {
  return RichText(
    textAlign: TextAlign.center,
    text: TextSpan(
        text: 'G',
        style: TextStyle(
            fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white),
        children: [
          TextSpan(
            text: 'M',
            style: TextStyle(color: Colors.black, fontSize: 30),
          ),
          TextSpan(
            text: 'oria',
            style: TextStyle(color: Colors.white, fontSize: 30),
          ),
        ]),
  );
}