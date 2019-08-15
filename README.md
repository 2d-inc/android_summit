# Android Summit

# Intro

We're going to show you how to build a determinate and indeterminate progress animation with a discrete start and end. 

## Sample Code

Get the source code for the example project. This a Flare-less project that shows the basics of what we're trying to achieve. Make sure you export with time from keyframe.

[https://github.com/2d-inc/liquid_progress_workshop](https://github.com/2d-inc/android_summit)

If you like to skip to the end, check out the [complete branch](https://github.com/2d-inc/android_summit/tree/complete) for the final implementation.

## What's an Action?

See progress_reporting_action.dart

For the purposes of this project an action is something that has a start, an end, and progress in-between. It's an abstraction of some determinate process.

Examples: Download, upload, process complicated data, etc.

## Example Action

To keep things simple and easy to test, we're going to implement an example action that simply progresses with time. It'll do it somewhat randomly in order to ensure that our animation switches states properly regardless of when an event occurs.

## ListView.builder

We'll also want to make sure that our animation can work when it's instanced multiple times on a page, so that if we have a list of items to download the app can properly display an efficient (virtualized) view of each one.

# Flare Architecture

Briefly discuss Flare files, Actors, Artboards, Animations, Controllers, etc.

## FlareActor

Think of it like a Flutter Image but you can also tell it which artboard, animation, etc to display. Has similar alignment and fit properties.

# Adding Flare

Create a new assets folder at the top level of the project.

Add flare_flutter and assets folder to dependencies.
```
    dependencies:	
    	flare_flutter: ^1.5.5
    
    flutter:
    	assets:
    		- assets/
```
## Exporting Flare Content

Go to Guido's public Flare file here:

[https://www.2dimensions.com/a/pollux/files/flare/liquid-download](https://www.2dimensions.com/a/pollux/files/flare/liquid-download)

Export the file and copy it to the assets folder we created earlier.

## In Flutter

Replace Container in GestureDetector with FlareActor.
```
    const FlareActor(
      "assets/Liquid Download.flr",
      animation: "Idle",
      fit: BoxFit.contain,
    	alignment: Alignment.center,
    )
```
This shows the basics of getting Flare into your app, but we need this to be a little more sophisticated so that we can use a custom controller, so let's make a new widget that'll wrap our FlareActor.

## Create liquid_progress.dart

Start as **StatelessWidget** simply wrapping the FlareActor with one final property, the action, passed in.

Show how changing animation from "Idle", to "Determinate", to "Indeterminate" works with **hot reload**.

Next thing we want is to create our **controller** which will drive these animations in response to progress changes. 

The controller is an object that will get passed in as a property to the FlareActor. That means we're going to need to store it somewhere, which means this widget will need to become **stateful**, but first let's do the **controller**.

## Create flare_progress_controller.dart

Implement abstract class.

Then pass in the action, monitor progress change.
```
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
```
Let's hook that up and test it all works.

## Convert LiquidProgress to StatefulWidget
```
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
```
## Add Controller Fields

These are the fields we'll be referencing in the next section. They get stored on the controller as it uses them to update state and track progress.
```
      ActorAnimation _idle;
      ActorAnimation _start;
      ActorAnimation _indeterminate;
      ActorAnimation _determinate;
      ActorAnimation _complete;
    
      _ProgressState _state;
      _ProgressState _nextState;
    
      double _progressValue = 0;
      double _time = 0;
```
## Make Controller Sync State

This will synchronize the state of the controller to the state of the progress reporter when it's initialized or changed.
```
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
```
Get animations at init and apply idle (first animation right away to make sure things are immediately in a non-setup state):

```
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
```

## Implement Advance

This is the meat of the controller which is called each frame the widget needs to update. To play nice here we really shouldn't continue advancing when we are not updating the animation, but to keep this already complicated example as brief as possible, we're leaving that as homework :)

What you'll see below is state machine logic mixed in with some edge cases for the indeterminate/determinate animation processing. The most important part to understand is how the animations are applied and how the time value is controllable and doesn't necessarily need to represent time (in this case we use it to represent progress).

```
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
```