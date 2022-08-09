// ignore_for_file: constant_identifier_names

enum ERC20Events { Transfer, Approve }

extension ERC20EventsExtension on ERC20Events {
  String get value {
    switch (this) {
      case ERC20Events.Transfer:
        return 'transfer';
      case ERC20Events.Approve:
        return 'approve';
    }
  }
}
