import 'package:easybudget/bloc/bloc.dart';
import 'package:easybudget/pages/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'pages/deniedPermissions.dart';

void main() => runApp(EasyBudget());

class EasyBudget extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      theme: ThemeData(
        primaryColor: Colors.green,
        accentColor: Colors.green,
        buttonColor: Colors.green,
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.green,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData (
          style: ElevatedButton.styleFrom(
            primary: Colors.green,
          ),
        )
      ),
    );
  }
}