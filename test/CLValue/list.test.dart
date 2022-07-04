import 'dart:convert';
import 'dart:typed_data';

import 'package:casper_dart_sdk/classes/CLValue/abstract.dart';
import 'package:casper_dart_sdk/classes/CLValue/bool.dart';
import 'package:casper_dart_sdk/classes/CLValue/byte_array.dart';
import 'package:casper_dart_sdk/classes/CLValue/key.dart';
import 'package:casper_dart_sdk/classes/CLValue/list.dart';
import 'package:casper_dart_sdk/classes/CLValue/numeric.dart';
import 'package:casper_dart_sdk/classes/CLValue/string.dart';
import 'package:casper_dart_sdk/classes/bignumber.dart';
import 'package:test/test.dart';

void main() {
  group('CLList', () {
    test('List should return proper clType', () {
      var myBool = CLBool(false);
      var myList = CLList.fromList([myBool]);

      expect(myList.clType().toString(), equals('List (Bool)'));
    });

    test(
        'Should be able to create List with proper values - correct by construction',
        () {
      var myList = CLList.fromList([CLBool(true), CLBool(false)]);

      expect(myList, isA<CLList>());
    });

    test('Should throw an error when list is not correct by construction', () {
      try {
        CLList.fromList([
          CLBool(true),
          CLList.fromList([CLBool(false)])
        ]);
      } catch (e) {
        expect(e.toString(), Exception('Invalid data provided.').toString());
      }
    });

    test('Should be able to return proper values by calling .value() on List',
        () {
      var myBool = CLBool(false);
      var myList = CLList.fromList([myBool]);

      expect(myList.data, equals([myBool]));
    });

    test('Get on non existing index should throw an error', () {
      var mList = CLList.fromCType(CLBoolType());

      try {
        mList.get(100);
      } catch (e) {
        expect(e.toString(), Exception('List index out of bounds.').toString());
      }
    });

    test('Should able to create empty List by providing type', () {
      var mList = CLList.fromCType(CLBoolType());
      var len = mList.size();

      expect(len, equals(0));

      try {
        mList.push(CLU8(10));
      } catch (e) {
        expect(e.toString(),
            Exception('Incosnsistent data type, use Bool.').toString());
      }
    });

    test('Get should return proper value', () {
      var myList = CLList.fromList([CLBool(true)]);
      var newItem = CLBool(false);

      myList.push(newItem);

      expect(myList.get(1), equals(newItem));
    });

    test('Set should be able to set values at already declared indexes', () {
      var myList = CLList.fromList([CLBool(true)]);
      var newItem = CLBool(false);

      myList.set(0, newItem);

      expect(myList.get(0), equals(newItem));
    });

    test('Set should throw error on wrong indexes', () {
      var myList = CLList.fromList([CLBool(true)]);

      try {
        myList.set(1, CLBool(false));
      } catch (e) {
        expect(e.toString(), Exception('List index out of bounds.').toString());
      }
    });

    test('Pop should remove last item from array and return it', () {
      var myList = CLList.fromList([CLBool(true), CLBool(false)]);
      CLBool popped = myList.pop();

      expect(myList.size(), equals(1));
      expect(popped, equals(CLBool(false)));
    });

    test('Should set nested value by chaining methods', () {
      var myList = CLList.fromList([
        CLList.fromList([CLBool(true), CLBool(false)])
      ]);

      myList.get(0).set(1, CLBool(true));

      expect(myList.get(0).get(1), equals(CLBool(true)));
    });

    test('Remove should remove item at certein index', () {
      var myList = CLList.fromList([CLBool(true), CLBool(false)]);

      myList.remove(0);

      expect(myList.get(0), equals(CLBool(false)));
    });

    test('toBytes() / fromBytes()', () {
      CLList myList = CLList.fromList([CLBool(false)]);
      var expected = Uint8List.fromList([1, 0, 0, 0, 0]);
      var bytes = CLValueParsers.toBytes(myList).unwrap();
      CLList fromBytes =
          CLValueParsers.fromBytes(expected, CLListType(CLBoolType())).unwrap()
              as CLList;
      expect(bytes, equals(expected));

      var _equals = true;
      for (int i = 0; i < myList.data.length; i++) {
        if (myList.data[i].value() != fromBytes.value()[i].value()) {
          _equals = false;
          break;
        }
      }
      expect(_equals, true);
    });

    test('toBytes() / fromBytes()', () {
      var myList = CLList.fromList([CLBool(false), CLBool(true)]);
      var bytes = CLValueParsers.toBytes(myList).unwrap();

      CLList fromBytes =
          CLValueParsers.fromBytes(bytes, CLListType(CLBoolType())).unwrap()
              as CLList;
      expect(fromBytes, myList);
    });

    test('Runs fromBytes properly', () {
      var myList = CLList.fromList([CLI32(100000), CLI32(-999)]);
      var bytes = CLValueParsers.toBytes(myList).unwrap();
      var listType = CLListType(CLI32Type());
      var fromBytes = CLValueParsers.fromBytes(bytes, listType).unwrap();
      expect(fromBytes, myList);
    });

    test('Runs toJSON() / fromJSON() on empty list', () {
      var myList = CLList.fromCType(CLStringType());
      var json = CLValueParsers.toJSON(myList).unwrap();

      var expectedJson =
          jsonDecode('{"bytes":"00000000","cl_type":{"List": "String" }}');
      var newList1 =
          CLValueParsers.fromJSON(json.toJSON()).unwrap() as CLList<CLValue>;
      var newList2 = CLValueParsers.fromJSON(expectedJson).unwrap();

      expect(newList1, myList);
      expect(newList2, myList);
    });

    test('Runs toJSON() / fromJSON() properly', () {
      var myList = CLList.fromList([
        CLList.fromList([CLBool(true), CLBool(false)]),
        CLList.fromList([CLBool(false)])
      ]);

      var json = CLValueParsers.toJSON(myList).unwrap();
      var newList = CLValueParsers.fromJSON(json.toJSON()).unwrap();

      var expectedJson = jsonDecode(
          '{"bytes":"020000000200000001000100000000","cl_type":{"List":{"List":"Bool"}}}');
      var newList2 = CLValueParsers.fromJSON(expectedJson).unwrap();

      expect(json.toJSON(), equals(expectedJson));
      expect(newList, myList);
      expect(newList2, myList);
    });

    test('Runs toJSON() / fromJSON() properly', () {
      var clKey = CLKey(CLByteArray(Uint8List.fromList([
        48,
        17,
        103,
        38,
        142,
        192,
        14,
        235,
        126,
        223,
        125,
        18,
        217,
        65,
        153,
        33,
        225,
        93,
        189,
        123,
        20,
        94,
        69,
        77,
        148,
        84,
        10,
        169,
        28,
        38,
        14,
        219
      ])));
      var myList = CLList.fromList([clKey, clKey, clKey]);

      var json = CLValueParsers.toJSON(myList).unwrap();
      var newList = CLValueParsers.fromJSON(json.toJSON()).unwrap();

      expect(newList, myList);
    });

    test('toBytesWithCLType() / fromBytesWithCLType()', () {
      CLList<CLList<CLBool>> myList = CLList.fromList([
        CLList.fromList([CLBool(true), CLBool(false)]),
        CLList.fromList([CLBool(false)])
      ]);

      var bytesWithCLType = CLValueParsers.toBytesWithType(myList).unwrap();

      var fromBytes =
          CLValueParsers.fromBytesWithType(bytesWithCLType).unwrap();

      expect(fromBytes, myList);
    });
  });
}
