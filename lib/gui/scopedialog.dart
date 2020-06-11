import 'package:flutter/material.dart';

Future<String> showScopeDialog(BuildContext context, Map<String, dynamic> scopes) async {

  var scopeKey = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select scope'),
          children: listOptions(context, scopes),
        );
      }
  );
  return scopeKey;
}

List<SimpleDialogOption> listOptions(BuildContext context, Map<String, dynamic> options) {
  List<SimpleDialogOption> dialogOptions = List<SimpleDialogOption>();
  for (String key in options.keys) {
    dialogOptions.add( SimpleDialogOption(
      child: Text(key),
      onPressed: () {
        Navigator.pop(context, options[key]);
        },
    ));
  }
  return dialogOptions;
}