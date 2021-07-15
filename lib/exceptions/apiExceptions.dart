class keyDoesNotExistException implements Exception {
  String cause;
  keyDoesNotExistException(this.cause);
}

class negativeAllocationException implements Exception {
  String cause;
  negativeAllocationException(this.cause);
}

class lackOfAvailableBudget implements Exception {
  String cause;
  lackOfAvailableBudget(this.cause);
}

class allocatedGreaterThanGoalException implements Exception {
  String cause;
  allocatedGreaterThanGoalException(this.cause);
}

class negativeBudgetException implements Exception {
  String cause;
  negativeBudgetException(this.cause);
}