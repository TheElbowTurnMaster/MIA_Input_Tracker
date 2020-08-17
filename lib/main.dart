import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miatracker/DailyGoalsTab/AddHours.dart';
import 'package:miatracker/DailyGoalsTab/ProgressListWidget.dart';
import 'package:miatracker/DrawerMenu.dart';
import 'package:flutter/services.dart';
import 'package:miatracker/Models/InputHoursUpdater.dart';
import 'package:miatracker/Models/Lifecycle.dart';
import 'package:miatracker/Models/shared_preferences.dart';
import 'package:miatracker/StatsTab/stats_settings_page.dart';
import 'Map.dart';
import 'Models/category.dart';
import 'Models/auth.dart';
import 'package:miatracker/signInPage.dart';
import 'package:provider/provider.dart';
import 'Models/user.dart';

import 'LogsTab/MultiInputLog.dart';
import 'StatsTab/StatisticsSummaryWidget.dart';
import 'anti_scroll_glow.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferencesHelper.instance.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MultiProvider(
      providers: [
        StreamProvider<bool>.value(value: AuthService.instance.loading),
        StreamProvider<FirebaseUser>.value(
            value: FirebaseAuth.instance.onAuthStateChanged),
        ChangeNotifierProvider<SharedPreferencesHelper>.value(
            value: SharedPreferencesHelper.instance),
      ],
      child: MaterialApp(
        builder: (context, child) {
          return ScrollConfiguration(
            behavior: MyBehavior(),
            child: child,
          );
        },
        title: 'MIA Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: SignInPage(),
      ),
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

  final pageNames = ["Daily Goals", "Media", "Statistics", "Log"];

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
    var user = Provider.of<AppUser>(context);
    user ??= AppUser();

    return Scaffold(
      appBar: AppBar(
        title: Text(pageNames[selectedIndex]),
        automaticallyImplyLeading: false,
        leading: (selectedIndex == 2) ? FlatButton(
          child: Icon(Icons.tune, color: Colors.white),
          onPressed: () =>
              Navigator.of(context).push(createSlideRoute(StatsSettingsPage())),
        ) : null,
      ),
      body: Center(
        child: IndexedStack(
          index: selectedIndex,
          children: <Widget>[
            ProgressListWidget(),
            Container(),
            StatisticsSummaryWidget(),
            MultiInputLog(),
          ],
        ),
      ),
      endDrawer: DrawerMenu(),
      bottomNavigationBar: PageStorage(
        bucket: bucket,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              title: Text('Daily Goals'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.movie),
              title: Text('Media'),
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
            Navigator.of(context).push(createSlideRoute(AddHours(
              user,
              user.categories,
              initialSelectionIndex: 0,
            )));
          },
        ),
      ),
    );
  }
}
