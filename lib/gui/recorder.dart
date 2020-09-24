import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:linto_flutter_client/audio/audioPlayer.dart';
import 'package:linto_flutter_client/audio/audiomanager.dart';
import 'package:linto_flutter_client/gui/dialogs.dart';
import 'package:audioplayers/audioplayers.dart';


const  TMP_FILE_NAME = "recorder_tmp.raw";
const String SAVE_FOLDER = "/Documents/";

enum RecorderState {
  IDLE,
  RECORDING,
  RECORDINGPAUSED,
  PLAYINGSTOPPED,
  PLAYING
}

class RecorderInterface extends StatefulWidget {
  final AudioManager audioManager;
  final Audio audioPlayer;

  RecorderInterface(this.audioManager, this.audioPlayer, {Key key}) : super(key: key);

  @override
  _RecorderInterface createState() => new _RecorderInterface();
}

class _RecorderInterface extends State<RecorderInterface> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AudioPlayer _audioPlayer;

  RecorderState state = RecorderState.IDLE;

  String recordingPath;
  String recordedPath;

  Stopwatch timeWatch = Stopwatch(); // Record duration
  Timer updateTimer; // Update displayed duration
  String duration = "00:00";

  Duration audioPosition = Duration(seconds: 0);
  Duration audioDuration = Duration(seconds: 1);

  StreamSubscription _durationSubscription;
  StreamSubscription _positionSubscription;
  StreamSubscription _playerCompleteSubscription;

  @override
  void initState() {
    super.initState();
    _positionSubscription = widget.audioPlayer.onPositionChanged.listen((event) {onPositionChanged(event);});
    _initAudioPlayer();
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
          if (state != RecorderState.IDLE) {
            filename = await saveDialog(context, "Save recorded audio ? (Will be saved in Documents/)");
            if (filename != null) {
              await saveFile(filename);
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
                              child: Text(duration,
                                style: TextStyle(fontSize: 30),),
                              alignment: Alignment.center,
                            ),
                            flex: 2,
                          ),
                          Visibility(
                            visible: [RecorderState.PLAYING, RecorderState.PLAYINGSTOPPED].contains(state),
                            child: Container(
                              child: Slider(
                                value: audioPosition.inSeconds.toDouble(),
                                min: 0,
                                max: audioDuration.inSeconds.toDouble(),
                                onChanged: (value) {
                                  setState(() {
                                    audioPosition = Duration(seconds: value.toInt());
                                    changePosition(Duration(seconds: value.toInt()));
                                  });

                                },
                              ),
                            )
                          ),
                          Expanded(
                            flex: 1,
                            child: ButtonBar(
                              alignment: MainAxisAlignment.spaceAround,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.stop),
                                  onPressed: ![RecorderState.RECORDING, RecorderState.RECORDINGPAUSED, RecorderState.PLAYING].contains(state) ? null : () {
                                    if([RecorderState.RECORDING, RecorderState.RECORDINGPAUSED].contains(state)) {
                                      stopRecording();
                                    } else {
                                      stopPlaying();
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.play_arrow),
                                  onPressed: !(state == RecorderState.PLAYINGSTOPPED) ? null : () {
                                    setState(() {
                                      state = RecorderState.PLAYING;
                                      resumePlaying();
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
                                  onPressed: ![RecorderState.IDLE, RecorderState.PLAYINGSTOPPED].contains(state) ? null : () {
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
        ),
    );
  }

  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer();
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) => onDurationChanged(duration));
    _positionSubscription = _audioPlayer.onAudioPositionChanged.listen((position) => onPositionChanged(position));
    _playerCompleteSubscription = _audioPlayer.onPlayerCompletion.listen((event) => onPlayingCompletion());
  }

   Future<void> startRecording() async {
     if (state == RecorderState.PLAYINGSTOPPED) {
       // confirm dialog
       timeWatch.reset();
       updateDuration();
     }
     setState(() {
       state = RecorderState.RECORDING;
     });
     timeWatch.start();
     updateTimer = Timer.periodic(Duration(seconds: 1), (timer) { updateDuration();});
     recordingPath = await widget.audioManager.startRecording();
   }

   void startPlaying() {
     _audioPlayer.resume();
     setState(() {
       state = RecorderState.PLAYING;
     });
   }

   void changePosition(Duration position) {
    _audioPlayer.seek(position);
   }

   void resumeRecording() {
    setState(() {
      state = RecorderState.RECORDING;
    });
    timeWatch.start();
    updateTimer = Timer.periodic(Duration(seconds: 1), (timer) { updateDuration();});
   }

   void setPosition(double value) {
      _audioPlayer.seek(Duration(seconds: value.toInt()));
   }

   bool resumePlaying() {
     _audioPlayer.resume();
     setState(() {
       state = RecorderState.PLAYING;
     });
   }

   void pauseRecording() {
    setState(() {
      state = RecorderState.RECORDINGPAUSED;
    });
    timeWatch.stop();
    updateTimer.cancel();
    widget.audioManager.pauseRecording();
   }

   bool pausePlaying() {
     _audioPlayer.stop();
     setState(() {
       state = RecorderState.PLAYINGSTOPPED;
     });
   }

   Future<void> stopRecording() async {
     setState(() {
       state = RecorderState.PLAYINGSTOPPED;
     });
     timeWatch.stop();
     updateTimer.cancel();
     recordedPath = await widget.audioManager.stopRecording();
     _audioPlayer.setUrl(recordedPath, isLocal: true);
   }

   void onAudioPositionChanged(Duration position) {
    setState(() {
      audioPosition = position;
    });

   }

   void onDurationChanged(Duration duration) {
    setState(() {
      audioDuration = duration;
    });
   }

   void onPlayingCompletion() {
    setState(() {
      state = RecorderState.PLAYINGSTOPPED;
      audioPosition = Duration(seconds: 0);
    });
   }

   bool stopPlaying() {
    setState(() {
      state = RecorderState.PLAYINGSTOPPED;
      _audioPlayer.stop();
      _audioPlayer.seek(Duration(seconds: 0));
    });
   }


   /// Timer function for updating UI duration.
   String updateDuration() {
     var duration = timeWatch.elapsed;
     int padLength = duration.inMinutes > 99 ? 3 : 2;
     setState(() {
       this.duration = "${duration.inMinutes.toString().padLeft(padLength,"0")}:${duration.inSeconds.remainder(60).toString().padLeft(2, "0")}";
     });
   }

   /// Audio Player callback on position change.
   void onPositionChanged(Duration position) {
    setState(() {
      audioPosition = position;
    });
   }

   void saveFile(String fileName) async {
      File waveFile = File(recordedPath);
      waveFile.copy("/storage/emulated/0$SAVE_FOLDER$fileName.wav");
   }
}