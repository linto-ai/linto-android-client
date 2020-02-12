import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_controller.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_dart/math/mat2d.dart';

class LinTODisplay extends StatefulWidget {
  LinTODisplay({Key key}) : super(key: key);

  @override
  _LinTODisplay createState() => new _LinTODisplay();
}

class _LinTODisplay extends State<LinTODisplay> with FlareController {
  String _animation = "Idle"; // Named animation in the flare asset

  double _mix = 0.5; // Amount of blending
  double _speed = 1.0;
  double _duration = 0.0; // Total elapsed time
  bool _isPaused = false;
  bool _isLooped = true;

  ActorAnimation _actor;

  set setLooped(bool looped) {
    _isLooped = looped;
  }

  @override
  void initialize(FlutterActorArtboard artboard) {
    _actor = artboard.getAnimation(_animation);
  }

  @override
  void setViewTransform(Mat2D viewTransform) {}

  @override
  bool advance(FlutterActorArtboard artboard, double elapsed) {
    _duration += elapsed * _speed;

    if (_duration <= _actor.duration) {
      _actor.apply(_duration, artboard, _mix);
    } else if (_isLooped) {
      _duration = 0.0;
      _actor.apply(_duration, artboard, _mix);
    } else {
      _actor.apply(_actor.duration, artboard, _mix);
    }
    return true;

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FlatButton(
        child: FlareActor('assets/linto/linto-idle.flr',
          alignment: Alignment.center,
          isPaused: _isPaused,
          fit: BoxFit.cover,
          animation: _animation,
          controller: this,
        ),
        onPressed: () {},
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      )
    );
  }
}