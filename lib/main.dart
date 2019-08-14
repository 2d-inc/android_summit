import 'package:flutter/material.dart';
import 'example_progress_action.dart';
import 'progress_reporting_action.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
            padding: const EdgeInsets.all(20),
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
                  width: 150,
                  height: 150,
                  child: action != null
                      ? ValueListenableBuilder<double>(
                          builder: (context, value, _) {
                            return Container(
                                child: Center(
                                  child: Text(
                                    "Progress: ${(value * 100).round()}%",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                color: value == 1 ? Colors.green : Colors.blue);
                          },
                          valueListenable: action.progress,
                        )
                      : Container(color: Colors.red),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
