import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String PREFFILE = "userpref.json";
const String TEMPLATEPATH = "assets/config/userpref.json";
const String KEYSTOREPASSKEYC = "linto_cred_password";
const String KEYSTOREPASSKEYM = "linto_mqtt_password";

/// User preferences holds client and system preference and allows them to persist between sessions.
class UserPreferences {
  Map<String, dynamic> clientPreferences;
  Map<String, dynamic> systemPreferences;
  String passwordC;
  String passwordM;

  File prefFile;

  FlutterSecureStorage storage = FlutterSecureStorage();

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
    try {
      passwordC = await storage.read(key: KEYSTOREPASSKEYC);
      passwordM = await storage.read(key: KEYSTOREPASSKEYM);
    } on Exception catch(error) {
      print(error);
      passwordC = "";
      passwordM = "";
    }
    systemPreferences = preferences["system"];
    print('User preferences loaded.');
  }

  void createPrefs() async {
    print('userprefs.json does not exist, creating from template ...');
    String basePrefs =  await rootBundle.loadString('assets/config/userpref.json');
    var serialized = jsonEncode(jsonDecode(basePrefs));
    await prefFile.writeAsString(serialized);
  }

  void updatePasswordC(String password) async {
    this.passwordC = password;
    storage.write(key: KEYSTOREPASSKEYC, value: password);
  }

  void updatePasswordM(String password) async {
    this.passwordM = password;
    storage.write(key: KEYSTOREPASSKEYM, value: password);
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
