package com.linagora.linto_flutter_client;

import android.content.res.AssetFileDescriptor;
import android.content.res.AssetManager;
import android.util.Log;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
  //private MethodChannel tfChannel;
  private static final String TF_CHANNEL = "tf_lite";
  private static final String VAD_CHANNEL = "vader";
  private tflite interpreter = new tflite();
  private VADer vader = new VADer();
  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
    createChannels(flutterEngine);
  }
    private void createChannels(FlutterEngine flutterEngine) {
      new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), TF_CHANNEL).setMethodCallHandler(
              (call, result) -> {
                  if (call.method.equals("loadModel")) {
                      String filePath = call.argument("modelPath");
                      try {
                          interpreter.loadModel(getAssets(), filePath);
                          Log.v("Channel", filePath);
                          result.success(true);
                      } catch (Exception e) {
                          result.error(null, "Failed to load TF model", e.getMessage());
                      }
                  } else if (call.method.equals("detect")) {
                      byte[] input = call.argument("input");
                      if (!interpreter.isReady()) {
                          result.error(null, "Failed to detect.", "Model hasn't been loaded.");
                      } else {
                          double res = interpreter.detect(input);
                          Log.v("Interpreter", "Prob is " + res);
                          result.success(res);
                      }

                  } else {
                      result.notImplemented();
                  }
              }
      );
      new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), VAD_CHANNEL).setMethodCallHandler(
              (call, result) -> {
                  if (call.method.equals("isSpeech")) {
                      byte[] frame = call.argument("frame");
                      result.success(vader.isSpeech(frame));
                  } else {
                      result.notImplemented();
                  }
              }
      );
    }

}
