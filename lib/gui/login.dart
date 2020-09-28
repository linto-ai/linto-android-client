import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:linto_flutter_client/client/client.dart' show AuthenticationStep;
import 'package:linto_flutter_client/gui/dialogs.dart';
import 'package:linto_flutter_client/logic/customtypes.dart';
import 'package:linto_flutter_client/logic/maincontroller.dart';
import 'package:linto_flutter_client/gui/mainInterface.dart';
import 'package:linto_flutter_client/gui/applications.dart' show Applications;

class Login extends StatefulWidget {
  final MainController mainController;
  final AuthenticationStep step;
  const Login({ Key key, this.mainController, this.step : AuthenticationStep.SERVERSELECTION}) : super(key: key);
  @override
  _Login createState() => _Login();
}

// Define a corresponding State class.
// This class holds data related to the form.
class _Login extends State<Login> {
  MainController _mainController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  void initState() {
    super.initState();
    _mainController = widget.mainController;
    }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    AuthenticationWidget authWidget = AuthenticationWidget(mainController : _mainController, scaffoldKey: _scaffoldKey, startingStep: widget.step,);
    return WillPopScope(
      onWillPop: () {},
      child: Scaffold(
        key: _scaffoldKey,
        body: Builder(
          builder: (context) =>
              SafeArea(
                  child: Center(
                      widthFactor: 1,
                      heightFactor: 1,
                      child: Container(
                        decoration: BoxDecoration(
                            gradient: RadialGradient(
                                colors: [Color.fromRGBO(255, 255, 255, 1), Color.fromRGBO(213, 231, 242, 1)]
                            )
                        ),
                        padding: EdgeInsets.all(20),
                        child: Flex(
                          direction: orientation == Orientation.portrait ? Axis.vertical : Axis.horizontal,
                          children: <Widget>[
                            authWidget,

                          ],
                        ),
                      )
                  )
              ),
        ),
        resizeToAvoidBottomInset: true,
      ),
    );
  }
}

/// Authentication Widget
class AuthenticationWidget extends StatefulWidget {
  final MainController mainController;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final AuthenticationStep startingStep;


  const AuthenticationWidget({ Key key, this.mainController, this.scaffoldKey, this.startingStep : AuthenticationStep.SERVERSELECTION}) : super(key: key);

  @override
  _AuthenticationWidget createState() => _AuthenticationWidget();
}

class _AuthenticationWidget extends State<AuthenticationWidget> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  GlobalKey<ScaffoldState> scaffoldKey;
  final _formCKey = GlobalKey<FormState>();
  final _formMKey = GlobalKey<FormState>();

  MainController _mainController;
  AuthenticationStep _step;

  // Welcome controller
  var _welcomeVisible = false;
  var _welcomeTextVisible = false;
  var _buttonVisible = false;

  // Credentials
  final _serverC = TextEditingController(text: "https://");
  final _serverFocus = FocusNode();

  final _loginC = TextEditingController();
  final _loginFocus = FocusNode();

  final _passwordC = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _passCVisible = false;

  // Direct Connexion
  final _deviceIDC = TextEditingController();
  final _deviceIDFocus = FocusNode();
  String _protocol = "mqtts";
  final _brokerC = TextEditingController();
  final _brokerFocus = FocusNode();
  final _portC = TextEditingController();
  final _portFocus = FocusNode();
  final _mqttLoginC = TextEditingController();
  final _mqttLoginFocus = FocusNode();
  final _mqttPassC = TextEditingController();
  final _mqttPassFocus = FocusNode();
  bool _passMVisible = false;
  final _scopeC = TextEditingController();
  final _scopeFocus = FocusNode();

  bool _remember = true;


  void initState() {
    super.initState();
    _mainController = widget.mainController;
    scaffoldKey = widget.scaffoldKey;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadUserPref();
      setState(() {
        _welcomeVisible = true;
      });
    });
    _step = widget.startingStep;
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    //_step = AuthenticationStep.WELCOME;
    switch(_step) {
      case AuthenticationStep.WELCOME : {
        return welcomeWidget();
      }
      break;

      case AuthenticationStep.DIRECTCONNECT : {
        return directWidget();
      }
      break;
      case AuthenticationStep.SERVERSELECTION : {
        return serverSelectionWidget();
      }
      break;
      // Credentials
      case AuthenticationStep.CREDENTIALS : {
        return credentialsWidget();

      }
      break;
      case AuthenticationStep.AUTHENTICATED : {
          return credentialsWidget();
      }
      break;
      case AuthenticationStep.CONNECTED: {}
    }
  }

  Widget serverSelectionWidget() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Spacer(),
          Expanded(
            child: AutoSizeText("Connect to the application server",
              style: TextStyle(fontSize: 25), maxLines: 2, textAlign: TextAlign.center,),
            flex: 1,
          ),
          Expanded(
            child: Form(
              key :_formCKey,
              child: TextFormField(
                controller: _serverC,
                focusNode: _serverFocus,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9.://]'))],
                decoration: InputDecoration(
                    labelText: ''
                ),
                validator: (value)  {
                  if (value.isEmpty || value == "https://") {
                    return 'Please enter server url';
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (term) {
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                  _formCKey.currentState.validate();
                  requestServerRoutes(_serverC.value.text);
                },
              ),
            ),
            flex: 2,
          ),

          Spacer(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                color: Color.fromRGBO(60, 187, 242, 0.9),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Icon(Icons.input, color: Colors.white,),
                    Text("  OK  ", style: TextStyle(fontSize: 20, color: Colors.white),),
                  ],
                ),
                onPressed: () {
                  requestServerRoutes(_serverC.value.text);
                  },
              ),

            ],
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RichText(
                text: TextSpan(
                    text: "More options",
                    style: TextStyle(color: Colors.blue, fontSize: 20, decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()..onTap = () {
                      setState(() {
                        _step = AuthenticationStep.DIRECTCONNECT;
                      });
                    }
                ),
              ),
            ],
          ),
          Spacer()
        ],
      ),
    );
  }

  Widget credentialsWidget() {
    return Expanded(
        child: Form(
          key: _formCKey,
          child: Flex(
            direction: MediaQuery.of(context).orientation == Orientation.portrait ? Axis.vertical : Axis.horizontal,
            children: <Widget>[
              Container(

                width: MediaQuery.of(context).size.width * (MediaQuery.of(context).orientation == Orientation.portrait ? 0.9 : 0.4),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Login :'
                      ),
                      inputFormatters: [FilteringTextInputFormatter.allow((RegExp(r'[a-zA-Z0-9@\-.]')))],
                      validator: (value)  {
                        if (value.isEmpty) {
                          return 'Please enter login';
                        }
                        return null;
                      },
                      controller: _loginC,
                      textInputAction: TextInputAction.next,
                      focusNode: _loginFocus,
                      onFieldSubmitted: (term) {
                        _loginFocus.unfocus();
                        FocusScope.of(context).requestFocus(_passwordFocus);
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _passCVisible ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _passCVisible = !_passCVisible;
                              });
                            },
                          )
                      ),
                      validator: (value)  {
                        if (value.isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                      controller: _passwordC,
                      obscureText: !_passCVisible,
                      focusNode: _passwordFocus,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (term) {
                        if (term.isNotEmpty) {
                          SystemChannels.textInput.invokeMethod('TextInput.hide');
                          authenticate(_loginC.value.text, _passwordC.value.text);
                        }
                      },
                    ),
                    StatefulBuilder(
                      builder: (context, _setState) => CheckboxListTile(
                          title: Text("Remember me"),
                          value: _remember,
                          onChanged: (bool val) {
                            setState(() {
                              _remember = val;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        RaisedButton(
                          color: Color.fromRGBO(60, 187, 242, 0.9),
                          child: Icon(Icons.arrow_back, color: Colors.white,),
                          onPressed: () {
                            setState(() {
                              _step = AuthenticationStep.SERVERSELECTION;
                            });
                          },
                        ),
                        RaisedButton(
                          color: Color.fromRGBO(60, 187, 242, 0.9),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Icon(Icons.input, color: Colors.white,),
                              Text("LOGIN", style: TextStyle(fontSize: 20, color: Colors.white),),
                            ],
                          ),
                          onPressed: () {
                            if (_loginC.value.text.isNotEmpty && _passwordC.value.text.isNotEmpty) {
                              authenticate(_loginC.value.text, _passwordC.value.text);
                            }
                          },
                        ),
                      ],
                    )

                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                ),
                padding: EdgeInsets.all(20),
              )
            ],
          ),
        )
    );
  }

  Widget welcomeWidget() {
    var width = MediaQuery.of(context).size.width * 0.6;
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Spacer(),
          Expanded(
              child:  AnimatedOpacity(
                opacity: _welcomeVisible ? 1.0 : 0.0,
                duration: Duration(seconds: 3),
                onEnd: () {
                  setState(() {
                    _welcomeTextVisible = true;
                  });
                },
                child: AutoSizeText("Welcome, ",
                  style: TextStyle(fontSize: 40), maxLines: 2, textAlign: TextAlign.center,),
              ),
              flex: 1
          ),
          Expanded(
            child:  AnimatedOpacity(
              opacity: _welcomeTextVisible ? 1.0 : 0.0,
              duration: Duration(seconds: 2),
              onEnd: () {
                setState(() {
                  _buttonVisible = true;
                });
              },
              child: AutoSizeText("We will guide you through the setup of your smart assistant.",
                style: TextStyle(fontSize: 25), maxLines: 2, textAlign: TextAlign.center,),
            ),
            flex: 1,
          ),

          Container(
            width: width,
            child: AnimatedOpacity(
              opacity: _buttonVisible ? 1.0 : 0.0,
              duration: Duration(seconds: 2),
              child: RaisedButton(
                color: Color.fromRGBO(60, 187, 242, 0.9),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Icon(Icons.settings, color: Colors.white,),
                    AutoSizeText("Get started",
                      style: TextStyle(fontSize: 25), maxLines: 2, textAlign: TextAlign.center,)
                  ],
                ),
                onPressed: () async {
                  if (! await _mainController.requestPermissions()) {
                    displaySnackMessage("Permissions missing");
                    return;
                  }
                  setState(() {
                    _step = AuthenticationStep.SERVERSELECTION;
                  });
                },
              ),
            ),
          ),

          Spacer()
        ],
      ),
    );
  }

  Widget directWidget() {
    return Expanded(
        child: Form(
          key: _formMKey,
          child: ListView(
            children: <Widget>[
              AutoSizeText("Directly connect to your single application",
                style: TextStyle(fontSize: 20), maxLines: 2, textAlign: TextAlign.center,),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'This device identifies as (unique ID):'
                ),
                inputFormatters: [FilteringTextInputFormatter.allow((RegExp(r'[a-zA-Z0-9@\-.]')))],
                validator: (value)  {
                  if (value.isEmpty) {
                    return 'Please enter a SN';
                  }
                  return null;
                },
                controller: _deviceIDC,
                textInputAction: TextInputAction.next,
                focusNode: _deviceIDFocus,
                onFieldSubmitted: (term) {
                  _deviceIDFocus.unfocus();
                  FocusScope.of(context).requestFocus(_brokerFocus);
                },
              ),
              Row(
                children : [
                  Flexible(
                    flex: 5,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        isDense: true,
                        hasFloatingPlaceholder: true,
                        alignLabelWithHint: true,
                        border: InputBorder.none,
                      ),
                      value: _protocol,
                      items: <String>['mqtt', 'mqtts'].map((String value) {
                        return new DropdownMenuItem(
                            value: value,
                            child: new Text(value)
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _protocol = value;
                        });
                      },
                    ),
                  ),
                  Flexible(
                    child: TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Connexion server'
                      ),
                      inputFormatters: [FilteringTextInputFormatter.allow((RegExp(r'[a-zA-Z0-9@\-.]')))],
                      validator: (value)  {
                        if (value.isEmpty) {
                          return 'Please enter url';
                        }
                        return null;
                      },
                      controller: _brokerC,
                      textInputAction: TextInputAction.next,
                      focusNode: _brokerFocus,
                      onFieldSubmitted: (term) {
                        _serverFocus.unfocus();
                        FocusScope.of(context).requestFocus(_portFocus);
                      },
                    ),
                    flex: 12,
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  Flexible(
                    child: TextFormField(
                      decoration: InputDecoration(
                          labelText: "port"
                      ),
                      controller: _portC,
                      focusNode: _portFocus,
                      inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                      keyboardType: TextInputType.number,
                      onFieldSubmitted: (term) {
                        _portFocus.unfocus();
                        FocusScope.of(context).requestFocus(_mqttLoginFocus);
                      },
                    ),
                    flex: 4
                  ),
                ]
              ),

              TextFormField(
                decoration: InputDecoration(
                  labelText: 'MQTT Login',

                ),
                inputFormatters: [FilteringTextInputFormatter.allow((RegExp(r'[a-zA-Z0-9@\-.]')))],
                validator: (value)  {
                  if (value.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
                controller: _mqttLoginC,
                focusNode: _mqttLoginFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (term) {
                  _mqttLoginFocus.unfocus();
                  FocusScope.of(context).requestFocus(_mqttPassFocus);

                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'MQTT Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passMVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passMVisible = !_passMVisible;
                      });
                    },
                  )
                ),
                validator: (value)  {
                  if (value.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
                controller: _mqttPassC,
                obscureText: !_passMVisible,
                focusNode: _mqttPassFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (term) {
                  _mqttPassFocus.unfocus();
                  FocusScope.of(context).requestFocus(_scopeFocus);
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Application ID',
                ),
                inputFormatters: [FilteringTextInputFormatter.allow((RegExp(r'[a-zA-Z0-9@\-.]')))],
                validator: (value)  {
                  if (value.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
                controller: _scopeC,
                focusNode: _scopeFocus,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (term) {
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                },
              ),
              StatefulBuilder(
                builder: (context, _setState) => CheckboxListTile(
                    title: Text("Remember me"),
                    value: _remember,
                    onChanged: (bool val) {
                      setState(() {
                        _remember = val;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                    color: Color.fromRGBO(60, 187, 242, 0.9),
                    child: Icon(Icons.arrow_back, color: Colors.white,),
                    onPressed: () {
                      setState(() {
                        _step = AuthenticationStep.SERVERSELECTION;
                      });
                    },
                  ),
                  RaisedButton(
                    color: Color.fromRGBO(60, 187, 242, 0.9),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Icon(Icons.input, color: Colors.white,),
                        Text("     Connect     ", style: TextStyle(fontSize: 20, color: Colors.white),),
                      ],
                    ),
                    onPressed: () {
                      directConnect();
                    },
                  ),

                ],
              ),
            ],
            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
        )
    );
  }

  void loadUserPref() {
    var preferences = _mainController.userPreferences;
    if (preferences.getBool('keep_info')) {
      setState(() {
        _serverC.text = preferences.getString("cred_server");
        _loginC.text = preferences.getString("cred_login");
        _passwordC.text = preferences.passwordC;

        _deviceIDC.text = preferences.getString("direct_sn");
        _brokerC.text = preferences.getString("direct_ip");
        _portC.text = preferences.getString("direct_port");
        _mqttLoginC.text = preferences.getString("direct_id");
        _mqttPassC.text = _mainController.userPreferences.passwordM;
        _scopeC.text = preferences.getString("direct_app");
      });
    }
  }

  void requestServerRoutes(String server) async {
    if (!_formCKey.currentState.validate()) return;
    List<dynamic> routes;
    try {
      routes = await _mainController.client.requestRoutes(server.trim());
    } on ClientErrorException catch(error) {
      displaySnackMessage(error.error.toString(), isError: true);
      return;
    }
    if (routes.length == 1) {
      _mainController.client.setAuthRoute(routes[0]);
    } else {
      var selected = await showRoutesDialog(context, "Select authentication method", routes);
      _mainController.client.setAuthRoute(selected);
    }
    setState(() {
      _step = AuthenticationStep.CREDENTIALS;
    });
  }

  /// Update connexion information.
  void updateConnPrefs(bool cred) {
    _mainController.userPreferences.setValues(
      {
        "first_login" : false,
        "keep_info" : _remember,
        "reconnect" : true,
      }
    );

    if(cred)  {
      _mainController.userPreferences.setValues(
          {
            "auth_cred" : true,
            "cred_server" : _serverC.text,
            "cred_login" : _loginC.text,
            "cred_route" : _mainController.client.authRoute["basePath"],
          }
      );
      _mainController.userPreferences.passwordC =_passwordC.value.text;
    } else {
      _mainController.userPreferences.setValues(
          {
            "auth_cred" : false,
            "direct_sn" : _deviceIDC.text,
            "direct_ip" : _brokerC.text,
            "direct_port" : _portC.text,
            "direct_id" : _mqttLoginC.text,
            "direct_app" : _scopeC.text
          }
      );
      _mainController.userPreferences.passwordM = _mqttPassC.value.text;
    }
  }

  /// Submit credential to the authentication server.
  void authenticate(String login, String password) async {
    // 1- Request authentification token
    try {
      await _mainController.client.requestAuthentification(login.trim(), password);
    } on ClientErrorException catch(error) {
      displaySnackMessage(error.error.toString(), isError: true);
      return;
    }
    // 2- Request scopes
    var scopes;
    try {
      scopes = await _mainController.client.requestScopes();
    } on ClientErrorException catch(error) {
      displaySnackMessage(error.error.toString(), isError: true);
      return;
    }
    print(scopes);

    if (_remember) {
      updateConnPrefs(true);
    }

    Navigator.pushNamed(context, "/applications");
  }

  void displaySnackMessage(String message, {bool isError: false}) async {
    final snackBarError = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Color(0x3db5e4),
    );
    scaffoldKey.currentState.showSnackBar(snackBarError);
  }

  Future<void> directConnect() async{
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    bool res = await _mainController.client.directConnexion(_brokerC.value.text,
                                                            _portC.value.text,
                                                            _mqttLoginC.value.text,
                                                            _mqttPassC.value.text,
                                                            _deviceIDC.value.text,
                                                            _scopeC.value.text,
                                                            _protocol == "mqtts");
    if (!res) {
      displaySnackMessage("Could not connect to broker using those informations.", isError: true);
    } else {
      updateConnPrefs(false);
      Navigator.pushNamed(context, '/main');
    }

  }
}