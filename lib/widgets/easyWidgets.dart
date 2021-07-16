
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget loadingView() {
  return Center(
    child: Container(
      width: 50,
      height: 50,
      child: CircularProgressIndicator(),
    ),
  );
}

Stack outLinedText(String str, double size) {
  return Stack(
    children: [
      Text(
        str,
        style: TextStyle(
          fontSize: size,
          foreground: Paint()
            .. style = PaintingStyle.stroke
            .. strokeWidth = 2
            .. color = Colors.black
        ),
      ),
      Text(
        str,
        style: TextStyle(
          fontSize: size,
          color: Colors.white,
        ),
      ),
    ],
  );
}