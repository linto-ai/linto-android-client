import 'package:flutter/material.dart';
import 'package:linto_flutter_client/gui/utils/flaredisplay.dart';
import 'package:auto_size_text/auto_size_text.dart';

class SlidingPanel extends StatefulWidget {
  SlidingPanel({Key key}) : super(key: key);
  _SlidingPanel state;
  @override
  _SlidingPanel createState() {
    state =  new _SlidingPanel();
    return state;
  }

  void displayMsg(String msg) {
    state.displayText(msg);
  }

  void startSpeaking() {

  }

  void stopSpeaking() {

  }

  void loading() {
    state.displayLoadingAnimation();
  }
}

class _SlidingPanel extends State<SlidingPanel> {
  bool _loadingDisplay = true;
  String _displayedText = "";

  @override
  void initState() {
    super.initState();
  }

  void displayLoadingAnimation() {
    setState(() {
      _loadingDisplay = true;
    });

  }

  void displayText(String text) {
    setState(() {
      _displayedText = text;
      _loadingDisplay = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double windowWidth = MediaQuery.of(context).size.width;
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            child: FlareDisplay(assetpath: 'assets/linto/linto.flr',
                animationName: 'idle',
                width: windowWidth * 0.25,
                height: windowWidth * 0.25),
            flex: 1,
          ),
          Expanded(
            flex: 2,
            child: _loadingDisplay ? FlareDisplay(assetpath: 'assets/icons/Loading.flr',
                animationName: 'Alarm',
                width: windowWidth * 0.25,
                height: windowWidth * 0.25) :
                  AutoSizeText(_displayedText,
                    style: TextStyle(fontSize: 40), maxLines: 4,),
          )
        ],
      ),
    );
  }
}