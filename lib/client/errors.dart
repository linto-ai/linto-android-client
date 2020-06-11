Map<String, List<String> > ERROR_CODES = {
  '0x0001' : ['Authentification Error', 'Missing authentification factor (login / password)'],
  '0x0002' : ['Authentification Error', 'Wrong authentification informations (login /passord)'],
  '0x0003' : ['Authentification Error', 'Missing authentification factor (token)'],
  '0x0004' : ['Authentification Error', 'Wrong authentification informations (token)'],
  '0x0005' : ['Missing scope', 'Asked scope could not be found on the server'],
  '0x0006' : ['No Scope', 'No Scope found for this device'],
  '0x0007' : ['Wrong format', 'Could not read message from server'],
  '0x0008' : ['API not found', 'Could not authenticate on this server'],
  '0x0009' : ['Request Timeout', 'Connexion attempt has timed out'],
  '0x0010' : ['Socket Error', 'Could not reach the server'],
  '0xFFFF' : ['Unknown', 'Unknow Error']
};

class ClientError {
  String code;

  ClientError({this.code : '0xFFFF'});

  String get title {
    return ERROR_CODES[code][0];
  }

  String get description {
    return ERROR_CODES[code][1];
  }

  @override
  String toString() {
    return "Error $code $title : $description";
  }
}