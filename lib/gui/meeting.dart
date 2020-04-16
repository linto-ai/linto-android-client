import 'package:flutter/material.dart';
import 'package:linto_flutter_client/gui/clock.dart';
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
  String _duration = '00:00';
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Clock(),
                    /*Container(
                      child: FlareActor('assets/icons/recording.flr',
                        alignment: Alignment.center,
                        isPaused: _isPaused,
                        fit: BoxFit.cover,
                        animation: 'recording',
                      )
                    )*/
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
                Flex(
                  direction: orientation == Orientation.portrait ? Axis.vertical : Axis.horizontal,
                  children: <Widget>[
                    //LinTODisplay(),
                    Column(
                      children: <Widget>[
                        Text(_meetingName),
                        Text(_duration),
                        Flex(
                          children: <Widget>[
                            FlatButton(
                              child: Text('Suspend Recording'),
                            ),
                            FlatButton(
                              child : Text('Stop Meeting')
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
}