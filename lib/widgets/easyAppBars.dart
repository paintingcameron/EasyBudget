import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

AppBar easyAppBar(String title) {
  return AppBar(
    centerTitle: true,
    toolbarHeight: 50,
    title: Text(title),
  );
}

AppBar easyAppBarBack() {
  return AppBar(
    leading: Builder(
      builder: (context) {
        return IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop([false]),
        );
      },
    ),
  );
}
