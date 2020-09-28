import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:linto_flutter_client/client/client.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;


/// Scope selection dialog
Future<ApplicationScope> showScopesDialog(BuildContext context, String title, List<ApplicationScope> options) async {
  var scope = await showDialog<ApplicationScope>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(title),
          children: listOptions(context, options),
        );
      }
  );
  return scope;
}

Future<bool> showScopeDialog(BuildContext context, ApplicationScope scope) async {
  var useScope = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text(scope.name, textAlign: TextAlign.center,),
        contentPadding: EdgeInsets.all(20),
        children: [
          Text(scope.description, maxLines: 5,),
          RaisedButton(
            child: Text("Use this application"),
            onPressed: () => Navigator.pop(context, true),
          ),
          ]
      );
    }
  );
  return useScope;
}

/// Scope selection items
List<SimpleDialogOption> listOptions(BuildContext context, List<ApplicationScope> scopes) {
  List<SimpleDialogOption> dialogOptions = List<SimpleDialogOption>();
  for (ApplicationScope entry in scopes) {
    dialogOptions.add( SimpleDialogOption(
      child: FlatButton(
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
               ListTile(
                leading: Icon(Icons.blur_circular),
                title: Text(entry.name),
                subtitle: Text(entry.description, maxLines: 4,),
              ),
            ],
          ),
        ),
        onPressed: () => Navigator.pop(context, entry),

      )
    ));
  }
  return dialogOptions;
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
Future<bool> confirmDialog(BuildContext context, String title, {String description : ""}) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return SimpleDialog(
        title: Text(title),
        children: <Widget>[
          Text(description),
          SimpleDialogOption(
            child: Text("Disconnect"),
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