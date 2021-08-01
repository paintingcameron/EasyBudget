import 'package:easybudget/bloc/bloc.dart';
import 'package:easybudget/exceptions/apiExceptions.dart';
import 'package:easybudget/main.dart';
import 'package:easybudget/models/project.dart';
import 'package:easybudget/models/subscription.dart';
import 'package:easybudget/pages/listPages.dart';
import 'package:easybudget/pages/deniedPermissions.dart';
import 'package:easybudget/pages/newProjectPage.dart';
import 'package:easybudget/pages/newSubscription.dart';
import 'package:easybudget/widgets/easyInputs.dart';
import 'package:easybudget/widgets/easyWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:easybudget/widgets/easyAppBars.dart';
import 'package:easybudget/globals.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';


enum button_options {
  open_projects,
  closed_projects,
  budget_entries,
  new_entry,
  new_project,
  quick_project,
  new_subscription,
  subscriptions,
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<dynamic> _blocPermission;

  Future<dynamic> _initBloc() async {
    if (await Permission.storage.request().isGranted) {
      var dir = await getApplicationDocumentsDirectory();
      Hive.init(dir.path);
      bloc = Bloc(await getApplicationDocumentsDirectory());
      await bloc.initRepo();
      await bloc.makeSubscriptionPayments();
      return bloc;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _blocPermission = _initBloc();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: _blocPermission,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data is Bloc) {
            bloc = snapshot.data;
            return homeView();
          } else {
            return DeniedPermissions();
          }
        } else {
          return loadingView();
        }
      },
    );
  }

  Widget homeView() {
    return Scaffold(
      appBar: easyAppBar(''),
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Column( //Whole screen column
          children: [
            TopView(),
            SizedBox(height: 20,),
            easyGridButtons(),
            SizedBox(height: 10,),
          ],
        ),
      ),
    );
  }

  Widget easyGridButtons() {
    return Expanded(
      child: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        physics: ScrollPhysics(),
        children: [
          gridButton(button_options.open_projects),
          gridButton(button_options.new_project),
          Column(
            children: [
              IconButton(
                iconSize: 95,
                icon: Image.asset('assets/images/deposit_icon.png'),
                onPressed: () async {
                  List<String> results = await showDialog(
                    context: context,
                    builder: (context) {
                      return EntryDialog();
                    },
                  );
                  if (results.length == 2) {
                    try {
                      await bloc.newEntry(double.parse(results[1]), results[0]);
                      Fluttertoast.showToast(
                          msg: 'New Entry added',
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.black54,
                          textColor: Colors.white
                      );
                    } on NegativeBudgetException {
                      await Future.delayed(Duration(milliseconds: 500));
                      await showDialog(
                        context: context,
                        builder: (context) =>
                            AlertDialog(
                              title: Text('ERROR'),
                              content: Text('Budget cannot be negative'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
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
                },
              ),
              SizedBox(height: 5,),
              Text('Deposit/Withdraw'),
            ],
          ),
          gridButton(button_options.closed_projects),
          gridButton(button_options.budget_entries),
          gridButton(button_options.quick_project),
          gridButton(button_options.new_subscription),
          gridButton(button_options.subscriptions),
        ],
      ),
    );
  }

  Widget gridButton(button_options opt) {
    return Column(
      children: [
        IconButton(
          iconSize: 100,
          icon: (opt == button_options.new_project) ? Icon(Icons.add_box_rounded) :
          (opt == button_options.open_projects) ? Icon(Icons.construction_rounded) :
          (opt == button_options.closed_projects) ? Icon(Icons.verified_rounded) :
          (opt == button_options.budget_entries) ? Icon(Icons.payments) :
          (opt == button_options.quick_project) ? Icon(Icons.shopping_bag) :
          (opt == button_options.new_subscription) ? Icon(Icons.loupe) :
              Icon(Icons.list_alt),
          onPressed: () async {
            switch (opt) {
              case button_options.open_projects:
                bloc.openProjects = true;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProjectListPage(true),
                  ),
                );
                break;
              case button_options.closed_projects:
                bloc.openProjects = false;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProjectListPage(false),
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
                break;
              case button_options.new_project:
                List<dynamic> results = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewProjectPage('New Project'),
                  ),
                );
                if (results.length == 3) {
                  await bloc.newProject(results[0], results[1], double.parse(results[2]));
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
              case button_options.quick_project:
                List<dynamic> results = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      var budget = bloc.repo.budgetBox.get(budget_key);
                      var allocated = bloc.repo.budgetBox.get(allocated_key);
                      budget ??= 0;
                      allocated ??= 0;
                      double available = budget - allocated;
                      return QuickNewProjectPage('Quick Buy', available);
                    }
                  ),
                );
                if (results.length == 3) {
                  Project project = await bloc.newProject(results[0],
                      results[1], double.parse(results[2]));

                  bloc.addToAllocated(project.key, project.goal);
                  bloc.markBought(project.key, true);

                  Fluttertoast.showToast(
                    msg: '${results[0]} purchased',
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
              case button_options.new_subscription:
                List<String> results = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewSubscriptionPage(),
                  )
                );

                if (results.length == 6) {
                  Subscription sub = await bloc.newSubscription(results[0], results[1],
                      double.parse(results[2]), results[3], int.parse(results[4]),
                      DateTime.parse(results[5]));

                  Fluttertoast.showToast(
                    msg: 'New Subscription: ${sub.name}',
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.black54,
                    textColor: Colors.white
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
              case button_options.subscriptions:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SubscriptionListPage(),
                  ),
                );
            }
          },
        ),
        Text(
          (opt == button_options.open_projects) ? 'Open Projects' :
          (opt == button_options.closed_projects) ? 'Closed Projects' :
          (opt == button_options.budget_entries) ? 'Deposits/Withdraws' :
          (opt == button_options.new_entry) ? 'New Entry' :
          (opt == button_options.new_project) ? 'New Project' :
          (opt == button_options.quick_project) ? 'Quick Buy' :
          (opt == button_options.new_subscription) ? '+ Subscription' :
              'Subscriptions',
        )
      ],
    );
  }
}

class TopView extends StatefulWidget {
  @override
  _TopViewState createState() => _TopViewState();
}

class _TopViewState extends State<TopView> {
  double budget = 0;
  double available = 0;
  double required = 0;

  _TopViewState() {
    bloc.budgetStream.listen((newBudget) {
      setState(() {
        budget = newBudget;
      });
    });

    bloc.availableStream.listen((newAvailable) {
      setState(() {
        available = newAvailable;
      });
    });

    bloc.requiredStream.listen((newRequired) {
      setState(() {
        required = newRequired;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 20,),
        availableChart(),
        // SizedBox(height: 20,),
        budgetRequired(),
      ],
    );
  }

  Widget budgetRequired() {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: (budget <= required ) ? [
                Text(
                  'Budget: $currency $budget',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Required: $currency $required',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ] : [
                Text(
                  'Required: $currency $required',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Budget: $currency $budget',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          LinearPercentIndicator(
            lineHeight: 14,
            percent: (budget <= required) ?
              ((required != 0) ? budget/required : 0 ):
              ((budget != 0) ? required/budget : 0),
            progressColor: Color(moneyGreen),
          ),
        ],
      ),
    );
  }

  Widget availableChart() {
    return CircularPercentIndicator(
      radius: 320,
      lineWidth: 20,
      percent: (budget == 0) ? 0 : available/budget,
      center: Text(
        'Available:\n$currency $available',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 45,
        ),
      ),
      progressColor: Color(moneyGreen),
      circularStrokeCap: CircularStrokeCap.round,
    );
  }
}