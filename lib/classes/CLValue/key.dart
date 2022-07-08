// ignore_for_file: constant_identifier_names

import 'dart:typed_data';

import 'package:oxidized/oxidized.dart';

import 'abstract.dart';
import 'account_hash.dart';
import 'byte_array.dart';
import 'constants.dart';
import 'uref.dart';

const int HASH_LENGTH = 32;

class CLKeyType extends CLType {
  @override
  Type get linksTo => CLKey;

  @override
  CLTypeTag get tag => CLTypeTag.Key;

  @override
  String toJson() => KEY_ID;

  @override
  String toString() => KEY_ID;
}

class CLKeyBytesParser extends CLValueBytesParsers {
  @override
  ResultAndRemainder<CLKey, CLErrorCodes> fromBytesWithRemainder(
      Uint8List bytes,
      [CLType? innerType]) {
    if (bytes.isEmpty) {
      return resultHelper(Err(CLErrorCodes.EarlyEndOfStream));
    }

    var tag = bytes[0];

    if (tag == KeyVariant.Account.index) {
      var parser = CLAccountHashBytesParser()
          .fromBytesWithRemainder(bytes.sublist(1), CLAccountHashType());
      var accountHashResult = parser.result;

      if (accountHashResult.isOk()) {
        return resultHelper(
            Ok(CLKey(accountHashResult.unwrap())), parser.remainder);
      } else {
        return resultHelper(Err(accountHashResult.unwrapErr()));
      }
    } else if (tag == KeyVariant.Hash.index) {
      var parser = CLByteArrayBytesParser().fromBytesWithRemainder(
          bytes.sublist(1),
          CLByteArrayType(
              HASH_LENGTH > bytes.length - 1 ? bytes.length - 1 : HASH_LENGTH));
      var hashResult = parser.result;

      if (hashResult.isOk()) {
        return resultHelper(Ok(CLKey(hashResult.unwrap())), parser.remainder);
      } else {
        return resultHelper(Err(hashResult.unwrapErr()));
      }
    } else if (tag == KeyVariant.URef.index) {
      var parser = CLURefBytesParser()
          .fromBytesWithRemainder(bytes.sublist(1), CLURefType());
      var urefResult = parser.result;

      if (urefResult.isOk()) {
        return resultHelper(Ok(CLKey(urefResult.unwrap())), parser.remainder);
      } else {
        return resultHelper(Err(urefResult.unwrapErr()));
      }
    } else {
      return resultHelper(Err(CLErrorCodes.Formatting));
    }
  }

  @override
  Result<Uint8List, CLErrorCodes> toBytes(CLValue val) {
    var account = val as CLKey;

    if (account.isAccount()) {
      var bytes = CLAccountHashBytesParser().toBytes(val).unwrap();
      return Ok(Uint8List.fromList([
        ...Uint8List.fromList([KeyVariant.Account.index]),
        ...bytes
      ]));
    }

    if (account.isHash()) {
      var bytes = CLByteArrayBytesParser().toBytes(val).unwrap();
      return Ok(Uint8List.fromList([
        ...Uint8List.fromList([KeyVariant.Hash.index]),
        ...bytes
      ]));
    }

    if (account.isURef()) {
      var bytes = CLURefBytesParser().toBytes(val).unwrap();
      return Ok(Uint8List.fromList([
        ...Uint8List.fromList([KeyVariant.URef.index]),
        ...bytes
      ]));
    }

    throw Exception("Unknown byte types");
  }
}

class CLKey extends CLValue {
  @override
  late CLValue data;

  CLKey(this.data);

  @override
  CLType clType() {
    return CLKeyType();
  }

  @override
  CLValue value() {
    return data;
  }

  bool isHash() {
    return data is CLByteArray;
  }

  bool isURef() {
    return data is CLURef;
  }

  bool isAccount() {
    return data is CLAccountHash;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other.runtimeType != runtimeType) return false;

    other as CLKey;
    return data == other.data;
  }

  @override
  int get hashCode => data.hashCode;
}
