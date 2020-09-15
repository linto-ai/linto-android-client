/// Transaction holds the informations and data relative to a request between
/// the client and the server.
/// Every transaction has an unique id shared between those formers.
class Transaction {
  final String _transactionID;
  TransactionState transactionState;

  Transaction(this._transactionID, {this.transactionState: TransactionState.RESOLVED});

  Map<String, dynamic> conversationData = {};

  String get transactionID {
    return _transactionID;
  }
}

enum TransactionState {
  WFORSERVER,
  WFORCLIENT,
  RESOLVED,
  TIMEDOUT
}