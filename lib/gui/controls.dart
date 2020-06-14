import 'package:flutter/material.dart';
import 'package:linto_flutter_client/logic/customtypes.dart';

class ControlBar extends StatefulWidget {
  final VoidCallback onLintoClicked;
  final VoidCallback onSettingClicked;
  final BoolCallBack onMicrophoneClicked;
  ControlBar({Key key, this.onLintoClicked, this.onSettingClicked, this.onMicrophoneClicked}) : super(key: key);

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
      //decoration: BoxDecoration(border: Border.all(),),
      padding: EdgeInsets.only(bottom: 20),
      child: Row( // Landscape
        children: <Widget>[
          Expanded(
            child: FlatButton(
              child: _micStatus ? Image.asset('assets/icons/mic_on.png', fit: BoxFit.fitHeight, height: 60, alignment: Alignment.topCenter,) : Image.asset('assets/icons/mic_off.png', fit: BoxFit.fitHeight, height: 60,),
              onPressed: () {
                setState(() {
                  _micStatus = !_micStatus;
                });
                this.widget.onMicrophoneClicked(_micStatus);
              },
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            flex: 2,
          ),
          Spacer(),
          Expanded(
            child: FlatButton(
              child: Image.asset('assets/icons/linto_alpha.png',height: 60, fit: BoxFit.contain),
              onPressed: () => this.widget.onLintoClicked(),
            ),
            flex: 2,
          ),
          Spacer(),
          Expanded(
            child: FlatButton(
              child: Image.asset('assets/icons/settings.png', fit: BoxFit.contain, height: 50,),
              onPressed: () => this.widget.onSettingClicked(),
            ),
            flex: 2,
          ),
        ],
      ),
    );
  }
}