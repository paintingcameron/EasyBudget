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
  @HiveField(3)
  late int _subID;

  Entry.newEntry(double amount, String desc, DateTime created, {subID = -1}) {
    _amount = amount;
    _desc = desc;
    _dateCreated = created;
    _subID = subID;
  }

  Entry(this._amount, this._desc, this._dateCreated, this._subID);

  DateTime get dateCreated => _dateCreated;
  String get desc => _desc;
  double get amount => _amount;
  int get subID => _subID;

  @override
  String toString() {
    return 'Entry:'
        '\n\t Description:\t$desc'
        '\n\t Amount:\t$amount'
        '\n\t Created: \t$_dateCreated'
        '\n\t SubID: \t$_subID';
  }
}