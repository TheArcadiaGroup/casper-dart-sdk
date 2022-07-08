import 'dart:typed_data';

import 'package:oxidized/oxidized.dart';
import 'package:collection/collection.dart';

import 'abstract.dart';
import 'constants.dart';
import 'key.dart';

class CLAccountHashType extends CLType {
  @override
  Type get linksTo => CLAccountHash;

  @override
  CLTypeTag get tag => CLTypeTag.AccountHash;

  @override
  String toString() => ACCOUNT_HASH_ID;

  @override
  String toJson() => toString();
}

class CLAccountHashBytesParser extends CLValueBytesParsers {
  @override
  Result<Uint8List, CLErrorCodes> toBytes(CLValue val) {
    if (val is CLKey) {
      return Ok(val.data.value());
    }
    return Ok(val.data);
  }

  @override
  ResultAndRemainder<CLAccountHash, CLErrorCodes> fromBytesWithRemainder(
      Uint8List bytes,
      [CLType? innerType]) {
    if (bytes.length < ACCOUNT_HASH_LENGTH) {
      return resultHelper(Err(CLErrorCodes.EarlyEndOfStream));
    }

    var accountHashBytes = bytes.sublist(0, ACCOUNT_HASH_LENGTH);
    var accountHash = CLAccountHash(accountHashBytes);
    return resultHelper(Ok(accountHash));
  }
}

class CLAccountHash extends CLValue {
  @override
  late Uint8List data;

  /// Constructs a new `AccountHash`.
  ///
  /// @param v The bytes constituting the public key.
  CLAccountHash(this.data);

  @override
  CLType clType() {
    return CLAccountHashType();
  }

  @override
  Uint8List value() {
    return data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other.runtimeType != runtimeType) return false;

    other as CLAccountHash;
    Function eq = const ListEquality().equals;
    return eq(data, other.data);
  }

  @override
  int get hashCode => data.hashCode;
}
