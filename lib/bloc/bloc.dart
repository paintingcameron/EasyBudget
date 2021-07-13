import 'dart:async';

import 'package:easybudget/api/tools.dart' as api;
import 'package:easybudget/models/entry.dart';
import 'package:easybudget/models/project.dart';
import 'package:easybudget/repo/repository.dart';
import 'package:easybudget/globals.dart' as globals;

Bloc g_bloc = Bloc('/Hive');

class Bloc {
  late Repository repo;
  late final StreamList<Project> projects;
  late final StreamList<Entry> entries;
  late final Money_Controller budget_controller;
  late final Money_Controller required_controller;
  late final Money_Controller unallocated_controller;
  late var open_projects;

  Bloc(var path) {
    print('starting to initialize bloc');
    projects = StreamList<Project>();
    entries = StreamList<Entry>();
    print('created stream lists');

    open_projects = true;

    repo = Repository();
    print('Initialized bloc object');
  }

  Future<void> init_repo() async {
    print('Initializing repo');
    await repo.init_boxes();

    sinkProjects();
    sinkAllEntries();

    var budget = repo.budget_box.get(globals.budget_key);
    var required = repo.budget_box.get(globals.required_key);
    var allocated = repo.budget_box.get(globals.allocated_key);
    budget ??= 0;
    required ??= 0;
    allocated ??= 0;

    budget_controller = Money_Controller(budget);
    required_controller = Money_Controller(required);
    unallocated_controller = Money_Controller(allocated);

    print('Done initializing repo');
  }

  Stream<List<Project>> get projects_stream => projects.stream;
  Stream<List<Entry>> get entries_stream => entries.stream;
  Stream<double> get budget_stream => budget_controller.stream;
  Stream<double> get required_stream => required_controller.stream;
  Stream<double> get unallocated_stream => unallocated_controller.stream;

  void sinkProjects() {
    projects.setList(api.get_open_closed_projects(repo.project_box.values.toList(), open_projects));
  }

  void sinkAllEntries() {
    entries.setList(repo.entry_box.values.toList());
  }

  void sinkBudget() {
    var budget = repo.budget_box.get(globals.budget_key);
    budget ??= 0;
    budget_controller.sinkValue(budget);
  }

  void sinkRequired() {
    var required = repo.budget_box.get(globals.required_key);
    required ??= 0;
    required_controller.sinkValue(required);
  }

  void sinkUnallocated() {
    var allocated = repo.budget_box.get(globals.allocated_key);
    var budget = repo.budget_box.get(globals.budget_key);
    allocated ??= 0;
    budget ??= 0;
    unallocated_controller.sinkValue(budget - allocated);
  }

  Future<void> new_project(String name, String desc, double goal) async {
    await api.new_project(repo.project_box, repo.budget_box, name, desc, goal);

    sinkRequired();
    sinkProjects();
  }

  void delete_project(String name) {
    api.delete_project(repo.project_box, repo.budget_box, name);

    sinkRequired();
    sinkUnallocated();
    sinkProjects();
  }

  void add_to_allocated(String name, double amount) {
    api.add_to_allocated(repo.project_box, repo.budget_box, name, amount);

    sinkUnallocated();
  }

  void edit_goal(String name, double newGoal) {
    api.edit_goal(repo.project_box, repo.budget_box, name, newGoal);

    sinkRequired();
  }

  Future<void> new_entry(double amount, String desc) async {
    await api.new_entry(repo.entry_box, repo.budget_box, amount, desc);

    sinkBudget();
    sinkUnallocated();
    sinkAllEntries();
  }

  void dispose()  {
    projects.dispose();
    entries.dispose();
    budget_controller.dispose();
    required_controller.dispose();
    unallocated_controller.dispose();
  }
}

class StreamList<T> {
  final StreamController <List<T>> _controller = StreamController();

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

class Money_Controller {
  final StreamController<double> _controller = StreamController();
  late double value;

  Money_Controller(double value) {
    this.value = value;
    sinkValue(value);
    print('initiating money controller');
  }

  Stream<double> get stream => _controller.stream;

  void sinkValue(double value) {
    _controller.sink.add(value);
  }

  void dispose() {
    _controller.close();
  }
}