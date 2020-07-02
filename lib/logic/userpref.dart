import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

const String PREFFILE = "userpref.json";
const String TEMPLATEPATH = "assets/config/userpref.json";

/// User preferences holds client and system preference and allows them to persist between sessions.
class UserPreferences {
  Map<String, dynamic> clientPreferences;
  Map<String, dynamic> systemPreferences;

  File prefFile;

  Future<void> init() async {
     await _loadPrefs();
  }

  /// Reads the user preferences from localpath/userprefs.json.
  /// If the file does not exist, copy template from assets/config/userpref.json
  Future<void> _loadPrefs() async {
    if (prefFile == null) {
      // fetch local path
    }
    var directory = await getApplicationDocumentsDirectory();
    String localPath = directory.path;

    print("Loading user preferences from userprefs.json ...");
    prefFile = File("$localPath/userprefs.json");
    await prefFile.exists().then((bool exist) async {
      if (!exist) {
        await createPrefs();
      }
    });

    try {
      await _readPrefs(prefFile);
    } on Exception catch(error) {
      print("Error while reading prefs: $error");
      await createPrefs();
      await _readPrefs(prefFile);
    }
    return;
  }

  void _readPrefs(File prefFile) async {
    String prefContent = await prefFile.readAsString();
    var preferences = jsonDecode(prefContent);
    clientPreferences = preferences["client"];
    systemPreferences = preferences["system"];
    print('User preferences loaded.');
  }

  void createPrefs() async {
    print('userprefs.json does not exist, creating from template ...');
    String basePrefs =  await rootBundle.loadString('assets/config/userpref.json');
    var serialized = jsonEncode(jsonDecode(basePrefs));
    await prefFile.writeAsString(serialized);
  }

  /// Get the user preferences file reference.
  /// If the file does not exist, it creates it from template.
  Future<File> _getPrefFile() async {
    await getApplicationDocumentsDirectory().then((var directory) async {
      String filePath = "${directory.path}/$PREFFILE";
      await prefFile.exists().then((bool exist) async{
        if (!exist) {
          String basePrefs =  await rootBundle.loadString('assets/config/userpref.json');
        }
      });
    });
  }

  /// Write current user preferences to the local preferences file.
  void updatePrefs() async {
    await prefFile.writeAsString(jsonEncode(this.toMap()));
    print('User preferences updated');
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> content = Map<String, dynamic>();
    content['client'] = clientPreferences;
    content['system'] = systemPreferences;
    return content;
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
