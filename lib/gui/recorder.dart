import 'dart:async';
import 'package:flutter/material.dart';
import 'package:linto_flutter_client/audio/audiomanager.dart';
import 'package:linto_flutter_client/gui/dialogs.dart';
import 'package:linto_flutter_client/audio/utils/wav.dart';


const  TMP_FILE_NAME = "recorder_tmp.raw";
enum RecorderState {
  PAUSED,
  STOPPED,
  RECORDING,
  PLAYING
}

class RecorderInterface extends StatefulWidget {
  final AudioManager audioManager;
  RecorderInterface(this.audioManager, {Key key}) : super(key: key);

  @override
  _RecorderInterface createState() => new _RecorderInterface();
}

class _RecorderInterface extends State<RecorderInterface> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  RecorderState state = RecorderState.STOPPED;
  bool _hasAudio = false;
  Stopwatch timeWatch = Stopwatch(); // Record duration
  Timer updateTimer; // Update displayed duration
  String duration = "00:00";

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
          if (state == RecorderState.RECORDING) stopRecording();
          else if (state == RecorderState.PLAYING) stopPlaying();
          String filename;
          if (_hasAudio) {
            filename = await saveDialog(context, "Save recorded audio ?");
            if (filename != null) {
              rawToWav(TMP_FILE_NAME, filename);
            }
          }
          if(updateTimer != null) {
            updateTimer.cancel();
          }

          return true;
        },
        child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text("Recorder"),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    _scaffoldKey.currentState.openEndDrawer();
                  },
                )
              ],
            ),
            body: SafeArea(
              child: Center(
                child: Flex(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  direction: orientation == Orientation.portrait ? Axis.vertical: Axis.horizontal,
                  children: [
                    Expanded(
                      flex: orientation == Orientation.portrait ? 4 : 5,
                      child: Image.asset('assets/icons/microphone.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 15,
                                  color: (() {
                                    switch(state) {
                                      case RecorderState.RECORDING : {
                                        return Colors.greenAccent;
                                      }
                                      break;
                                      case RecorderState.PLAYING : {
                                        return Colors.lightBlueAccent;
                                      }
                                      break;
                                      default : {
                                        return Colors.red;
                                      }
                                    }
                                  }()),
                                ),
                              ),
                              child: Text(duration, style: TextStyle(fontSize: 30),),
                              alignment: Alignment.center,
                            ),
                            flex: 2,
                          ),
                          Expanded(
                            flex: 1,
                            child: ButtonBar(
                              alignment: MainAxisAlignment.spaceAround,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.stop),
                                  onPressed: ![RecorderState.RECORDING, RecorderState.PLAYING].contains(state) ? null : () {
                                    if( state == RecorderState.RECORDING) {
                                      stopRecording();
                                    } else {
                                      stopPlaying();
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.play_arrow),
                                  onPressed: ![RecorderState.PAUSED, RecorderState.STOPPED].contains(state) ? null : _hasAudio ? null : () {
                                    setState(() {
                                      state = RecorderState.PLAYING;
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.pause),
                                  onPressed: ![RecorderState.PLAYING, RecorderState.RECORDING].contains(state) ? null : () {
                                    if (state == RecorderState.RECORDING) {
                                      pauseRecording();
                                    } else {
                                      pausePlaying();
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.fiber_manual_record, color: state == RecorderState.RECORDING ? Colors.grey : Colors.red,),
                                  onPressed: ![RecorderState.PAUSED, RecorderState.STOPPED].contains(state) ? null : () {
                                    startRecording();
                                  },
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          endDrawer: Drawer(
            child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[],
            ),
          ),
        ),
    );
  }
   void startRecording() {
     if (state == RecorderState.STOPPED) {
       if (_hasAudio) {

       }
       timeWatch.reset();
       updateDuration();
     }
     setState(() {
       _hasAudio = true;
       state = RecorderState.RECORDING;
     });
     timeWatch.start();
     updateTimer = Timer.periodic(Duration(seconds: 1), (timer) { updateDuration();});
     widget.audioManager.startRecording(TMP_FILE_NAME);
   }

   bool startPlaying() {}

   void resumeRecording() {

    setState(() {
      state = RecorderState.RECORDING;
    });
    timeWatch.start();
    updateTimer = Timer.periodic(Duration(seconds: 1), (timer) { updateDuration();});
   }

   bool resumePlaying() {}

   void pauseRecording() {
    setState(() {
      state = RecorderState.PAUSED;
    });
    timeWatch.stop();
    updateTimer.cancel();
    widget.audioManager.pauseRecording();
   }

   bool pausePlaying() {}

   bool stopRecording() {
     setState(() {
       state = RecorderState.STOPPED;
     });
     timeWatch.stop();
     updateTimer.cancel();
     widget.audioManager.stopRecording();
   }

   bool stopPlaying() {}

   /// Saves temporary recording file to device user directory.
   void saveAudio(String filename) {

   }

   /// Timer function for updating UI duration.
   String updateDuration() {
     var duration = timeWatch.elapsed;
     int padLength = duration.inMinutes > 99 ? 3 : 2;
     setState(() {
       this.duration = "${duration.inMinutes.toString().padLeft(padLength,"0")}:${duration.inSeconds.remainder(60).toString().padLeft(2, "0")}";
     });
   }

}