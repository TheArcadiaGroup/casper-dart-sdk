import 'dart:typed_data';

import 'bignumber.dart';
import 'CLValue/abstract.dart';

Function(dynamic val) toBytesNumber(int bitSize, bool signed) {
  return (dynamic val) {
    var valBN = BigNumber.from(val);
    var maxUintValue = maxUint256BN.mask(bitSize);

    if (signed) {
      var bounds = maxUintValue.mask(bitSize - 1);

      if (valBN.gt(bounds) || val.lt(bounds.add(oneBN).mul(negativeOneBN))) {
        throw Exception('value out-of-bounds, value: ' + val.toString());
      }
    } else if (valBN.lt(zeroBN) || valBN.gt(maxUintValue.mask(bitSize))) {
      throw Exception('value out-of-bounds, value: ' + val.toString());
    }

    var valTwos = valBN.toTwos(bitSize).mask(bitSize);

    var bytes = hexToUint8List(valTwos.toHexString());

    if (valTwos.gte(zeroBN)) {
      // for positive number, we had to deal with paddings
      if (bitSize > 64) {
        // if zero just return zero
        if (valTwos.eq(zeroBN)) {
          return bytes;
        }

        // for u128, u256, u512, we have to and append extra byte for length
        return Uint8List.fromList([...bytes, ...List.filled(bytes.length, 0)])
            .reversed;
      } else {
        // for other types, we have to add padding 0s
        var byteLength = bitSize ~/ 8;
        return Uint8List.fromList([
          ...List.from(bytes.reversed),
          ...Uint8List(byteLength - bytes.length)
        ]);
      }
    } else {
      return bytes.reversed;
    }
  };
}

/// Converts `u8` to little endian.
Uint8List toBytesU8(dynamic val) {
  return toBytesNumber(8, false)(val);
}

/// Converts `i32` to little endian.
Uint8List toBytesI32(dynamic val) {
  return toBytesNumber(32, true)(val);
}

/// Converts `u32` to little endian.
Uint8List toBytesU32(dynamic val) {
  return toBytesNumber(32, false)(val);
}

/// Converts `u64` to little endian.
Uint8List toBytesU64(dynamic val) {
  return toBytesNumber(64, false)(val);
}

/// Converts `i64` to little endian.
Uint8List toBytesI64(dynamic val) {
  return toBytesNumber(64, true)(val);
}

/// Converts `u128` to little endian.
Uint8List toBytesU128(dynamic val) {
  return toBytesNumber(128, false)(val);
}

/// Converts `u256` to little endian.
Uint8List toBytesU256(dynamic val) {
  return toBytesNumber(256, false)(val);
}

/// Converts `u512` to little endian.
Uint8List toBytesU512(dynamic val) {
  return toBytesNumber(512, false)(val);
}

/// Serializes a string into an array of bytes.
Uint8List toBytesString(String str) {
  var arr = Uint8List.fromList(str.codeUnits);
  var u32Vec = toBytesU32(arr.length);
  return Uint8List.fromList([...u32Vec, ...arr]);
}

String fromBytesString(Uint8List bytes) {
  return String.fromCharCodes(bytes);
}

Uint8List toBytesArrayU8(Uint8List arr) {
  return Uint8List.fromList([...toBytesU32(arr.length), ...arr]);
}

/// Serializes a vector of values of type `T` into an array of bytes.
Uint8List toBytesVector<T extends ToBytes>(List<T> vec) {
  List<Uint8List> valueByteList = List.empty(growable: true);
  for (var i = 0; i < vec.length; i++) {
    var subList = vec[i].toBytes().unwrap();
    valueByteList.add(subList);
  }

  var u32Vec = toBytesU32(vec.length);
  valueByteList.insert(0, u32Vec);
  var result = valueByteList.expand((element) => element).toList();
  return Uint8List.fromList(result);
}

/// Serializes a vector of values of type `T` into an array of bytes.
Uint8List toBytesVectorNew<T extends CLValue>(List<T> vec) {
  List<Uint8List> valueByteList = List.empty(growable: true);
  for (var i = 0; i < vec.length; i++) {
    var s = CLValueParsers.toBytes(vec[i]).unwrap();
    valueByteList.add(s);
  }

  var u32Vec = toBytesU32(vec.length);
  valueByteList.insert(0, u32Vec);
  var result = valueByteList.expand((element) => element).toList();
  return Uint8List.fromList(result);
}
