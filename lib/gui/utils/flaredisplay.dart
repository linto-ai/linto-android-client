import 'package:flutter/material.dart';
import 'package:flare_flutter/flare_controller.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_dart/math/mat2d.dart';


class FlareDisplay extends StatefulWidget {
  final double width;
  final double height;
  final String assetpath;
  final String animationName;
  FlareDisplay({Key key, this.width, this.height, this.assetpath, this.animationName,}) : super(key: key);

  @override
  _FlareDisplay createState() => new _FlareDisplay();

}

class _FlareDisplay extends State<FlareDisplay> with FlareController{
  // Widget
  double _width;
  double _height;

  // Flare animation
  String assetPath;
  String animation;
  ActorAnimation _actor;

  // Controller
  double _mix = 0.5; // Amount of blending
  double _speed = 1.0;
  double _duration = 0.0;

  // Status
  bool _isPlaying = true;
  bool _isLooped = true;

  @override
  void initialize(FlutterActorArtboard artboard) {
    _actor = artboard.getAnimation(animation);
    print("${_actor.duration}");
  }

  @override
  void initState() {
    assetPath = widget.assetpath;
    animation = widget.animationName;
    super.initState();
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
        child: FlareActor(widget.assetpath,
          alignment: Alignment.center,
          isPaused: ! _isPlaying,
          fit: BoxFit.contain,
          animation: animation,
          controller: this,
        ),
        onPressed: () {},
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        padding: EdgeInsets.all(0),
      ),
      width: widget.width,
      height: widget.height,
      //decoration: BoxDecoration(border: Border.all()),
    );
  }
}