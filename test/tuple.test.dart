import 'dart:convert';
import 'dart:typed_data';

import 'package:casper_dart_sdk/classes/CLValue/abstract.dart';
import 'package:casper_dart_sdk/classes/CLValue/bool.dart';
import 'package:casper_dart_sdk/classes/CLValue/byte_array.dart';
import 'package:casper_dart_sdk/classes/CLValue/numeric.dart';
import 'package:casper_dart_sdk/classes/CLValue/string.dart';
import 'package:casper_dart_sdk/classes/CLValue/tuple.dart';
import 'package:test/test.dart';

void main() {
  group('CLTuple', () {
    test('Tuple2 should return proper clType', () {
      var myBool = CLBool(false);
      var myStr = CLString('ABC');
      var myTup = CLTuple2([myBool, myStr]);

      expect(myTup.clType().toString(), 'Tuple2 (Bool, String)');
    });

    test(
        'Should be able to create tuple with proper values - correct by construction',
        () {
      var myTup2 = CLTuple2([CLBool(true), CLBool(false)]);

      expect(myTup2, isA<CLTuple2>());
    });

    test('Should throw an error when tuple is not correct by construction', () {
      try {
        CLTuple1([CLBool(true), CLBool(false)]);
      } catch (e) {
        expect(e.toString(), Exception('Too many elements!').toString());
      }
    });

    test('Should be able to return proper values by calling .value() on Tuple',
        () {
      var myBool = CLBool(false);
      var myTuple = CLTuple1([myBool]);

      expect(myTuple.value(), [myBool]);
    });

    test('Get should return proper value', () {
      var myTup = CLTuple2([CLBool(true)]);
      var newItem = CLBool(false);

      myTup.push(newItem);

      expect(myTup.get(1), newItem);
    });

    test('Set should be able to set values at already declared indexes', () {
      var myTup = CLTuple1([CLBool(true)]);
      var newItem = CLBool(false);

      myTup.set(0, newItem);

      expect(myTup.get(0), newItem);
    });

    test('Set should throw error on wrong indexes', () {
      var myTup = CLTuple1([CLBool(true)]);

      try {
        myTup.set(1, CLBool(false));
      } catch (e) {
        expect(
            e.toString(), Exception('Tuple index out of bounds.').toString());
      }
    });

    test('Push should be able to push values to tuple', () {
      var myTup = CLTuple2([CLBool(true)]);
      var newItem = CLBool(false);

      myTup.push(newItem);

      expect(myTup.get(1), newItem);
    });

    test('Push should throw error if there is no more space in the tuple', () {
      var myTup = CLTuple1([CLBool(true)]);

      try {
        myTup.push(CLBool(false));
      } catch (e) {
        expect(
            e.toString(), Exception('No more space in this tuple!').toString());
      }
    });

    test('Should run toBytes() / fromBytes()', () {
      var myTup1 = CLTuple1([CLBool(true)]);
      var myTup2 = CLTuple2([CLBool(false), CLI32(-555)]);
      var myTup3 = CLTuple3([CLI32(-555), CLString('ABC'), CLString('XYZ')]);

      var myTup1Bytes = CLValueParsers.toBytes(myTup1).unwrap();
      var myTup2Bytes = CLValueParsers.toBytes(myTup2).unwrap();
      var myTup3Bytes = CLValueParsers.toBytes(myTup3).unwrap();

      expect(
          CLValueParsers.fromBytes(myTup1Bytes, CLTuple1Type([CLBoolType()]))
              .unwrap(),
          myTup1);

      expect(
          CLValueParsers.fromBytes(
              myTup2Bytes, CLTuple2Type([CLBoolType(), CLI32Type()])).unwrap(),
          myTup2);

      expect(
          CLValueParsers.fromBytes(myTup3Bytes,
                  CLTuple3Type([CLI32Type(), CLStringType(), CLStringType()]))
              .unwrap(),
          (myTup3));
    });
  });

  test('fromJSON() / toJSON()', () {
    var arr = CLByteArray(Uint8List.fromList([1, 2, 3]));
    var arr2 = CLByteArray(Uint8List.fromList([
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10,
      11,
      12,
      13,
      14,
      15,
      16,
      17,
      18,
      19,
      20,
      21,
      22,
      23,
      24,
      25,
      26,
      27,
      28,
      29,
      30,
      31,
      32,
      33,
      34
    ]));

    var myTup1 = CLTuple1([arr]);
    var myTup2 = CLTuple2([arr, arr2]);
    var myTup3 = CLTuple3([arr, arr2, CLString('ABC')]);

    var myTup1JSON = CLValueParsers.toJSON(myTup1).unwrap();
    var expectedMyTup1JSON =
        jsonDecode('{"bytes":"010203","cl_type":{"Tuple1":[{"ByteArray":3}]}}');

    var myTup2JSON = CLValueParsers.toJSON(myTup2).unwrap();
    var expectedMyTup2JSON = jsonDecode(
        '{"bytes":"0102030102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122","cl_type":{"Tuple2":[{"ByteArray":3},{"ByteArray":34}]}}');

    var myTup3JSON = CLValueParsers.toJSON(myTup3).unwrap();
    var expectedMyTup3JSON = jsonDecode(
        '{"bytes":"0102030102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f20212203000000414243","cl_type":{"Tuple3":[{"ByteArray":3},{"ByteArray":34},"String"]}}');

    expect(myTup1JSON.toJSON(), expectedMyTup1JSON);
    expect(CLValueParsers.fromJSON(expectedMyTup1JSON).unwrap(), myTup1);

    expect(myTup2JSON.toJSON(), expectedMyTup2JSON);
    expect(CLValueParsers.fromJSON(expectedMyTup2JSON).unwrap(), myTup2);

    expect(myTup3JSON.toJSON(), expectedMyTup3JSON);
    expect(CLValueParsers.fromJSON(expectedMyTup3JSON).unwrap(), myTup3);
  });
}
