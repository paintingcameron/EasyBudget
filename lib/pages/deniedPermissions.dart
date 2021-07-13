import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restart_app/restart_app.dart';

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
                Flexible(
                  flex: 9,
                  fit: FlexFit.tight,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.sd_card_alert_rounded,
                        size: 300,
                      ),
                      Text(
                        'Storage Permissions Denied',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 15
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (await Permission.storage.request().isGranted) {
                        print('Storage Permissions Granted');
                        Restart.restartApp();
                      } else {
                        print('Storage Permissions Still Denied');
                      }
                    },
                    child: Text('Enable Storage Permissions'),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}