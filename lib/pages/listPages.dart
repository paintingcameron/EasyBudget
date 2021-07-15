import 'package:easybudget/bloc/bloc.dart';
import 'package:easybudget/models/entry.dart';
import 'package:easybudget/models/project.dart';
import 'package:easybudget/pages/projectPage.dart';
import 'package:easybudget/widgets/easyWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easybudget/widgets/easyAppBars.dart';

class ProjectListPage extends StatelessWidget {
  final Bloc _bloc;

  ProjectListPage(this._bloc);

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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: easyAppBar(),
      body: StreamBuilder<List<Project>>(
        stream: _bloc.projects_stream,
        builder: (context, AsyncSnapshot<List<Project>> snapshot) {
          if (snapshot.hasData) {
            return getListView(snapshot.data!, context);
          } else {
            _bloc.sinkProjects();
            return loadingView();
          }
        },
      ),
    );
  }
}

class EntryListPage extends StatelessWidget {
  final Bloc _bloc;

  EntryListPage(this._bloc);

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
        title: Text('\$ ${item.amount}'),
        subtitle: Text(item.desc),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: easyAppBar_back(),
        body: StreamBuilder<List<Entry>>(
          stream: _bloc.entries_stream,
          builder: (context, AsyncSnapshot<List<Entry>> snapshot) {
            if (snapshot.hasData) {
              return getListView(snapshot.data!);
            } else {
              _bloc.sinkAllEntries();
              return loadingView();
            }
          },
        ),
      ),
    );
  }
}