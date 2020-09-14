import 'package:flutter/material.dart';
import 'package:linto_flutter_client/client/client.dart';


/// Scope selection dialog
Future<ApplicationScope> showScopeDialog(BuildContext context, String title, List<ApplicationScope> options) async {
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