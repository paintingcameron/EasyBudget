import 'package:easybudget/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum project_stat {
  goal,
  allocation,
}

class EntryDialog extends StatelessWidget {
  final TextEditingController descController = TextEditingController();
  final TextEditingController  amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('New Budget Entry'),
      content: Form(
        key: _formKey,
        child: Container(
          height: 200,
          width: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Where is the money from?',
                  labelText: 'Description *',
                ),
                maxLines: 1,
                controller: descController,
                keyboardType: TextInputType.multiline,
                validator: (desc) {
                  if (desc == null || desc.isEmpty) {
                    return 'Please enter a desc';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30,),
              Row(
                children: [
                  Container(
                    width: 120,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        icon: Icon(Icons.attach_money_sharp),
                      ),
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\-0-9]')),
                      ],
                      validator: (amount) {
                        if (amount == null || amount.isEmpty) {
                          return 'Entry amount';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(['']),
        ),
        TextButton(
            child: Text('Save'),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.of(context).pop([descController.text, amountController.text]);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Invalid entry')));
              }
            }
        )
      ],
    );
  }
}

class ProjectDialog extends StatelessWidget {
  final TextEditingController _goalController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final double _currentStat;
  final project_stat stat;

  ProjectDialog(this._currentStat, this.stat);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text((stat == project_stat.goal) ? 'Edit Goal' : 'Add to Allocation'),
      content: Form(
        key: _formKey,
        child: Container(
          height: 140,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Current ${(stat == project_stat.goal) ? 'Goal' : 'Allocation'}:',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                Text(
                  '$currency $_currentStat',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextFormField(
                  controller: _goalController,
                  keyboardType: TextInputType.number,
                  inputFormatters: (stat == project_stat.goal)?
                                    [FilteringTextInputFormatter.digitsOnly]:
                                    [FilteringTextInputFormatter.allow(RegExp(r'[\-0-9]'))],
                  validator: (variable) {
                    if (variable == null || variable.isEmpty) {
                      return 'Please enter a new ${(stat == project_stat.goal)?'goal':'allocation'}';
                    }
                    return null;
                  },
                )
              ],
            ),
          ),
        ),
      ),
      actions: [
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child:
                  Text(
                    'cancel',
                    style: TextStyle(fontSize: 20),
                  ),
              ),
              TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.of(context).pop(_goalController.text);
                  }
                },
                child:
                Text(
                  'save',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

Future<bool> easyConfirmation(BuildContext context,String message) async {
  return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are You Sure?'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('cancel'),
          ),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true) ,
              child: Text('ok')),
        ],
      )
  );
}