import 'package:easybudget/widgets/easyWidgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easybudget/widgets/easyAppBars.dart';

abstract class ListPage<T> extends StatelessWidget{
  Stream<T> list_stream;
  String title;

  Widget get_listview(List<T> lst) {
    return ListView.builder(
      itemCount: lst.length,
      itemBuilder: (BuildContext context, int index) {
        return getListItem(lst[index]);
      },
    );
  }

  Widget getListItem(T item);

  ListPage(this.list_stream, this.title);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: easyAppBar_back(),
        body: StreamBuilder(
          builder: (context, AsyncSnapshot<List<T>> snapshot) {
            if (snapshot.hasData) {
              return get_listview(snapshot.data!);
            } else {
              return loadingView();
            }
          },
        ),
      ),
    );
  }
}