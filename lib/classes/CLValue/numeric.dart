import 'dart:typed_data';

import 'package:oxidized/oxidized.dart';
import 'package:collection/collection.dart';

import 'abstract.dart';
import 'constants.dart';
import '../bignumber.dart';
import '../byte_converters.dart';

abstract class NumericBytesParser extends CLValueBytesParsers {
  @override
  Result<Uint8List, CLErrorCodes> toBytes(CLValue val) {
    val as Numeric;
    Function eq = const ListEquality().equals;
    if ((val.bitSize == 128 || val.bitSize == 256 || val.bitSize == 512) &&
        val.originalBytes != null &&
        val.originalBytes!.isNotEmpty &&
        eq(val.originalBytes, Uint8List.fromList([1, 0]))) {
      return Ok(val.originalBytes ?? Uint8List.fromList([]));
    }

    return Ok(toBytesNumber(val.bitSize, val.signed)(val.data));
  }
}

abstract class Numeric extends CLValue {
  @override
  late BigNumber data;

  // NOTE: Original bytes are only used for legacy purposes.
  Uint8List? originalBytes;
  late int bitSize;
  late bool signed;

  Numeric(int _bitSize, bool _isSigned, dynamic _value,
      [Uint8List? _originalBytes]) {
    if (_isSigned == false) {
      if ((_value is BigNumber && _value.isNegative()) ||
          (_value is num && _value.sign < 0)) {
        throw Exception("Can't provide negative numbers with isSigned=false");
      }
    }

    if (_originalBytes != null && _originalBytes.isNotEmpty) {
      originalBytes = _originalBytes;
    }

    bitSize = _bitSize;
    signed = _isSigned;
    data = BigNumber.from(_value);
  }

  @override
  BigNumber value() {
    return data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other.runtimeType != runtimeType) return false;

    other as Numeric;
    return data == other.data;
  }

  @override
  int get hashCode => data.hashCode;
}

///
/// CLI32
///
class CLI32Type extends CLType {
  @override
  get linksTo => CLI32;

  @override
  CLTypeTag get tag => CLTypeTag.I32;

  @override
  String toJson() => I32_ID;

  @override
  String toString() => I32_ID;
}

class CLI32BytesParser extends NumericBytesParser {
  @override
  ResultAndRemainder<CLI32, CLErrorCodes> fromBytesWithRemainder(
      Uint8List bytes,
      [CLType? innerType]) {
    // print(bytes);
    if (bytes.length < 4) {
      return resultHelper(Err(CLErrorCodes.EarlyEndOfStream));
    }

    var i32Bytes = Uint8List.fromList(bytes.sublist(0, 4));
    var i32 = BigNumber.from(Uint8List.fromList(i32Bytes.reversed.toList()))
        .fromTwos(32);
    var remainder = bytes.sublist(4);

    return resultHelper(Ok(CLI32(i32)), remainder);
  }
}

class CLI32 extends Numeric {
  CLI32(dynamic val) : super(32, true, val);

  @override
  CLType clType() {
    return CLI32Type();
  }
}

///
/// CLI64
///
class CLI64Type extends CLType {
  @override
  get linksTo => CLI64;

  @override
  CLTypeTag get tag => CLTypeTag.I64;

  @override
  String toJson() => I64_ID;

  @override
  String toString() => I64_ID;
}

class CLI64BytesParser extends NumericBytesParser {
  @override
  ResultAndRemainder<CLI64, CLErrorCodes> fromBytesWithRemainder(
      Uint8List bytes,
      [CLType? innerType]) {
    if (bytes.length < 8) {
      return resultHelper(Err(CLErrorCodes.EarlyEndOfStream));
    }

    var i64Bytes = Uint8List.fromList(bytes.sublist(0, 8));
    var i64 = BigNumber.from(Uint8List.fromList(i64Bytes.reversed.toList()))
        .fromTwos(64);
    var remainder = bytes.sublist(8);

    return resultHelper(Ok(CLI64(i64)), remainder);
  }
}

class CLI64 extends Numeric {
  CLI64(dynamic val) : super(64, true, val);

  @override
  CLType clType() {
    return CLI64Type();
  }
}

///
/// CLU8
///
class CLU8Type extends CLType {
  @override
  get linksTo => CLU8;

  @override
  CLTypeTag get tag => CLTypeTag.U8;

  @override
  String toJson() => U8_ID;

  @override
  String toString() => U8_ID;
}

class CLU8BytesParser extends NumericBytesParser {
  @override
  ResultAndRemainder<CLU8, CLErrorCodes> fromBytesWithRemainder(Uint8List bytes,
      [CLType? innerType]) {
    if (bytes.isEmpty) {
      return resultHelper(Err(CLErrorCodes.EarlyEndOfStream));
    }

    return resultHelper(Ok(CLU8(bytes[0])), bytes.sublist(1));
  }
}

class CLU8 extends Numeric {
  CLU8(dynamic val) : super(8, false, val);

  @override
  CLType clType() {
    return CLU8Type();
  }
}

///
/// CLU32
///
class CLU32Type extends CLType {
  @override
  get linksTo => CLU32;

  @override
  CLTypeTag get tag => CLTypeTag.U32;

  @override
  String toJson() => U32_ID;

  @override
  String toString() => U32_ID;
}

class CLU32BytesParser extends NumericBytesParser {
  @override
  ResultAndRemainder<CLU32, CLErrorCodes> fromBytesWithRemainder(
      Uint8List bytes,
      [CLType? innerType]) {
    if (bytes.length < 4) {
      return resultHelper(Err(CLErrorCodes.EarlyEndOfStream));
    }

    var u32Bytes = Uint8List.fromList(bytes.sublist(0, 4));
    var u32 = BigNumber.from(Uint8List.fromList(u32Bytes.reversed.toList()));
    var remainder = bytes.sublist(4);

    return resultHelper(Ok(CLU32(u32)), remainder);
  }
}

class CLU32 extends Numeric {
  CLU32(dynamic val) : super(32, false, val);

  @override
  CLType clType() {
    return CLU32Type();
  }
}

///
/// CLU64
///
class CLU64Type extends CLType {
  @override
  get linksTo => CLU64;

  @override
  CLTypeTag get tag => CLTypeTag.U64;

  @override
  String toJson() => U64_ID;

  @override
  String toString() => U64_ID;
}

class CLU64BytesParser extends NumericBytesParser {
  @override
  ResultAndRemainder<CLU64, CLErrorCodes> fromBytesWithRemainder(
      Uint8List bytes,
      [CLType? innerType]) {
    if (bytes.length < 8) {
      return resultHelper(Err(CLErrorCodes.EarlyEndOfStream));
    }

    var u64Bytes = Uint8List.fromList(bytes.sublist(0, 8));
    var u64 = BigNumber.from(Uint8List.fromList(u64Bytes.reversed.toList()));
    var remainder = bytes.sublist(8);

    return resultHelper(Ok(CLU64(u64)), remainder);
  }
}

class CLU64 extends Numeric {
  CLU64(dynamic val) : super(64, false, val);

  @override
  CLType clType() {
    return CLU64Type();
  }
}

///
/// CLU128
///
class CLU128Type extends CLType {
  @override
  get linksTo => CLU128;

  @override
  CLTypeTag get tag => CLTypeTag.U128;

  @override
  String toJson() => U128_ID;

  @override
  String toString() {
    return U128_ID;
  }
}

class CLU128BytesParser extends NumericBytesParser {
  @override
  ResultAndRemainder<CLValue, CLErrorCodes> fromBytesWithRemainder(
      Uint8List bytes,
      [CLType? innerType]) {
    return fromBytesBigInt(bytes, 128);
  }
}

class CLU128 extends Numeric {
  CLU128(dynamic val, [Uint8List? originalBytes])
      : super(128, false, val, originalBytes);

  @override
  CLType clType() {
    return CLU128Type();
  }
}

///
/// CLU256
///
class CLU256Type extends CLType {
  @override
  get linksTo => CLU256;

  @override
  CLTypeTag get tag => CLTypeTag.U256;

  @override
  String toJson() => U256_ID;

  @override
  String toString() => U256_ID;
}

class CLU256BytesParser extends NumericBytesParser {
  @override
  ResultAndRemainder<CLValue, CLErrorCodes> fromBytesWithRemainder(
      Uint8List bytes,
      [CLType? innerType]) {
    return fromBytesBigInt(bytes, 256);
  }
}

class CLU256 extends Numeric {
  CLU256(dynamic val, [Uint8List? originalBytes])
      : super(256, false, val, originalBytes);

  @override
  CLType clType() {
    return CLU256Type();
  }
}

///
/// CLU512
///
class CLU512Type extends CLType {
  @override
  get linksTo => CLU512;

  @override
  CLTypeTag get tag => CLTypeTag.U512;

  @override
  String toJson() => U512_ID;

  @override
  String toString() => U512_ID;
}

class CLU512BytesParser extends NumericBytesParser {
  @override
  ResultAndRemainder<CLValue, CLErrorCodes> fromBytesWithRemainder(
      Uint8List bytes,
      [CLType? innerType]) {
    return fromBytesBigInt(bytes, 512);
  }
}

class CLU512 extends Numeric {
  CLU512(dynamic val, [Uint8List? originalBytes])
      : super(512, false, val, originalBytes);

  @override
  CLType clType() {
    return CLU512Type();
  }
}

ResultAndRemainder<CLValue, CLErrorCodes> fromBytesBigInt(
    Uint8List rawBytes, int bitSize) {
  if (rawBytes.isEmpty) {
    return resultHelper(Err(CLErrorCodes.EarlyEndOfStream));
  }

  var byteSize = bitSize / 8;
  var n = rawBytes[0];

  if (n > byteSize) {
    return resultHelper(Err(CLErrorCodes.Formatting));
  }

  if (n + 1 > rawBytes.length) {
    return resultHelper(Err(CLErrorCodes.EarlyEndOfStream));
  }

  var bigIntBytes = n == 0 ? [0] : rawBytes.sublist(1, 1 + n);
  var remainder = rawBytes.sublist(1 + n);
  var value = BigNumber.from(bigIntBytes.reversed.toList());

  if (bitSize == 128) {
    return resultHelper(Ok(CLU128(value, rawBytes)), remainder);
  }

  if (bitSize == 256) {
    return resultHelper(Ok(CLU256(value, rawBytes)), remainder);
  }

  if (bitSize == 512) {
    return resultHelper(Ok(CLU512(value, rawBytes)), remainder);
  }

  return resultHelper(Err(CLErrorCodes.Formatting));
}
