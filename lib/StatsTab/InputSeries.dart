import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:miatracker/Models/InputHoursUpdater.dart';
import 'package:miatracker/Models/TimeFrameModel.dart';
import 'package:miatracker/Models/aggregate_data_model.dart';
import 'package:miatracker/Models/user.dart';
import 'package:provider/provider.dart';
import '../Models/user.dart' as model;
import '../Models/InputEntry.dart';
import '../Map.dart';

class InputChart extends StatelessWidget {
  final bool isTimeBased;

  final List<bool> choiceArray;

  InputChart({@required this.choiceArray, this.isTimeBased = true});

  @override
  Widget build(BuildContext context) {
    AppUser user = Provider.of<AppUser>(context);
    var dateTimes = Provider.of<TimeFrameModel>(context);

    Map<DateTime, DailyInputEntry> entries =
        Provider.of<Map<DateTime, DailyInputEntry>>(context);
    if (user == null || entries == null) return Center(child: CircularProgressIndicator());

    List<model.Category> categories = user.categories
        .where((element) => element.isTimeBased == isTimeBased)
        .toList();

    List<LineChartBarData> series = [];

    for (int i = categories.length - 1; i >= 0; i--) {
      if (choiceArray[i]) {
        List<FlSpot> inputSeriesList = [];
        for (int j = 0;
            j <
                daysBetween(dateTimes.dateStartEndTimes[0],
                    dateTimes.dateStartEndTimes[1]);
            j++) {
          double hours = 0;
          if (entries[daysAgo(-j, dateTimes.dateStartEndTimes[0])] != null &&
              entries[daysAgo(-j, dateTimes.dateStartEndTimes[0])]
                      .categoryHours[categories[i].name] !=
                  null) {
            hours = math.max(
                0,
                entries[daysAgo(-j, dateTimes.dateStartEndTimes[0])]
                    .categoryHours[categories[i].name]);
          }
          inputSeriesList.add(FlSpot(j.toDouble(), hours));
        }

        series.add(LineChartBarData(
            spots: inputSeriesList,
            colors: [categories[i].color],
            dotData: FlDotData(show: false)));
      }
    }
    if (series.length == 0) return Container();
    var maxValue = getMaxValue(series);

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          enabled: false,
        ),
        maxY: math.max((maxValue * 2).ceilToDouble()/2 + .25, 1.25),
          gridData: FlGridData(
              show: true, drawHorizontalLine: true, horizontalInterval: getTicksFromMaxValue(maxValue)),
          titlesData: FlTitlesData(
            bottomTitles: _getXAxis(series, dateTimes.dateStartEndTimes),
            leftTitles: SideTitles(
              reservedSize: isTimeBased ? 25 : 10,
              showTitles: true,
              interval: getTicksFromMaxValue(maxValue),
              getTitles: (value) {
                return convertToDisplay(value, isTimeBased);
              },
              checkToShowTitle: (minValue, maxValue, sideTitles, appliedInterval, value) => (value % 0.5 == 0),
            ),
          ),
          borderData: FlBorderData(
            border: Border(
              bottom: BorderSide(width: 1, color: Colors.grey),
            ),
          ),
          lineBarsData: series),
      swapAnimationDuration: Duration(milliseconds: 0),
    );
  }

  double getTicksFromMaxValue(double maxValue) {
    if(!isTimeBased) return 1;
    if(maxValue >= 5) return 1;
    else if(maxValue >= 4) return 0.5;
    else return 0.25;
  }

  double getMaxValue(List<LineChartBarData> series) {
    return series
        .map((series) => series.spots.map((e) => e.y).reduce(math.max))
        .reduce(math.max);
  }

  SideTitles _getXAxis(
      List<LineChartBarData> lineChartDataList, List<DateTime> startEndPoints) {
    var tickProvider;
    var tickFormatter;

    switch (TimeFrameModel().selectedTimeSpan) {
      case TimeSpan.HalfYear:
        tickProvider =
            (minValue, maxValue, sideTitles, appliedInterval, value) {
          return daysAgo(-value.toInt(), TimeFrameModel().dateStartEndTimes[0])
                  .day ==
              1;
        };
        tickFormatter = (value) {
          DateTime date =
              daysAgo(-value.toInt(), TimeFrameModel().dateStartEndTimes[0]);
          return '${getDate(date, showYear: false, showDay: false)}\n${getDate(date, showYear: true, showMonth: false, showDay: false).substring(2)}';
        };
        break;
      case TimeSpan.Month:
        tickProvider =
            (minValue, maxValue, sideTitles, appliedInterval, value) {
          return (value + 1) % 7 == 0 || value == 0;
        };
        tickFormatter = (value) {
          DateTime date =
              daysAgo(-value.toInt(), TimeFrameModel().dateStartEndTimes[0]);
          return '${getDate(date, showYear: false)}';
        };
        break;
      case TimeSpan.Week:
        tickFormatter = (value) {
          DateTime date =
              daysAgo(-value.toInt(), TimeFrameModel().dateStartEndTimes[0]);
          return '${getDate(date, showYear: false)}\n${getDay(date.weekday)}';
        };
        break;
    }

    return SideTitles(
      reservedSize: 10,
      showTitles: true,
      interval: 1,
      checkToShowTitle: tickProvider,
      getTitles: tickFormatter,
    );
  }
}
