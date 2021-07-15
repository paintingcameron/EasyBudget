
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