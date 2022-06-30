import 'package:casper_dart_sdk/classes/conversions.dart';
import 'package:casper_dart_sdk/classes/serialization.dart';
import 'package:pinenacl/ed25519.dart';
import 'package:test/test.dart';

void main() {
  group('PublicKeyArg', () {
    test('should serialize as 32 bytes with content using little endiannes',
        () {
      var key = SigningKey.generate().publicKey;
      var result = PublicKeyArg(key.toUint8List());
      expect(result.length, 32);
      expect(result[0], key[0]);
      expect(result[31], key[31]);
    });
  });

  group('PublicKeyArg', () {
    test('should serialize as 64 bits using little endiannes', () {
      var input = BigInt.from(1234567890);
      var result = UInt64Arg(input);
      var output = bytesToBigInt(result);

      expect(result.length, 64 / 8);
      expect(output, input);
    });
  });

  group('Args', () {
    test('should serialize with size ++ concatenation of parts', () {
      var a = SigningKey.generate().publicKey;
      var b = BigInt.from(500000);
      var result = Args([PublicKeyArg(a.toUint8List()), UInt64Arg(b)]);

      expect(result[0], 2);
      expect(result[1], 0);
      expect(result[4], 32);
      expect(result[5], 0);
      expect(result[40], 8);
      expect(result.sublist(8, 40), a);
      expect(bytesToBigInt(result.sublist(44)), b);
    });

    test('should work with the hardcoded example', () {
      var a = Uint8List.fromList(List.filled(32, 1));
      var b = BigInt.from(67305985);
      var result = Args([PublicKeyArg(a), UInt64Arg(b)]);

      var expected = Uint8List.fromList([
        2,
        0,
        0,
        0,
        32,
        0,
        0,
        0,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        1,
        8,
        0,
        0,
        0,
        1,
        2,
        3,
        4,
        0,
        0,
        0,
        0
      ]);

      expect(result, expected);
    });
  });
}
