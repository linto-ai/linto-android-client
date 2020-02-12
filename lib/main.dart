import 'package:flutter/material.dart';
import 'package:linto_flutter_client/audio/audiomanager.dart';


import 'gui/mainInterface.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Center(
              child: MainInterface(),
          )
        ),
      ),
    );

  }
}

