import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:casper_dart_sdk/classes/CLValue/clvalue.dart';
import 'package:casper_dart_sdk/classes/contracts.dart';
import 'package:casper_dart_sdk/classes/conversions.dart';
import 'package:casper_dart_sdk/classes/keys.dart';
import 'package:test/test.dart';

void main() {
  group('Ed25519', () {
    test('calculates the account hash', () {
      var signKeyPair = Ed25519.newKey();
      var name = 'ED25519'.toLowerCase().codeUnits;
      var sep = base16Decode('00');
      var bytes = Uint8List.fromList(
          [...name, ...sep, ...signKeyPair.publicKey.value()]);
      var hash = byteHash(bytes);

      expect(Ed25519.accountHashEd25519(signKeyPair.publicKey.value()), hash);
    });

    test('should generate PEM file for Ed25519 correctly', () {
      var keyPair = Ed25519.newKey();
      var publicKeyInPem = keyPair.exportPublicKeyInPem();
      var privateKeyInPem = keyPair.exportPrivateKeyInPem();

      var tempDir = Directory.systemTemp;
      var file1 = File(tempDir.path + '/public.pem');
      var file2 = File(tempDir.path + '/private.pem');

      file1.writeAsStringSync(publicKeyInPem);
      file2.writeAsStringSync(privateKeyInPem);

      var keyPair2 = Ed25519.parseKeyFiles(
          tempDir.path + '/public.pem', tempDir.path + '/private.pem');

      expect(base64Encode(keyPair.publicKey.value()),
          base64Encode(keyPair2.publicKey.value()));
      expect(
          base64Encode(keyPair.privateKey), base64Encode(keyPair2.privateKey));

      var msg = Uint8List.fromList(('hello world').codeUnits);
      var signature = keyPair.sign(msg);
      expect(keyPair.verify(signature, msg), true);
    });

    test('should deal with different line-endings', () {
      var keyWithoutPem =
          'MCowBQYDK2VwAyEA4PFXL2NuakBv3l7yrDg65HaYQtxKR+SCRTDI+lXBoM8=';
      var key1 = base64Decode(keyWithoutPem);
      var keyWithLF = '-----BEGIN PUBLIC KEY-----\n'
          'MCowBQYDK2VwAyEA4PFXL2NuakBv3l7yrDg65HaYQtxKR+SCRTDI+lXBoM8=\n'
          '-----END PUBLIC KEY-----\n';
      var key2 = Ed25519.readBase64WithPEM(keyWithLF);
      expect(key2, key1);

      var keyWithCRLF = '-----BEGIN PUBLIC KEY-----\r\n'
          'MCowBQYDK2VwAyEA4PFXL2NuakBv3l7yrDg65HaYQtxKR+SCRTDI+lXBoM8=\r\n'
          '-----END PUBLIC KEY-----\r\n';
      var key3 = Ed25519.readBase64WithPEM(keyWithCRLF);
      expect(key3, key1);
    });

    test('get publickey', () {
      var base64 = '-----BEGIN PRIVATE KEY-----\n'
          'MCowBQYDK2VwAyEA4PFXL2NuakBv3l7yrDg65HaYQtxKR+SCRTDI+lXBoM8=\n'
          '-----END PRIVATE KEY-----\n';
      var privateKey = Ed25519.readBase64WithPEM(base64);
      var publicKey = Ed25519.privateToPublicKey(privateKey);
      expect(Ed25519.accountHexStr(publicKey),
          '01458a2f3c0885d329fced28b49e85f55a8fc3f16e78a2eaae172e3a5e9d057ddf');
    });
  });

  group('Secp256k1', () {
    test('calculates the account hash', () {
      var signKeyPair = Secp256K1.newKey();
      var name = 'secp256k1'.toLowerCase().codeUnits;
      var sep = base16Decode('00');
      var bytes = Uint8List.fromList(
          [...name, ...sep, ...signKeyPair.publicKey.value()]);
      var hash = byteHash(bytes);

      expect(
          Secp256K1.accountHashSecp256K1(signKeyPair.publicKey.value()), hash);
    });

    test('should generate PEM file for Secp256k1 correctly', () {
      var keyPair = Secp256K1.newKey();
      var publicKeyInPem = keyPair.exportPublicKeyInPem();
      var privateKeyInPem = keyPair.exportPrivateKeyInPem();

      var tempDir = Directory.systemTemp;
      var file1 = File(tempDir.path + '/public.pem');
      var file2 = File(tempDir.path + '/private.pem');

      file1.writeAsStringSync(publicKeyInPem);
      file2.writeAsStringSync(privateKeyInPem);

      var keyPair2 = Secp256K1.parseKeyFiles(
          tempDir.path + '/public.pem', tempDir.path + '/private.pem');

      expect(base64Encode(keyPair.publicKey.value()),
          base64Encode(keyPair2.publicKey.value()));
      expect(
          base64Encode(keyPair.privateKey), base64Encode(keyPair2.privateKey));

      var msg = Uint8List.fromList(('hello world').codeUnits);
      var signature = keyPair.sign(msg);
      expect(keyPair.verify(signature, msg), true);
    });

    test('get publickey', () {
      var base64_2 = '-----BEGIN EC PRIVATE KEY-----\n'
          'MHQCAQEEIPCR7Cs+AzPFATVPvp/K1zOBQX5ifxfGuCX1kzwy24uXoAcGBSuBBAAK\n'
          'oUQDQgAEXQ99NFyYY4FP88zZNGZLvSj7kR2DILfKuYKPAhNBcF3ZZgQHUXxT0lb8\n'
          'teHP8hv36fe9171dQuZZbo7V1Wej8A==\n'
          '-----END EC PRIVATE KEY-----';
      var privateKey2 =
          Secp256K1.parsePrivateKey(Secp256K1.readBase64WithPEM(base64_2));
      var publicKey2 = Secp256K1.privateToPublicKey(privateKey2);
      expect(Secp256K1.accountHexStr(publicKey2),
          '02025d0f7d345c9863814ff3ccd934664bbd28fb911d8320b7cab9828f021341705d');
    });
  });
}
