import 'package:flutter/material.dart';


/// Scope selection dialog
Future<String> showScopeDialog(BuildContext context, String title, List<dynamic> options) async {
  var scopeKey = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(title),
          children: listOptions(context, options),
        );
      }
  );
  return scopeKey;
}

/// Scope selection items
List<SimpleDialogOption> listOptions(BuildContext context, List<dynamic> options) {
  List<SimpleDialogOption> dialogOptions = List<SimpleDialogOption>();
  for (Map<String, dynamic> entry in options) {
    dialogOptions.add( SimpleDialogOption(
      child: Text(entry['name']),
      onPressed: () {
        Navigator.pop(context, entry['topic']);
        },
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

/// Simple yes/no dialog

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