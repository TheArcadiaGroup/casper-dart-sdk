import 'dart:convert';

import 'package:casper_dart_sdk/classes/CLValue/abstract.dart';
import 'package:casper_dart_sdk/classes/CLValue/string.dart';
import 'package:test/test.dart';

void main() {
  group('CLString', () {
    test('CLString value() should return proper value', () {
      var str = CLString('ABC');
      expect(str.value(), 'ABC');
    });

    test('CLString clType() should return proper type', () {
      var str = CLString('ABC');
      expect(str.clType().toString(), 'String');
    });

    test('CLString size() should return proper string length', () {
      var str = CLString('ABC');
      expect(str.size(), 3);
    });

    test('toBytes() / fromBytes()', () {
      var str = CLString('ABC');
      var bytes = CLValueParsers.toBytes(str).unwrap();
      var result = CLValueParsers.fromBytes(bytes, CLStringType()).unwrap();
      expect(result, str);
    });

    test('toJSON() / fromJSON()', () {
      var str = CLString('ABC-DEF');
      var json = CLValueParsers.toJSON(str).unwrap();
      var expectedJson =
          jsonDecode('{"bytes":"070000004142432d444546","cl_type":"String"}');
      var fromJSON = CLValueParsers.fromJSON(expectedJson).unwrap();

      expect(json.toJson(), expectedJson);
      expect(fromJSON, str);
    });
  });
}
