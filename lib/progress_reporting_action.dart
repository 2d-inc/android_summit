import 'package:flutter/material.dart';

abstract class ProgressReportingAction {
  final ValueNotifier<double> progress = ValueNotifier<double>(0);
  bool get isComplete => progress.value == 1;
}
