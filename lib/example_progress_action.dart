import 'dart:async';
import 'dart:math';

import 'progress_reporting_action.dart';

class ExampleProgressAction extends ProgressReportingAction {
  Timer _timer;
  final Random rand = Random();
  @override
  void start() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      progress.value = min(1, progress.value + rand.nextDouble() * 0.2);
      if (progress.value == 1) {
        _timer.cancel();
      }
    });
  }
}
