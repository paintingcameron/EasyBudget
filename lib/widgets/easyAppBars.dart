import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

AppBar easyAppBar() {
  return AppBar(
    centerTitle: true,
    toolbarHeight: 50,
    flexibleSpace: Padding(
      padding: EdgeInsets.only(top: 35),
      child: Container(
          alignment: Alignment.center,
          child: Icon(Icons.attach_money_outlined)
      )
    ),
  );
}

AppBar easyAppBar_back() {
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
