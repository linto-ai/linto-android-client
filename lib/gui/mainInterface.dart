import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linto_flutter_client/audio/audioInput.dart';
import 'package:linto_flutter_client/audio/audiomanager.dart';
import 'package:linto_flutter_client/gui/calendar.dart';
import 'package:linto_flutter_client/gui/clock.dart';
import 'package:linto_flutter_client/gui/lintoDisplay.dart';
import 'package:linto_flutter_client/gui/meeting.dart';
import 'package:linto_flutter_client/gui/slidingPanelContent.dart';
import 'package:linto_flutter_client/gui/weather.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:linto_flutter_client/gui/controls.dart';
import 'package:linto_flutter_client/client/client.dart';

class MainInterface extends StatefulWidget {
  final LinTOClient client;
  final AudioManager audioManager;

  MainInterface({Key key, this.client, this.audioManager}) : super(key: key);

  @override
  _MainInterface createState() => new _MainInterface();
}

class _MainInterface extends State<MainInterface> {
    PanelController _controller = PanelController();
  @override
  void initState() {
    super.initState();
    if (! widget.audioManager.isReady) {
      widget.audioManager.onReady = onAudioReady;
      widget.audioManager.initialize();
    }
    widget.audioManager.onKeyWordSpotted = onKeyword;

  }
    @override
    Widget build(BuildContext context) {
     Orientation orientation = MediaQuery.of(context).orientation;
     return Scaffold(
       body: SafeArea(
         child: Center(
           child: SlidingUpPanel(
             panel: Center(
                 child : SlidingPanel()
             ),
             onPanelClosed: () => onPanelClosed(),
             body: Container(
               child: Column(
                 children: <Widget>[
                   Expanded(
                     // Time and weather
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Flex(
                          children: <Widget>[
                            Expanded(child: Clock()),
                            Expanded(child: WeatherWidget()),
                          ],
                          direction: orientation == Orientation.portrait ? Axis.vertical : Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        ),
                      ),
                     flex: 10,
                   ),
                   Expanded(
                     child: FlatButton(
                       child: CalendarWidget(),
                       onPressed: () => displayMeeting(),
                     ),
                     flex: 6,
                   ),
                   Expanded(
                     child: ControlBar(
                       onLintoClicked: () => onLinToClicked(),
                     ),
                   flex: orientation == Orientation.portrait ? 5 : 6,
                   )
                 ],
                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               ),
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

    void closePanel(){
    _controller.close();
    }

    void onLinToClicked(){
    widget.audioManager.triggerKeyword();
      expandPanel();
    }
    void onKeyword() {
      expandPanel();
    }

    void onUtteranceStart(){

    }

    void onUtteranceStop(){

    }

    void onAudioReady() {
      widget.audioManager.startDetecting();
    }

    void onPanelClosed() {
      widget.audioManager.cancelUtterance();
      widget.audioManager.startDetecting();

    }

    void displayMeeting() {
      Navigator.push(context, MaterialPageRoute(builder: (context) => MeetingInterface()));
    }
}