import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeniedPermissions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('test');
    return MaterialApp(
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('EasyBudget'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Denied Permissions"),
              ],
            ),
          ),
        );
      }
    );
  }
}