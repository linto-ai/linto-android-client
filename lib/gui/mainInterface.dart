import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linto_flutter_client/audio/audioInput.dart';
import 'package:linto_flutter_client/audio/audiomanager.dart';
import 'package:linto_flutter_client/gui/calendar.dart';
import 'package:linto_flutter_client/gui/clock.dart';
import 'package:linto_flutter_client/gui/lintoDisplay.dart';
import 'package:linto_flutter_client/gui/weather.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:linto_flutter_client/gui/controls.dart';

class MainInterface extends StatefulWidget {
  MainInterface({Key key}) : super(key: key);

  @override
  _MainInterface createState() => new _MainInterface();
}

class _MainInterface extends State<MainInterface> {
  AudioManager audioManager;
  PanelController _controller = PanelController();
  @override
  void initState() {
    super.initState();
    audioManager = AudioManager(
        onDetection: () => onKeyword(),
        onReady: () => onAudioReady());
    audioManager.initialize();
  }
    @override
    Widget build(BuildContext context) {
     Orientation orientation = MediaQuery.of(context).orientation;
     return Scaffold(
       body: SafeArea(
         child: Center(
           child: SlidingUpPanel(
             panel: Center(
                 child : Row(
                   children: <Widget>[
                     Text("Han han")
                   ],
                 )
             ),
             onPanelClosed: () => onPanelClosed(),
             body: FractionallySizedBox(
               child: Container(
                 child: Column(
                   children: <Widget>[
                     Flex(
                       children: <Widget>[
                         Clock(),
                         WeatherWidget()
                       ],
                       direction: orientation == Orientation.portrait ? Axis.vertical : Axis.horizontal,
                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                     ),
                     CalendarWidget(),
                     ControlBar(
                       onLintoClicked: () => onLinToClicked(),
                     )
                   ],
                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                 ),
                 padding: EdgeInsets.all(10),
               ),
               widthFactor: 0.95,
               heightFactor: 0.95,
             ),
             minHeight: 0,
             maxHeight: MediaQuery.of(context).size.height * 0.5,
             backdropEnabled: true,
             controller: _controller,
           ),
         )
       ),
     );
    }

    void expandPanel(){
    _controller.open();
    }

    void onLinToClicked(){
    audioManager.dummyDetect();
      expandPanel();
    }
    void onKeyword() {
      expandPanel();
    }

    void onAudioReady() {
      audioManager.startDetecting();
    }

    void onPanelClosed() {
    audioManager.startDetecting();
    }
}