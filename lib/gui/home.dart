import 'package:flutter/material.dart';
import 'package:linto_flutter_client/logic/maincontroller.dart';

import 'package:linto_flutter_client/gui/mainInterface.dart';
import 'package:linto_flutter_client/client/client.dart';
import 'package:linto_flutter_client/gui/login.dart';


class Home extends StatefulWidget {
  final MainController mainController;
  const Home({ Key key, this.mainController}) : super(key: key);
  @override
  _Home createState() => _Home();
}

// Define a corresponding State class.
// This class holds data related to the form.
class _Home extends State<Home> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>
  MainController _mainController;
  bool _visible = false;
  void initState() {
    super.initState();
    _mainController = widget.mainController;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      //startup();
      setState(() {
        _visible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery
        .of(context)
        .orientation;
    double lintoWidth = MediaQuery
        .of(context)
        .size
        .width * (orientation == Orientation.portrait ? 0.9 : 0.45);
    return Scaffold(
        body: Center(
          child: Flex(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            direction: orientation == Orientation.portrait ? Axis.vertical : Axis.horizontal,
            children: <Widget>[
              AnimatedOpacity(
                opacity: _visible ? 1.0 : 0.0,
                duration: Duration(milliseconds: 2000),
                child: Image.asset('assets/icons/linto_ai.png',height: lintoWidth, fit: BoxFit.contain),
                onEnd: () async => startup(),
              )
            ],
          )
        )
    );
  }

  Future startup() async {
    var clientPrefs;
    AuthenticationStep resultStep = AuthenticationStep.WELCOME;
    _mainController.userPreferences.init().whenComplete(() async {
      clientPrefs = _mainController.userPreferences.clientPreferences;
      //print(_mainController.userPreferences);
      if (clientPrefs['first_login']) {
        Navigator.push(context, MaterialPageRoute(builder: (context) =>
            Login(mainController: _mainController,
              step: AuthenticationStep.WELCOME,)));
        return;
      } else if (!clientPrefs['keep_info']){
        await Navigator.push(context, MaterialPageRoute(builder: (context) =>
            Login(mainController: _mainController,
              step: AuthenticationStep.SERVERSELECTION,)));
      } else {
        try {
          resultStep = await _mainController.client
              .reconnect(_mainController.userPreferences);
          // success -> main interface
          // Failure -> login - step
        } on Exception catch(error) {
          print(error);
          Navigator.push(context, MaterialPageRoute(builder: (context) => Login(mainController: _mainController,step: AuthenticationStep.SERVERSELECTION,)));
        }

        if (resultStep == AuthenticationStep.CONNECTED) {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => MainInterface(mainController: _mainController,)));
        } else {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => Login(mainController: _mainController, step: resultStep)),);
        }
      }
      while (true) {
        await Navigator.push(context, MaterialPageRoute(builder: (context) => Login(mainController: _mainController, step: AuthenticationStep.SERVERSELECTION)));
      }
    });
  }
}