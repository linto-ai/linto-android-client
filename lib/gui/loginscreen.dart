import 'package:flutter/material.dart';
import 'package:linto_flutter_client/client/client.dart';
import 'package:linto_flutter_client/gui/mainInterface.dart';

class LoginScreen extends StatefulWidget {
  final LinTOClient client;
  const LoginScreen({ Key key, this.client }): super(key: key);
  @override
  LoginScreenForm createState() => LoginScreenForm();
}

// Define a corresponding State class.
// This class holds data related to the form.
class LoginScreenForm extends State<LoginScreen> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  final _login = TextEditingController();
  final _password = TextEditingController();
  final _server = TextEditingController();

  final FocusNode _loginFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _serverFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
        body: SafeArea(
          child: Center(
            widthFactor: 0.95,
            heightFactor: 0.95,
            child: Form(
              key: _formKey,
              child: Flex(
                  direction: orientation == Orientation.portrait ? Axis.vertical : Axis.horizontal,
                  children: <Widget>[
                    Container(
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
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (term) {
                              _serverFocus.unfocus();
                              FocusScope.of(context).requestFocus(_serverFocus);
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                                labelText: 'Server'
                            ),
                            validator: (value)  {
                              if (value.isEmpty) {
                                return 'Please enter server info';
                              }
                              return null;
                            },
                            controller: _server,
                            textInputAction: TextInputAction.done,
                            focusNode: _serverFocus,
                            onFieldSubmitted: (term) {
                              _passwordFocus.unfocus();
                              onLoginPressed();
                            },
                          ),
                          FlatButton(
                            child: Text('LOGIN'),
                            onPressed: () => onLoginPressed(),
                          )
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      ),
                      padding: EdgeInsets.all(10),
                    ),
                    Image.asset('assets/icons/linto_ai.png', fit: BoxFit.fitHeight),
                  ]
              )
          )
        )
      ),
      resizeToAvoidBottomInset: false,
    );
  }
  void onLoginPressed() async{
    if (! _formKey.currentState.validate()) {
      return;
    }
    var res = await widget.client.requestAuthentification(_login.value.text, _password.value.text, _server.value.text, true);
    if (res) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => MainInterface()));
    }
  }
  
}