import 'package:flutter/material.dart';
import 'package:linto_flutter_client/gui/home.dart';
import 'package:linto_flutter_client/gui/login.dart';
import 'package:linto_flutter_client/logic/maincontroller.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final MainController mainController = MainController();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Home(mainController: mainController,)
    );
  }
}

