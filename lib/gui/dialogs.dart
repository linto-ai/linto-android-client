import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:linto_flutter_client/client/client.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;

/// Displays application description dialog and provides a selection button.
/// Returns Future<True> if application is selected.
Future<bool> showScopeDialog(BuildContext context, ApplicationScope scope) async {
  List<Card> skillList(List<dynamic> skills) {
    if (skills.length == 0) {
      return [Card(
        child: Text("No informations provided", textAlign: TextAlign.center,),
      )];
    }
    return skills.map((skill) {
      return Card(
        child: Text( skill["name"],
          textAlign: TextAlign.center,
        ),
      );
    }).toList();
  }
  var useScope = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text(scope.name, textAlign: TextAlign.center,),
        contentPadding: EdgeInsets.all(20),
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.5,
            child: ListView(
                  children: [
                    Text(scope.description, maxLines: 5,),
                    RaisedButton(
                      child: Text("Use this application"),
                      onPressed: () => Navigator.pop(context, true),
                    ),
                    Divider(),
                    Text("Available skills:"),
                    ...skillList(scope.skills)
                  ],
            ),
          ),
        ]
      );
    }
  );
  return useScope;
}
/// Route selection dialog
Future<Map<String, dynamic>> showRoutesDialog(BuildContext context, String title, List<dynamic> options) async {
  var scopeKey = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(title),
          children: listRoutes(context, options),
        );
      }
  );
  return scopeKey;
}
/// Route selection options
List<SimpleDialogOption> listRoutes(BuildContext context, List<dynamic> options) {
  List<SimpleDialogOption> dialogOptions = List<SimpleDialogOption>();
  for (Map<String, dynamic> entry in options) {
    dialogOptions.add( SimpleDialogOption(
      child: Text(entry['type']),
      onPressed: () {
        Navigator.pop(context, entry);
      },
    ));
  }
  return dialogOptions;
}

/// Disconnect confirm dialog
Future<bool> confirmDialog(BuildContext context, String title, {String confirmText : "Disconnect", String description : ""}) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text(title),
        children: <Widget>[
          Text(description, textAlign: TextAlign.center,),
          SimpleDialogOption(
            child: Text(confirmText),
            onPressed: () {
              Navigator.pop(context, true);
            }),
          SimpleDialogOption(
            child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context, false);
              }),
        ],
      );
    }
  );
}

/// Simple information dialog with dismiss button.
Future<void> infoDialog(BuildContext context, String message) async {
  return await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text(message),
        children: <Widget>[
          SimpleDialogOption(
              child: Text("Dismiss"),
              onPressed: () {
                Navigator.pop(context, true);
              }),
        ],
      );
    }
  );
}

/// Save or ignore dialog, returns a filename.
Future<String> saveDialog(BuildContext context, String message) async {
  TextEditingController fileName = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          contentPadding: EdgeInsets.all(10),
          title: Text(message, maxLines: 3,),
          children: <Widget>[
            Column(
              children: [
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: fileName,
                    decoration: InputDecoration(
                      labelText: 'File name'
                  ),
                    inputFormatters: [FilteringTextInputFormatter.allow((RegExp(r'[a-zA-Z0-9@\-.]')))],
                    validator: (value) {
                      if (value.isEmpty) return "A file needs a name";
                      else return null;
                    },
                  ),
                ),
                Row(
                  children: [
                    SimpleDialogOption(
                        child: Text("Ignore"),
                        onPressed: () {
                          Navigator.pop(context, null);
                    }),
                    SimpleDialogOption(
                        child: Text("Save"),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            Navigator.pop(context, fileName.value.text);
                          }
                        }
                    ),
                  ],
                )
              ],
            )
          ],
        );
      }
  );
}

Future<Map<String, dynamic>> newMeetingDialog(BuildContext context) async {
  TextEditingController meetingName = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  return await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text("Meeting"),
        contentPadding: EdgeInsets.all(20),
        children: [
          Form(
            key: _formKey,
            child: TextFormField(
              controller: meetingName,
              decoration: InputDecoration(
                  labelText: "Meeting Name"
              ),
              validator:(value)  {
                if (value.isEmpty || value == "https://") {
                  return 'Please enter a meeting name';
                }
                return null;
              },
            ),
          ),
          Row(
            children: [
              SimpleDialogOption(
                child: Text("Cancel"),
                onPressed: () {
                  return Navigator.pop(context,null);
                },
              ),
              SimpleDialogOption(
                child: Text("Create Meeting"),
                onPressed: () {
                  if(_formKey.currentState.validate()) {
                    return Navigator.pop(context,{"meeting_name": meetingName.value.text});
                  }
                },
              )
            ],
          )
        ],
      );
    }
  );
}

Future<void> aboutDialog(BuildContext context, String clientVersion) async {
  return await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          contentPadding: EdgeInsets.all(20),
          title: Text("LinTO Android Client"),
          children: <Widget>[
            Text("Client version: $clientVersion"),
            Text(" "),
            RichText(
              text: TextSpan(
                text: 'An issue ? Report on ',
                style: TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: "github",
                    style: TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () { launch('https://github.com/linto-ai/linto-android-client/issues');
                      },
                  )
                ],

              )),
            Text(" "),
            RichText(
                text: TextSpan(
                  text: 'More about LinTO on ',
                  style: TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: "linto.ai",
                      style: TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () { launch('https://linto.ai');
                        },
                    )
                  ],

                )),
            Text(" "),
            FlatButton(
              child: Image.asset('assets/icons/linagora-labs.png',
                fit: BoxFit.contain,
                width: 200,),
                onPressed: () => launch("https://research.linagora.com"),
                ),
            SimpleDialogOption(
                child: Text("Dismiss", textAlign: TextAlign.right,),
                onPressed: () {
                  Navigator.pop(context, true);
                }),
          ],
        );
      }
  );
}

Future<void> helpDialog(BuildContext context, MainAxisAlignment position, String text ,{Widget displayWidget}) async {
  const double imageSize = 80.0;
  return await showDialog<void>(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext context) {
      return new Column(
        mainAxisAlignment: position,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: imageSize, bottom: 20, left: 20, right: 20),
                  child: Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width - 20,
                    padding: EdgeInsets.only(top: imageSize / 4 + 10, bottom: 10, left: 10, right: 10),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(220, 255, 255, 255),
                      border: Border.all(
                          color: Colors.lightBlue,
                          width: 2
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(text,
                          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.normal, decoration: TextDecoration.none), maxLines: 5,),
                        displayWidget == null ? Container() : displayWidget
                      ],
                    )
                  ),
                ),
                Positioned(
                  child: Image.asset('assets/icons/linto_alpha.png', height: 100,),
                  left: MediaQuery.of(context).size.width / 2 - imageSize / 2 - 10,
                  top: imageSize / 4 - 10,
                )
              ],
            ),
          )
        ]
      );
    }
  );
}