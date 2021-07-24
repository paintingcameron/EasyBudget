
import 'package:easybudget/models/subscription.dart';
import 'package:easybudget/widgets/easyAppBars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

final typeOptions = <PeriodTypes, String>{
  PeriodTypes.Daily : 'Daily',
  PeriodTypes.Weekly : 'Weekly',
  PeriodTypes.Monthly: 'Monthly',
  PeriodTypes.Annually : 'Annually',
};

class NewSubscriptionPage extends StatefulWidget {

  _NewSubscriptionPageState createState() => _NewSubscriptionPageState();
}

class _NewSubscriptionPageState extends State<NewSubscriptionPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  PeriodTypes option = PeriodTypes.Daily;

  DateTime startDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final bool showFab = MediaQuery.of(context).viewInsets.bottom==0.0;
    return Scaffold(
      appBar: easyAppBarBack(),
      body: SingleChildScrollView(
        child: Center(
          child: Column (
            children: [
              SizedBox(height: 50,),
              Text(
                'New Subscription',
                style: TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left:40, right: 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(height: 50),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Name',
                        ),
                        controller: nameController,
                        maxLines: 1,
                        keyboardType: TextInputType.name,
                        validator: (name) {
                          if (name == null || name.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 50,),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Description'
                        ),
                        controller: descController,
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        validator: (desc) {
                          if (desc == null || desc.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 50,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Amount',
                              ),
                              controller: amountController,
                              maxLines: 1,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly,],
                              validator: (amount) {
                                if (amount == null || amount.isEmpty) {
                                  return 'Please enter a subscription amount';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width:50),
                          Container(
                            width: 100,
                            child: DropdownButton<PeriodTypes>(
                              isExpanded: true,
                              value: option,
                              items: typeOptions.keys.toList().map((e) {
                                String? str = typeOptions[e];
                                str ??= 'Daily';
                                return DropdownMenuItem<PeriodTypes>(
                                  value: e,
                                  child: Text(
                                    str,
                                  ),
                                );
                              }).toList(),
                              hint: Text(
                                'Please choose a subscription type'
                              ),
                              onChanged: (type) {
                                setState(() {
                                  option = type!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 50,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Start Date: ${DateFormat('dd-MM-yyyy').format(startDate)}',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          IconButton(
                            iconSize: 30,
                            onPressed: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: startDate,
                                firstDate: startDate,
                                lastDate: DateTime(startDate.year+50, startDate.month, startDate.day),
                              );
                            },
                            icon: Icon(Icons.calendar_today),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: (showFab)? floatingActionButtons(context):null,
    );
  }

  Widget floatingActionButtons(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          FloatingActionButton(
            heroTag: 'btn_close',
            onPressed: () {
              Navigator.of(context).pop([false]);
            },
            child: Icon(Icons.close),
            backgroundColor: Colors.red,
          ),
          FloatingActionButton(
            heroTag: 'btn_save',
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.of(context).pop([nameController.text, descController.text, amountController.text]);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Invalid Project')));
              }
            },
            child: Icon(Icons.done),
            backgroundColor: Colors.green,
          ),
        ],
      ),
    );
  }
}