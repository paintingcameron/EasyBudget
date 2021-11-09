import 'package:easybudget/exceptions/apiExceptions.dart';
import 'package:easybudget/models/entry.dart';
import 'package:easybudget/models/project.dart';
import 'package:easybudget/models/subscription.dart';
import 'package:hive/hive.dart';
import '../globals.dart' as globals;

//--------------------------------------------------------------------------------------------------
//                                        Entry Tools
//--------------------------------------------------------------------------------------------------
/// Gets a list of all the edits to the budget from the Hive box [entryBox].
List<Entry> getBudgetEntries(Box<Entry> entryBox) {
  var entries = entryBox.values.toList();

  print(entries);

  return entries;
}

/// Creates a new edit to the budget
///
/// The new [amount] with its description, [desc], is saved into the [entryBox] and the updated
/// budget is saved to [budgetBox].
Future<Entry> newEntry(Box<Entry> entryBox, Box<double> budgetBox,
    double amount, String desc, DateTime created, {subID = -1}) async {

  var budget = budgetBox.get(globals.budget_key);
  budget ??= 0;

  if (budget - amount < 0) {
    throw new NegativeBudgetException('Budget cannot be negative');
  }

  print(created);

  var entry = Entry.newEntry(amount, desc, created, subID: subID);
  print('new entry: $entry');

  await entryBox.add(entry);

  print('new Budget: $budget');
  await budgetBox.put(globals.budget_key, (budget + amount));

  return entry;
}

//--------------------------------------------------------------------------------------------------
//                                       Project Tools
//--------------------------------------------------------------------------------------------------
/// Gets those [projects] that are either open or closed depending on the [open] option
List<Project> getOpenClosedProjected(List<Project> projects, bool open) {
  var filtered = <Project>[];

  for (var project in projects) {
    if (project.bought != open) {
      filtered.add(project);
    }
  }

  return filtered;
}

/// Creates a new project with the given [name], [desc] and [goal]. Adds it to a Hive box and
/// updates the budget box accordingly
Future<Project> newProject(Box<Project> projectBox, Box<double> budgetBox,
    String name, String desc, double goal) async {

  var project = Project(name, desc, goal);
  await projectBox.add(project);

  var required = budgetBox.get(globals.required_key);
  required ??= 0;
  required += goal;
  await budgetBox.put(globals.required_key, required);

  return project;
}

/// Attempts to delete a project from a Hive box
///
/// Throws [KeyDoesNotExistException] if the given [id] does not exist in the Hive projects box.
/// Otherwise the operation succeeds silently.
Future<void> deleteProject(Box<Project> projectBox, Box<double> budgetBox, int id) async {
  if (!projectBox.containsKey(id)) {
    throw KeyDoesNotExistException('The given key: $id does not exist in the projects hive');
  }

  var project = projectBox.get(id);

  var required = budgetBox.get(globals.required_key);
  var allocated = budgetBox.get(globals.allocated_key);
  required ??= 0;
  allocated ??= 0;

  required -= project!.goal;
  allocated -= project.allocated;

  await budgetBox.put(globals.required_key, required);
  await budgetBox.put(globals.allocated_key, allocated);

  await projectBox.delete(id);
  print('Project: ${project.name} deleted');
}

/// Deletes all projects from the Hive box
void deleteAllProjects(Box<Project> projectBox) async {
  await projectBox.deleteAll(projectBox.keys);
}

/// Adds an [amount] to the allocated budget for a specific [project].
///
/// If the [amount] is a negative number [NegativeAllocationException] is thrown. If [amount] is
/// is greater than the goal for the [project] then [AllocatedGreaterThanGoalException] is thrown.
/// If [amount] is greater than the amount of available budget unallocated [LackOfAvailableBudget]
/// is thrown.
void addToAllocated(Box<Project> projectBox, Box<double> budgetBox, int id, double amount) {

  var project = projectBox.get(id);

  if (amount > project!.goal) {
    throw AllocatedGreaterThanGoalException('Cannot allocate R$amount to a project with goal: '
        'R${project.goal}');
  }

  var budget = budgetBox.get(globals.budget_key);
  var allocated = budgetBox.get(globals.allocated_key);

  budget ??= 0;
  allocated ??= 0;

  if ((budget - allocated) < amount) {
    throw LackOfAvailableBudget('Not enough available budget to allocate.'
        '\nAvailable budget: R${budget-allocated}');
  }

  if (allocated + amount < 0) {
    throw NegativeAllocationException('Allocated amount cannot be negative');
  }

  allocated += amount;
  budgetBox.put(globals.allocated_key, allocated);

  project.addAllocated(amount);
  project.save();
}

/// Assigns the goal project with the given [name] to [newGoal] and saves the affects to the
void editGoal(Box<Project> projectBox, Box<double> budgetBox, int id, double newGoal) {
  var project = projectBox.get(id);

  var required = budgetBox.get(globals.required_key);
  required ??= 0;
  required = (required - project!.goal) + newGoal;
  budgetBox.put(globals.required_key, required);

  project.goal = newGoal;
  project.save();
}

/// Marks the project with Hive key: [id] as [bought]
///
/// A project that is bought will deduct from the budget, required and allocated the goal of the
/// project while a project that is marked as not bought will add to those fields.
void markBought(Box<Project> projectBox, Box<double> budgetBox, int id, bool bought) {
  var project = projectBox.get(id);

  var budget = budgetBox.get(globals.budget_key);
  var required = budgetBox.get(globals.required_key);
  var allocated = budgetBox.get(globals.allocated_key);

  budget ??= 0;
  required ??= 0;
  allocated ??= 0;

  if (bought) {
    budget -= project!.goal;
    required -= project.goal;
    allocated -= project.goal;
  } else {
    budget += project!.goal;
    required += project.goal;
    allocated += project.goal;
  }

  budgetBox.put(globals.budget_key, budget);
  budgetBox.put(globals.required_key, required);
  budgetBox.put(globals.allocated_key, allocated);

  project.bought = bought;
  project.save();
}

//--------------------------------------------------------------------------------------------------
//                                       Subscription Tools
//--------------------------------------------------------------------------------------------------

Future<Subscription> newSubscription(Box<Subscription> subsBox, String name,
    String desc, double amount, String type, int period, DateTime startDate) async {

  Subscription sub = Subscription.newSub(name, desc, amount, startDate, period, type);

  await subsBox.add(sub);

  return sub;
}

List<Subscription> getPausedSubscriptions(Box<Subscription> subsBox, bool paused) {
  List<Subscription> subs = [];

  for (var sub in subsBox.values) {
    if (sub.paused == paused) {
      subs.add(sub);
    }
  }

  return subs;
}

/// Makes all possible payments for the running subscriptions in [subsBox]
///
/// Throws [StoppedSubscriptionsException] with subscriptions that couldn't be paid if there is
/// insufficient funds to complete all subscription payments.
/// TODO: Order the list such that subscribed income is before payments
Future<void> paySubscriptions(Box<Subscription> subsBox, Box<Entry> entryBox, Box<double> budgetBox) async {
  DateTime now = DateTime.now();

  for (int i = 0; i < subsBox.length; i++) {
    Subscription sub = subsBox.values.elementAt(i);
    try {
      print(sub.key);
      while (sub.paymentDue(now)) {
        await newEntry(entryBox, budgetBox, sub.amount, 'Subscription: ${sub.name}',
            sub.nextPayment(), subID: sub.key);
        sub.makePayment();
      }
    } on NegativeBudgetException {
      print('insufficient budget');
      List<Subscription> unpaid = subsBox.values.skip(i).toList();
      for (var sub in unpaid) {
        sub.pause = true;
      }
      throw StoppedSubscriptionsException('Insufficient funds to pay all subscriptions', unpaid);
    }
  }
}

/// Removes a subscription with the Hive key [id]
///
/// Throws a [KeyDoesNotExistException] if the [id] does not exist in [subsBox]
void removeSubscription(Box<Subscription> subsBox, int id) async {
  if (!subsBox.containsKey(id)) {
    throw KeyDoesNotExistException('Subscription id: $id does not exist');
  }

  await subsBox.delete(id);
}

void pauseSubscription(Box<Subscription> subsBox, int id) {
  var sub = subsBox.get(id);

  sub!.pause = !sub.paused;

  sub.save();
}

List<Entry> getSubEntries(Box<Entry> entryBox, int id) {
  return entryBox.values.where((entry) => entry.subID == id).toList();
}