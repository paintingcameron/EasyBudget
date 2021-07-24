import 'package:hive/hive.dart';

part 'project.g.dart';

@HiveType(typeId: 0)
class Project extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  String desc;
  @HiveField(2)
  double goal;
  @HiveField(3)
  late double allocated;
  @HiveField(4)
  late bool bought;
  @HiveField(5)
  late DateTime dateCreated;

  Project(this.name, this.desc, this.goal, {allocated = 0.0, bought = false}) {
    this.allocated = allocated;
    this.bought = bought;
    this.dateCreated = DateTime.now();
  }

  void addAllocated(double amount) => allocated += amount;
  
  @override
  String toString() {
    return 'Project:'
        '\n  Name:\t\t\t$name'
        '\n  Desc:\t\t\t$desc'
        '\n  Goal:\t\t\t$goal'
        '\n  Allocated:\t$allocated'
        '\n  Bought:\t\t$bought';
  }

}