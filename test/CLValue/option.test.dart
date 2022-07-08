import 'dart:convert';
import 'dart:typed_data';

import 'package:casper_dart_sdk/classes/CLValue/abstract.dart';
import 'package:oxidized/oxidized.dart';
import 'package:test/test.dart';

import 'package:casper_dart_sdk/classes/CLValue/bool.dart';
import 'package:casper_dart_sdk/classes/CLValue/option.dart';

void main() {
  group('CLOption', () {
    var mySomeOpt = CLOption(Some(CLBool(true)));
    var myNoneOpt = CLOption(const None<CLValue>(), CLBoolType());

    test('Should be valid by construction', () {
      expect(mySomeOpt, isA<CLOption>());
      expect(myNoneOpt, isA<CLOption>());
    });

    test('clType() should return proper type', () {
      expect(mySomeOpt.clType().toString(), equals('Option (Bool)'));
    });

    test('toBytes() / fromBytes()', () {
      var myType = CLOptionType(CLBoolType());
      var optionFromBytes =
          CLValueParsers.fromBytes(Uint8List.fromList([1, 1]), myType).unwrap();

      var mySomeOptData = mySomeOpt.data;
      var optionFromBytesData = optionFromBytes.data as Some<CLValue>;

      var mySomeOptBytes = CLValueParsers.toBytes(mySomeOpt).unwrap();
      var myNoneOptBytes = CLValueParsers.toBytes(myNoneOpt).unwrap();

      expect(mySomeOptBytes, Uint8List.fromList([1, 1]));
      expect(myNoneOptBytes, Uint8List.fromList([0]));
      expect(optionFromBytesData.unwrap().data, mySomeOptData.unwrap().data);
    });

    test('fromJSON() / toJSON()', () {
      var jsonSome = CLValueParsers.toJSON(mySomeOpt).unwrap();
      var jsonNone = CLValueParsers.toJSON(myNoneOpt).unwrap();

      var expectedJsonSome =
          jsonDecode('{"bytes":"0101","cl_type":{"Option":"Bool"}}');
      var expectedJsonNone =
          jsonDecode('{"bytes":"00","cl_type":{"Option":"Bool"}}');

      expect(jsonSome.toJson(), expectedJsonSome);
      expect(jsonNone.toJson(), expectedJsonNone);

      var eJsonSomeData = CLValueParsers.fromJSON(expectedJsonSome).unwrap()
          as CLOption<CLValue>;
      var eJsonNoneData = CLValueParsers.fromJSON(expectedJsonNone).unwrap()
          as CLOption<CLValue>;

      expect(eJsonSomeData, mySomeOpt);
      expect(eJsonNoneData, myNoneOpt);
    });
  });
}
