import 'package:easybudget/exceptions/apiExceptions.dart';
import 'package:easybudget/models/entry.dart';
import 'package:easybudget/models/project.dart';
import 'package:hive/hive.dart';
import '../globals.dart' as globals;

//-------------------------------------------Budget Tools-------------------------------------------
/// Gets a list of all the edits to the budget from the Hive box [entry_box].
List<Entry> get_budget_entries(Box<Entry> entry_box) {
  var entries = entry_box.values.toList();

  return entries;
}

/// Creates a new edit to the budget
///
/// The new [amount] with its description, [desc], is saved into the [entry_box] and the updated
/// budget is saved to [budget_box].
Future<Entry> new_entry(Box<Entry> entry_box, Box<double> budget_box,
    double amount, String desc) async {

  var budget = budget_box.get(globals.budget_key);
  budget ??= 0;

  if (budget + amount < 0) {
    throw new negativeBudgetException('Budget cannot be negative');
  }

  var entry = Entry.newEntry(amount, desc);

  await entry_box.add(entry);

  await budget_box.put(globals.budget_key, (budget + amount));

  return entry;
}

//------------------------------------------Project Tools-------------------------------------------
/// Gets those [projects] that are either open or closed depending on the [open] option
List<Project> get_open_closed_projects(List<Project> projects, bool open) {
  var filtered = <Project>[];

  for (var project in projects) {
    if (project.bought == open) {
      filtered.add(project);
    }
  }

  return filtered;
}

/// Creates a new project with the given [name], [desc] and [goal]. Adds it to a Hive box and
/// updates the budget box accordingly
Future<Project> new_project(Box<Project> project_box, Box<double> budget_box,
    String name, String desc, double goal) async {

  var project = Project(name, desc, goal);
  await project_box.add(project);

  var required = budget_box.get(globals.required_key);
  required ??= 0;
  required += goal;
  await budget_box.put(globals.required_key, required);

  return project;
}

/// Attempts to delete a project from a Hive box
///
/// Throws [keyDoesNotExistException] if the given [id] does not exist in the Hive projects box.
/// Otherwise the operation succeeds silently.
void delete_project(Box<Project> project_box, Box<double> budget_box, int id) async {
  if (!project_box.containsKey(id)) {
    throw keyDoesNotExistException('The given key: $id does not exist in the projects hive');
  }

  var project = project_box.get(id);

  var required = budget_box.get(globals.required_key);
  var allocated = budget_box.get(globals.allocated_key);
  required ??= 0;
  allocated ??= 0;

  required -= project!.goal;
  allocated -= project.allocated;

  await budget_box.put(globals.required_key, required);
  await budget_box.put(globals.allocated_key, allocated);

  await project_box.delete(id);
}

/// Deletes all projects from the Hive box
void delete_all_projects(Box<Project> project_box) async {
  await project_box.deleteAll(project_box.keys);
}

/// Adds an [amount] to the allocated budget for a specific [project].
///
/// If the [amount] is a negative number [negativeAllocationException] is thrown. If [amount] is
/// is greater than the goal for the [project] then [allocatedGreaterThanGoalException] is thrown.
/// If [amount] is greater than the amount of available budget unallocated [lackOfAvailableBudget]
/// is thrown.
void add_to_allocated(Box<Project> project_box, Box<double> budget_box, int id, double amount) {
  if (amount < 0) {
    throw negativeAllocationException('Allocated amount of R$amount cannot be negative');
  }

  var project = project_box.get(id);

  if (amount > project!.goal) {
    throw allocatedGreaterThanGoalException('Cannot allocate R$amount to a project with goal: '
        'R${project.goal}');
  }

  var budget = budget_box.get(globals.budget_key);
  var allocated = budget_box.get(globals.allocated_key);

  budget ??= 0;
  allocated ??= 0;

  if ((budget - allocated) < amount) {
    throw lackOfAvailableBudget('Not enough available budget to allocate.'
        '\nAvailable budget: R${budget-allocated}');
  }

  allocated += amount;
  budget_box.put(globals.allocated_key, allocated);

  project.add_allocated(amount);
  project.save();
}

/// Assigns the goal project with the given [name] to [new_goal] and saves the affects to the
void edit_goal(Box<Project> project_box, Box<double> budget_box, int id, double new_goal) {
  var project = project_box.get(id);

  var required = budget_box.get(globals.required_key);
  required ??= 0;
  required = (required - project!.goal) + new_goal;
  budget_box.put(globals.required_key, required);

  project.goal = new_goal;
  project.save();
}