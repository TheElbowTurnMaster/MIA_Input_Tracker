import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miatracker/Map.dart';
import 'package:miatracker/Models/GoalEntry.dart';
import 'dart:math' as math;
import 'package:miatracker/Models/database.dart';
import 'package:miatracker/new_category_dialog.dart';
import 'package:provider/provider.dart';
import 'Models/user.dart';

import 'LogsTab/ConfirmDialog.dart';

class GoalsPageWidget extends StatefulWidget {
  @override
  _GoalsPageWidgetState createState() => _GoalsPageWidgetState();
}

class _GoalsPageWidgetState extends State<GoalsPageWidget> {
  Map<Category, TextEditingController> controllersMap;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    AppUser user = Provider.of<AppUser>(context);
    if(user == null) return Scaffold(
      appBar: AppBar(
        title: Text("Something went wrong"),
      ),
      body: Center(
        child: Text(
          '$user'
        ),
      ),
    );

    final controllers = List.generate(
        user.categories.length, (i) {
          var controller = TextEditingController();
          controller.text = convertToDisplay(user.categories[i].goalAmount ?? 0, user.categories[i].isTimeBased);
          return controller;
        });
    controllersMap = Map.fromIterables(user.categories, controllers);

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text("Daily Target"),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 6,
                  child: Text(
                    'Category',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    'Daily Goal',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Input Type',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 6,
            child: Form(
              autovalidate: false,
              key: _formKey,
              child: ListView.builder(
                itemCount: math.min(user.categories.length + 1, 8),
                itemBuilder: (context, index) {
                  if (index == user.categories.length) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FlatButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.add,
                              color: Colors.grey,
                            ),
                            Text(
                              "Add New Category",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        onPressed: () async {
                          Category category = await showDialog(context: context, child: NewCategoryDialog()) ?? Category();
                          if (category.name != null && category.name != '' && category.isTimeBased != null)
                            DatabaseService.instance.updateCategories(user, category:category, isDelete: false);
                        },
                      ),
                    );
                  }
                  return Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0),
                    child: Dismissible(
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
                      confirmDismiss: (direction) async {
                        return await asyncConfirmDialog(context,
                            title: 'Confirm Delete',
                            description:
                            'Delete category? Logs of this category will remain but will not be visible in the home page or graphs.');
                      },
                      onDismissed: (direction) async {
                        DatabaseService.instance
                            .updateCategories(user, category: user.categories[index], isDelete: true);
                      },
                      key: UniqueKey(),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 6,
                            child: Text(
                              "${user.categories[index].name}",
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: TextFormField(
                              controller:
                              controllersMap[user.categories[index]],
                              keyboardType: (user.categories[index].isTimeBased) ? TextInputType.datetime : TextInputType.numberWithOptions(signed: false, decimal: false),
                              decoration: InputDecoration(
                                labelText: (user.categories[index].isTimeBased) ? 'HH:mm' : '#',
                              ),
                              validator: (value) {
                                var result;
                                if(user.categories[index].isTimeBased) {
                                  result = parseTime(value);
                                } else {
                                  result = int.tryParse(value);
                                }
                                if(result == null) return 'Incorrect Format';
                                else return null;
                              },
                            ),
                          ),

                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                (user.categories[index].isTimeBased
                                    ? 'Time'
                                    : 'Quantity'),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 30, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    RaisedButton(
                      child: Text("Cancel"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    RaisedButton(
                      child: Text(
                        "Save",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () {
                        if(_formKey.currentState.validate()) {
                          controllersMap.forEach((k, v) {
                            try {
                              final value = (k.isTimeBased) ? parseTime(v.text) : double.tryParse(v.text);
                              if (value != null) {
                                DatabaseService.instance.addGoalEntry(
                                    user,
                                    GoalEntry.now(
                                        inputType: k.name, amount: value));
                              }
                            } on FormatException {
                              print("get yeeted on by doubles");
                            }
                          });
                          Navigator.pop(context);
                        }
                      },
                      color: Colors.blue,
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if(controllersMap != null)
      controllersMap.forEach((k, v) {
        v.dispose();
      });
    super.dispose();
  }

}
