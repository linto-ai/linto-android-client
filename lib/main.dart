import 'package:flutter/material.dart';
import 'package:linto_flutter_client/audio/audiomanager.dart';
import 'package:linto_flutter_client/logic/maincontroller.dart';
import 'package:linto_flutter_client/client/client.dart';
import 'package:linto_flutter_client/gui/loginscreen.dart';
import 'package:linto_flutter_client/gui/meeting.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final MainController mainController = MainController();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: LoginScreen(mainController: mainController,)
    );
  }
}

