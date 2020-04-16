import 'package:flutter/material.dart';
import 'package:linto_flutter_client/gui/mainInterface.dart';
import 'package:linto_flutter_client/client/client.dart';
import 'package:linto_flutter_client/gui/loginscreen.dart';
import 'package:linto_flutter_client/gui/meeting.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final LinTOClient client = LinTOClient();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: MeetingInterface()//LoginScreen(client: client,),
    );
  }
}

