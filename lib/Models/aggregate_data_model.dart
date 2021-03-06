
import '../Map.dart';
import 'dart:math' as math;

import 'InputEntry.dart';

class DailyInputEntry {
  DateTime dateTime;
  Map<String, dynamic> categoryHours;
  List<InputEntry> inputEntries;

  DailyInputEntry({this.dateTime, this.categoryHours, this.inputEntries}) {
    this.dateTime = daysAgo(0, dateTime);
  }

  factory DailyInputEntry.fromMap(Map<String, dynamic> map) {
    if(map == null) return null;

    List<InputEntry> tempList = [];
    try {
      tempList = List<InputEntry>.from(map['inputEntries'].map((i) => InputEntry.fromMap(i)));
    } catch (e) {
    }

    return DailyInputEntry(
    dateTime: (map['dateTime'] != null) ? map['dateTime'].toDate().toUtc() : null,
    categoryHours: map['categoryHours'] ?? {},
    inputEntries: tempList,
  );
  }

  Map<String, dynamic> toMap() {
    var tempList = [];
    try {
      tempList = List<dynamic>.from(inputEntries.map((e) => e.toMap()));
    } catch (e) {print(e);}

    return {
    "dateTime": dateTime,
    "categoryHours": categoryHours,
    'inputEntries': tempList,
  };
  }

  @override
  bool operator ==(other) {
    return other is DailyInputEntry && sameDay(dateTime, other.dateTime);
  }

  @override
  int get hashCode => dateTime.hashCode;

}