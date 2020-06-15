import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

class Options {
  double notificationvolume;
  double speechVolume;
  String language;

  Future updateUserPref(double notif, double speech){
    notificationvolume = notif;
    speechVolume = speech;
  }

  Future loadUserPref() async {
    String content =  await rootBundle.loadString('assets/config/userpref.json');
    var data = json.decode(content)['system'];
    notificationvolume = data['notificationVolume'];
    speechVolume = data['notificationVolume'];
    language = data['language'];
  }
}
