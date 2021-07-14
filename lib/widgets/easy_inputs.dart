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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('New Budget Entry'),
      content: Container(
        height: 200,
        width: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Text('Entry Description:'),
            ),
            TextField(
              maxLines: 1,
              controller: descController,
              keyboardType: TextInputType.multiline,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Text('Entry Amount:'),
            ),
            Row(
              children: [
                Text('R'),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Container(
                    width: 80,
                    child: TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\-0-9]')),
                        //FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
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
            //print('Desc: ${descController.text}\nAmount: R ${amountController.text}');
            //TODO: Check if budget entry is valid and save if so
            Navigator.of(context).pop([descController.text, amountController.text]);
          }
        )
      ],
    );
  }
}