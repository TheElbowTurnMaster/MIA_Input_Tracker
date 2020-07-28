import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:miatracker/LogsTab/ConfirmDialog.dart';
import 'package:miatracker/Models/DataStorageHelper.dart';
import 'package:miatracker/Models/Entry.dart';
import 'package:miatracker/Models/GoalEntry.dart';
import 'package:miatracker/Models/InputHoursUpdater.dart';
import 'package:provider/provider.dart';

import '../Models/InputEntry.dart';
import '../Map.dart';

class InputLog extends StatelessWidget {
  final durationFormat = NumberFormat("0.0");
  final DateTime dateTime;

  InputLog({this.dateTime});

  @override
  Widget build(BuildContext context) {
    final providedGoalEntries = Provider.of<List<GoalEntry>>(context);
    final providedInputEntries = Provider.of<List<InputEntry>>(context);

    if(providedInputEntries == null || providedGoalEntries == null)
      return Container();

    final goalEntries = Filter.filterEntries(providedGoalEntries,
        startDate: dateTime, endDate: daysAgo(-1, dateTime));
    final inputEntries = Filter.filterEntries(providedInputEntries,
        startDate: dateTime, endDate: daysAgo(-1, dateTime));

    List<Entry> compiled = [];
    compiled.addAll(goalEntries);
    compiled.addAll(inputEntries);
    compiled.sort();

    return ListView.builder(
        itemCount: compiled.length,
        itemBuilder: (context, index) {
          final entry = compiled[index];

          String subtitleText = '';
          if (entry is InputEntry) {
            subtitleText = entry.description;
          }
          final goalText = "Set daily goal to ";

          if (entry is GoalEntry) {
            return Card(
                child: Container(
                  color: Color.fromRGBO(235, 235, 235, 1),
                  child: ListTile(
                    subtitle: Text(subtitleText),
                    leading: Text(
                      entry.inputType.name,
                      style: TextStyle(
                        color: Color.fromRGBO(140, 140, 140, 1),
                      ),
                    ),
                    title: Text(
                      '$goalText${convertToTime(entry.amount)}',
                      style: TextStyle(
                        color: Color.fromRGBO(140, 140, 140, 1),
                      ),
                    ),
                    trailing: Text(
                      entry.time,
                      style: TextStyle(
                        color: Color.fromRGBO(140, 140, 140, 1),
                      ),
                    ),
                  ),
                ));
          }

          return Dismissible(
            direction: DismissDirection.endToStart,
            background: Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              alignment: AlignmentDirectional.centerEnd,
              color: Colors.red,
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            key: UniqueKey(),
            confirmDismiss: (disDirection) async {
              return await asyncConfirmDialog(context, title: "Confirm Delete", description: 'Delete entry? This action cannot be undone');
            },
            onDismissed: (dis) {
              DataStorageHelper()
                  .deleteEntry(compiled[index]);
            },
            child: Card(
                child: ListTile(
                  subtitle: Text(subtitleText),
                  leading: Text(
                    entry.inputType.name,
                  ),
                  title: Text('${convertToTime(entry.amount)}'),
                  trailing: Text(entry.time),
                )),
          );
        });
  }
}
