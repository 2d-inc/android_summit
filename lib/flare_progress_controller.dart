import 'dart:math';

import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_controller.dart';

import 'progress_reporting_action.dart';

enum _ProgressState { idle, start, inProgress, complete }

class FlareProgressController extends FlareController {
  ActorAnimation _idle;
  ActorAnimation _start;
  ActorAnimation _indeterminate;
  ActorAnimation _determinate;
  ActorAnimation _complete;

  _ProgressState _state;
  _ProgressState _nextState;

  double _progressValue = 0;
  double _time = 0;
  
  ProgressReportingAction _action;
  ProgressReportingAction get action => _action;
  set action(ProgressReportingAction value) {
    if (_action == value) {
      return;
    }

    _action = value;
    syncState();

    isActive.value = true;
  }

  void syncState() {
    if (_action != null) {
      _time = 0;
      _state = _ProgressState.idle;
      _progressValue = 0;
      if (_action.isComplete) {
        _state = _ProgressState.complete;
        if (_complete != null) {
          _time = _complete.duration;
        }
      } else {
        _nextState = _ProgressState.start;
      }
    }
  }

  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    _time += elapsed;
    ActorAnimation currentAnimation;
    switch (_state) {
      case _ProgressState.idle:
        currentAnimation = _idle;
        break;
      case _ProgressState.start:
        currentAnimation = _start;
        _nextState = _ProgressState.inProgress;
        break;
      case _ProgressState.inProgress:
        currentAnimation = _indeterminate;
        if (_action != null) {
          _progressValue +=
              (_action.progress.value - _progressValue) * min(1, elapsed * 5);
          if (_action.progress.value >= 1 && _progressValue >= 0.99) {
            _nextState = _ProgressState.complete;
          }

          if (_determinate != null) {
            _determinate.apply(
                _determinate.duration * _progressValue, artboard, 1);
          }
        }
        break;
      case _ProgressState.complete:
        currentAnimation = _complete;
        break;
    }

    if (currentAnimation != null) {
      currentAnimation.apply(
          currentAnimation.isLooping
              ? _time % currentAnimation.duration
              : _time,
          artboard,
          1);
    }

    if (_nextState != null && _time >= (currentAnimation?.duration ?? 0)) {
      _state = _nextState;
      _nextState = null;
      if (currentAnimation != null) {
        _time = currentAnimation.duration != 0
            ? _time % currentAnimation.duration
            : 0;
      } else {
        _time = 0;
      }
    }

    if (currentAnimation != null && currentAnimation.isLooping) {
      _time %= currentAnimation.duration;
    }

    return true;
  }

  @override
  void initialize(FlutterActorArtboard artboard) {
    _idle = artboard.getAnimation("Idle");
    _start = artboard.getAnimation("Start");
    _indeterminate = artboard.getAnimation("Indeterminate");
    _determinate = artboard.getAnimation("Determinate");
    _complete = artboard.getAnimation("Complete");

    _idle?.apply(0, artboard, 1);

    syncState();
  }

  @override
  void setViewTransform(Mat2D viewTransform) {}
}
