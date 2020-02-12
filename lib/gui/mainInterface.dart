import 'package:flutter/material.dart';
import 'lintoDisplay.dart';
import 'audioControl.dart';
import 'package:flutter/services.dart';
import 'package:linto_flutter_client/audio/audiomanager.dart';


class MainInterface extends StatefulWidget {
  MainInterface({Key key}) : super(key: key);

  @override
  _MainInterface createState() => new _MainInterface();
}

class _MainInterface extends State<MainInterface> {

  var audioManager = new AudioManager();

  //Interfaces
  LinTODisplay _display = LinTODisplay();
  AudioControl _audioControl = AudioControl();

  @override
  void initState(){
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    audioManager.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          FlatButton(child: Text('debug'), onPressed: () {
            /*if (audioManager.isDetecting) {
              audioManager.stopDetecting();
            } else {
              audioManager.startDetecting();
            }*/
            audioManager.dummyDetect();
          }), //debug
          Expanded(child: _display, flex: 4,),
          Expanded(child: _audioControl, flex: 1),
        ],
      ),
      padding: EdgeInsets.all(15),
    );
  }
}