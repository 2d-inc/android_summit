import 'package:flutter/material.dart';

abstract class ProgressReportingAction {
  ValueNotifier<double> progress = ValueNotifier<double>(0);
  void start();
}
