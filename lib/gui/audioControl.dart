import 'package:flutter/material.dart';

class AudioControl extends StatefulWidget {
  AudioControl({Key key}) : super(key: key);

  @override
  _AudioControl createState() => new _AudioControl();
}

class _AudioControl extends State<AudioControl> {
  bool _micOn = true;
  double _volume = 100.0;
  bool _sliderVisible = false;

  bool get isMuted {
    return _volume == 0.0;
  }

  set micOn (bool v) {
    setState(() {
      _micOn = v;
    });
  }

  bool get micOn {
    return _micOn;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          FlatButton(
            child: _micOn ? Image.asset('assets/icons/mic_on.png', fit: BoxFit.scaleDown) : Image.asset('assets/icons/mic_off.png', fit: BoxFit.scaleDown),
            onPressed: () {
              setState(() {
                _micOn = !_micOn;
              });
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          Spacer(flex: 3,),
          Visibility(
            maintainState: true,
            visible: _sliderVisible,
            child: Slider(
              min: 0.0,
              max: 100.0,
              value: _volume,
              onChangeEnd: (double value) {
                setState(() {
                  _sliderVisible = false;
                });
              },
              onChanged: (double value) {
                setState(() {
                  _volume = value;
                });
              },
            )
          ),
          FlatButton(
            child: isMuted ? Image.asset('assets/icons/volume_off.png', fit: BoxFit.scaleDown,) : Image.asset('assets/icons/volume_on.png', fit: BoxFit.scaleDown),
            onPressed: () {
              setState(() {
                _sliderVisible = true;
              });
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
        ],
      ),
      margin: new EdgeInsets.symmetric(horizontal: 20.0),
    );
  }
}


