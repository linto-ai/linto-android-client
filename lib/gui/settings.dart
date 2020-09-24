import 'package:flutter/material.dart';
import 'package:linto_flutter_client/logic/maincontroller.dart';
import 'package:linto_flutter_client/logic/userpref.dart';
import 'package:linto_flutter_client/gui/dialogs.dart' show confirmDialog;


class OptionInterface extends StatefulWidget {
  final MainController mainController;

  OptionInterface({Key key, this.mainController}) : super(key: key);

  @override
  _OptionInterface createState() => new _OptionInterface();
}
// TODO: Implement basic option blocks and categories for easy maintenance and additions

class _OptionInterface extends State<OptionInterface> {
  MainController _mainController;
  UserPreferences _userPref;
  double _notif;
  double _speech;

  @override
  void initState() {
    super.initState();
    _mainController = widget.mainController;
    _userPref = _mainController.userPreferences;
    _notif = _userPref.systemPreferences["notificationVolume"] * 100;
    _speech = _userPref.systemPreferences["speechVolume"]  * 100;
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    return new WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            body: SafeArea(
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Row(
                            children: <Widget>[
                              FlatButton(
                                child: Icon(Icons.arrow_back, size: 48,),
                                onPressed: () => onPop(),
                              ),
                              Spacer(),
                              Text('SETTINGS', style: TextStyle(fontSize: 36),),
                              Spacer(flex: 2,)
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 50),
                            child: Column (
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text('Notifications'.padRight(15, ' '), textAlign: TextAlign.left,),
                                      Slider(
                                        value: _notif,
                                        min: 0.0, max: 100.0,
                                        label: _notif.toString(),
                                        onChanged: (value) {
                                          setState(() {
                                            _notif = value;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text('Speech'.padRight(15, ' '), textAlign: TextAlign.left,),
                                      Slider(
                                        value: _speech,
                                        min: 0.0, max: 100.0,
                                        label: _speech.toString(),
                                        onChanged: (value) {
                                          setState(() {
                                            _speech = value;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                )

                              ]
                          ),
                        ),
                        Spacer(),
                        sysInfo(_mainController),
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                    ),
                  )
                )
            )
        )
    );
  }

  Future onPop() async {
    _userPref.systemPreferences["notificationVolume"] = _notif / 100;
    _userPref.systemPreferences["speechVolume"] = _speech / 100;
    _userPref.updatePrefs();
    Navigator.pop(context, false);
  }
  }

Container sysInfo(MainController controller) {
  Map<String, String> entryKeys;
  if (controller.userPreferences.clientPreferences["auth_cred"]) {
    entryKeys = {
      'Login': controller.client.login,
      'Server': controller.client.server,
      'Scope' : controller.client.currentScope.name
    };
  } else {
    entryKeys = {
      'Id' : controller.client.deviceID,
      'Broker': controller.client.brokerURL,
      'Scope' : controller.client.currentScope.name
    };
  }


  return Container(
    child: Column(
      children: entryKeys.entries.map((e) => SysInfoEntry(e.key, e.value)).toList(),
    ),
    padding: EdgeInsets.only(left: 20, right: 20),
    color: Colors.black12,
  );
}

Container SysInfoEntry (String key, String value) {
  return Container(
    child: Row(
      children: <Widget>[
        Text(key.padRight(10, ' ') ,style: TextStyle(fontWeight: FontWeight.bold),),
        Text(value.length < 30 ? value :value.substring(0,30))
      ],
    ),
  );
}