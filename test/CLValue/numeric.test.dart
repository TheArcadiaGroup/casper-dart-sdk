import 'dart:convert';

import 'package:casper_dart_sdk/classes/CLValue/abstract.dart';
import 'package:casper_dart_sdk/classes/CLValue/numeric.dart';
import 'package:test/test.dart';

const maxI64 = '9223372036854775807';
const maxU8 = 255;
const maxU32 = 4294967295;
const maxU64 = '18446744073709551615';

void main() {
  group('Numeric implementation tests', () {
    test('Bool should return proper clType', () {
      var n = CLI32(10);
      expect(n.value().toNumber(), equals(10));
    });

    test('Numeric clType() should return proper type', () {
      var n = CLU128(20000);
      expect(n.clType().toString(), equals('U128'));
    });

    test('Unsigned Numeric cant accept negative numbers in constructor', () {
      try {
        CLU128(-100);
      } catch (e) {
        expect(
            e.toString(),
            Exception("Can't provide negative numbers with isSigned=false")
                .toString());
      }
    });

    test('CLI32 do proper toBytes()/fromBytes()', () {
      var num1 = CLI32(-10);
      var numBytes1 = CLValueParsers.toBytes(num1).unwrap();

      var num2 = CLI32(1);
      var numBytes2 = CLValueParsers.toBytes(num2).unwrap();

      var fromBytes1 =
          CLValueParsers.fromBytes(numBytes1, CLI32Type()).unwrap() as CLI32;

      var fromBytes2 =
          CLValueParsers.fromBytes(numBytes2, CLI32Type()).unwrap() as CLI32;

      expect(fromBytes1, equals(num1));
      expect(fromBytes2, equals(num2));
    });

    test('CLI64 do proper toBytes()/fromBytes()', () {
      var num1 = CLI64(-10);
      var numBytes1 = CLValueParsers.toBytes(num1).unwrap();

      var num2 = CLI64(maxI64);
      var numBytes2 = CLValueParsers.toBytes(num2).unwrap();

      var fromBytes1 =
          CLValueParsers.fromBytes(numBytes1, CLI64Type()).unwrap() as CLI64;

      var fromBytes2 =
          CLValueParsers.fromBytes(numBytes2, CLI64Type()).unwrap() as CLI64;

      expect(fromBytes1, equals(num1));
      expect(fromBytes2, equals(num2));
    });

    test('CLU8 do proper toBytes()/fromBytes()', () {
      var num1 = CLU8(10);
      var numBytes1 = CLValueParsers.toBytes(num1).unwrap();

      var num2 = CLU8(maxU8);
      var numBytes2 = CLValueParsers.toBytes(num2).unwrap();

      var fromBytes1 =
          CLValueParsers.fromBytes(numBytes1, CLU8Type()).unwrap() as CLU8;

      var fromBytes2 =
          CLValueParsers.fromBytes(numBytes2, CLU8Type()).unwrap() as CLU8;

      expect(fromBytes1, equals(num1));
      expect(fromBytes2, equals(num2));
    });

    test('CLU32 do proper toBytes()/fromBytes()', () {
      var num1 = CLU32(10);
      var numBytes1 = CLValueParsers.toBytes(num1).unwrap();

      var num2 = CLU32(maxU32);
      var numBytes2 = CLValueParsers.toBytes(num2).unwrap();

      var fromBytes1 =
          CLValueParsers.fromBytes(numBytes1, CLU32Type()).unwrap();

      var fromBytes2 =
          CLValueParsers.fromBytes(numBytes2, CLU32Type()).unwrap();

      expect(fromBytes1, equals(num1));
      expect(fromBytes2, equals(num2));
    });

    test('CLU64 do proper toBytes()/fromBytes()', () {
      var num1 = CLU64(10);
      var numBytes1 = CLValueParsers.toBytes(num1).unwrap();

      var num2 = CLU64(maxU64);
      var numBytes2 = CLValueParsers.toBytes(num2).unwrap();

      var fromBytes1 =
          CLValueParsers.fromBytes(numBytes1, CLU64Type()).unwrap() as CLU64;

      var fromBytes2 =
          CLValueParsers.fromBytes(numBytes2, CLU64Type()).unwrap() as CLU64;

      expect(fromBytes1, equals(num1));
      expect(fromBytes2.value().toBigInt(), equals(num2.value().toBigInt()));
    });

    test('CLI32 toJSON() / fromJSON()', () {
      var num1 = CLI32(10);
      var num1JSON = CLValueParsers.toJSON(num1).unwrap();
      var expectedJson = jsonDecode('{"bytes":"0a000000","cl_type":"I32"}');
      var num2 = CLValueParsers.fromJSON(expectedJson).unwrap() as CLI32;

      expect(num1JSON.toJson(), equals(expectedJson));
      expect(num2, equals(num1));
    });

    test('CLI64 toJSON() / fromJSON()', () {
      var num1 = CLI64(maxI64);
      var num1JSON = CLValueParsers.toJSON(num1).unwrap();
      var expectedJson =
          jsonDecode('{"bytes":"ffffffffffffff7f","cl_type":"I64"}');
      var num2 = CLValueParsers.fromJSON(expectedJson).unwrap() as CLI64;

      expect(num1JSON.toJson(), equals(expectedJson));
      expect(num2.value().toBigInt(), equals(num1.value().toBigInt()));
    });

    test('CLU8 toJSON() / fromJSON()', () {
      var num1 = CLU8(maxU8);
      var num1JSON = CLValueParsers.toJSON(num1).unwrap();
      var expectedJson = jsonDecode('{"bytes":"ff","cl_type":"U8"}');
      CLU8 num2 = CLValueParsers.fromJSON(expectedJson).unwrap() as CLU8;

      expect(num1JSON.toJson(), equals(expectedJson));
      expect(num2, equals(num1));
    });

    test('CLU32 toJSON() / fromJSON()', () {
      var num1 = CLU32(maxU32);
      var num1JSON = CLValueParsers.toJSON(num1).unwrap();
      var expectedJson = jsonDecode('{"bytes":"ffffffff","cl_type":"U32"}');
      CLU32 num2 = CLValueParsers.fromJSON(expectedJson).unwrap() as CLU32;

      expect(num1JSON.toJson(), equals(expectedJson));
      expect(num2, equals(num1));
    });

    test('CLU64 toJSON() / fromJSON()', () {
      var num1 = CLU64(maxU64);
      var num1JSON = CLValueParsers.toJSON(num1).unwrap();
      var expectedJson =
          jsonDecode('{"bytes":"ffffffffffffffff","cl_type":"U64"}');
      CLU64 num2 = CLValueParsers.fromJSON(expectedJson).unwrap() as CLU64;

      expect(num1JSON.toJson(), equals(expectedJson));
      expect(num2, equals(num1));
    });
  });
}
