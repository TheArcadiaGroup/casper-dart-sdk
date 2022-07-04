import 'dart:convert';
import 'dart:typed_data';

import 'package:casper_dart_sdk/classes/CLValue/abstract.dart';
import 'package:casper_dart_sdk/classes/CLValue/bool.dart';
import 'package:casper_dart_sdk/classes/CLValue/builders.dart';
import 'package:casper_dart_sdk/classes/CLValue/constants.dart';
import 'package:test/test.dart';

void main() {
  group('CLBool', () {
    test('Bool should return proper clType', () {
      var myBool = CLBool(false);
      var clType = myBool.clType();
      expect(clType.toString(), equals('Bool'));
    });

    test('Should be able to return proper value by calling .value()', () {
      var myBool = CLBool(false);
      var myBool2 = CLBool(true);

      expect(myBool.value(), equals(false));
      expect(myBool2.value(), equals(true));
    });

    test('toBytes() / fromBytes() do proper bytes serialization', () {
      var myBool1 = CLValueBuilder.boolean(false);
      var myBool2 = CLBool(true);
      var myBoolBytes1 = CLValueParsers.toBytes(myBool1).unwrap();
      var myBoolBytes2 = CLValueParsers.toBytes(myBool2).unwrap();

      CLBool fromBytes1 = CLValueParsers.fromBytes(myBoolBytes1, CLBoolType())
          .unwrap() as CLBool;
      CLBool fromBytes2 = CLValueParsers.fromBytes(myBoolBytes2, CLBoolType())
          .unwrap() as CLBool;

      expect(myBoolBytes1, equals(Uint8List.fromList([0])));
      expect(myBoolBytes2, equals(Uint8List.fromList([1])));

      expect(fromBytes1, equals(myBool1));
      expect(fromBytes2, equals(myBool2));

      expect(
          CLValueParsers.fromBytes(Uint8List.fromList([9, 1]), CLBoolType())
              .isOk(),
          equals(false));

      expect(
          CLValueParsers.fromBytes(Uint8List.fromList([9, 1]), CLBoolType())
              .unwrapErr(),
          equals(CLErrorCodes.Formatting));

      expect(
          CLValueParsers.fromBytes(Uint8List.fromList([]), CLBoolType()).isOk(),
          equals(false));

      expect(
          CLValueParsers.fromBytes(Uint8List.fromList([]), CLBoolType())
              .unwrapErr(),
          equals(CLErrorCodes.EarlyEndOfStream));
    });

    test('toJSON() / fromJSON() do proper bytes serialization', () {
      var myBool = CLBool(false);
      var json = CLValueParsers.toJSON(myBool).unwrap();
      var expectedJSON = jsonDecode('{"bytes":"00","cl_type":"Bool"}');

      var myBool2 = CLValueParsers.fromJSON(expectedJSON).unwrap();

      expect(json.toJSON(), equals(expectedJSON));
      expect(myBool2, equals(myBool));
    });
  });
}
