import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'example_progress_action.dart';
import 'liquid_progress.dart';
import 'progress_reporting_action.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color.fromRGBO(48, 109, 211, 1)),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<ProgressReportingAction> progressActions =
      List.filled(100, null, growable: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: progressActions.length,
        itemBuilder: (context, index) {
          final action = progressActions[index];
          return Padding(
            padding: const EdgeInsets.all(0),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    ExampleProgressAction action = ExampleProgressAction();
                    progressActions[index] = action;
                    action.start();
                  });
                },
                child: Container(
                  width: 200,
                  height: 200,
                  child: LiquidProgress(action),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
