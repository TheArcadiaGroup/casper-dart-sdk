import 'dart:convert';
import 'dart:typed_data';
import 'package:convert/convert.dart';

/// Convert base64 encoded string to base16 encoded string
///
/// @param base64 base64 encoded string
String base64to16(String base64String) {
  return encodeBase16(base64Decode(base64String));
}

/// Encode Uint8Array into string using Base-16 encoding.
String encodeBase16(Uint8List bytes) {
  return hex.encode(bytes.toList());
}

/// Decode Base-16 encoded string and returns Uint8Array of bytes.
///
/// @param base16String base16 encoded string
Uint8List decodeBase16(String base16String) {
  return Uint8List.fromList(hex.decode(base16String));
}
