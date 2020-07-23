import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class Category {
  final String name;

  Category({@required this.name});

  @override
  bool operator ==(covariant Category o) {
    return name == o.name;
  }

  @override
  int get hashCode => name.hashCode;
}

String getMonth(int month) {
  Map<int,String> months = {
    1:'Jan',
    2:'Feb',
    3:'Mar',
    4:'Apr',
    5:'May',
    6:'Jun',
    7:'Jul',
    8:'Aug',
    9:'Sep',
    10:'Oct',
    11:'Nov',
    12:'Dec',
  };

  return months[month];
}

String getDay(int weekday) {
  Map<int,String> days = {
    1:'Mon',
    2:'Tue',
    3:'Wed',
    4:'Thurs',
    5:'Fri',
    6:'Sat',
    7:'Sun',
  };
  return days[weekday];
}

String getDate(DateTime date, {bool showDay, bool showYear, bool showMonth}) {
  String year = '';
  year = (showYear ?? true) ? ', ${date.year}' : '';
  if((showMonth ?? true) && (showYear ?? true) && !(showDay ?? true))
    year = date.year.toString();
  int month = date.month;
  String day = (showDay ?? true) ? '${date.day}' : '';

  return '${(showMonth ?? true) ? getMonth(month) + ' ' : ''}$day$year'.trim();
}


int daysBetween(DateTime d1, DateTime d2) {
  d1 = DateTime.utc(d1.year, d1.month, d1.day);
  d2 = DateTime.utc(d2.year, d2.month, d2.day);
  return d1.difference(d2).inDays.abs();
}

bool sameDay(DateTime date, DateTime date2) {
  return (date.year == date2.year) && (date.month == date2.month) && (date.day == date2.day);
}

DateTime daysAgo(int days, [DateTime dateTime]) {
  dateTime = dateTime ?? DateTime.now();
  return DateTime(dateTime.year, dateTime.month, dateTime.day - days);
}

DateTime monthsAgo(int months, [DateTime dateTime]) {
  dateTime = dateTime ?? DateTime.now();
  return DateTime(dateTime.year, dateTime.month - months, 1);
}

class UsefulShit {

  UsefulShit._();

  static final doubleDecimalFormat = NumberFormat("0.00");
  static final leadingZeroFormat = NumberFormat("00");

  static String convertToTime(double time) {
    int hours = time.floor();
    int minutes = ((time % 1) * 60).round();

    return '$hours:${leadingZeroFormat.format(minutes)}';
  }
}