import 'package:oxidized/oxidized.dart';

import 'dart:typed_data';

import 'abstract.dart';
import 'constants.dart';

class CLUnitType extends CLType {
  @override
  get linksTo => CLUnit();

  @override
  CLTypeTag get tag => CLTypeTag.Unit;

  @override
  String toString() => UNIT_ID;

  @override
  String toJson() => UNIT_ID;
}

class CLUnitBytesParser extends CLValueBytesParsers {
  @override
  ResultAndRemainder<CLValue, CLErrorCodes> fromBytesWithRemainder(
      Uint8List bytes,
      [CLType? innerType]) {
    return resultHelper(Ok(CLUnit()), bytes);
  }

  @override
  Result<Uint8List, CLErrorCodes> toBytes(CLValue val) {
    return (Ok(Uint8List.fromList([])));
  }
}

class CLUnit extends CLValue {
  @override
  get data => null;

  @override
  CLType clType() {
    return CLUnitType();
  }

  @override
  Null value() {
    return data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other.runtimeType != runtimeType) return false;

    other as CLUnit;
    return data == other.data;
  }

  @override
  int get hashCode => data.hashCode;
}
