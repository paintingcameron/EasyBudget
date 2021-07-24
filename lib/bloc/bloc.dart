import 'dart:async';

import 'package:easybudget/api/tools.dart' as api;
import 'package:easybudget/exceptions/apiExceptions.dart';
import 'package:easybudget/models/entry.dart';
import 'package:easybudget/models/project.dart';
import 'package:easybudget/models/subscription.dart';
import 'package:easybudget/repo/repository.dart';
import 'package:easybudget/globals.dart' as globals;

class Bloc {
  late Repository repo;
  late bool openProjects;

  Bloc(var path) {
    openProjects = true;

    repo = Repository();
  }

  Future<void> initRepo() async {
    await repo.initBoxes();
    await repo.initStream();
  }

  Stream<List<Project>> get projectStream => repo.projectList.stream;
  Stream<List<Entry>> get entryStream => repo.entriesList.stream;
  Stream<List<Subscription>> get subscriptionStream => repo.subsList.stream;
  Stream<double> get budgetStream => repo.budgetController.stream;
  Stream<double> get requiredStream => repo.requiredController.stream;
  Stream<double> get availableStream => repo.availableController.stream;

  void sinkProjects() {
    repo.projectList.setList(api.getOpenClosedProjected(repo.projectBox.values.toList(), openProjects));
  }

  void sinkAllEntries() {
    repo.entriesList.setList(repo.entryBox.values.toList());
  }

  void sinkBudget() {
    var budget = repo.budgetBox.get(globals.budget_key);
    budget ??= 0;
    repo.budgetController.sinkValue(budget);
  }

  void sinkRequired() {
    var required = repo.budgetBox.get(globals.required_key);
    required ??= 0;
    repo.requiredController.sinkValue(required);
  }

  void sinkUnallocated() {
    var budget = repo.budgetBox.get(globals.budget_key);
    var allocated = repo.budgetBox.get(globals.allocated_key);
    budget ??= 0;
    allocated ??= 0;

    repo.availableController.sinkValue(budget - allocated);
  }

  void sinkAllSubscriptions() {
    repo.subsList.setList(repo.subsBox.values.toList());
  }

  Future<Project> newProject(String name, String desc, double goal) async {
    Project project = await api.newProject(repo.projectBox, repo.budgetBox, name, desc, goal);

    sinkRequired();
    return project;
  }

  void deleteProject(int id) async {
    await api.deleteProject(repo.projectBox, repo.budgetBox, id);

    sinkRequired();
    sinkUnallocated();
    sinkProjects();
  }

  void addToAllocated(int id, double amount) {
    api.addToAllocated(repo.projectBox, repo.budgetBox, id, amount);

    sinkUnallocated();
    sinkProjects();
  }

  void editGoal(int id, double newGoal) {
    api.editGoal(repo.projectBox, repo.budgetBox, id, newGoal);

    sinkRequired();
    sinkProjects();
  }

  void markBought(int id, bool bought) {
    api.markBought(repo.projectBox, repo.budgetBox, id, bought);

    sinkBudget();
    sinkRequired();
    sinkUnallocated();

    sinkProjects();
  }

  Future<void> newEntry(double amount, String desc) async {
    await api.newEntry(repo.entryBox, repo.budgetBox, amount, desc);

    sinkBudget();
    sinkUnallocated();
  }

  Future<void> newSubscription(String name, String desc, double amount, PeriodTypes type,
      int period, DateTime startDate) async {
    await api.newSubscription(repo.subsBox, name, desc, amount, type, period, startDate);

    //TODO: Figure out which types of subscriptions are sunk when there is a new subscription
  }

  Future<dynamic> makeSubscriptionPayments() async {

    var out;

    try {
      api.paySubscriptions(repo.subsBox, repo.entryBox, repo.budgetBox);
      out = true;
    } on StoppedSubscriptionsException catch (e) {
      out = e.subsList;
    }

    sinkBudget();
    sinkUnallocated();

    return out;
  }

  void pauseSubscription(int id) => api.pauseSubscription(repo.subsBox, id);

  void dispose()  {
    repo.projectList.dispose();
    repo.entriesList.dispose();
    repo.budgetController.dispose();
    repo.requiredController.dispose();
    repo.availableController.dispose();
  }
}