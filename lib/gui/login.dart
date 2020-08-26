import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:linto_flutter_client/client/client.dart' show AuthenticationStep;
import 'package:linto_flutter_client/gui/dialogs.dart';
import 'package:linto_flutter_client/gui/utils/flaredisplay.dart';
import 'package:linto_flutter_client/logic/customtypes.dart';
import 'package:linto_flutter_client/logic/maincontroller.dart';
import 'package:linto_flutter_client/gui/mainInterface.dart';


class Login extends StatefulWidget {
  final MainController mainController;
  final AuthenticationStep step;
  const Login({ Key key, this.mainController, this.step : AuthenticationStep.NOTCONNECTED}) : super(key: key);
  @override
  _Login createState() => _Login();
}

// Define a corresponding State class.
// This class holds data related to the form.
class _Login extends State<Login> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>
  MainController _mainController;

  void initState() {
    super.initState();
    _mainController = widget.mainController;
    }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    double lintoWidth = MediaQuery.of(context).size.width * (orientation == Orientation.portrait ? 0.9: 0.45);
    return Scaffold(
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
                          Expanded(
                            child: Image.asset('assets/icons/linto_ai.png',height: lintoWidth, fit: BoxFit.contain),
                            flex: 1,
                          ),
                          AuthenticationWidget(mainController : _mainController, scaffoldContext: context, startingStep: widget.step,)
                        ],
                      ),
                    )
                )
            ),
      ),
      resizeToAvoidBottomInset: false,);
  }
}

/// Authentication Widget
class AuthenticationWidget extends StatefulWidget {
  final MainController mainController;
  final BuildContext scaffoldContext;
  final AuthenticationStep startingStep;
  const AuthenticationWidget({ Key key, this.mainController, this.scaffoldContext, this.startingStep : AuthenticationStep.NOTCONNECTED}) : super(key: key);
  @override
  _AuthenticationWidget createState() => _AuthenticationWidget();
}

class _AuthenticationWidget extends State<AuthenticationWidget> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  MainController _mainController;
  BuildContext _scaffoldContext;
  AuthenticationStep _step;

  String _server = "https://";
  String _login = "";
  String _password = "";
  bool _remember = true;

  final _loginC = TextEditingController();
  final _passwordC = TextEditingController();
  final _serverC = TextEditingController(text: "https://");

  final FocusNode _loginFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();


  void initState() {
    super.initState();
    _mainController = widget.mainController;
    _scaffoldContext = widget.scaffoldContext;
    WidgetsBinding.instance.addPostFrameCallback((_) =>loadUserPref());
    _step = widget.startingStep;
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    switch(_step) {
      case AuthenticationStep.FIRSTLAUNCH : {
        return welcomeWidget();
      }
      break;
      case AuthenticationStep.NOTCONNECTED : {
        return serverSelectionWidget();
      }
      break;
      // Credentials
      case AuthenticationStep.SERVERSELECTED : {
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
        children: <Widget>[
          Spacer(),
          Expanded(
            child: AutoSizeText("Please enter the authentication server.",
              style: TextStyle(fontSize: 40), maxLines: 2,),
            flex: 1,
          ),
          Expanded(
            child: Form(
              key :_formKey,
              child: TextFormField(
                controller: _serverC,
                decoration: InputDecoration(
                    labelText: 'Server'
                ),
                validator: (value)  {
                  if (value.isEmpty) {
                    return 'Please enter login';
                  }
                  return null;
                },
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (term) {
                  _formKey.currentState.validate();
                  requestServerRoutes(_scaffoldContext, _serverC.value.text);
                },
              ),
            ),
            flex: 2,
          ),
          RaisedButton(
            color: Color.fromRGBO(60, 187, 242, 0.9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Icon(Icons.input, color: Colors.white,),
                Text("Check Server", style: TextStyle(fontSize: 20, color: Colors.white),),
              ],
            ),
            onPressed: () {requestServerRoutes(_scaffoldContext, _serverC.value.text);},
          ),

          Spacer()
        ],
      ),
    );
  }

  Widget credentialsWidget() {
    return Expanded(
        child: Form(
          key: _formKey,
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

                      ),
                      validator: (value)  {
                        if (value.isEmpty) {
                          return 'Please enter password';
                        }
                        return null;
                      },
                      controller: _passwordC,
                      obscureText: true,
                      focusNode: _passwordFocus,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (term) {
                        if (term.isNotEmpty) {
                          authenticate(_scaffoldContext, _loginC.value.text, _passwordC.value.text);
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
                          authenticate(_scaffoldContext, _loginC.value.text, _passwordC.value.text);
                        }
                      },
                    ),
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
    return Expanded(
      child: Column(
        children: <Widget>[
          Spacer(),
          Expanded(
            child: AutoSizeText("Welcome ! To get started with LinTO press the setup button.",
              style: TextStyle(fontSize: 40), maxLines: 2,),
            flex: 1,
          ),

            RaisedButton(
              color: Color.fromRGBO(60, 187, 242, 0.9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Icon(Icons.settings, color: Colors.white,),
                  Text("Setup LinTO", style: TextStyle(fontSize: 30),),
                ],
              ),
              onPressed: () async {
                if (! await _mainController.requestPermissions()) {
                  displaySnackMessage(context, "Permissions missing");
                  return;
                }
                setState(() {
                  _step = AuthenticationStep.NOTCONNECTED;
                });
              },
            ),
            Spacer()
            //flex: 2,

        ],
      ),
    );
  }

  void loadUserPref() {
    if (_mainController.userPreferences.clientPreferences['keep_info']) {
      setState(() {
        _server =
        _mainController.userPreferences.clientPreferences['last_server'];
        _login =
        _mainController.userPreferences.clientPreferences['last_login'];
        _password =
        _mainController.userPreferences.clientPreferences['last_password'];
        _serverC.text = _server;
        _loginC.text = _login;
        _passwordC.text = _password;
      });
    }
  }

  void requestServerRoutes(BuildContext context, String server) async {
    List<dynamic> routes;
    try {
      routes = await _mainController.client.requestRoutes(server.trim());
    } on ClientErrorException catch(error) {
      displaySnackMessage(context, error.error.toString(), isError: true);
      return;
    }
    if (routes.length == 1) {
      _mainController.client.setAuthRoute(routes[0]);
    } else {
      var selected = await showRoutesDialog(context, "Select authentication method", routes);
      _mainController.client.setAuthRoute(selected);
    }
    setState(() {
      _step = AuthenticationStep.SERVERSELECTED;
    });
  }

  /// Update connexion information.
  void updateConnPrefs() {
    _mainController.userPreferences.clientPreferences['first_login'] = false;
    _mainController.userPreferences.clientPreferences['keep_info'] = _remember;
    _mainController.userPreferences.clientPreferences['last_server'] = _serverC.text.trim();
    _mainController.userPreferences.clientPreferences['last_route'] = _mainController.client.authRoute;
    _mainController.userPreferences.clientPreferences['last_login'] = _loginC.text.trim();
    _mainController.userPreferences.clientPreferences['last_password'] = _passwordC.text.trim();
    _mainController.userPreferences.clientPreferences['last_scope'] = _mainController.client.currentScope;
    _mainController.userPreferences.updatePrefs();
  }

  /// Submit credential to the authentication server.
  void authenticate(BuildContext scaffoldContext, String login, String password) async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    // 1- Request authentification token
    try {
      await _mainController.client.requestAuthentification(login.trim(), password);
    } on ClientErrorException catch(error) {
      displaySnackMessage(scaffoldContext, error.error.toString(), isError: true);
      return;
    }
    // 2- Request scopes
    var scopes;
    try {
      scopes = await _mainController.client.requestScopes();
    } on ClientErrorException catch(error) {
      displaySnackMessage(scaffoldContext, error.error.toString(), isError: true);
      return;
    }
    print(scopes);

    // 3 Select scope
    var selectedScope = await showScopeDialog(scaffoldContext, "Select application", scopes);

    // 4- Establish connexion to broker
    var success = await _mainController.client.setScope(selectedScope);
    if (!success) {
      displaySnackMessage(scaffoldContext, 'Could not connect to broker', isError: true);
      return;
    }

    if (_remember) {
      updateConnPrefs();
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => MainInterface(mainController: _mainController,)));
  }

  void displaySnackMessage(BuildContext context, String message, {bool isError: false}) async {
    final snackBarError = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Color(0x3db5e4),
    );
    Scaffold.of(context).showSnackBar(snackBarError);
  }
}