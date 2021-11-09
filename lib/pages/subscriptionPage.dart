import 'package:easybudget/globals.dart';
import 'package:easybudget/main.dart';
import 'package:easybudget/models/entry.dart';
import 'package:easybudget/models/subscription.dart';
import 'package:easybudget/widgets/easyAppBars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

DateFormat formatter = DateFormat('dd/MM/yyyy');

class SubscriptionPage extends StatefulWidget {
  final Subscription sub;

  SubscriptionPage(this.sub);

  _SubscriptionPageState createState() => _SubscriptionPageState(sub);
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  Subscription sub;

  _SubscriptionPageState(this.sub);

  @override
  Widget build(BuildContext context) {
    print(DateTime.now().difference(sub.lastPaid).inMicroseconds.abs() /
        sub.nextPayment().difference(sub.lastPaid).inMicroseconds.abs());
    print(DateTime.now().difference(sub.lastPaid).inMicroseconds.abs());
    print(sub.nextPayment().difference(sub.lastPaid).inMicroseconds.abs());

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: easyAppBarBack(),
      body: Center(
        child: Column(
          children: [
            topView(),
            Divider(),
            entryList(),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton(
              backgroundColor: Colors.red,
              child: Icon(Icons.delete_forever,),
              onPressed: () {
                bloc.deleteSubscription(sub.key);
                Navigator.of(context).pop();
              },
            ),
            (sub.paused) ? FloatingActionButton(
              backgroundColor: Color(moneyGreen),
              child: Icon(Icons.play_arrow_outlined),
              onPressed: () {
                setState(() {
                  sub.pause = false;
                  sub.save();
                });
              },
            ) : FloatingActionButton(
              backgroundColor: Colors.grey,
              child: Icon(Icons.pause),
              onPressed: () {
                setState(() {
                  sub.pause = true;
                  sub.save();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget topView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.topRight,
            child: Text(
              'Started: ${formatter.format(sub.startDate)}',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ),
        SizedBox(height: 30,),
        Text(
            sub.name,
            style: TextStyle(
              fontSize: (sub.name.length >= 15) ? 40 : 50,
              fontWeight: FontWeight.bold,
            )
        ),
        Text(
          (sub.paused) ? 'Paused' : 'Running',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 40,),
        Text(
          '$currency ${sub.amount}',
          style: TextStyle(
            fontSize: 40,
          ),
        ),
        Text(
          '/ ${sub.period} ${sub.type}${(sub.period != 1) ? 's':''}',
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: subscriptionProgress(),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
                sub.desc
            ),
          ),
        ),
      ],
    );
  }

  Widget subscriptionProgress() {
    int nextDuration = sub.nextPayment().difference(sub.lastPaid).inMicroseconds.abs();
    int sinceDuration = DateTime.now().difference(sub.lastPaid).inMicroseconds.abs();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatter.format(sub.lastPaid)),
              Text(formatter.format(sub.nextPayment())),
            ],
          ),
        ),
        LinearPercentIndicator(
          lineHeight: 20,
          percent:  (nextDuration == 0) ? 1 : sinceDuration/nextDuration,
          progressColor: Color(moneyGreen),
        ),
      ],
    );
  }

  Widget entryList() {
    List<Entry> entries = bloc.getSubEntries(sub.key);
    print(entries);
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 250,
      decoration: BoxDecoration(
          boxShadow: [
            const BoxShadow(
              color: Colors.grey,
            ),
            const BoxShadow(
              color: Colors.white,
              spreadRadius: -1.0,
              blurRadius: 1,
            )
          ]
      ),
      child: ListView.builder(
        itemCount: entries.length,
        itemBuilder: (BuildContext context, int index) {
          Entry item = entries[index];
          return Card(
            child: ListTile(
              title: Text(item.desc),
              subtitle: Text(
                  '${DateFormat('dd/mm/yyyy').format(item.dateCreated)}'),
              trailing: Text(
                '$currency ${item.amount}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget entryList() {
  //   return Container(
  //     width: MediaQuery.of(context).size.width,
  //     height: 250,
  //     alignment: Alignment.center,
  //     child: StreamBuilder(
  //       stream: bloc.entryStream,
  //       builder: (context, AsyncSnapshot<List<Entry>> snapshot) {
  //         if (snapshot.hasData) {
  //           List<Entry> entries = snapshot.data!;
  //           return Container(
  //             decoration: BoxDecoration(
  //                 boxShadow: [
  //                   const BoxShadow(
  //                     color: Colors.grey,
  //                   ),
  //                   const BoxShadow(
  //                     color: Colors.white,
  //                     spreadRadius: -1.0,
  //                     blurRadius: 1,
  //                   )
  //                 ]
  //             ),
  //             child: ListView.builder(
  //               itemCount: entries.length,
  //               itemBuilder: (BuildContext context, int index) {
  //                 Entry item = entries[index];
  //                 return Card(
  //                   child: ListTile(
  //                     title: Text(item.desc),
  //                     subtitle: Text(
  //                         '${DateFormat('dd/mm/yyyy').format(item.dateCreated)}'),
  //                     trailing: Text(
  //                       '$currency ${item.amount}',
  //                       style: TextStyle(
  //                         fontWeight: FontWeight.bold,
  //                         fontSize: 20,
  //                       ),
  //                     ),
  //                   ),
  //                 );
  //               }
  //             ),
  //           );
  //         } else {
  //           return Text('No Payments Yet');
  //         }
  //       },
  //     ),
  //   );
  // }
}