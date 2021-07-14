import 'dart:io';

import 'package:easybudget/models/entry.dart';
import 'package:easybudget/models/entryAdaptor.dart.cstm';
import 'package:easybudget/models/project.dart';
import 'package:easybudget/models/projectAdaptor.dart.cstm';
import 'package:hive/hive.dart';
import 'package:easybudget/globals.dart' as globals;

class Repository {
  late Box<Project> project_box;
  late Box<Entry> entry_box;
  late Box<double> budget_box;

  Future<void> init_boxes() async {
    print('Starting to initiate boxes');
    Hive.registerAdapter(ProjectAdaptor());
    Hive.registerAdapter(EntryAdaptor());
    print('Registered adapters');
    project_box = await Hive.openBox<Project>(globals.project_box);
    entry_box = await Hive.openBox<Entry>(globals.entries_box);
    budget_box = await Hive.openBox<double>(globals.budget_box);

    print('Done initiated boxes');
  }

  void empty_boxes() async {
    await project_box.deleteAll(project_box.keys);
    await entry_box.deleteAll(entry_box.keys);
    await budget_box.deleteAll(budget_box.keys);
  }
}