import 'package:easybudget/bloc/bloc.dart';
import 'package:easybudget/pages/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'pages/deniedPermissions.dart';

final int moneyGreen = 0xFF00b74c;

void main() => runApp(EasyBudget());

class EasyBudget extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      theme: ThemeData(
        primaryColor: Color(moneyGreen,),
        accentColor: Color(moneyGreen),
        buttonColor: Color(moneyGreen),
        buttonTheme: ButtonThemeData(
          buttonColor: Color(moneyGreen),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData (
          style: ElevatedButton.styleFrom(
            primary: Color(moneyGreen),
          ),
        ),
        iconTheme: IconThemeData(
          color: Color(moneyGreen),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}