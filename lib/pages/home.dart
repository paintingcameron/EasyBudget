import 'package:easybudget/bloc/bloc.dart';
import 'package:easybudget/exceptions/apiExceptions.dart';
import 'package:easybudget/pages/listPages.dart';
import 'package:easybudget/pages/deniedPermissions.dart';
import 'package:easybudget/pages/newProjectPage.dart';
import 'package:easybudget/widgets/easyInputs.dart';
import 'package:easybudget/widgets/easyWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easybudget/widgets/easyAppBars.dart';
import 'package:easybudget/globals.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum button_options {
  open_projects,
  closed_projects,
  budget_entries,
  new_entry,
  new_project
}

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
      bloc = Bloc(await getApplicationDocumentsDirectory());
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
    return FutureBuilder<dynamic>(
          future: _bloc_permission,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data is Bloc) {
                bloc = snapshot.data;
                return HomeView();
              } else {
                return DeniedPermissions();
              }
            } else {
              return loadingView();
            }
          },
        );
  }

  Widget HomeView() {
    return Scaffold(
      appBar: easyAppBar(),
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Column( //Whole screen column
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            easy_stats(bloc),
            easy_buttons(),
          ],
        ),
      ),
    );
  }

  Widget easy_stats(Bloc bloc) {
    return Column(                                                 //Top info column
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 30, bottom: 10),
          child: Text('Total Budget', style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),),
        ),
        StreamBuilder(
          stream: bloc.budget_stream,
          builder: (context, budget_shot) => Text(
            '$currency ${budget_shot.data}',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
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
            child: Text('$currency ${snapshot.data}'),
          ),
        ),
      ],
    );
  }

  Widget easy_buttons() {
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
              bloc.open_projects = true;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProjectListPage(),
                ),
              );
              break;
            case button_options.closed_projects:
              bloc.open_projects = false;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProjectListPage(),
                )
              );
              break;
            case button_options.budget_entries:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EntryListPage(),
                ),
              );
              break;
            case button_options.new_entry:
              List<String> results = await showDialog(
                context: context,
                builder: (context) {
                  return EntryDialog();
                },
              );
              if (results.length == 2) {
                try {
                  await bloc.new_entry(double.parse(results[1]), results[0]);
                  Fluttertoast.showToast(
                    msg: 'New Entry added',
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.black54,
                    textColor: Colors.white
                  );
                } on negativeBudgetException {
                  await Future.delayed(Duration(milliseconds: 500));
                  await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('ERROR'),
                        content: Text('Budget cannot be negative'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop() ,
                            child: Text('ok')),
                        ],
                      ),
                  );
                }
              } else {
                Fluttertoast.showToast(
                  msg: 'Canceled',
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.black54,
                  textColor: Colors.white
                );
              }
              break;
            case button_options.new_project:
              List<dynamic> results = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewProjectPage(),
                ),
              );
              if (results.length == 3) {
                await bloc.new_project(results[0], results[1], double.parse(results[2]));
                Fluttertoast.showToast(
                  msg: 'New Project: ${results[0]}',
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.black54,
                  textColor: Colors.white,
                );
              } else {
                Fluttertoast.showToast(
                    msg: 'Canceled',
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.black54,
                    textColor: Colors.white
                );
              }
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

