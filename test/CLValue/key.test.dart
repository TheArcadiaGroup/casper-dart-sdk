import 'dart:convert';
import 'dart:typed_data';

import 'package:casper_dart_sdk/classes/CLValue/abstract.dart';
import 'package:casper_dart_sdk/classes/CLValue/account_hash.dart';
import 'package:casper_dart_sdk/classes/CLValue/byte_array.dart';
import 'package:casper_dart_sdk/classes/CLValue/key.dart';
import 'package:casper_dart_sdk/classes/CLValue/uref.dart';
import 'package:casper_dart_sdk/classes/conversions.dart';
import 'package:test/test.dart';

void main() {
  group('CLKey', () {
    const urefAddr =
        '2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a';

    test('Create with (CLByteArray) and test .value() / isHash()', () {
      var byteArr = CLByteArray(Uint8List.fromList([21, 31]));
      var myKey = CLKey(byteArr);

      expect(myKey.value(), equals(byteArr));
      expect(myKey.isHash(), equals(true));
    });

    test('Create with (CLUref) and test .value() / isURef()', () {
      var uref = CLURef(decodeBase16(urefAddr), AccessRights.READ_ADD_WRITE);
      var myKey = CLKey(uref);

      expect(myKey.value(), equals(uref));
      expect(myKey.isURef(), equals(true));
    });

    test('Create with (CLAccountHash) and test .value() isAccount()', () {
      var arr8 = Uint8List.fromList([21, 31]);
      var myHash = CLAccountHash(arr8);
      var myKey = CLKey(myHash);

      expect(myKey.value(), equals(myHash));
      expect(myKey.isAccount(), equals(true));
    });

    test('toBytes() / fromBytes() with CLByteArray', () {
      var arr8 = Uint8List.fromList(List.filled(32, 42));
      var byteArr = CLByteArray(arr8);
      var expectedBytes = Uint8List.fromList([1, ...List.filled(32, 42)]);
      var myKey = CLKey(byteArr);
      var bytes = CLValueParsers.toBytes(myKey).unwrap();
      var fromExpectedBytes =
          CLValueParsers.fromBytes(bytes, CLKeyType()).unwrap() as CLKey;

      expect(bytes, equals(expectedBytes));
      expect(fromExpectedBytes, equals(myKey));
    });

    test('toJSON() / fromJSON() with CLByteArray', () {
      var byteArr = CLByteArray(Uint8List.fromList([21, 31]));
      var myKey = CLKey(byteArr);
      var json = CLValueParsers.toJSON(myKey).unwrap();
      var expectedJSON = jsonDecode('{"bytes":"01151f","cl_type":"Key"}');
      var fromJSON = CLValueParsers.fromJSON(expectedJSON).unwrap() as CLKey;

      expect(json.toJSON(), equals(expectedJSON));
      expect(fromJSON, equals(myKey));
    });

    test('toBytes() / fromBytes() with CLAccountHash', () {
      var hash = CLAccountHash(Uint8List.fromList(List.filled(32, 42)));
      var expectedBytes = Uint8List.fromList([0, ...List.filled(32, 42)]);
      var myKey = CLKey(hash);
      var bytes = CLValueParsers.toBytes(myKey).unwrap();
      var fromExpectedBytes =
          CLValueParsers.fromBytes(bytes, CLKeyType()).unwrap() as CLKey;

      expect(bytes, equals(expectedBytes));
      expect(fromExpectedBytes, equals(myKey));
    });

    test('toJSON() / fromJSON() with CLAccountHash', () {
      var hash = CLAccountHash(Uint8List.fromList(List.filled(32, 42)));
      var myKey = CLKey(hash);
      var json = CLValueParsers.toJSON(myKey).unwrap();
      var expectedJSON = jsonDecode(
          '{"bytes":"002a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a","cl_type":"Key"}');

      var fromJSON = CLValueParsers.fromJSON(expectedJSON).unwrap() as CLKey;

      expect(json.toJSON(), equals(expectedJSON));
      expect(fromJSON, equals(myKey));
    });

    test('toBytes() / fromBytes() with CLURef', () {
      var urefAddr =
          '2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a';
      var truth = decodeBase16(
          '022a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a07');

      var uref = CLURef(decodeBase16(urefAddr), AccessRights.READ_ADD_WRITE);
      var myKey = CLKey(uref);
      var bytes = CLValueParsers.toBytes(myKey).unwrap();
      var fromExpectedBytes =
          CLValueParsers.fromBytes(bytes, CLKeyType()).unwrap() as CLKey;

      expect(bytes, equals(truth));
      expect(fromExpectedBytes, equals(myKey));
    });

    test('toJSON() / fromJSON() with CLUref', () {
      var urefAddr =
          '2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a';
      var uref = CLURef(decodeBase16(urefAddr), AccessRights.READ_ADD_WRITE);
      var myKey = CLKey(uref);
      var json = CLValueParsers.toJSON(myKey).unwrap();
      var expectedJSON = jsonDecode(
          '{"bytes":"022a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a07","cl_type":"Key"}');

      var fromJSON = CLValueParsers.fromJSON(expectedJSON).unwrap() as CLKey;

      expect(json.toJSON(), equals(expectedJSON));
      expect(fromJSON, equals(myKey));
    });

    test('Should be able to return proper value by calling .clType()', () {
      var arr8 = CLByteArray(Uint8List.fromList([21, 31]));
      var myKey = CLKey(arr8);

      expect(myKey.clType().toString(), equals('Key'));
    });
  });
}
