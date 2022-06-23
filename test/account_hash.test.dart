import 'dart:typed_data';

import 'package:casper_dart_sdk/classes/CLValue/account_hash.dart';
import 'package:test/test.dart';

void main() {
  group('CLAccountHash', () {
    test('Should be able to return proper value by calling .value()', () {
      var arr8 = Uint8List.fromList([21, 31]);
      var hash = CLAccountHash(arr8);

      expect(hash.value(), equals(arr8));
    });

    test('toBytes() / fromBytes() do proper bytes serialization', () {
      var expectedBytes = Uint8List.fromList(List.filled(32, 42));
      var hash = CLAccountHash(expectedBytes);
      var fromBytes = CLAccountHashBytesParser()
          .fromBytesWithRemainder(expectedBytes)
          .result
          .unwrap();

      expect(hash.data, expectedBytes);
      expect(fromBytes, equals(hash));
    });
  });
}
