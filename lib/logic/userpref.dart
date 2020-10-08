import 'dart:io';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String KEYSTOREPASSKEYC = "linto_cred_password";
const String KEYSTOREPASSKEYM = "linto_mqtt_password";

/// User preferences holds client and system preference and allows them to persist between sessions.
class UserPreferences {

  static const Map<String, dynamic> INITIAL_PREF = {
    "first_login" : true,
    "reconnect" : false,
    "keep_info" : false,
    "auth_cred" : true,
    "cred_server" : "https://",
    "cred_route" : "",
    "cred_login" : "",
    "cred_app" : "",
    "direct_sn" : "",
    "direct_ip" : "",
    "direct_port" : "",
    "direct_id" :"",
    "direct_app" : "",
    "notif_volume" : 1.0,
    "speech_volume" : 1.0
  };

  String _passwordC;
  String _passwordM;
  SharedPreferences _preferences;

  File prefFile;

  FlutterSecureStorage storage = FlutterSecureStorage();

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
    if(!_preferences.containsKey("first_login")) {
      setValues(INITIAL_PREF);
    }
    _passwordC = await storage.read(key: KEYSTOREPASSKEYC);
    _passwordM = await storage.read(key: KEYSTOREPASSKEYM);
  }

  void setValues(Map<String, dynamic> values) {
    for(String key in values.keys) {
      switch(values[key].runtimeType) {
        case bool: {
          _preferences.setBool(key, values[key]);
        }
        break;
        case int: {
          _preferences.setInt(key, values[key]);
        }
        break;
        case double: {
          _preferences.setDouble(key, values[key]);
        }
        break;
        case String: {
          _preferences.setString(key, values[key]);
        }
        break;
        default : {
          continue;
        }
      }
    }
    return;
  }

  void resetValue() {
    setValues(INITIAL_PREF);
  }

  String getString (String key) {
    return _preferences.containsKey(key) ? _preferences.getString(key) : null;
  }

  bool getBool (String key) {
    return _preferences.containsKey(key) ? _preferences.getBool(key) : null;
  }

  double getDouble (String key) {
    return _preferences.containsKey(key) ? _preferences.getDouble(key) : null;
  }

  void setValue(String key, var value) {
    switch(value.runtimeType) {
      case int: {
        _preferences.setInt(key, value);
      }
      break;
      case double: {
        _preferences.setDouble(key, value);
      }
      break;
      case String: {
        _preferences.setString(key, value);
      }
      break;
      case bool: {
        _preferences.setBool(key, value);
      }
      break;
      default : {
      }
    }
  }

  set passwordC(String password) {
    this._passwordC = password;
    storage.write(key: KEYSTOREPASSKEYC, value: password);
  }

  String get passwordC {
    return _passwordC;
  }

  set passwordM(String password) {
    this._passwordM = password;
    storage.write(key: KEYSTOREPASSKEYM, value: password);
  }

  String get passwordM {
    return _passwordM;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> content = Map<String, dynamic>();
    for(String key in INITIAL_PREF.keys) {
      content[key] = _preferences.get(key);
    }
    return content;
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
