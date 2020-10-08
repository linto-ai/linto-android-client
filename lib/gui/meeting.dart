import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linto_flutter_client/gui/utils/flaredisplay.dart';
import 'package:linto_flutter_client/logic/uicontroller.dart';

class MeetingInterface extends StatefulWidget {
  final Map<String, dynamic> meetingInfo;
  MeetingInterface(this.meetingInfo, {Key key}) : super(key: key);

  @override
  _MeetingInterface createState() => new _MeetingInterface();
}

class _MeetingInterface extends State<MeetingInterface> implements VoiceUIController{
  bool isActiveView = true;
  bool _isPaused = false;
  String _meetingName = 'Meeting';

  DateTime _startTime;
  String _time = '00:00:00';
  String _duration = '00:00';
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _meetingName = widget.meetingInfo["meeting_name"];
    _time = _formatTime();
    _startTime = DateTime.now();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _updateTime());
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    double windowHeight = MediaQuery.of(context).size.height;
    double windowWidth = MediaQuery.of(context).size.width;
    double lintoSizeFactor = orientation == Orientation.portrait ? 0.6: 0.35;
    return Scaffold(
        body: SafeArea(
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                    gradient: RadialGradient(
                        colors: [Color.fromRGBO(255, 255, 255, 1), Color.fromRGBO(213, 231, 242, 1)]
                    )
                ),
                child: Column(
                  children: <Widget>[
                    Container(// Time and Rec Icon
                      child: Row(
                        children: <Widget>[
                          Text(_time, style: TextStyle(fontSize: 30),),
                          FlareDisplay(assetpath: 'assets/icons/recording.flr',
                              animationName: 'recording',
                              width: 50,
                              height: 50)
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      ),
                      padding: EdgeInsets.only(left: 10, right: 10),
                    ),
                    Container(// LinTo and meeting info and controls
                      child: Flex(
                        direction: orientation == Orientation.portrait ? Axis.vertical: Axis.horizontal,
                        children: <Widget>[
                          FlareDisplay(assetpath: 'assets/linto/linto.flr',
                            animationName: 'idle',
                            width: windowWidth * lintoSizeFactor,
                            height: windowWidth * lintoSizeFactor,),
                          Container(
                            child: Column(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    child: AutoSizeText(_meetingName, style: TextStyle(fontSize: 50),textAlign: TextAlign.center,),
                                  ),
                                  flex: 2,
                                ),
                                Expanded(
                                  child: Container(
                                    child: AutoSizeText(_duration, style: TextStyle(fontSize: 50),textAlign: TextAlign.center,),
                                  ),
                                  flex: 1,
                                ),
                                Expanded(
                                  child: Container(
                                      child: Flex(
                                        direction: orientation == Orientation.portrait ? Axis.vertical: Axis.horizontal,
                                        children: <Widget>[
                                          FlatButton(
                                            child: AutoSizeText("Suspend recording", style: TextStyle(fontSize: 20)),
                                          ),
                                          FlatButton(
                                            child: AutoSizeText("End meeting", style: TextStyle(fontSize: 20)),
                                            onPressed: () => Navigator.pop(context),
                                          )
                                        ],
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      )
                                  ),
                                  flex: 2,
                                ),
                              ],
                            ),
                            //decoration: BoxDecoration(border: Border.all()),
                            height: orientation == Orientation.portrait ? windowHeight * 0.45: windowWidth * lintoSizeFactor,
                            width: orientation == Orientation.portrait ? windowWidth : windowWidth - (windowWidth * lintoSizeFactor) - 2,
                          )
                        ],
                      ),
                      //decoration: BoxDecoration(border: Border.all()),
                    ),
                    Container( // Bottom Bar
                      child: Row(
                        children: <Widget>[

                        ],
                      ),
                    )
                  ],
                ),
              )

            ),
        )
    );
  }
  void _updateTime() {
    setState(() {
      _time = _formatTime();
      _duration = _formatDuration();
    });
  }

  String _formatDuration() {
    var f = new NumberFormat("#00", "en_US");
    int second = 0;
    num minutes = 0;
    int elapsed_time = (DateTime.now().millisecondsSinceEpoch - _startTime.millisecondsSinceEpoch) ~/ 1000;
    minutes = elapsed_time / 60;
    second = elapsed_time % 60;
    return '${f.format(minutes.toInt())}:${f.format(second)}';
  }

  String _formatTime() {
    return DateFormat('HH:mm:ss').format(DateTime.now());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void onKeywordSpotted() {

  }

  @override
  void onLintoSpeakingStart() {

  }

  @override
  void onLintoSpeakingStop() {

  }

  @override
  void onRequestPending() {

  }

  @override
  void onUtteranceCanceled() {

  }

  @override
  void onUtteranceEnd() {
    // TODO: implement onUtteranceEnd
  }

  @override
  void onUtteranceStart() {

  }

  @override
  void onMessage(String msg, {String topMsg}) {

  }

  @override
  void onDisconnect() {

  }

  @override
  void display(String content, bool isURL) {

  }

  @override
  void onError(String errorMessage) {
    print("An error occured");
  }
}