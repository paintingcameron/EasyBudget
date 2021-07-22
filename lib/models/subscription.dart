import 'package:hive/hive.dart';

part 'subscription.g.dart';

enum PeriodTypes {
  Daily,
  Weekly,
  Monthly,
  Annually
}

@HiveType(typeId: 2)
class Subscription extends HiveObject {
  @HiveField(0)
  late String _name;
  @HiveField(1)
  late String _desc;
  @HiveField(2)
  late double _amount;
  @HiveField(3)
  late var _period;   //(type is Daily or Weekly) ? Duration : int
  @HiveField(4)
  late PeriodTypes _type;
  @HiveField(5)
  late DateTime _startDate;
  @HiveField(6)
  late DateTime _lastPaid;
  @HiveField(7)
  late bool _paused;

  Subscription(this._name, this._desc, this._amount, this._period, this._type,
      this._startDate, this._lastPaid, this._paused);

  Subscription.newSub(String name, String desc, double amount, DateTime startDate,
      int period, PeriodTypes type) {
    _name = name;
    _desc = desc;
    _amount = amount;
    _type = type;
    _startDate = startDate;

    _paused = true;

    switch (type) {
      case PeriodTypes.Daily:
        _period = Duration(days: period);
        break;
      case PeriodTypes.Weekly:
        _period = Duration(days: period*7);
        break;
      case PeriodTypes.Monthly:
      case PeriodTypes.Annually:
        _period = _period;
    }
  }

  String get name => _name;
  String get desc => _desc;
  double get amount => _amount;
  DateTime get startDate => _startDate;
  bool get paused => _paused;

  set pause(bool pause) {
    this._paused = pause;
    this.save();
  }

  bool paymentDue(DateTime now) {
    if (_paused) return false;

    switch (_type) {
      case PeriodTypes.Daily:
      case PeriodTypes.Weekly:
        return _lastPaid.add(_period).isBefore(now);
      case PeriodTypes.Monthly:
        return DateTime(_lastPaid.year, _lastPaid.month+1, _lastPaid.day).isBefore(now);
      case PeriodTypes.Annually:
        return DateTime(_lastPaid.year+1, _lastPaid.month, _lastPaid.day).isBefore(now);
    }
  }

  void makePayment() {
    switch (_type) {
      case PeriodTypes.Daily:
      case PeriodTypes.Weekly:
        _lastPaid = _lastPaid.add(_period);
        break;
      case PeriodTypes.Monthly:
        if (_lastPaid.month == 12) {
          _lastPaid = DateTime(_lastPaid.year+1, 1, _lastPaid.day);
        } else {
          _lastPaid = DateTime(_lastPaid.year, _lastPaid.month+1, _lastPaid.day);
        }
        break;
      case PeriodTypes.Annually:
        _lastPaid = DateTime(_lastPaid.year+1, _lastPaid.month, _lastPaid.day);
    }
  }
}