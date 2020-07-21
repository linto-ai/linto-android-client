import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linto_flutter_client/gui/calendar.dart';
import 'package:linto_flutter_client/gui/clock.dart';
import 'package:linto_flutter_client/gui/meeting.dart';
import 'package:linto_flutter_client/gui/settings.dart';
import 'package:linto_flutter_client/gui/slidingPanelContent.dart';
import 'package:linto_flutter_client/gui/weather.dart';
import 'package:linto_flutter_client/logic/maincontroller.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:linto_flutter_client/gui/controls.dart';
import 'package:linto_flutter_client/logic/uicontroller.dart';

class MainInterface extends StatefulWidget {
  final MainController mainController;

  MainInterface({Key key, this.mainController}) : super(key: key);

  @override
  _MainInterface createState() => new _MainInterface();
}

class _MainInterface extends State<MainInterface> implements VoiceUIController{
  MainController _mainController;
  bool isActiveView = true;
  SlidingPanel panel = SlidingPanel();

  PanelController _controller = PanelController();
  @override
  void initState() {
    super.initState();
    _mainController = widget.mainController;
    _mainController.currentUI = this;
    _mainController.init();

  }
  @override
  Widget build(BuildContext context) {
   Orientation orientation = MediaQuery.of(context).orientation;
   return new WillPopScope(
     onWillPop: () async => false,
     child: Scaffold(
       body: SafeArea(
           child: Center(
             child: SlidingUpPanel(
               panel: Center(
                   child : panel
               ),
               onPanelClosed: () => onPanelClosed(),
               body: Container(
                 decoration: BoxDecoration(
                   gradient: RadialGradient(
                     colors: [Color.fromRGBO(255, 255, 255, 1), Color.fromRGBO(213, 231, 242, 1)]
                   )
                 ),
                 child: Column(
                   children: <Widget>[
                     Expanded(
                       // Time and weather
                       child: Container(
                         padding: EdgeInsets.all(10),
                         child: Flex(
                           children: <Widget>[
                             Expanded(child: Clock()),
                             Expanded(child:WeatherWidget()
                             ),
                           ],
                           direction: orientation == Orientation.portrait ? Axis.vertical : Axis.horizontal,
                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                         ),
                       ),
                       flex: 10,
                     ),
                     Expanded(
                       child: ControlBar(
                         onLintoClicked: () => onLinToClicked(),
                         onMicrophoneClicked: (value) => {},
                         onSettingClicked: () async => displaySettings(),
                       ),
                       flex: orientation == Orientation.portrait ? 6 : 6,
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
    _mainController.triggerKeyWord();
    expandPanel();
  }
  void onKeyword() {
    expandPanel();
  }

  void onPanelClosed() {
    _mainController.abord();
  }

  void displayMeeting() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => MeetingInterface()));
  }

  void displaySettings() async {
    bool disconnected = await Navigator.push(context, MaterialPageRoute(builder: (context) => OptionInterface(mainController: _mainController,)));
    if (disconnected) {
      _mainController.disconnect();
    }
  }

  @override
  void onKeywordSpotted() {
    expandPanel();
  }

  @override
  void onLintoSpeakingStart() {
    panel.startSpeaking();
  }

  @override
  void onLintoSpeakingStop() {
    panel.stopSpeaking();
  }

  @override
  void onRequestPending() {
    panel.loading();
  }

  @override
  void onUtteranceCanceled() {
    closePanel();
  }

  @override
  void onUtteranceEnd() {
    // TODO: implement onUtteranceEnd
  }

  @override
  void onUtteranceStart() {
    panel.loading();
  }

  @override
  void onMessage(String msg) {
    expandPanel();
    panel.displayMsg(msg);
  }

  @override
  void onDisconnect() {
    Navigator.pop(context, false);
  }
}