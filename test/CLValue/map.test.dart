import 'dart:convert';

import 'package:casper_dart_sdk/classes/CLValue/abstract.dart';
import 'package:casper_dart_sdk/classes/CLValue/bool.dart';
import 'package:casper_dart_sdk/classes/CLValue/builders.dart';
import 'package:casper_dart_sdk/classes/CLValue/map.dart';
import 'package:casper_dart_sdk/classes/CLValue/numeric.dart';
import 'package:casper_dart_sdk/classes/CLValue/string.dart';
import 'package:test/test.dart';

void main() {
  group('CLKey', () {
    test('Maps should return proper clType', () {
      var myMap = CLMap.fromList([
        {CLBool(true): CLBool(false)}
      ]);

      expect(myMap.clType().toString(), 'Map (Bool: Bool)');
    });

    test(
        'Should be able to create Map with proper values - correct by varruction',
        () {
      var myKey = CLString('ABC');
      var myVal = CLI32(123);
      var myMap = CLMap.fromList([
        {myKey: myVal}
      ]);

      expect(myMap, isA<CLMap>());
      expect(
          myMap.data,
          equals(CLMap.fromList([
            {myKey: myVal}
          ]).data));
    });

    test('Should throw an error when CLMap is not correct by varruction', () {
      try {
        CLMap.fromList([
          {CLString('ABC'): CLI32(123)},
          {CLString('DEF'): CLBool(false)}
        ]);
      } catch (e) {
        expect(e.toString(), Exception('Invalid data provided.').toString());
      }
    });

    test('Should be able to return proper values by calling .get() on Map', () {
      var myKey = CLString('ABC');
      var myVal = CLI32(10);
      var myMap = CLMap.fromList([
        {myKey: myVal}
      ]);

      expect(myMap.get(CLString('ABC')), equals(CLI32(10)));
    });

    test('Get() should return undefined on non-existing key', () {
      var myKey = CLString('ABC');
      var myVal = CLI32(10);
      var myMap = CLMap.fromList([
        {myKey: myVal}
      ]);

      expect(myMap.get(CLString('DEF')), equals(null));
    });

    test('Should able to create empty Map by providing type', () {
      var myMap = CLMap.fromMap({CLStringType(): CLStringType()});
      var len = myMap.size();

      expect(len, 0);
    });

    test('Set should be able to set values at already declared keys', () {
      var myKey = CLString('ABC');
      var myVal = CLI32(10);
      var myMap = CLMap.fromList([
        {myKey: myVal}
      ]);
      var newVal = CLI32(11);

      myMap.set(myKey, newVal);

      expect(myMap.get(CLString('ABC')), equals(CLI32(11)));
      expect(myMap.size(), 1);
    });

    test('Set should be able to set values at empty keys', () {
      var myKey = CLString('ABC');
      var myVal = CLI32(10);
      var myMap = CLMap.fromList([
        {myKey: myVal}
      ]);

      myMap.set(CLString('DEF'), CLI32(11));

      expect(myMap.get(CLString('DEF')), equals(CLI32(11)));
      expect(myMap.size(), 2);
    });

    test('Remove should remove key/value pair at already declared keys', () {
      var myKey = CLString('ABC');
      var myVal = CLI32(10);
      var myMap = CLMap.fromList([
        {myKey: myVal}
      ]);

      myMap.delete(CLString('ABC'));

      expect(myMap.size(), equals(0));
    });

    test('fromBytes() / toBytes()', () {
      var myKey = CLString('ABC');
      var myVal = CLI32(10);
      var myMap = CLMap.fromList([
        {myKey: myVal}
      ]);

      var bytes = CLValueParsers.toBytes(myMap).unwrap();
      var mapType = CLMapType({CLStringType(): CLI32Type()});
      CLMap<CLValue, CLValue> fromBytes =
          CLValueParsers.fromBytes(bytes, mapType).unwrap() as CLMap;

      expect(fromBytes, myMap);
    });

    test('fromJSON() / toJSON()', () {
      var myKey = CLString('ABC');
      var myVal = CLI32(10);
      var myMap = CLMap.fromList([
        {myKey: myVal}
      ]);

      var json = CLValueParsers.toJSON(myMap).unwrap();
      var expectedJson = jsonDecode(
          '{"bytes":"01000000030000004142430a000000","cl_type":{"Map":{"key":"String","value":"I32"}}}');
      CLMap fromJson = CLValueParsers.fromJSON(expectedJson).unwrap() as CLMap;

      expect(json.toJson(), equals(expectedJson));
      expect(fromJson, myMap);
    });

    test('Tests maps created used CLValueBuilder', () {
      var myMap = CLValueBuilder.mapFromList([
        {CLValueBuilder.string('A'): CLValueBuilder.string('1')}
      ]);

      expect(myMap.get(CLValueBuilder.string('A')),
          equals(CLValueBuilder.string('1')));
    });
  });
}
