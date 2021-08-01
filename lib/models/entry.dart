import 'package:hive/hive.dart';

part 'entry.g.dart';

@HiveType(typeId: 1)
class Entry extends HiveObject {
  @HiveField(0)
  late double _amount;
  @HiveField(1)
  late String _desc;
  @HiveField(2)
  late DateTime _dateCreated;

  Entry.newEntry(double amount, String desc) {
    _amount = amount;
    _desc = desc;
    _dateCreated = DateTime.now();
  }

  Entry(this._amount, this._desc, this._dateCreated);

  DateTime get dateCreated => _dateCreated;

  String get desc => _desc;

  double get amount => _amount;

  @override
  String toString() {
    return 'Entry:'
        '\n\t Description:\t$desc'
        '\n\t Amount:\t$amount';
  }
}