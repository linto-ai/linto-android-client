import 'package:flutter/material.dart';
import 'package:linto_flutter_client/gui/utils/flaredisplay.dart';

class SlidingPanel extends StatefulWidget {
  SlidingPanel({Key key}) : super(key: key);
  @override
  _SlidingPanel createState() => new _SlidingPanel();
}

class _SlidingPanel extends State<SlidingPanel> {
  @override
  void initState() {
    super.initState();
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
            child: FlareDisplay(assetpath: 'assets/icons/Loading.flr',
                animationName: 'Alarm',
                width: windowWidth * 0.25,
                height: windowWidth * 0.25),
          )
        ],
      ),
    );
  }
}