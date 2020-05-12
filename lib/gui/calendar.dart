import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
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
    return Container(
      //decoration: BoxDecoration(border: Border.all(),),
      child: Column(
        children: _events.sublist(0, _nEventDisplayed),
      ),
    );
  }
}

class CalendarEventWidget extends StatefulWidget {
  CalendarEventWidget({Key key}) : super(key: key);
  @override
  _CalendarEventWidget createState() => new _CalendarEventWidget();
}

class _CalendarEventWidget extends State<CalendarEventWidget> {
  String _envent_id;
  String _date = 'Today';
  String _time = '17:00';
  String _title = "Test Event";
  String _description = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce a semper massa. Maecenas risus nulla, laoreet vel porttitor quis, placerat a felis. Pellentesque malesuada ultrices metus, vel dapibus justo efficitur. ";
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
                child: Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(child: AutoSizeText(_date, style: TextStyle(fontSize: 200), textAlign: TextAlign.left, maxLines: 1,),flex: 1,),
                      Expanded(child: AutoSizeText(_time, style: TextStyle(fontSize: 200), textAlign: TextAlign.left, maxLines: 1), flex: 1,),
                      Expanded(child: AutoSizeText(_title, style: TextStyle(fontSize: 200), textAlign: TextAlign.center, maxLines: 1),flex: 4,),
                    ],
                  ),
                ),
                flex : 3
            ),
            Expanded(
                child : AutoSizeText(_description, style: TextStyle(fontSize: 200), textAlign: TextAlign.left, maxLines: 3,),
                flex: 2
            ),
          ],
        ),
      ),
      flex: 1,
    );
  }
}