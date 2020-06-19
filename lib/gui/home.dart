import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:linto_flutter_client/gui/scopedialog.dart';
import 'package:linto_flutter_client/gui/utils/flaredisplay.dart';
import 'package:linto_flutter_client/logic/customtypes.dart';
import 'package:linto_flutter_client/logic/maincontroller.dart';
import 'package:linto_flutter_client/gui/mainInterface.dart';


enum AuthenticationStep {
  NONE,
  SELECT_SERVER,
  ROUTE_SELECTED,
  AUTHENTICATED,
  CONTEXT_SELECTED
}

class Home extends StatefulWidget {
  final MainController mainController;
  const Home({ Key key, this.mainController}) : super(key: key);
  @override
  _Home createState() => _Home();
}

// Define a corresponding State class.
// This class holds data related to the form.
class _Home extends State<Home> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();

  MainController _mainController;
  AuthenticationStep _step;
  String _lastServer;
  String _lastUser;

  void initState() {
    super.initState();
    _mainController = widget.mainController;
    _mainController.client.getLastServer().then((value) => _lastServer = value);
    _mainController.client.getLastUser().then((value) => _lastUser = value);
    _step = AuthenticationStep.NONE;
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
                    widthFactor: 0.95,
                    heightFactor: 0.95,
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: Flex(
                        direction: orientation == Orientation.portrait ? Axis.vertical : Axis.horizontal,
                        children: <Widget>[
                          Expanded(
                            child: FlareDisplay(assetpath: 'assets/linto/linto.flr',
                                animationName: 'idle',
                                width: lintoWidth,
                                height: lintoWidth),
                            flex: 1,
                          ),
                          getDisplayStep(context, _step),
                        ],
                      ),
                    )
                )
            ),
      ),
      resizeToAvoidBottomInset: false,);
  }

  Widget getDisplayStep(BuildContext context, AuthenticationStep step) {
    switch(step) {
      case AuthenticationStep.NONE : {
        return Expanded(
          child: Column(
            children: <Widget>[
              Spacer(),
              Expanded(
                child: AutoSizeText("Welcome ! To get started with LinTO press the setup button.",
                  style: TextStyle(fontSize: 40), maxLines: 2,),
                flex: 1,
              ),
              Expanded(
                child: FlatButton(
                  child: Text("Setup LinTO", style: TextStyle(fontSize: 30),),
                  onPressed: () async {
                    if (! await _mainController.requestPermissions()) {
                      displaySnackMessage(context, "Permissions missing");
                    return;
                    }
                    setState(() {
                      _step = AuthenticationStep.SELECT_SERVER;
                    });
                  },
                ),
                flex: 2,
              )
            ],
          ),
        );
      }
      break;
      case AuthenticationStep.SELECT_SERVER : {
        final _server = TextEditingController(text: _lastServer);
        return Expanded(
          child: Column(
            children: <Widget>[
              Spacer(),
              Expanded(
                child: AutoSizeText("Please input the authentication server.",
                  style: TextStyle(fontSize: 40), maxLines: 2,),
                flex: 1,
              ),
              Expanded(
                child: Form(
                  key :_formKey,
                  child: TextFormField(
                    controller: _server,
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
                      requestServerRoutes(context, _server.value.text);
                    },
                  ),
                ),
                flex: 2,
              ),
              FlatButton(
                child: Text("Check Server"),
                onPressed: () {requestServerRoutes(context, _server.value.text);},
              ),
              Spacer()
            ],
          ),
        );
      }
      break;

      case AuthenticationStep.ROUTE_SELECTED : {
        final _formKey = GlobalKey<FormState>();
        final _login = TextEditingController(text: _lastUser);
        final _password = TextEditingController(text: "YOUR PASSWORD");

        final FocusNode _loginFocus = FocusNode();
        final FocusNode _passwordFocus = FocusNode();


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
                          controller: _login,
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
                          controller: _password,
                          obscureText: true,
                          focusNode: _passwordFocus,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (term) {
                            if (! term.isEmpty) {
                              authenticate(context, _login.value.text, _password.value.text);
                            }
                          },
                        ),
                        FlatButton(
                          child: Text('LOGIN'),
                          onPressed: () {
                            if (! _login.value.text.isEmpty && ! _password.value.text.isEmpty) {
                              authenticate(context, _login.value.text, _password.value.text);
                            }
                          },
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
      break;
      case AuthenticationStep.CONTEXT_SELECTED : {

      }
      break;
      case AuthenticationStep.AUTHENTICATED : {

      }
      break;
    }
  }

  void requestServerRoutes(BuildContext context, String server) async {
    List<dynamic> routes;
    try {
      routes = await _mainController.client.requestRoutes(server);
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
      _step = AuthenticationStep.ROUTE_SELECTED;
    });
  }

  void authenticate(BuildContext scaffoldContext, String login, String password) async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    // 1- Request authentification token
    try {
      await _mainController.client.requestAuthentification(login, password);
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