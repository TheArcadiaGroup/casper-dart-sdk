import 'dart:typed_data';

import 'package:oxidized/oxidized.dart';

import 'abstract.dart';
import 'constants.dart';

class CLBoolType extends CLType {
  @override
  Type get linksTo => CLBool;

  @override
  CLTypeTag get tag => CLTypeTag.Bool;

  @override
  String toString() => BOOL_ID;

  @override
  String toJson() => BOOL_ID;
}

class CLBoolBytesParser extends CLValueBytesParsers {
  @override
  Result<Uint8List, CLErrorCodes> toBytes(CLValue val) {
    return Ok(Uint8List.fromList(List.from([val.value() ? 1 : 0])));
  }

  @override
  ResultAndRemainder<CLBool, CLErrorCodes> fromBytesWithRemainder(
      Uint8List bytes,
      [CLType? innerType]) {
    if (bytes.isEmpty) {
      return resultHelper(Err(CLErrorCodes.EarlyEndOfStream));
    }
    if (bytes[0] == 1) {
      return resultHelper(Ok(CLBool(true)), bytes.sublist(1));
    } else if (bytes[0] == 0) {
      return resultHelper(Ok(CLBool(false)), bytes.sublist(1));
    } else {
      return resultHelper(Err(CLErrorCodes.Formatting));
    }
  }
}

class CLBool extends CLValue {
  @override
  late bool data;
  late CLBoolBytesParser bytesParser;

  CLBool(this.data);

  @override
  CLType clType() {
    return CLBoolType();
  }

  @override
  bool value() {
    return data;
  }

  static ResultAndRemainder<CLValue, CLErrorCodes> fromBytesWithRemainder(
      Uint8List bytes) {
    if (bytes.isEmpty) {
      return resultHelper(Err(CLErrorCodes.EarlyEndOfStream));
    }
    if (bytes[0] == 1) {
      return resultHelper(Ok(CLBool(true)), bytes.sublist(1));
    } else if (bytes[0] == 0) {
      return resultHelper(Ok(CLBool(false)), bytes.sublist(1));
    } else {
      return resultHelper(Err(CLErrorCodes.Formatting));
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other.runtimeType != runtimeType) return false;

    other as CLBool;
    return data == other.data;
  }

  @override
  int get hashCode => data.hashCode;
}
