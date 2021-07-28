
import 'package:easybudget/tools/generalTools.dart';
import 'package:easybudget/widgets/easyAppBars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

final typeOptions = <String>{
  'day',
  'week',
  'month',
  'year',
};

class NewSubscriptionPage extends StatefulWidget {

  _NewSubscriptionPageState createState() => _NewSubscriptionPageState();
}

class _NewSubscriptionPageState extends State<NewSubscriptionPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController periodController = TextEditingController();
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  String typeOption = 'day';
  DateTime startDate = DateTime.now();
  bool positive = true;

  @override
  void initState() {
    super.initState();

    periodController.text = '1';
  }

  @override
  Widget build(BuildContext context) {
    final bool showFab = MediaQuery.of(context).viewInsets.bottom==0.0;
    return Scaffold(
      appBar: easyAppBarBack(),
      body: SingleChildScrollView(
        child: Center(
          child: Column (
            children: [
              SizedBox(height: 40,),
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
                      SizedBox(height: 40),
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
                      SizedBox(height: 40,),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Description'
                        ),
                        controller: descController,
                        maxLines: 2,
                        keyboardType: TextInputType.multiline,
                        validator: (desc) {
                          if (desc == null || desc.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 40,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Every',
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                          SizedBox(width: 20,),
                          Container(
                            width: 70,
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Period',
                              ),
                              controller: periodController,
                              keyboardType: TextInputType.number,
                              validator: (period) {
                                if (period == null || period.isEmpty) {
                                  return '';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 20),
                          Container(
                            width: 100,
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: typeOption,
                              items: typeOptions.map((e) {
                                return DropdownMenuItem<String>(
                                  value: e,
                                  child: Text(
                                    '$e${(periodController.text != '1') ? 's' : ''}',
                                  ),
                                );
                              }).toList(),
                              hint: Text(
                                'Please choose a subscription type'
                              ),
                              onChanged: (type) {
                                setState(() {
                                  typeOption = type!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: Icon(
                              (positive) ? Icons.add : Icons.remove,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                positive = !positive;
                              });
                            },
                            iconSize: 40,
                          ),
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
                                  return '';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30,),
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

                              picked ??= DateTime.now();
                              startDate = picked;
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
                Navigator.of(context).pop([nameController.text, descController.text,
                  ((positive) ? '' : '-')+amountController.text, typeOption, periodController.text,
                  formatDate(startDate)]);
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