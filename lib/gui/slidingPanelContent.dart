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

  void displayMsg(String msg, {String topMsg}) {
    state.displayText(msg, topMsg : topMsg);
  }

  void displayLoading() {
    state.displayLoadingAnimation();
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
  String _topMsg = "";

  @override
  void initState() {
    super.initState();
  }

  void displayLoadingAnimation() {
    setState(() {
      _loadingDisplay = true;
      _displayedText = "";
    });

  }

  void displayText(String text, {String topMsg}) {
    setState(() {
      _topMsg = topMsg == null ? "LinTO says:" : "«$topMsg»";
      _displayedText = text;
      _loadingDisplay = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double windowWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 10),
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
            child: Container(
              child: _loadingDisplay ? FlareDisplay(assetpath: 'assets/icons/Loading.flr',
                  animationName: 'Alarm',
                  width: windowWidth * 0.25,
                  height: windowWidth * 0.25) : Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: AutoSizeText(_topMsg, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic), maxLines: 2, textAlign: TextAlign.left,),
                  ),
                  Spacer(),
                  Expanded(
                    flex: 5,
                    child: AutoSizeText(_displayedText,
                      style: TextStyle(fontSize: 50), maxLines: 4, textAlign: TextAlign.center,),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}