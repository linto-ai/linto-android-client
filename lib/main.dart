import 'package:flutter/material.dart';
import 'package:linto_flutter_client/gui/applications.dart';
import 'package:linto_flutter_client/gui/home.dart';
import 'package:linto_flutter_client/gui/login.dart';
import 'package:linto_flutter_client/gui/mainInterface.dart';
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
      initialRoute: '/',
      routes : {
        '/': (context) => Home(mainController: mainController),
        '/login' : (context) => Login(mainController: mainController,),
        '/applications' : (context) => Applications(mainController: mainController,),
        '/main' : (context) => MainInterface(mainController: mainController,),
      }
    );
  }
}

