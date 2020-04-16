import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Clock extends StatefulWidget {
  Clock({Key key}) : super(key: key);

  @override
  _Clock createState() => new _Clock();
}

class _Clock extends State<Clock> {
  String _date;
  String _time;
  String _day;
  Timer _timer;
  @override
  void initState() {
    _time = _formatTime(DateTime.now());
    _date = _formatDate(DateTime.now());
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
        child: Column(
          children: <Widget>[
            Text(_date,
              style: TextStyle(fontSize: 25),),
            Text(_time,
              style: TextStyle(fontSize: 65),),
          ],
        )
      );

  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatTime(now);
    setState(() {
      _time = formattedDateTime;
    });
    // UPDATE DATE IF ?
  }

  String _formatTime(DateTime dateTime) {
    return DateFormat('HH:mm:ss').format(dateTime);
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('(EEEE) dd/MM/yyyy').format(dateTime);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}