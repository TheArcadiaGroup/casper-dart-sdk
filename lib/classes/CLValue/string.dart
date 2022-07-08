import 'dart:typed_data';
import 'package:oxidized/oxidized.dart';

import 'abstract.dart';
import 'constants.dart';
import 'numeric.dart';

import '../byte_converters.dart';

class CLStringType extends CLType {
  @override
  Type get linksTo => CLString;

  @override
  CLTypeTag get tag => CLTypeTag.String;

  @override
  String toString() => STRING_ID;

  @override
  String toJson() => STRING_ID;
}

class CLStringBytesParser extends CLValueBytesParsers {
  @override
  ResultAndRemainder<CLString, CLErrorCodes> fromBytesWithRemainder(
      Uint8List bytes,
      [CLType? innerType]) {
    var clU32res = CLU32BytesParser().fromBytesWithRemainder(bytes);
    var len = clU32res.result.unwrap().value().toNumber() as int;

    if (clU32res.remainder != null) {
      var val = fromBytesString(clU32res.remainder!.sublist(0, len));
      return resultHelper(Ok(CLString(val)), clU32res.remainder?.sublist(len));
    }

    return resultHelper(Err(CLErrorCodes.EarlyEndOfStream));
  }

  @override
  Result<Uint8List, CLErrorCodes> toBytes(CLValue val) {
    return Ok(toBytesString(val.data));
  }
}

class CLString extends CLValue {
  @override
  late String data;

  CLString(this.data);

  @override
  CLType clType() {
    return CLStringType();
  }

  @override
  value() {
    return data;
  }

  int size() {
    return data.length;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other.runtimeType != runtimeType) return false;

    other as CLString;
    return data == other.data;
  }

  @override
  int get hashCode => data.hashCode;
}
