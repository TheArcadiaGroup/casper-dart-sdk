import 'dart:typed_data';

import 'package:oxidized/oxidized.dart';
import 'package:collection/collection.dart';

import 'abstract.dart';
import 'constants.dart';
import 'key.dart';

class CLByteArrayType extends CLType {
  @override
  Type get linksTo => CLByteArray;

  @override
  CLTypeTag get tag => CLTypeTag.ByteArray;

  late int size;

  CLByteArrayType(this.size);

  @override
  String toString() {
    return BYTE_ARRAY_ID;
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{BYTE_ARRAY_ID: size};

  @override
  Uint8List toBytes() {
    Uint8List list1 = Uint8List.fromList(List.from([tag.value]));
    Uint8List list2 =
        Uint32List.fromList(List.from([size])).buffer.asUint8List();
    return Uint8List.fromList([...list1, ...list2]);
  }
}

class CLByteArrayBytesParser extends CLValueBytesParsers {
  @override
  Result<Uint8List, CLErrorCodes> toBytes(CLValue val) {
    if (val is CLKey) {
      return Ok(val.data.value());
    }
    return Ok(val.data);
  }

  @override
  ResultAndRemainder<CLByteArray, CLErrorCodes> fromBytesWithRemainder(
      Uint8List bytes,
      [CLType? innerType]) {
    innerType as CLByteArrayType;
    var byteArray = CLByteArray(bytes.sublist(0, innerType.size));
    return resultHelper(Ok(byteArray), bytes.sublist(innerType.size));
  }
}

class CLByteArray extends CLValue {
  @override
  late Uint8List data;

  /// Constructs a new `CLByteArray`.
  ///
  /// @param v The bytes array with max length 32.
  CLByteArray(this.data);

  @override
  CLType clType() {
    return CLByteArrayType(data.length);
  }

  @override
  Uint8List value() {
    return data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other.runtimeType != runtimeType) return false;

    other as CLByteArray;
    Function eq = const ListEquality().equals;
    return eq(data, other.data);
  }

  @override
  int get hashCode => data.hashCode;
}
