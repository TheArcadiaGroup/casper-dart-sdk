import 'dart:convert';
import 'dart:typed_data';

import 'package:casper_dart_sdk/classes/CLValue/abstract.dart';
import 'package:casper_dart_sdk/classes/CLValue/byte_array.dart';
import 'package:test/test.dart';

void main() {
  group('CLByteArray', () {
    test('Should be able to return proper value by calling .value()', () {
      var arr8 = Uint8List.fromList([21, 31]);
      var myHash = CLByteArray(arr8);

      expect(myHash.value(), equals(arr8));
    });

    test('Should be able to return proper value by calling .clType()', () {
      var arr8 = Uint8List.fromList([21, 31]);
      var myHash = CLByteArray(arr8);

      expect(myHash.clType().toString(), equals('ByteArray'));
    });

    test(
        'Should be able to return proper byte array by calling toBytes() / fromBytes()',
        () {
      var expectedBytes = Uint8List.fromList(List.filled(32, 42));
      var hash = CLByteArray(expectedBytes);
      var bytes = CLValueParsers.toBytes(hash).unwrap();
      var bytes2 =
          CLValueParsers.fromBytes(bytes, CLByteArrayType(32)).unwrap();

      expect(bytes, equals(expectedBytes));
      expect(bytes2, equals(hash));
    });

    test('toJson() / fromJson()', () {
      var bytes = Uint8List.fromList(List.filled(32, 42));
      var hash = CLByteArray(bytes);
      var json = CLValueParsers.toJSON(hash).unwrap();

      var expectedJSON = jsonDecode(
          '{"bytes":"2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a","cl_type":{"ByteArray":32}}');

      var bytes2 = CLValueParsers.fromJSON(expectedJSON).unwrap();

      expect(json.toJSON(), equals(expectedJSON));
      expect(bytes2, equals(hash));
    });

    test('fromJSON() with length more than 32 bytes', () {
      var json = jsonDecode(
          '{"bytes":"7f8d377b97dc7fbf3a777f5ae75eb6edbe79739df9d747f86bbf3b7f7efcd37d7a7b475c7fcefb6f8d3cd7dedcf1a6bd","cl_type":{"ByteArray":48}}');
      var bytes = CLValueParsers.fromJSON(json).unwrap();
      var expectedJSON = CLValueParsers.toJSON(bytes).unwrap();

      expect(expectedJSON.toJSON(), equals(json));
    });
  });
}
