import 'dart:async';
import 'package:flutter/material.dart';
import 'package:linto_flutter_client/audio/audiomanager.dart';
import 'package:linto_flutter_client/logic/maincontroller.dart';



class DictationInterface extends StatefulWidget {
  final MainController mainController;

  DictationInterface(this.mainController, {Key key}) : super(key: key);

  @override
  _DictationInterface createState() => new _DictationInterface();
}

class _DictationInterface extends State<DictationInterface> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController textController = TextEditingController();

  bool isStreaming = false;
  bool isReady = false;

  StreamSubscription streamSub;

  @override
  void initState() {
    widget.mainController.audioManager.stopDetecting();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery
        .of(context)
        .orientation;
    return WillPopScope(
        onWillPop: () async {
          streamSub?.cancel();
          if (isStreaming) widget.mainController.stopStream();
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
                                  size: 60,)
                            ),
                            flex: 2,
                          ),

                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  child: TextField(maxLines: orientation == Orientation.portrait ? 8 : 7,
                                  controller: textController,),
                                  decoration: BoxDecoration(
                                      border: Border.all(),
                                      borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                ButtonBar(
                                  alignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                        icon: Icon(Icons.fiber_manual_record),
                                        onPressed: !(!isStreaming && !isReady) ? null : () {startDictation();}
                                    ),
                                    IconButton(
                                        icon: Icon(Icons.stop),
                                        onPressed: !(isStreaming && isReady) ? null : () {stopDictation();}
                                    ),
                                    IconButton(
                                        icon: Icon(Icons.content_copy),
                                        onPressed: () =>  textController.text += "test"
                                    ),
                                    IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () =>  textController.clear()
                                    ),
                                  ],
                                )
                              ],
                            ),
                            flex: 3,
                          )
                        ],
                      ),
                    ))
            )
        )
    );
  }

  void startDictation() {
    setState(() {
      isReady = false;
      isStreaming = true;
    });
    widget.mainController.initStream(onStreamingReady);
  }

  void stopDictation() {
    setState(() {
      isReady = false;
      isStreaming = false;
    });
    streamSub?.cancel();
    widget.mainController.stopStream();
  }

  void onStreamingReady() {
    setState(() {
      isReady = true;
    });
    StreamController<String> controller = widget.mainController.startStream();
    streamSub = controller.stream.listen((event) {
      textController.text += event;
      textController.text += "\n";
    });
  }
}