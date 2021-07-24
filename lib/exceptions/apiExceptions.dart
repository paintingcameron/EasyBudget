import 'package:easybudget/models/subscription.dart';

class KeyDoesNotExistException implements Exception {
  String cause;
  KeyDoesNotExistException(this.cause);
}

class NegativeAllocationException implements Exception {
  String cause;
  NegativeAllocationException(this.cause);
}

class LackOfAvailableBudget implements Exception {
  String cause;
  LackOfAvailableBudget(this.cause);
}

class AllocatedGreaterThanGoalException implements Exception {
  String cause;
  AllocatedGreaterThanGoalException(this.cause);
}

class NegativeBudgetException implements Exception {
  String cause;
  NegativeBudgetException(this.cause);
}

class StoppedSubscriptionsException implements Exception {
  String cause;
  List<Subscription> subsList;
  StoppedSubscriptionsException(this.cause, this.subsList);
}