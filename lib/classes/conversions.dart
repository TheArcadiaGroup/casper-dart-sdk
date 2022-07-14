import 'dart:convert';
import 'dart:typed_data';
import 'package:convert/convert.dart';

/// Convert base64 encoded string to base16 encoded string
///
/// @param base64 base64 encoded string
String base64to16(String base64String) {
  return base16Encode(base64Decode(base64String));
}

/// Encode Uint8Array into string using Base-16 encoding.
String base16Encode(Uint8List bytes) {
  return hex.encode(bytes.toList());
}

/// Decode Base-16 encoded string and returns Uint8Array of bytes.
///
/// @param base16String base16 encoded string
Uint8List base16Decode(String base16String) {
  return Uint8List.fromList(hex.decode(base16String));
}

BigInt bytesToBigInt(Uint8List bytes) {
  BigInt read(int start, int end) {
    if (end - start <= 4) {
      int result = 0;
      for (int i = end - 1; i >= start; i--) {
        result = result * 256 + bytes[i];
      }
      return BigInt.from(result);
    }
    int mid = start + ((end - start) >> 1);
    var result =
        read(start, mid) + read(mid, end) * (BigInt.one << ((mid - start) * 8));
    return result;
  }

  return read(0, bytes.length);
}

Uint8List bigIntToBytes(BigInt number) {
  // Not handling negative numbers. Decide how you want to do that.
  int bytes = (number.bitLength + 7) >> 3;
  var b256 = BigInt.from(256);
  var result = Uint8List(bytes);
  for (int i = 0; i < bytes; i++) {
    result[i] = number.remainder(b256).toInt();
    number = number >> 8;
  }
  return result;
}
