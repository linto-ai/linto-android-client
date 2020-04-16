import 'dart:async';
import 'package:flutter/material.dart';

class CalendarWidget extends StatefulWidget {
  CalendarWidget({Key key}) : super(key: key);

  @override
  _CalendarWidget createState() => new _CalendarWidget();
}

class _CalendarWidget extends State<CalendarWidget> {
  List<CalendarEventWidget> _events = List<CalendarEventWidget>();
  int _nEventDisplayed = 1;
  @override
  void initState() {
    _events.add(CalendarEventWidget());
    _events.add(CalendarEventWidget());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    return Column(
      children: _events.sublist(0, _nEventDisplayed),
    );
  }
}

class CalendarEventWidget extends StatefulWidget {
  CalendarEventWidget({Key key}) : super(key: key);
  @override
  _CalendarEventWidget createState() => new _CalendarEventWidget();
}

class _CalendarEventWidget extends State<CalendarEventWidget> {
  String _date = 'Today';
  String _time = '17:00';
  String _title = "Test Event";
  String _location = "At: Home";
  String _description = "Test event description";
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Row(
                children: <Widget>[
                  Text(_date),
                  Text(_time),
                  Text(_location),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ),
              Spacer(),
              Text(_title,),
              Spacer(),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              Text(_description, textAlign: TextAlign.left,)
            ],
            mainAxisAlignment: MainAxisAlignment.start,
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
    );
  }
}