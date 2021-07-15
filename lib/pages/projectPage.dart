
import 'package:easybudget/models/project.dart';
import 'package:easybudget/widgets/easyAppBars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProjectPage extends StatefulWidget {
  final Project project;

  ProjectPage(this.project);

  _ProjectPageState createState() => _ProjectPageState(project);
}

class _ProjectPageState extends State<ProjectPage> {
  Project project;

  _ProjectPageState(this.project);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: easyAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 30,),
            Text(
              '${project.name}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 70,
              ),
            ),
            SizedBox(height: 40,),
            Text(
              'Goal: \$ ${project.goal}',
              style: TextStyle(
                fontSize: 40,
              ),
            ),
            SizedBox(height: 10,),
            Text(
              'Allocated: \$ ${project.allocated}',
              style: TextStyle(
                fontSize: 40,
              ),
            ),
            SizedBox(height: 20,),
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
            SizedBox(height: 20,),
            Container(
              width: 370,
              height: 60,
              child: ElevatedButton(
                child: Text('Edit Goal'),
                onPressed: () => print('Edit Project Goal'),
              ),
            ),
            SizedBox(height: 20,),
            Container(
              width: 370,
              height: 60,
              child: ElevatedButton(
                child: Text('Allocate Budget'),
                onPressed: () => print('Edit Project Goal'),
              ),
            ),
            SizedBox(height: 20,),
            Container(
              width: 370,
              height: 60,
              child: ElevatedButton(
                child: Text('Delete Project'),
                onPressed: () => print('Edit Project Goal'),
              ),
            ),
            SizedBox(height: 20,),
            Container(
              width: 370,
              height: 60,
              child: ElevatedButton(
                child: Text('Save Changes'),
                onPressed: () => print('Edit Project Goal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}