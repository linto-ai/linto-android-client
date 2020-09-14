import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linto_flutter_client/client/client.dart';
import 'package:linto_flutter_client/gui/clock.dart';
import 'package:linto_flutter_client/gui/meeting.dart';
import 'package:linto_flutter_client/gui/settings.dart';
import 'package:linto_flutter_client/gui/slidingPanelContent.dart';
import 'package:linto_flutter_client/logic/maincontroller.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:linto_flutter_client/gui/controls.dart';
import 'package:linto_flutter_client/logic/uicontroller.dart';
import 'package:linto_flutter_client/gui/webviews.dart';
import 'package:linto_flutter_client/gui/dialogs.dart';

class MainInterface extends StatefulWidget {
  final MainController mainController;

  MainInterface({Key key, this.mainController}) : super(key: key);

  @override
  _MainInterface createState() => new _MainInterface();
}

class _MainInterface extends State<MainInterface> implements VoiceUIController{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  MainController _mainController;
  bool isActiveView = true;
  SlidingPanel panel = SlidingPanel();
  ApplicationScope currentApplication;


  PanelController _controller = PanelController();
  @override
  void initState() {
    super.initState();
    _mainController = widget.mainController;
    _mainController.currentUI = this;
    _mainController.init();
    currentApplication = _mainController.client.currentScope;

  }
  @override
  Widget build(BuildContext context) {
   Orientation orientation = MediaQuery.of(context).orientation;
   return new WillPopScope(
     onWillPop: () async => false,
     child: Scaffold(
       key: _scaffoldKey,
       appBar: AppBar(
         title: Text(currentApplication.name),
         automaticallyImplyLeading: false,
         actions: <Widget>[
           IconButton(
              icon: const Icon(Icons.menu),
             onPressed: () {
               _scaffoldKey.currentState.openEndDrawer();
             },
           )
         ],
       ),
       endDrawer: Drawer(
         child: ListView(
           padding: EdgeInsets.zero,
           children: <Widget>[
             Container(
               child: DrawerHeader(
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                   children: <Widget>[
                     Text("Manage your device.")
                   ],
                 ),
                 decoration: BoxDecoration(
                     color: Colors.lightBlue
                 ),
               ),
               height: 120,
             ),
             Text("Current application:"),
             Card(
               child: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: <Widget>[
                   ListTile(
                     leading: Icon(Icons.brightness_1),
                     title: Text(currentApplication.name),
                     subtitle: Text(currentApplication.description),
                   ),
                 ],
               ),
             ),
             Divider(),
             Text("Applications:"),
             ...listScopes(currentApplication),
             Divider(),
             FlatButton.icon(
                 onPressed: () => displaySettings(),
                 icon: Icon(Icons.settings),
                 label: Text("Settings", textAlign: TextAlign.left,)),
             FlatButton.icon(
                 onPressed: () async {
                   await confirmDialog(context, "Disconnect ?").then((bool toDisconnect) {
                     if (toDisconnect) {
                       _mainController.userPreferences
                           .clientPreferences["keep_info"] = false;
                       _mainController.userPreferences.updatePrefs();
                       _mainController.disconnect();
                       Navigator.pop(context);
                     }
                  });
                 },
                 icon: Icon(Icons.person_outline),
                 label: Text("Disconnect", textAlign: TextAlign.left)),
           ],
         ),
       ),
       body: SafeArea(
           child: Center(
             child: SlidingUpPanel(
               panel: Center(
                   child : panel
               ),
               onPanelClosed: () => onPanelClosed(),
               body: Container(
                 decoration: BoxDecoration(
                   gradient: RadialGradient(
                     colors: [Color.fromRGBO(255, 255, 255, 1), Color.fromRGBO(213, 231, 242, 1)]
                   )
                 ),
                 child: Column(
                   children: <Widget>[
                     Expanded(
                       // Time and weather
                       child: Container(
                         padding: EdgeInsets.only(top: 10),
                         /*decoration: BoxDecoration(
                           border: Border.all(),
                         ),*/
                         child: Flex(
                           children: <Widget>[
                             Expanded(child: Clock()),
                           ],
                           direction: orientation == Orientation.portrait ? Axis.vertical : Axis.horizontal,
                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                         ),
                       ),
                       flex: orientation == Orientation.portrait ? 3: 2,
                     ),
                     Expanded(
                       child: Container(
                         child: GridView.count(
                           padding: const EdgeInsets.all(20),
                           primary: false,
                           crossAxisSpacing: 10,
                           mainAxisSpacing: 10,
                           crossAxisCount: orientation == Orientation.portrait ? 3 : 6,
                           children: <Widget>[
                             FlatButton(
                               child: Image.asset('assets/icons/meeting_blue.png', height: 80, width: 80,),
                               onPressed: () => displayMeeting(),
                             ),
                             FlatButton(
                               child: FittedBox(
                                 fit: BoxFit.fill,
                                 child: Icon(Icons.record_voice_over, color: Color.fromARGB(255, 60,187,242), size: 80,),
                               ),
                               onPressed: () async => await infoDialog(context, "Not Implemented"),
                             ),
                             FlatButton(
                                 child: FittedBox(
                                     fit: BoxFit.fill,
                                     child: Icon(Icons.recent_actors, color: Color.fromARGB(255, 60,187,242), size: 80,)
                                 ),
                               onPressed: () async => await infoDialog(context, "Not Implemented"),
                             ),
                             FlatButton(
                                 child: FittedBox(
                                     fit: BoxFit.fill,
                                     child: Icon(Icons.mic_none, color: Color.fromARGB(255, 60,187,242), size: 80,)
                                 ),
                               onPressed: () async => await infoDialog(context, "Not Implemented"),
                             ),
                             FlatButton(
                                 child: FittedBox(
                                     fit: BoxFit.fill,
                                     child: Icon(Icons.help_outline, color: Color.fromARGB(255, 60,187,242), size: 80,)
                                 ),
                               onPressed: () async => await infoDialog(context, "Not Implemented"),
                             )
                           ],
                         ),
                       ),
                       flex: 3,
                     ),
                     Expanded(
                       child: FlatButton(
                         child: Image.asset('assets/icons/linto_alpha.png',
                             height: orientation == Orientation.portrait ? 80: 80,
                             fit: BoxFit.contain),
                         onPressed: () => onLinToClicked(),
                       ),
                       flex: orientation == Orientation.portrait ? 2 : 2,
                     ),
                     Spacer(flex: orientation == Orientation.portrait ? 1 : 2,)
                   ],
                   mainAxisAlignment: MainAxisAlignment.spaceAround,
                 ),
               ),
               minHeight: 0,
               maxHeight: MediaQuery.of(context).size.height * 0.5,
               backdropEnabled: true,
               controller: _controller,
             ),
           )
       ),
     ),
   );
  }

  void expandPanel(){
  _controller.open();
  }

  void closePanel(){
  _controller.close();
  }

  void onLinToClicked(){
    _mainController.triggerKeyWord();
    expandPanel();
  }
  void onKeyword() {
    expandPanel();
  }

  void onPanelClosed() {
    _mainController.abord();
  }

  void displayMeeting() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => MeetingInterface()));
  }

  void notImplementedDisplay() async {

  }

  void displaySettings() async {
    bool disconnected = await Navigator.push(context, MaterialPageRoute(builder: (context) => OptionInterface(mainController: _mainController,)));
    if (disconnected) {
      _mainController.disconnect();
    } else if (_scaffoldKey.currentState.isEndDrawerOpen) {
      Navigator.pop(context); // Close the drawer when exiting settings.
    }
  }

  List<Card> listScopes(ApplicationScope currentApp) {
    List<Card> availableApplication = List<Card>();
    for (ApplicationScope scope in _mainController.client.scopes) {
      if (scope != currentApp) {
        availableApplication.add(
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.input),
                    title: Text(scope.name),
                    subtitle: Text(scope.description),
                  ),
                  ButtonBar(
                    children: <Widget>[
                      RaisedButton(
                        child: const Text("Switch to"),
                        onPressed: () {
                          _mainController.client.changeScope(scope);
                          setState(() {
                            currentApplication = _mainController.client.currentScope;
                          });

                        },
                      )
                    ],
                  )
                ],
              ),
            )
        );
      }
    }
    return availableApplication;
  }

  @override
  void onKeywordSpotted() {
    expandPanel();
  }

  @override
  void onLintoSpeakingStart() {
    panel.startSpeaking();
  }

  @override
  void onLintoSpeakingStop() {
    panel.stopSpeaking();
    Future.delayed(const Duration(seconds: 3)).whenComplete(() {
      closePanel();
    });
  }

  @override
  void onRequestPending() {
    panel.loading();
  }

  @override
  void onUtteranceCanceled() {
    closePanel();
  }

  @override
  void onUtteranceEnd() {
    // TODO: implement onUtteranceEnd
  }

  @override
  void onUtteranceStart() {
    panel.loading();
  }

  @override
  void onMessage(String msg) {
    expandPanel();
    panel.displayMsg(msg);
  }

  @override
  Future<void> onDisconnect() async{
    Navigator.pop(context, false);
  }

  @override
  void display(String content, bool isURL) {
    showWebviewDialog(context, content, isURL);
  }

  @override
  void onError(String errorMessage) {
    final snackBarError = SnackBar(
      content: Text(errorMessage),
      backgroundColor: Colors.red,
    );
    closePanel();
    _scaffoldKey.currentState.showSnackBar(snackBarError);
  }
}