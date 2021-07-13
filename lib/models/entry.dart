import 'package:hive/hive.dart';

part 'entry.g.dart';

@HiveType(typeId: 1)
class Entry extends HiveObject {
  @HiveField(0)
  late double _amount;
  @HiveField(1)
  late String _desc;
  @HiveField(2)
  late DateTime _date_created;

  Entry.newEntry(double amount, String desc) {
    _amount = amount;
    _desc = desc;
    _date_created = DateTime.now();
  }

  Entry(this._amount, this._desc, this._date_created);

  DateTime get date_created => _date_created;

  String get desc => _desc;

  double get amount => _amount;
}