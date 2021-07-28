
import 'package:easybudget/widgets/easyAppBars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

class NewProjectPage extends StatelessWidget {
  TextEditingController nameController = new TextEditingController();
  TextEditingController descController = new TextEditingController();
  TextEditingController amountController = new TextEditingController();
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  String title;

  NewProjectPage(this.title);

  @override
  Widget build(BuildContext context) {
    final bool showFab = MediaQuery.of(context).viewInsets.bottom==0.0;
    return Scaffold(
      appBar: easyAppBarBack(),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              pageTitle(title),
              projectForm('Goal'),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: showFab?floatingActionButtons(context):null,
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

  Widget pageTitle(String title) {
    return Container(
      height: 150,
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 60
        ),
      ),
    );
  }

  Widget projectForm(String amountTitle) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Project Name *',
              ),
              maxLines: 1,
              controller: nameController,
              keyboardType: TextInputType.text,
              inputFormatters: [LengthLimitingTextInputFormatter(18)],
              validator: (name) {
                if (name == null || name.isEmpty) {
                  return 'Please enter a project name';
                }
                return null;
              },
            ),
            SizedBox(height: 30,),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Project Description',
              ),
              controller: descController,
              maxLines: 5,
              keyboardType: TextInputType.multiline,
              validator: (desc) {
                if (desc == null || desc.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            SizedBox(height: 30,),
            TextFormField(
              decoration: const InputDecoration(
                icon: Icon(Icons.attach_money_sharp),
                labelText: 'Project Cost'
              ),
              controller: amountController,
              maxLines: 1,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly,],
              validator: (goal) {
                if (goal == null || goal.isEmpty) {
                  return 'Please enter a ${amountTitle.toLowerCase()}';
                }
                return null;
              },
            )
          ],
        ),
      ),
    );
  }
}

class QuickNewProjectPage extends NewProjectPage {
  double _available;
  QuickNewProjectPage(String title, this._available) : super(title);

  @override
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
              if (!_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Invalid Project')));
              } else if (double.parse(amountController.text) > _available) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Insufficient available funds')));
              } else {
                Navigator.of(context).pop([nameController.text, descController.text, amountController.text]);
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