
import 'package:easybudget/exceptions/apiExceptions.dart';
import 'package:easybudget/globals.dart';
import 'package:easybudget/main.dart';
import 'package:easybudget/models/project.dart';
import 'package:easybudget/widgets/easyInputs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

enum button_options {
  edit_goal,
  allocated_budget,
}

class ProjectPage extends StatefulWidget {
  final Project project;

  ProjectPage(this.project);

  _ProjectPageState createState() => _ProjectPageState(project);
}

class _ProjectPageState extends State<ProjectPage> {
  final Project project;

  _ProjectPageState(this.project);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text((project.bought) ? 'Closed' : 'Open'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 20),
              child: Text(
                '${project.name}'.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  fontSize: (project.name.length >= 15) ? 40 : 50,
                ),
              ),
            ),
            Row (
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularPercentIndicator(
                  radius: 260,
                  lineWidth: 15,
                  percent: project.allocated/project.goal,
                  center: Text(
                    'To Goal:\n$currency ${project.goal-project.allocated}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  progressColor: Color(moneyGreen),
                  circularStrokeCap: CircularStrokeCap.round,
                  // progressColor: Color(0xFFFFDF00),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child:
                          Text(
                            'Goal: $currency ${project.goal}\n'
                            'Allocated: $currency ${project.allocated}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              height: 2,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                        ),
                      ),
                    ),
                    // Container(
                    //   padding: EdgeInsets.only(right:25),
                    //   alignment: Alignment.centerRight,
                    //   child: Text('${DateFormat('dd/mm/yyyy').format(project.date_created)}'),
                    // ),
                  ],
                ),
              ],
            ),
            Container(
              width: 370,
              height: 100,
              alignment: Alignment.centerLeft,
              child: Text(
                '${project.desc}',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            buttonsColumn(context),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton(
              heroTag: 'delete_project',
              child: Icon(Icons.delete_forever),
              backgroundColor: Colors.red,
              onPressed: () async {
                bool delete = await easyConfirmation(context, 'Delete ${project.name}?');
                if (delete) {
                  bloc.delete_project(project.key);
                  Navigator.of(context).pop();
                }
              },
            ),
            (project.goal == project.allocated) ?
            FloatingActionButton(
              heroTag: 'bought_status',
              child: (project.bought) ? Icon(Icons.remove_shopping_cart) : Icon(Icons.shopping_cart),
              onPressed: () async {
                var bought = await easyConfirmation(
                  context,
                  'Mark ${project.name} as ${(project.bought)?'not ':''}bought?',
                );
                if (bought) {
                  setState(() {
                    project.bought = !project.bought;
                    bloc.mark_bought(project.key, project.bought);
                  });
                }
              },
            ) :
            FloatingActionButton(
              heroTag: 'greyed_bought_status',
              backgroundColor: Colors.grey,
              child: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Project goal not reached')));
                },
              ),
              onPressed: null,
            ),
          ],
        ),
      ),
    );
  }

  Widget btnOption(button_options opt, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 25.0, left: 8, right: 8),
      child: Container(
        width: 370,
        height: 60,
        child: ElevatedButton(
          child: Text(
              (opt == button_options.edit_goal) ? 'Edit Goal' : 'Allocate Budget'
          ),
          onPressed: (project.bought)? null : () async {
            switch (opt) {
              case button_options.edit_goal:
                var newGoal = await showDialog(
                    context: context,
                    builder: (context) => ProjectDialog(project.goal, project_stat.goal)
                );
                if (newGoal != null) {
                  setState(() {
                    bloc.edit_goal(project.key, double.parse(newGoal));
                  });
                }
                break;
              case button_options.allocated_budget:
                var newAllocation = await showDialog(
                  context: context,
                  builder: (context) => ProjectDialog(project.allocated, project_stat.allocation),
                );
                if (newAllocation != null) {
                  setState(() {
                    try {
                      bloc.add_to_allocated(project.key, double.parse(newAllocation));
                    } on allocatedGreaterThanGoalException {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Allocated amount cannot be greater than goal')));
                    } on lackOfAvailableBudget {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Insufficient available funds for allocation amount')));
                    } on negativeAllocationException {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Allocated amount cannot be negative')));
                    }
                  });
                }
                break;
            }
          },
        ),
      ),
    );
  }

  Widget buttonsColumn(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        btnOption(button_options.edit_goal, context),
        btnOption(button_options.allocated_budget, context),
      ],
    );
  }
}
