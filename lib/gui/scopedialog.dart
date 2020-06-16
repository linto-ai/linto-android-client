import 'package:flutter/material.dart';

Future<String> showScopeDialog(BuildContext context, String title, List<Map<String, String>> options) async {

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

List<SimpleDialogOption> listOptions(BuildContext context, List<Map<String, String>> options) {
  List<SimpleDialogOption> dialogOptions = List<SimpleDialogOption>();
  for (Map<String, String> entry in options) {
    dialogOptions.add( SimpleDialogOption(
      child: Text(entry['name']),
      onPressed: () {
        Navigator.pop(context, entry['topic']);
        },
    ));
  }
  return dialogOptions;
}

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