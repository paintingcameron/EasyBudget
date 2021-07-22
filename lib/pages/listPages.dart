import 'package:easybudget/bloc/bloc.dart';
import 'package:easybudget/globals.dart';
import 'package:easybudget/models/entry.dart';
import 'package:easybudget/models/project.dart';
import 'package:easybudget/pages/projectPage.dart';
import 'package:easybudget/widgets/easyWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easybudget/widgets/easyAppBars.dart';
import 'package:intl/intl.dart';

class ProjectListPage extends StatelessWidget {
  bool open;

  ProjectListPage(this.open);

  Widget getListView(List<Project> lst, BuildContext context) {
    return ListView.builder(
      itemCount: lst.length,
      itemBuilder: (BuildContext context, int index) {
        return getListItem(lst[index], context);
      },
    );
  }

  Widget getListItem(Project project, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectPage(project),
          ),
        );
      },
      child: Card(
        child: ListTile(
          title: Text('${project.name}'),
          subtitle: Text('${project.desc}'),
          trailing: Text(
            '$currency ${project.allocated} / $currency ${project.goal}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: easyAppBar_title('${(open) ? 'Open' : 'Closed '} Projects'),
      body: StreamBuilder<List<Project>>(
        stream: bloc.projectStream,
        builder: (context, AsyncSnapshot<List<Project>> snapshot) {
          if (snapshot.hasData) {
            return getListView(snapshot.data!, context);
          } else {
            bloc.sinkProjects();
            return loadingView();
          }
        },
      ),
    );
  }
}

class EntryListPage extends StatelessWidget {

  Widget getListView(List<Entry> lst) {
    return ListView.builder(
      itemCount: lst.length,
      itemBuilder: (BuildContext context, int index) {
        return getListItem(lst[index]);
      },
    );
  }

  Widget getListItem(Entry item) {
    return Card(
      child: ListTile(
        title: Text(item.desc),
        subtitle: Text('${DateFormat('dd/mm/yyyy').format(item.date_created)}'),
        trailing: Text(
          '$currency ${item.amount}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: easyAppBar_title('Deposits / Withdraws'),
        body: StreamBuilder<List<Entry>>(
          stream: bloc.entryStream,
          builder: (context, AsyncSnapshot<List<Entry>> snapshot) {
            if (snapshot.hasData) {
              return getListView(snapshot.data!);
            } else {
              bloc.sinkAllEntries();
              return loadingView();
            }
          },
        ),
      ),
    );
  }
}