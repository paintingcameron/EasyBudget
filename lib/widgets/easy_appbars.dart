import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

AppBar easy_appbar() {
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

AppBar easy_appbar_back(var context) {
  return AppBar(
    centerTitle: true,
    toolbarHeight: 50,
    flexibleSpace: Padding(
      padding: EdgeInsets.only(top: 35),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 50,
            width: 50,
            child: IconButton(
              icon: Icon(Icons.arrow_back_outlined),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Icon(Icons.attach_money_outlined),
            )
          ),
          Container(
            height: 50,
            width: 50,
          )
        ],
      ),
    ),
  );

}