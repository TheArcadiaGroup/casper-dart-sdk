import 'dart:convert';

import 'package:casper_dart_sdk/classes/CLValue/abstract.dart';
import 'package:casper_dart_sdk/classes/CLValue/unit.dart';
import 'package:test/test.dart';

void main() {
  group('CLUntest', () {
    test('Untest value() should return proper value', () {
      var unit = CLUnit();
      expect(unit.value(), null);
    });

    test('Untest clType() should return proper type', () {
      var unit = CLUnit();
      expect(unit.clType().toString(), 'Unit');
    });

    test('fromJSON() / toJSON()', () {
      var unit = CLUnit();
      var json = CLValueParsers.toJSON(unit).unwrap();
      var expectedJson = jsonDecode('{"bytes":"","cl_type":"Unit"}');

      expect(json.toJson(), expectedJson);
      expect(CLValueParsers.fromJSON(expectedJson).unwrap(), unit);
    });
  });
}
