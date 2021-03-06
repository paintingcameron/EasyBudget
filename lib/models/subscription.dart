import 'package:hive/hive.dart';
import 'package:easybudget/tools/generalTools.dart';

part 'subscription.g.dart';

@HiveType(typeId: 2)
class Subscription extends HiveObject {
  @HiveField(0)
  late String _name;
  @HiveField(1)
  late String _desc;
  @HiveField(2)
  late double _amount;
  @HiveField(3)
  late int _period;
  @HiveField(4)
  late String _type;
  @HiveField(5)
  late DateTime _startDate;
  @HiveField(6)
  late DateTime _lastPaid;
  @HiveField(7)
  late bool _paused;
  @HiveField(8)
  late bool _initPay;

  Subscription(this._name, this._desc, this._amount, this._period, this._type,
      this._startDate, this._lastPaid, this._paused, this._initPay);

  Subscription.newSub(String name, String desc, double amount, DateTime startDate,
      int period, String type) {
    _name = name;
    _desc = desc;
    _amount = amount;
    _type = type;
    _startDate = startDate;
    _period = period;
    _lastPaid = startDate.clone();

    _paused = false;
    _initPay = false;
  }

  String get name => _name;
  String get desc => _desc;
  double get amount => _amount;
  DateTime get startDate => _startDate;
  bool get paused => _paused;
  int get period => _period;
  String get type => _type;
  DateTime get lastPaid => _lastPaid;

  set pause(bool pause) {
    this._paused = pause;
    this.save();
  }

  DateTime nextPayment() {
    if (!_initPay) {
      return _startDate;
    }
    switch(_type) {
      case 'day':
        return _lastPaid.add(Duration(days: _period));
      case 'week':
        return _lastPaid.add(Duration(days: _period*7));
      case 'month':
        int moreMonths = _lastPaid.month + _period;
        return DateTime(_lastPaid.year + moreMonths~/12 , moreMonths%12, _lastPaid.day);
      default:
        return DateTime(_lastPaid.year+_period, _lastPaid.month, _lastPaid.day);
    }
  }

  bool paymentDue(DateTime now) {
    if (_paused) return false;

    if (_initPay) {
      DateTime nextPay = this.nextPayment();
      return nextPay.equal(now) || nextPay.isBefore(now);
    } else {
      return _startDate.equal(now) || _startDate.isBefore(now);
    }
  }

  void makePayment() {
    _lastPaid = nextPayment();

    if (!_initPay) {
      _initPay = true;
    }

    this.save();
  }
}