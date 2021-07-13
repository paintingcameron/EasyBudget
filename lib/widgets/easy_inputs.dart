import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EntryDialog extends StatefulWidget {
  @override
  _EntryDialogState createState() => _EntryDialogState();
}

class _EntryDialogState extends State<EntryDialog> {
  double amount = 0;
  var myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('New Budget Entry'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              maxLines: null,
              controller: myController,
              keyboardType: TextInputType.multiline,
            ),
          ),
          Slider(
            value: amount,
            onChanged: (val) {
              setState(() {
                amount = val;
              });
            }
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        TextButton(
          child: Text('Save'),
          onPressed: () {
            print('Desc: ${myController.text}\nAmount: R$amount');
            //TODO: Check if budget entry is valid and save if so
            Navigator.of(context).pop(true);
          }
        )
      ],
    );
  }
}