import 'package:easybudget/globals.dart';
import 'package:easybudget/main.dart';
import 'package:easybudget/models/subscription.dart';
import 'package:easybudget/tools/generalTools.dart';
import 'package:easybudget/widgets/easyAppBars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: easyAppBarBack(),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.topRight,
                child: Text(
                  'Started: ${prettifyDate(sub.startDate)}',
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
              (sub.paused) ? 'Running' : 'Paused',
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
        ),
      ),
    );
  }

  Widget subscriptionProgress() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(prettifyDate(sub.lastPaid)),
              Text(prettifyDate(sub.nextPayment())),
            ],
          ),
        ),
        LinearPercentIndicator(
          lineHeight: 20,
          percent: DateTime.now().difference(sub.lastPaid).inMicroseconds /
                    sub.nextPayment().difference(sub.lastPaid).inMicroseconds,
          progressColor: Color(moneyGreen),
        ),
      ],
    );
  }
}