import 'package:flutter/material.dart';
import 'package:linto_flutter_client/client/client.dart';
import 'package:linto_flutter_client/gui/clock.dart';
import 'package:linto_flutter_client/gui/meeting.dart';
import 'package:linto_flutter_client/gui/settings.dart';
import 'package:linto_flutter_client/gui/slidingPanelContent.dart';
import 'package:linto_flutter_client/logic/maincontroller.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
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

  bool isListening = true;

  PanelController _endDrawerController = PanelController();
  @override
  void initState() {
    super.initState();
    _mainController = widget.mainController;
    _mainController.currentUI = this;
    _mainController.init();
    currentApplication = _mainController.client.currentScope;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if(_mainController.userPreferences.getBool("first_login")) {
        await displayHelp();
        _mainController.userPreferences.setValue("first_login", false);
      }
    });

  }

  @override
  Widget build(BuildContext context) {
   Orientation orientation = MediaQuery.of(context).orientation;
   return new WillPopScope(
     onWillPop: () async {
       Navigator.popAndPushNamed(context, '/applications');
       return true;
     },
     child: Scaffold(
       key: _scaffoldKey,
       appBar: AppBar(
         title: Text(currentApplication.name),
         automaticallyImplyLeading: true,
         leading: IconButton(
           icon: const Icon(Icons.storage),
           onPressed: () {
             Navigator.popAndPushNamed(context, '/applications');
           },
         ),
         actions: <Widget>[
           IconButton(
              icon: const Icon(Icons.menu),
             onPressed: () {
               _scaffoldKey.currentState.openEndDrawer();
             },
           )
         ],
       ),
       drawer: Container(
         width: 120,
         child: Drawer(
           child: ListView(
             padding: EdgeInsets.zero,
             children: [
               Container(
                 height: 100,
                 child: DrawerHeader(
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                     children: <Widget>[
                       Text("Tools", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                     ],
                   ),
                   decoration: BoxDecoration(
                       color: Colors.lightBlue
                   ),
                 ),
               ),
               Column(
                 children: [
                   Text("Recorder", style: TextStyle(color: Colors.lightBlue, fontSize: 18, fontWeight: FontWeight.bold),),
                   FlatButton(
                     child: FittedBox(
                         fit: BoxFit.fill,
                         child: Icon(Icons.mic_none, color: Color.fromARGB(255, 60,187,242), size: 80,)
                     ),
                     onPressed: ()  async {
                       displayRecorder();
                     },
                   ),
                 ],
               ),
               Column(
                 children: [
                   Text("Dictation", style: TextStyle(color: Colors.lightBlue, fontSize: 18, fontWeight: FontWeight.bold),),
                   FlatButton(
                     child: FittedBox(
                         fit: BoxFit.fill,
                         child: Icon(Icons.record_voice_over, color: Color.fromARGB(255, 60,187,242), size: 80,)
                     ),
                     onPressed: () async {
                       _mainController.audioManager.stopDetecting();
                       await Navigator.popAndPushNamed(context, '/dictation');
                       if (isListening) _mainController.audioManager.startDetecting();
                     }
                   ),
                 ],
               ),
               Column(
                 children: [
                   Text("About", style: TextStyle(color: Colors.lightBlue, fontSize: 18, fontWeight: FontWeight.bold),),
                   FlatButton(
                     child: FittedBox(
                         fit: BoxFit.fill,
                         child: Icon(Icons.help_outline, color: Color.fromARGB(255, 60,187,242), size: 80,)
                     ),
                     onPressed: () async => await aboutDialog(context, _mainController.client.version),
                   )
                 ],
               ),
             ],
           ),
         ),
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
                     Text("Manage your device", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),)
                   ],
                 ),
                 decoration: BoxDecoration(
                     color: Colors.lightBlue
                 ),
               ),
               height: 100,
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
                       _mainController.disconnect();
                       Navigator.popAndPushNamed(context, '/login');
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
                           crossAxisCount: orientation == Orientation.portrait ? 3 : 5,
                           children: <Widget>[],
                         ),
                       ),
                       flex: 3,
                     ),
                     Expanded(
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                         crossAxisAlignment: orientation == Orientation.portrait? CrossAxisAlignment.center: CrossAxisAlignment.start,
                         children: [
                           FlatButton(
                             child: FittedBox(
                                 fit: BoxFit.fill,
                                 child: Icon(Icons.apps, color: Color.fromARGB(255, 60,187,242), size: 60,)
                             ),
                             onPressed: () => _scaffoldKey.currentState.openDrawer(),
                           ),
                           FlatButton(
                             child: Image.asset('assets/icons/linto_alpha.png',
                                 height: orientation == Orientation.portrait ? 100: 100,
                                 fit: BoxFit.contain),
                             onPressed: () => onLinToClicked(),
                             onLongPress: null, // Mute ?
                           ),
                           FlatButton(
                             child:  Image.asset(isListening ? 'assets/icons/mic_on.png' : 'assets/icons/mic_off.png',
                                 height: 60,
                                 fit: BoxFit.contain),
                             onPressed: () {
                               setState(() {
                                 isListening = !isListening;
                                 isListening ? _mainController.audioManager.startDetecting() : _mainController.audioManager.stopDetecting();
                               });
                             },
                             onLongPress: null, // Mute ?
                           ),

                         ]
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
               controller: _endDrawerController,
             ),
           )
       ),
     ),
   );
  }

  void displayHelp() async {
    await helpDialog(context, MainAxisAlignment.center, "This is LinTO main interface. You can interact with your assistant by saying \"LinTO !\"");
    await helpDialog(context, MainAxisAlignment.center, "On the top left corner your can change the current application.",
      displayWidget :  Icon(Icons.storage, color: Colors.lightBlue,));
    await helpDialog(context, MainAxisAlignment.center, "On the top right corner your can access the application settings.",
        displayWidget :  Icon(Icons.menu, color: Colors.lightBlue,));
    await helpDialog(context, MainAxisAlignment.center, "You can access the tools on the botton left corner.",
        displayWidget :  Icon(Icons.apps, color: Colors.lightBlue,));
    await helpDialog(context, MainAxisAlignment.center, "Tap on LinTO to start an vocal interaction.");
    await helpDialog(context, MainAxisAlignment.center, "Don't want to be listenned ? Toggle the microphone on the bottom right icon.",
        displayWidget :  Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Image.asset('assets/icons/mic_on.png',
              height: 60,
              fit: BoxFit.contain),
          Image.asset('assets/icons/mic_off.png',
              height: 60,
              fit: BoxFit.contain),
        ],));
  }

  void expandPanel(){
  _endDrawerController.open();
  }

  void closePanel(){
  _endDrawerController.close();
  }

  void onLinToClicked(){
    _mainController.triggerKeyWord();
    expandPanel();
  }
  void onKeyword() {
    expandPanel();
  }

  void onPanelClosed() {
    panel.displayLoading();
    _mainController.abord();
    isListening ? _mainController.audioManager.startDetecting() : _mainController.audioManager.stopDetecting();
  }

  void displayMeeting() async{
    var ret = await newMeetingDialog(context);
    if (ret == null) return;
    Navigator.push(context, MaterialPageRoute(builder: (context) => MeetingInterface(ret)));
  }

  void displayRecorder() async {
    _mainController.audioManager.stopDetecting();
    await Navigator.pushNamed(context, '/recorder');
    if(isListening) {
      _mainController.audioManager.startDetecting();
    }

  }

  void displaySettings() async {
    bool disconnected = await Navigator.push(context, MaterialPageRoute(builder: (context) => OptionInterface(mainController: _mainController,)));
    if (disconnected ?? false) {
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
  void onMessage(String msg, {String topMsg}) {
    expandPanel();
    panel.displayMsg(msg, topMsg: topMsg); // Temporary, ponctuation and capitalisation are meant to be set server-side.
  }

  @override
  Future<void> onDisconnect() async{
    Navigator.popAndPushNamed(context, '/login');
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