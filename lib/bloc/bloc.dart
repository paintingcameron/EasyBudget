import 'dart:async';

import 'package:easybudget/api/tools.dart' as api;
import 'package:easybudget/models/entry.dart';
import 'package:easybudget/models/project.dart';
import 'package:easybudget/repo/repository.dart';
import 'package:easybudget/globals.dart' as globals;

class Bloc {
  late Repository repo;
  late final StreamList<Project> projects;
  late final StreamList<Entry> entries;
  late final Money_Controller budgetController;
  late final Money_Controller requiredController;
  late final Money_Controller availableController;
  late bool openProjects;

  Bloc(var path) {
    projects = StreamList<Project>();
    entries = StreamList<Entry>();

    openProjects = true;

    repo = Repository();
  }

  Future<void> init_repo() async {
    await repo.init_boxes();

    var budget = repo.budget_box.get(globals.budget_key);
    var required = repo.budget_box.get(globals.required_key);
    var allocated = repo.budget_box.get(globals.allocated_key);
    budget ??= 0;
    required ??= 0;
    allocated ??= 0;

    budgetController = Money_Controller(budget);
    requiredController = Money_Controller(required);
    availableController = Money_Controller(budget - allocated);
  }

  Stream<List<Project>> get projects_stream => projects.stream;
  Stream<List<Entry>> get entries_stream => entries.stream;
  Stream<double> get budget_stream => budgetController.stream;
  Stream<double> get required_stream => requiredController.stream;
  Stream<double> get unallocated_stream => availableController.stream;

  void sinkProjects() {
    projects.setList(api.getOpenClosedProjected(repo.project_box.values.toList(), openProjects));
  }

  void sinkAllEntries() {
    entries.setList(repo.entry_box.values.toList());
  }

  void sinkBudget() {
    var budget = repo.budget_box.get(globals.budget_key);
    budget ??= 0;
    budgetController.sinkValue(budget);
  }

  void sinkRequired() {
    var required = repo.budget_box.get(globals.required_key);
    required ??= 0;
    requiredController.sinkValue(required);
  }

  void sinkUnallocated() {
    var budget = repo.budget_box.get(globals.budget_key);
    var allocated = repo.budget_box.get(globals.allocated_key);
    budget ??= 0;
    allocated ??= 0;

    availableController.sinkValue(budget - allocated);
  }

  Future<Project> new_project(String name, String desc, double goal) async {
    Project project = await api.newProject(repo.project_box, repo.budget_box, name, desc, goal);

    sinkRequired();
    return project;
  }

  void delete_project(int id) async {
    await api.deleteProject(repo.project_box, repo.budget_box, id);

    sinkRequired();
    sinkUnallocated();
    sinkProjects();
  }

  void add_to_allocated(int id, double amount) {
    api.addToAllocated(repo.project_box, repo.budget_box, id, amount);

    sinkUnallocated();
    sinkProjects();
  }

  void edit_goal(int id, double newGoal) {
    api.editGoal(repo.project_box, repo.budget_box, id, newGoal);

    sinkRequired();
    sinkProjects();
  }

  void mark_bought(int id, bool bought) {
    api.markBought(repo.project_box, repo.budget_box, id, bought);

    sinkBudget();
    sinkRequired();
    sinkUnallocated();

    sinkProjects();
  }

  Future<void> new_entry(double amount, String desc) async {
    await api.newEntry(repo.entry_box, repo.budget_box, amount, desc);

    sinkBudget();
    sinkUnallocated();
  }

  void dispose()  {
    projects.dispose();
    entries.dispose();
    budgetController.dispose();
    requiredController.dispose();
    availableController.dispose();
  }
}

class StreamList<T> {
  final StreamController <List<T>> _controller = StreamController.broadcast();

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
  }

  Stream<double> get stream => _controller.stream;

  void sinkValue(double value) {
    _controller.sink.add(value);
  }

  void dispose() {
    _controller.close();
  }
}