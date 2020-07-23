import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miatracker/DailyGoalsTab/AddHours.dart';
import 'package:miatracker/DailyGoalsTab/ProgressListWidget.dart';
import 'package:miatracker/Models/DataStorageHelper.dart';
import 'package:miatracker/DrawerMenu.dart';
import 'package:flutter/services.dart';
import 'package:miatracker/Models/InputHoursUpdater.dart';
import 'package:miatracker/Models/Lifecycle.dart';

import 'LogsTab/MultiInputLog.dart';
import 'StatsTab/StatisticsSummaryWidget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataStorageHelper().init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MaterialApp(
      title: 'MIA Tracker',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Immersion Tracker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);


  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final bucket = PageStorageBucket();
  int selectedIndex = 0;
  bool visible = true;

  final pageNames = ["Daily Goals", "Statistics", "Log"];

  onItemTap(int index) {
    setState(() {
      selectedIndex = index;
      if (index != 0)
        visible = false;
      else
        visible = true;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addObserver(LifecycleEventHandler(resumeCallBack: () async {
      InputHoursUpdater.ihu.resumeUpdate();
    }));
  }

  @override
  Widget build(BuildContext context) {
    //DataStorageHelper().deleteAllInputEntries();
    //DataStorageHelper().resetAllHours();

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(pageNames[selectedIndex]),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: IndexedStack(
          index: selectedIndex,
          children: <Widget>[
//            ReorderableListView(
//              onReorder: ,
//              children: List.generate(DataStorageHelper().categoryNames.length + 1, (index) {
//                if(index == DataStorageHelper().categoryNames.length) return SizedBox(height: 200);
//                else return GlobalProgressWidget(DataStorageHelper().categories[index]);
//              }),
//            ),
            ProgressListWidget(),
            StatisticsSummaryWidget(),
            MultiInputLog(),
          ],
        ),
      ),
      endDrawer: DrawerMenu(),
      bottomNavigationBar: PageStorage(
        bucket: bucket,
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text('Daily Goals'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              title: Text('Stats'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              title: Text('Log'),
            ),
          ],
          currentIndex: selectedIndex,
          onTap: onItemTap,
        ),
      ),
      floatingActionButton: Visibility(
        visible: visible,
        child: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddHours()),
            );
          },
        ),
      ),
    );
  }

  _onReorder(int index1, int index2) {

  }

}
