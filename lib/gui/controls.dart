import 'package:flutter/material.dart';
import 'package:linto_flutter_client/gui/mainInterface.dart';

class ControlBar extends StatefulWidget {
  final LintoCallback onLintoClicked;
  ControlBar({Key key, this.onLintoClicked}) : super(key: key);

  @override
  _ControlBar createState() => new _ControlBar();
}

class _ControlBar extends State<ControlBar> {
  bool _micStatus = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery
        .of(context)
        .orientation;
    return Container(
      child: Row( // Landscape
        children: <Widget>[
          FlatButton(
            child: _micStatus ? Image.asset('assets/icons/mic_on.png', fit: BoxFit.scaleDown, height: 50,) : Image.asset('assets/icons/mic_off.png', fit: BoxFit.scaleDown, height: 50,),
            onPressed: () {
              setState(() {
                _micStatus = !_micStatus;
              });
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          Spacer(),
          FlatButton(
            child: Image.asset('assets/icons/linto_alpha.png', fit: BoxFit.scaleDown, height: 100,),
            onPressed: () => this.widget.onLintoClicked(),
          ),
          Spacer(),
          FlatButton(
            child: Image.asset('assets/icons/settings.png', fit: BoxFit.scaleDown, height: 50,),
          )
        ],
      ),
    );
  }
}

typedef LintoCallback = void Function();