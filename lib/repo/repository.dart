import 'dart:async';
import 'package:easybudget/models/entry.dart';
import 'package:easybudget/models/project.dart';
import 'package:easybudget/models/subscription.dart';
import 'package:hive/hive.dart';
import 'package:easybudget/globals.dart' as globals;

class Repository {
  late Box<Project> projectBox;
  late Box<Entry> entryBox;
  late Box<double> budgetBox;
  late Box<Subscription> subsBox;

  late final StreamList<Project> projectList;
  late final StreamList<Entry> entriesList;
  late final StreamList<Subscription> subsList;

  late final MoneyController budgetController;
  late final MoneyController requiredController;
  late final MoneyController availableController;

  Future<void> initBoxes() async {
    Hive.registerAdapter(ProjectAdapter());
    Hive.registerAdapter(EntryAdapter());
    Hive.registerAdapter(SubscriptionAdapter());

    projectBox = await Hive.openBox<Project>(globals.project_box);
    entryBox = await Hive.openBox<Entry>(globals.entries_box);
    budgetBox = await Hive.openBox<double>(globals.budget_box);
    subsBox = await Hive.openBox<Subscription>(globals.subscriptionKey);
  }

  Future<void> initStream() async {
    projectList = StreamList<Project>();
    entriesList = StreamList<Entry>();
    subsList = StreamList<Subscription>();

    var budget = budgetBox.get(globals.budget_key);
    var required = budgetBox.get(globals.required_key);
    var allocated = budgetBox.get(globals.allocated_key);
    budget ??= 0;
    required ??= 0;
    allocated ??= 0;

    budgetController = MoneyController(budget);
    requiredController = MoneyController(required);
    availableController = MoneyController(budget - allocated);
  }

  void emptyStream() async {
    await projectBox.deleteAll(projectBox.keys);
    await entryBox.deleteAll(entryBox.keys);
    await budgetBox.deleteAll(budgetBox.keys);
  }
}


class StreamList<T> {
  final StreamController<List<T>> _controller = StreamController.broadcast();

  Stream<List<T>> get stream => _controller.stream;

  List<T> _list = [];

  void setList(List<T> list) {
    _list = list;
    sinkList();
  }

  void addToList(T value) {
    _list.add(value);
    sinkList();
  }

  void sinkList() {
    _controller.sink.add(_list);
  }

  void dispose() {
    _controller.close();
  }
}

class MoneyController {
  final StreamController<double> _controller = StreamController();
  late double value;

  MoneyController(double value) {
    this.value = value;
    sinkValue(value);
  }

  Stream<double> get stream => _controller.stream;

  void sinkValue(double value) {
    _controller.sink.add(value);
  }

  void dispose() {
    _controller.close();
  }
}