import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


Future<void> showWebviewDialog(BuildContext context, String content, bool isUrl) async {
  var scopeKey = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        var screenSize = MediaQuery.of(context).size;
        return SimpleDialog(
          children: [
            Container(
              child: WebviewDisplay(content, isUrl),
              height: screenSize.height * 0.90,
              width: screenSize.width *0.8,
          )]
        );
      }
  );
  return scopeKey;
}

class WebviewDisplay extends StatelessWidget {
  String _url = 'https://flutter.dev';
  final Completer<WebViewController> _controller = Completer<WebViewController>();

  WebviewDisplay(String content, bool isURL) {
    if(isURL) {
      _url = content;
    } else {
      String contentBase64 = base64Encode(const Utf8Encoder().convert(content));
      _url = 'data:text/html;base64,$contentBase64';
    }
  }

  Widget build(BuildContext context) {
    return WebView(
      initialUrl: _url,
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) {
        _controller.complete(webViewController);},
    );
  }
}