import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:casper_dart_sdk/classes/CLValue/abstract.dart';
import 'dart:typed_data';

import 'package:casper_dart_sdk/classes/CLValue/public_key.dart';
import 'package:casper_dart_sdk/classes/conversions.dart';
import 'package:casper_dart_sdk/classes/keys.dart';
import 'package:test/test.dart';
import 'package:asn1lib/asn1lib.dart';

void main() {
  group('CLPublicKey', () {
    var rawEd25519Account = Uint8List.fromList([
      154,
      211,
      137,
      116,
      146,
      249,
      164,
      57,
      9,
      35,
      64,
      255,
      83,
      105,
      131,
      86,
      169,
      250,
      100,
      248,
      12,
      68,
      201,
      17,
      43,
      62,
      151,
      55,
      158,
      87,
      186,
      148
    ]);

    var rawSecp256K1Account = Uint8List.fromList([
      2,
      159,
      140,
      124,
      87,
      6,
      242,
      206,
      197,
      115,
      224,
      181,
      184,
      223,
      197,
      239,
      249,
      252,
      127,
      235,
      243,
      153,
      111,
      242,
      225,
      125,
      76,
      204,
      37,
      56,
      70,
      41,
      229
    ]);

    var publicKeyEd25519 =
        CLPublicKey(rawEd25519Account, CLPublicKeyTag.ED25519);

    var publicKeySecp256K1 =
        CLPublicKey(rawSecp256K1Account, CLPublicKeyTag.SECP256K1);

    test('Valid by construction', () {
      expect(publicKeyEd25519, isA<CLPublicKey>());
      expect(publicKeySecp256K1, isA<CLPublicKey>());
    });

    test('Invalid by construction', () {
      try {
        CLPublicKey(rawEd25519Account, 4);
      } catch (e) {
        expect(e.toString(),
            Exception('Unsupported type of public key').toString());
      }
    });

    test('Proper clType() value', () {
      expect(publicKeyEd25519.clType().toString(), 'PublicKey');
    });

    test('CLPublicKey.fromhex() value', () {
      var ed25519Account = Ed25519.newKey();
      var ed25519AccountHex = ed25519Account.accountHex();

      expect(CLPublicKey.fromHex(ed25519AccountHex).value(),
          ed25519Account.publicKey.value());

      var secp256K1Account = Secp256K1.newKey();
      var secp256K1AccountHex = secp256K1Account.accountHex();

      expect(CLPublicKey.fromHex(secp256K1AccountHex).value(),
          secp256K1Account.publicKey.value());

      try {
        CLPublicKey.fromHex('1');
      } catch (e) {
        expect(e.toString(),
            Exception('Asymmetric key error: too short').toString());
      }
    });

    test('CLPublicKey.fromEd25519() return proper value', () {
      var pub = CLPublicKey.fromEd25519(rawEd25519Account);
      expect(pub.value(), rawEd25519Account);
    });

    test('CLPublicKey.fromSecp256K1 return proper value', () {
      var pub = CLPublicKey.fromSecp256K1(rawSecp256K1Account);
      expect(pub.value(), rawSecp256K1Account);
    });

    test('fromHex() should serializes to the same hex value by using toHex()',
        () {
      var accountKey =
          '01f9235ff9c46c990e1e2eee0d531e488101fab48c05b75b8ea9983658e228f06b';
      var publicKey = CLPublicKey.fromHex(accountKey);
      var accountHex = publicKey.toHex();

      expect(accountHex, accountKey);
      expect(publicKey.isEd25519(), true);
    });

    test('toAccountHash() valid result', () {
      var accountKey =
          '01f9235ff9c46c990e1e2eee0d531e488101fab48c05b75b8ea9983658e228f06b';
      var publicKey = CLPublicKey.fromHex(accountKey);
      var accountHash = publicKey.toAccountHash();

      var validResult = Uint8List.fromList([
        145,
        171,
        120,
        7,
        189,
        47,
        216,
        41,
        215,
        192,
        156,
        198,
        81,
        187,
        81,
        206,
        63,
        183,
        251,
        252,
        224,
        127,
        79,
        141,
        250,
        233,
        141,
        132,
        130,
        235,
        172,
        98
      ]);

      expect(accountHash, validResult);
    });

    test('isEd25519() valid result', () {
      expect(publicKeyEd25519.isEd25519(), true);
      expect(publicKeyEd25519.isSecp256K1(), false);
    });

    test('isSecp256K1() valid result', () {
      expect(publicKeySecp256K1.isEd25519(), false);
      expect(publicKeySecp256K1.isSecp256K1(), true);
    });

    test('toBytes() / fromBytes()', () {
      var bytes = Uint8List.fromList(List.filled(32, 42));
      var publicKey = CLPublicKey.fromEd25519(bytes);
      var toBytes = CLValueParsers.toBytes(publicKey).unwrap();
      var validResult = Uint8List.fromList([1, ...List.filled(32, 42)]);

      expect(toBytes, equals(validResult));
      expect(CLValueParsers.fromBytes(toBytes, CLPublicKeyType()).unwrap(),
          equals(publicKey));
    });

    test('toJSON() / fromJSON()', () {
      var bytes = Uint8List.fromList(List.filled(32, 42));
      var publicKey = CLPublicKey.fromEd25519(bytes);
      var json = CLValueParsers.toJSON(publicKey).unwrap();
      var expectedJson = jsonDecode(
          '{"bytes":"012a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a","cl_type":"PublicKey"}');

      expect(json.toJSON(), expectedJson);
      expect(CLValueParsers.fromJSON(expectedJson).unwrap(), publicKey);
    });
  });
}
