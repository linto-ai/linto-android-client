import 'dart:async';
import 'package:flutter/material.dart';
import 'package:linto_flutter_client/gui/clock.dart';
import 'package:intl/intl.dart';
import "package:flare_flutter/flare_actor.dart";
import 'package:linto_flutter_client/gui/lintoDisplay.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';

class MeetingInterface extends StatefulWidget {
  MeetingInterface({Key key}) : super(key: key);

  @override
  _MeetingInterface createState() => new _MeetingInterface();
}

class _MeetingInterface extends State<MeetingInterface> {
  bool _isPaused = false;
  String _meetingName = 'Meeting';

  DateTime _startTime;
  String _time = '00:00:00';
  String _duration = '00:00';
  Timer _timer;
  @override
  void initState() {
    super.initState();
    _time = _formatTime();
    _startTime = DateTime.now();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _updateTime());
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    double lintoSizeFactor = orientation == Orientation.portrait ? 0.6: 0.3;
    return Scaffold(
        body: SafeArea(
            child: Center(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: <Widget>[
                        Text(_time, style: TextStyle(fontSize: 30),),
                        Spacer(),
                        Container(
                            child: FlareActor('assets/icons/recording.flr',
                              alignment: Alignment.center,
                              isPaused: _isPaused,
                              snapToEnd: true,
                              fit: BoxFit.cover,
                              animation: 'recording',
                            ),
                            width: 50,
                            height: 50
                        )
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    ),
                  )
                  ,
                  Flex(
                    direction: orientation == Orientation.portrait ? Axis.vertical : Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                          child: FlareActor('assets/linto/linto.flr',
                            alignment: Alignment.center,
                            isPaused: _isPaused,
                            fit: BoxFit.cover,
                            animation: 'idle',
                            snapToEnd: true,
                          ),
                          width: MediaQuery.of(context).size.width * lintoSizeFactor,
                          height: MediaQuery.of(context).size.width * lintoSizeFactor,
                      ),
                      Column(
                        children: <Widget>[
                          Text(_meetingName),
                          Text(_duration),
                          Flex(
                            children: <Widget>[
                              FlatButton(
                                child: Text('Suspend Recording'),
                              ),
                              FittedBox(child: FlatButton(
                                child : Text('Stop Meeting'),),
                                fit: BoxFit.cover,
                              )
                            ],
                            direction: orientation == Orientation.portrait ? Axis.vertical : Axis.horizontal,
                          )
                        ],
                      )
                    ],
                  )
                ],
              ),
            )
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
    int second = 0;
    int minutes = 0;
    int elapsed_time = DateTime.now().second - _startTime.second;
    minutes = elapsed_time ~/ 60;
    second = elapsed_time % 60;
    return '${minutes}:${second}';
  }

  String _formatTime() {
    return DateFormat('HH:mm:ss').format(DateTime.now());
  }
}