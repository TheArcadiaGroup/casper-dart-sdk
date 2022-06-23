import 'dart:convert';
import 'dart:typed_data';

import 'package:casper_dart_sdk/classes/CLValue/abstract.dart';
import 'package:casper_dart_sdk/classes/CLValue/bool.dart';
import 'package:casper_dart_sdk/classes/CLValue/list.dart';
import 'package:casper_dart_sdk/classes/CLValue/numeric.dart';
import 'package:casper_dart_sdk/classes/CLValue/option.dart';
import 'package:casper_dart_sdk/classes/CLValue/result.dart';
import 'package:oxidized/oxidized.dart';
import 'package:test/test.dart';

void main() {
  var myTypes = CLResultTypeMap(CLBoolType(), CLU8Type());
  var myOkRes = CLResult(Ok(CLBool(true)), myTypes);
  var myErrRes = CLResult(Err(CLU8(1)), myTypes);

  var myTypesComplex = CLResultTypeMap(CLListType(CLListType(CLU8Type())),
      CLOptionType(CLListType(CLListType(CLU8Type()))));

  var myOkComplexRes = CLResult(
      Ok(CLList.fromList([
        CLList.fromList([CLU8(5), CLU8(10), CLU8(15)])
      ])),
      myTypesComplex);

  var myErrComplexRes = CLResult(
      Err(CLOption(Some(CLList.fromList([
        CLList.fromList([CLU8(5), CLU8(10), CLU8(15)])
      ])))),
      myTypesComplex);

  group('CLResult', () {
    test('Should be valid by varruction', () {
      expect(myOkRes, isA<CLResult>());
      expect(myErrRes, isA<CLResult>());
    });

    test('clType() should return proper type', () {
      expect(myOkRes.clType().toString(), 'Result (OK: Bool, ERR: Bool)');
    });

    test('toBytes() / fromBytes()', () {
      var okBytes = CLValueParsers.toBytes(myOkRes).unwrap();
      var errBytes = CLValueParsers.toBytes(myErrRes).unwrap();

      expect(okBytes, equals(Uint8List.fromList([1, 1])));
      expect(errBytes, equals(Uint8List.fromList([0, 1])));

      var okFromBytes =
          CLValueParsers.fromBytes(okBytes, CLResultType(myTypes)).unwrap();

      var errFromBytes =
          CLValueParsers.fromBytes(errBytes, CLResultType(myTypes)).unwrap()
              as CLResult<CLType, CLType>;

      expect(okFromBytes, myOkRes);
      expect(errFromBytes, myErrRes);
    });

    test('toJSON() / fromJSON() on Ok', () {
      var myOkJson = CLValueParsers.toJSON(myOkRes).unwrap();
      var expectedOkJson = jsonDecode(
          '{"bytes":"0101","cl_type":{"Result":{"ok":"Bool","err":"U8"}}}');

      var myOkFromJson = CLValueParsers.fromJSON(expectedOkJson).unwrap();

      expect(myOkJson.toJSON(), expectedOkJson);
      expect(myOkFromJson, myOkRes);
    });

    test('toJSON() / fromJSON() on Err', () {
      var myErrJson = CLValueParsers.toJSON(myErrRes).unwrap();
      var expectedErrJson = jsonDecode(
          '{"bytes":"0001","cl_type":{"Result":{"ok":"Bool","err":"U8"}}}');

      var myErrFromJson = CLValueParsers.fromJSON(expectedErrJson).unwrap();

      expect(myErrJson.toJSON(), expectedErrJson);
      expect(myErrFromJson, myErrRes);
    });

    test('toBytesWithType() / fromBytesWithType()', () {
      var okResBytesWithCLType =
          CLValueParsers.toBytesWithType(myOkRes).unwrap();
      var okFromBytes =
          CLValueParsers.fromBytesWithType(okResBytesWithCLType).unwrap();

      var errResBytesWithCLType =
          CLValueParsers.toBytesWithType(myErrRes).unwrap();
      var errFromBytes =
          CLValueParsers.fromBytesWithType(errResBytesWithCLType).unwrap();

      expect(okFromBytes, myOkRes);
      expect(errFromBytes, myErrRes);
    });

    test('Complex examples toBytesWithCLType() / fromBytesWithCLType()', () {
      var okResBytesWithCLType =
          CLValueParsers.toBytesWithType(myOkComplexRes).unwrap();
      var okFromBytes =
          CLValueParsers.fromBytesWithType(okResBytesWithCLType).unwrap();

      var errResBytesWithCLType =
          CLValueParsers.toBytesWithType(myErrComplexRes).unwrap();
      var errFromBytes =
          CLValueParsers.fromBytesWithType(errResBytesWithCLType).unwrap();

      expect(okFromBytes, myOkComplexRes);
      expect(errFromBytes, myErrComplexRes);
    });
  });
}
