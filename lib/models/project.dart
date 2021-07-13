import 'package:hive/hive.dart';

part 'project.g.dart';

@HiveType(typeId: 0)
class Project extends HiveObject {
  @HiveField(0)
  String _name;
  @HiveField(1)
  String _desc;
  @HiveField(2)
  double _goal;
  @HiveField(3)
  late double _allocated;
  @HiveField(4)
  late bool _bought;

  Project(this._name, this._desc, this._goal, {allocated = 0.0, bought = false}) {
    _allocated = allocated;
    _bought = bought;
  }

  void add_allocated(double amount) => _allocated += amount;

  set bought(bool value) {
    _bought = value;
  }

  set allocated(double value) {
    _allocated = value;
  }

  set goal(double goal) {
    _goal = goal;
  }

  bool get bought => _bought;

  double get allocated => _allocated;

  double get goal => _goal;

  String get desc => _desc;

  String get name => _name;

  @override
  String toString() {
    return 'Project:'
        '\n  Name:\t\t\t$_name'
        '\n  Desc:\t\t\t$_desc'
        '\n  Goal:\t\t\t$_goal'
        '\n  Allocated:\t$_allocated'
        '\n  Bought:\t\t$_bought';
  }

}