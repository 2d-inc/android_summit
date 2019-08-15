import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'flare_progress_controller.dart';
import 'progress_reporting_action.dart';

class LiquidProgress extends StatefulWidget {
  final ProgressReportingAction action;
  const LiquidProgress(this.action);

  @override
  _LiquidProgressState createState() => _LiquidProgressState();
}

class _LiquidProgressState extends State<LiquidProgress> {
  final FlareProgressController _controller = FlareProgressController();

  @override
  void initState() {
	  super.initState();
	  _controller.action = widget.action;
  }

  @override
  void didUpdateWidget(LiquidProgress oldWidget) {
    _controller.action = widget.action;
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlareActor(
      "assets/Liquid Download.flr",
      controller: _controller,
      fit: BoxFit.contain,
      alignment: Alignment.center,
    );
  }
}
