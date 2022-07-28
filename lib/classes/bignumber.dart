// ignore_for_file: non_constant_identifier_names

import 'dart:typed_data';

import 'bn.dart';

const maxSafe = 0x1fffffffffffff;
const _constructorGuard = {};

///
/// BigNumber
///
/// A wrapper around the BN.js object. We use the BN.js library
/// because it is used by elliptic, so it is required regardless.
///
class BigNumber {
  String _hex = '';

  static final NEGATIVE_ONE = BigNumber.from(-1);
  static final ZERO = BigNumber.from(0);
  static final ONE = BigNumber.from(1);
  static final TWO = BigNumber.from(2);
  static final MAXUINT256 = BigNumber.from(
      '0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff');

  BigNumber(dynamic constructorGuard, String hex) {
    if (constructorGuard != _constructorGuard) {
      throw Exception('cannot call constructor directly; use BigNumber.from');
    }

    _hex = hex;
  }

  BigNumber fromTwos(int value) {
    return toBigNumber(toBN(this).fromTwos(value));
  }

  BigNumber toTwos(int value) {
    return toBigNumber(toBN(this).toTwos(value));
  }

  BigNumber abs() {
    if (_hex[0] == "-") {
      return BigNumber.from(_hex.substring(1));
    }
    return this;
  }

  BigNumber add(BigNumber other) {
    return toBigNumber(toBN(this).add(toBN(other)));
  }

  BigNumber div(BigNumber other) {
    var o = BigNumber.from(other);

    if (o.isZero()) {
      throw Exception('division by zero');
    }

    return toBigNumber(toBN(this).div(toBN(other)));
  }

  BigNumber mul(BigNumber other) {
    return toBigNumber(toBN(this).mul(toBN(other)));
  }

  BigNumber mod(BigNumber other) {
    return toBigNumber(toBN(this).mod(toBN(other)));
  }

  BigNumber pow(BigNumber other) {
    var value = toBN(other);
    if (value.isNeg()) {
      throw Exception('cannot raise to negative values');
    }
    return toBigNumber(toBN(this).pow(value));
  }

  BigNumber and(BigNumber other) {
    var value = toBN(other);
    if (isNegative() || value.isNeg()) {
      throw Exception("cannot 'and' negative values");
    }
    return toBigNumber(toBN(this).and(value));
  }

  BigNumber or(BigNumber other) {
    var value = toBN(other);
    if (isNegative() || value.isNeg()) {
      throw Exception("cannot 'or' negative values");
    }
    return toBigNumber(toBN(this).or(value));
  }

  BigNumber xor(BigNumber other) {
    var value = toBN(other);
    if (isNegative() || value.isNeg()) {
      throw Exception("cannot 'xor' negative values");
    }
    return toBigNumber(toBN(this).xor(value));
  }

  BigNumber mask(int value) {
    if (isNegative() || value < 0) {
      throw Exception('cannot mask negative values');
    }

    return toBigNumber(toBN(this).maskn(value));
  }

  BigNumber shl(int value) {
    if (isNegative() || value < 0) {
      throw Exception("cannot shift negative values");
    }
    return toBigNumber(toBN(this).shln(value));
  }

  BigNumber shr(int value) {
    if (isNegative() || value < 0) {
      throw Exception("cannot shift negative values");
    }
    return toBigNumber(toBN(this).shrn(value));
  }

  bool eq(BigNumber other) {
    return toBN(this).eq(toBN(other));
  }

  bool lt(BigNumber other) {
    return toBN(this).lt(toBN(other));
  }

  bool lte(BigNumber other) {
    return toBN(this).lte(toBN(other));
  }

  bool gt(BigNumber other) {
    return toBN(this).gt(toBN(other));
  }

  bool gte(BigNumber other) {
    return toBN(this).gte(toBN(other));
  }

  bool isNegative() {
    return (_hex[0] == '-');
  }

  bool isZero() {
    return toBN(this).isZero();
  }

  num toNumber() {
    try {
      return toBN(this).toNumber();
    } catch (error) {
      throw Exception("overflow toNumber " + toString());
    }
  }

  BigInt toBigInt() {
    try {
      return BigInt.parse(toString());
    } catch (e) {
      rethrow;
    }
  }

  @override
  String toString() {
    return toBN(this).toString(10);
  }

  String toHexString() {
    return _hex;
  }

  String toJSON() {
    String hexString = toHexString();
    return '{"type": "BigNumber", "hex": $hexString}';
  }

  static BigNumber from(dynamic value) {
    if (value is BigNumber) {
      return value;
    }

    if (value is String) {
      if (RegExp(r'^-?0x[0-9a-f]+$').hasMatch(value)) {
        return BigNumber(_constructorGuard, toHex(value));
      }

      if (RegExp(r'^-?[0-9]+$').hasMatch(value)) {
        return BigNumber(_constructorGuard, toHex(BN(value)));
      }
    }

    if (value is num) {
      if (value % 1 > 0) {
        throw Exception("underflow: BigNumber.from " + value.toString());
      }

      if (value >= maxSafe || value <= -maxSafe) {
        throw Exception("overflow BigNumber.from " + value.toString());
      }

      return BigNumber.from(value.toString());
    }

    if (value is List || value is Iterable) {
      return BigNumber.from(uint8ListToHex(Uint8List.fromList(value)));
    }

    throw Exception('invalid BigNumber value');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other.runtimeType != runtimeType) return false;

    return toString() == other.toString();
  }

  @override
  int get hashCode => _hex.hashCode;
}

String toHex(dynamic value) {
  if (value is BN) {
    return toHex(value.toString(16));
  }

  if (value is String) {
    // If negative, prepend the negative sign to the normalized positive value
    if (value[0] == '-') {
      // Strip off the negative sign
      value = value.substring(1);

      // Cannot have mulitple negative signs (e.g. "--0x04")
      if (value[0] == "-") {
        throw Exception("invalid hex value: " + value);
      }

      // Call toHex on the positive component
      value = toHex(value);

      // Do not allow "-0x00"
      if (value == '0x00') {
        return value;
      }

      // Negate the value
      return "-" + value;
    }

    // Add a "0x" prefix if missing
    if (!value.contains("0x")) {
      value = "0x" + value;
    }

    // Normalize zero
    if (value == "0x") {
      return "0x00";
    }

    // Make the string even length
    if (value.length % 2 > 0) {
      value = "0x0" + value.substring(2);
    }

    // Trim to smallest even-length string
    while (value.length > 4 && value.substring(0, 4) == "0x00") {
      value = "0x" + value.substring(4);
    }
  }
  return value;
}

BN toBN(dynamic value) {
  var hex = BigNumber.from(value).toHexString();
  if (hex[0] == '-') {
    return BN('-' + hex.substring(3), 16);
  }

  return BN(hex.substring(2), 16);
}

BigNumber toBigNumber(BN value) {
  return BigNumber.from(toHex(value));
}

Uint8List hexToUint8List(String hex) {
  if (hex.length % 2 != 0) {
    throw 'Odd number of hex digits';
  }

  if (hex.contains("0x")) {
    hex = hex.substring(2);
  }

  var l = hex.length ~/ 2;
  var result = Uint8List(l);
  for (var i = 0; i < l; ++i) {
    var x = int.parse(hex.substring(i * 2, (2 * (i + 1))), radix: 16);
    if (x.isNaN) {
      throw 'Expected hex string';
    }
    result[i] = x;
  }
  return result;
}

String uint8ListToHex(Uint8List list) {
  String result = "0x";
  String hexCharacters = "0123456789abcdef";
  for (var i = 0; i < list.length; i++) {
    var v = list[i];
    result += hexCharacters[(v & 0xf0) >> 4] + hexCharacters[v & 0x0f];
  }

  return result;
}
