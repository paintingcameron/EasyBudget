// String formatDate(DateTime date) {
//   String month;
//   String day;
//   month = '${(date.month < 10) ? '0' : ''}${date.month}';
//   day = '${(date.day < 10) ? '0' : ''}${date.day}';
//
//   return '${date.year}-$month-$day';
// }
//
// String prettifyDate(DateTime date) {
//   return '${date.day}/${date.month}/${date.year}';
// }

extension DateExtensions on DateTime {
  bool equal(DateTime date) {
    return this.year == date.year && this.month == date.month && this.day == date.day;
  }

  DateTime clone() {
    return DateTime(this.year, this.month, this.day);
  }
}