import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

const String weatherWidgetExemple = '''
<!DOCSTRING html><html>
<body>
<a class="weatherwidget-io" href="https://forecast7.com/fr/43d601d44/toulouse/" data-label_1="TOULOUSE" data-label_2="WEATHER" data-icons="Climacons Animated" data-mode="Current" data-theme="pure" data-basecolor="" >TOULOUSE WEATHER</a>
<script>
!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src='https://weatherwidget.io/js/widget.min.js';fjs.parentNode.insertBefore(js,fjs);}}(document,'script','weatherwidget-io-js');
</script>
</body>
</html>
''';

class WeatherWidget extends StatefulWidget {
  @override
  _WeatherWidgetState createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
    @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    return  WeatherWebview(weatherWidgetExemple);

  }

}

class WeatherWebview extends StatelessWidget {
  String _url = 'https://flutter.dev';
  final Completer<WebViewController> _controller = Completer<WebViewController>();

  WeatherWebview(String url) {
    String contentBase64 = base64Encode(const Utf8Encoder().convert(weatherWidgetExemple));
    _url = 'data:text/html;base64,$contentBase64';
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