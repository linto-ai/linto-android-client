import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linto_flutter_client/logic/maincontroller.dart';



class DictationInterface extends StatefulWidget {
  final MainController mainController;

  DictationInterface(this.mainController, {Key key}) : super(key: key);

  @override
  _DictationInterface createState() => new _DictationInterface();
}

class _DictationInterface extends State<DictationInterface> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int cursorPos = 0;
  bool isStreaming = false;
  bool isReady = false;

  StreamSubscription streamSub;
  String currentText = " ";

  Timer timeout;

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
          timeout?.cancel();
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
                            flex: 4,
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Text(currentText),
                              ),
                            ),
                            flex: 6,
                          ),
                          Expanded(
                            flex: 1,
                            child: ButtonBar(
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
                                    onPressed: () =>  copyToClipboard()
                                ),
                                IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      setState(() {
                                        currentText = "";
                                      });
                                      cursorPos = 0;
                                    }
                                ),
                              ],
                            )
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
    timeout = Timer(Duration(seconds: 5) ,onTimeout);
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
    timeout.cancel();
    setState(() {
      isReady = true;
    });
    StreamController<Map<String, dynamic>> controller = widget.mainController.startStream();
    streamSub = controller.stream.listen((event) {
      onText(event);
    });
  }
  void onText(Map<String, dynamic> input) {
    if (input.keys.contains("partial")) {
      currentText = currentText.substring(0, cursorPos);
      currentText += "${input["partial"]}";
    } else {
      currentText = currentText.substring(0, cursorPos);
      currentText += "${input["text"]}.\n";
      cursorPos += input["text"].length + 1;
    }
    setState(() {
      currentText = currentText;
    });
  }

  void onTimeout() {
    setState(() {
      isStreaming = false;
    });
    final snackBarError = SnackBar(
      content: Text("Failed to init streaming service."),
      backgroundColor: Colors.red,
    );
    _scaffoldKey.currentState.showSnackBar(snackBarError);
  }

  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: currentText));
    final snackBarError = SnackBar(
      content: Text("Text copied to clipboard"),
      backgroundColor: Color(0x3db5e4),
    );
    _scaffoldKey.currentState.showSnackBar(snackBarError);
  }
}