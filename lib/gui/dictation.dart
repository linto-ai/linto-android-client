import 'dart:async';
import 'package:flutter/material.dart';
import 'package:linto_flutter_client/audio/audiomanager.dart';



class DictationInterface extends StatefulWidget {
  final AudioManager audioManager;

  DictationInterface(this.audioManager, {Key key}) : super(key: key);

  @override
  _DictationInterface createState() => new _DictationInterface();
}

class _DictationInterface extends State<DictationInterface> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery
        .of(context)
        .orientation;
    return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text("Dictation"),
            ),
            body: SafeArea(
                child: Container(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Flex(
                        direction: orientation == Orientation.portrait ? Axis
                            .vertical : Axis.horizontal,
                        children: [
                          Expanded(
                            child: FittedBox(
                                fit: BoxFit.fill,
                                child: Icon(Icons.record_voice_over,
                                  color: Color.fromARGB(255, 60, 187, 242),
                                  size: 80,)
                            ),
                          ),

                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  child: TextField(maxLines: orientation == Orientation.portrait ? 8 : 7,),
                                  decoration: BoxDecoration(
                                      border: Border.all(),
                                      borderRadius: BorderRadius.circular(12)
                                  ),
                                ),
                                ButtonBar(
                                  alignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                        icon: Icon(Icons.fiber_manual_record),
                                        onPressed: null
                                    ),
                                    IconButton(
                                        icon: Icon(Icons.stop),
                                        onPressed: null
                                    ),
                                    IconButton(
                                        icon: Icon(Icons.content_copy),
                                        onPressed: null
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ))
            )
        )
    );
  }
}