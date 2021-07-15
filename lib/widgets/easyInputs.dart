import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EntryDialog extends StatefulWidget {
  @override
  _EntryDialogState createState() => _EntryDialogState();
}

class _EntryDialogState extends State<EntryDialog> {
  var descController = TextEditingController();
  var amountController = TextEditingController();
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
                        //FilteringTextInputFormatter.digitsOnly,
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