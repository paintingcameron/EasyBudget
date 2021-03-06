import 'package:easybudget/globals.dart';
import 'package:easybudget/models/entry.dart';
import 'package:easybudget/models/project.dart';
import 'package:easybudget/models/subscription.dart';
import 'package:easybudget/pages/projectPage.dart';
import 'package:easybudget/pages/subscriptionPage.dart';
import 'package:easybudget/widgets/easyWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easybudget/widgets/easyAppBars.dart';
import 'package:intl/intl.dart';

abstract class ListPage<T> extends StatelessWidget {
  final String title;
  final Stream<List<T>> listStream;

  ListPage(this.title, this.listStream);

  Widget getListView(List<T> lst, BuildContext context) {
    return ListView.builder(
      itemCount: lst.length,
      itemBuilder: (BuildContext context, int index) {
        return getListItem(lst.reversed.toList()[index], context);
      },
    );
  }

  Widget getListItem(T item, BuildContext context);

  AppBar listAppBar() {
    return easyAppBar(title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: listAppBar(),
      body: StreamBuilder<List<T>>(
        stream: listStream,
        builder: (context, AsyncSnapshot<List<T>> snapshot) {
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

class SubscriptionListPage extends ListPage<Subscription> {
  SubscriptionListPage() : super('Subscriptions', bloc.subscriptionStream);

  @override
  AppBar listAppBar() {
    return AppBar(
      centerTitle: true,
      toolbarHeight: 50,
      title: Text(title),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: PopupMenuButton(
            icon: Icon(Icons.filter_list),
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                value: 0,
                child: Text('All'),
              ),
              PopupMenuItem<int>(
                value: 1,
                child: Text('Paused'),
              ),
              PopupMenuItem<int>(
                value: 2,
                child: Text('Running'),
              ),
            ],
            onSelected: (item) {
              switch(item) {
                case 0:
                  bloc.sinkAllSubscriptions();
                  break;
                case 1:
                  bloc.sinkPausedSubscriptions(true);
                  break;
                case 2:
                  bloc.sinkPausedSubscriptions(false);
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget getListItem(Subscription item, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SubscriptionPage(item)),
        );
      },
      child: Card(
        child: ListTile(
          title: Text(item.name),
          subtitle: Text(item.desc),
          trailing: Container(
            width: 110,
            child: Row(
              children: [
                Text(
                  '${item.period} ${(item.type=='day')?'d':
                  (item.type=='week')?'w':
                  (item.type=='month')?'m':'y'} / ',
                ),
                Text(
                  '$currency ${item.amount}',
                  style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProjectListPage extends ListPage<Project> {
  final bool open;

  ProjectListPage(this.open) : super('${(open) ? 'Open' : 'Closed '} Projects', bloc.projectStream);

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
          title: Text(project.name),
          subtitle: Text(project.desc),
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
}

class EntryListPage extends ListPage<Entry> {
  EntryListPage() : super('Deposits / Withdraws', bloc.entryStream);

  Widget getListItem(Entry item, BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(item.desc),
        subtitle: Text('${DateFormat('dd/MM/yyyy').format(item.dateCreated)}'),
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
}