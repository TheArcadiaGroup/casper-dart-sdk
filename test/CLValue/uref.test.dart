import 'dart:convert';

import 'package:casper_dart_sdk/classes/CLValue/abstract.dart';
import 'package:casper_dart_sdk/classes/CLValue/uref.dart';
import 'package:casper_dart_sdk/classes/conversions.dart';
import 'package:pinenacl/ed25519.dart';
import 'package:test/test.dart';

void main() {
  group('CLUref', () {
    const urefAddr =
        '2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a';
    var exampleURef =
        CLURef(base16Decode(urefAddr), AccessRights.READ_ADD_WRITE);

    const formattedStr =
        'uref-ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff-007';

    test('Should be valid by construction', () {
      expect(exampleURef, isA<CLURef>());

      try {
        CLURef(base16Decode('3a3a3a'), AccessRights.READ_ADD_WRITE);
      } catch (e) {
        expect(e.toString(),
            Exception('The length of URefAddr should be 32').toString());
      }
    });

    test('Should return proper clType()', () {
      expect(exampleURef.clType().toString(), 'URef');
    });

    test('Should return proper value()', () {
      expect(exampleURef.value(), {
        'data': base16Decode(urefAddr),
        'accessRights': AccessRights.READ_ADD_WRITE
      });
    });

    test('fromFormattedStr() / toFormattedStr() proper value', () {
      var myURef = CLURef.fromFormattedStr(formattedStr);

      expect(myURef, isA<CLURef>());
      expect(myURef.toFormattedStr(), formattedStr);

      try {
        CLURef.fromFormattedStr('xxxx-ttttttttttttttt-000');
      } catch (e) {
        expect(e.toString(), Exception("Prefix is not 'uref-'").toString());
      }

      try {
        CLURef.fromFormattedStr('uref-ttttttttttttttt');
      } catch (e) {
        expect(
            e.toString(), Exception('No access rights as suffix').toString());
      }
    });

    test('toBytes() / fromBytes() proper values', () {
      var expectedBytes = Uint8List.fromList([...List.filled(32, 42), 7]);
      var toBytes = CLValueParsers.toBytes(exampleURef).unwrap();
      var fromBytes =
          CLValueParsers.fromBytes(expectedBytes, CLURefType()).unwrap();

      expect(toBytes, expectedBytes);
      expect(fromBytes, exampleURef);
    });

    test('fromJSON() / toJSON()', () {
      var json = CLValueParsers.toJSON(exampleURef).unwrap();
      var expectedJson = jsonDecode(
          '{"bytes":"2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a07","cl_type":"URef"}');

      expect(CLValueParsers.fromJSON(expectedJson).unwrap(), exampleURef);
      expect(json.toJson(), expectedJson);
    });
  });
}
