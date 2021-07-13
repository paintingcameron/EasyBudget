import 'package:easybudget/bloc/bloc.dart';
import 'package:easybudget/pages/deniedPermissions.dart';
import 'package:easybudget/widgets/easy_inputs.dart';
import 'package:easybudget/widgets/easy_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easybudget/widgets/easy_appbars.dart';
import 'package:easybudget/globals.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<dynamic> _bloc_permission;

  Future<dynamic> _get_bloc_permission() async {
    if (await Permission.storage.request().isGranted) {
      var dir = await getApplicationDocumentsDirectory();
      Hive.init(dir.path);
      Bloc bloc = Bloc(await getApplicationDocumentsDirectory());
      await bloc.init_repo();
      return bloc;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _bloc_permission = _get_bloc_permission();
  }

  @override
  Widget build(BuildContext context) {
    print('building Home page');
    return MaterialApp(
      builder: (context, child) {
        return FutureBuilder<dynamic>(
          future: _bloc_permission,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data is Bloc) {
                Bloc? bloc = snapshot.data;
                return HomeView(bloc!);
              } else {
                return DeniedPermissions();
              }
            } else {
              return loadingView();
            }
          },
        );
      },
    );
  }

  Widget HomeView(Bloc bloc) {
    return MaterialApp(
      builder: (context, child) {
        return Scaffold(
          appBar: easy_appbar(),
          body: Center(
            child: Column(                                              //Whole screen column
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                easy_stats(bloc),
                boxed_buttons(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget easy_stats(Bloc bloc) {
    return Column(                                                 //Top info column
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 30, bottom: 10),
          child: Text(
            'Total Budget:',
            style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
          ),
        ),
        StreamBuilder(
          stream: bloc.budget_stream,
          builder: (context, budget_shot) => Text(
            "R ${budget_shot.data}", style: TextStyle(fontSize: 30),),
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            easy_min_stat(bloc.required_stream, 'Required'),
            easy_min_stat(bloc.unallocated_stream, 'Unallocated'),
          ],
        ),
      ],
    );
  }

  Widget easy_min_stat(Stream stream, String title) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('$title:', style: TextStyle(fontSize: 30),),
        StreamBuilder(
          stream: stream,
          builder: (context, snapshot) => Padding(
            padding: const EdgeInsets.only(top:8.0),
            child: Text('R ${snapshot.data}'),
          ),
        ),
      ],
    );
  }

  Widget boxed_buttons() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          opt_button(button_options.open_projects),
          opt_button(button_options.closed_projects),
          opt_button(button_options.budget_entries),
          opt_button(button_options.new_entry),
          opt_button(button_options.new_project),
        ],
      ),
    );
  }

  Widget opt_button(button_options opt) {
    return Container(
      width: 340,
      height: 60,
      child: ElevatedButton(
        onPressed: () async {
          switch (opt) {
            case button_options.open_projects:
            // TODO: Handle this case.
              break;
            case button_options.closed_projects:
            // TODO: Handle this case.
              break;
            case button_options.budget_entries:
            // TODO: Handle this case.
              break;
            case button_options.new_entry:
              var result = await showDialog(
                                  context: context,
                                  builder: (context) => EntryDialog());
              if (result) {
                Fluttertoast.showToast(
                    msg: 'New Entry added',
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.white12,
                    textColor: Colors.white
                );
              } else {
                Fluttertoast.showToast(
                    msg: 'Canceled',
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.white12,
                    textColor: Colors.white
                );
              }
              break;
            case button_options.new_project:
            // TODO: Handle this case.
              break;
          }
        },
        child: Text(
          (opt == button_options.open_projects) ? 'Open Projects' :
          (opt == button_options.closed_projects)? 'Closed Projects' :
          (opt == button_options.budget_entries)? 'Budget Entries' :
          (opt == button_options.new_entry)? 'New Entry' : 'New Project',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

