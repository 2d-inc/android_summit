import 'dart:async';
import 'dart:math';

import 'progress_reporting_action.dart';

class ExampleProgressAction extends ProgressReportingAction {
  Timer _timer;
  final Random rand = Random();
  void start() {
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      progress.value = min(1, progress.value + rand.nextDouble() * 0.07);
      if (progress.value == 1) {
        _timer.cancel();
      }
    });
  }
}