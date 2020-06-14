import 'package:flutter/material.dart';
import 'package:linto_flutter_client/logic/maincontroller.dart';
import 'package:linto_flutter_client/logic/options.dart';


class OptionInterface extends StatefulWidget {
  final MainController mainController;

  OptionInterface({Key key, this.mainController}) : super(key: key);

  @override
  _OptionInterface createState() => new _OptionInterface();
}
// TODO: Implement basic option blocks and categories for easy maintenance and additions

class _OptionInterface extends State<OptionInterface> {
  MainController _mainController;
  Options _options;
  double _notif;
  double _speech;

  @override
  void initState() {
    super.initState();
    _mainController = widget.mainController;
    _options = _mainController.options;
    _notif = _options.notificationvolume;
    _speech = _options.speechVolume;
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    return new WillPopScope(
        onWillPop: () async {
          _options.updateUserPref();
          return true;
          },
        child: Scaffold(
            body: SafeArea(
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Text('Notification'),
                      Slider(value: _notif,
                        min: 0.0, max: 100.0,
                        label: _notif.toString(),
                        onChanged: (value) {setState(() {
                          _notif = value;
                        });},),
                      Text('Speech'),
                      Slider(value: _speech,
                        min: 0.0, max: 100.0,
                        label: _speech.toString(),
                        onChanged: (value) {setState(() {
                          _speech = value;
                        });}
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                  ),
                ))));
  }
}

class SysInfo extends Container{
  final MainController _mainController;
  SysInfo(Key key, this._mainController) : super(key : key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return super.build(context);
  }
}

class SysInfoEntry {
  SysInfoEntry(String key, String value)
}