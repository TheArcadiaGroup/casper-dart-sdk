import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:casper_dart_sdk/classes/casper_client.dart';
import 'package:casper_dart_sdk/classes/conversions.dart';
import 'package:casper_dart_sdk/classes/deploy_util.dart';
import 'package:casper_dart_sdk/classes/keys.dart';
import 'package:test/test.dart';

void main() {
  group('CasperClient', () {
    var casperClient = CasperClient('https://casper-node.tor.us');

    test(
        'should generate new Ed25519 key pair, and compute public key from private key',
        () {
      var edKeyPair = casperClient.newKeyPair(SignatureAlgorithm.Ed25519);
      var publicKey = edKeyPair.publicKey.value();
      var privateKey = edKeyPair.privateKey;
      var convertFromPrivateKey = casperClient.privateToPublicKey(
          privateKey, SignatureAlgorithm.Ed25519);
      expect(convertFromPrivateKey, publicKey);
    });

    test('should generate PEM file for Ed25519 correctly', () {
      var edKeyPair = casperClient.newKeyPair(SignatureAlgorithm.Ed25519);
      var publicKeyInPem = edKeyPair.exportPublicKeyInPem();
      var privateKeyInPem = edKeyPair.exportPrivateKeyInPem();

      var tempDir = Directory.systemTemp;
      var file1 = File(tempDir.path + '/public.pem');
      var file2 = File(tempDir.path + '/private.pem');

      file1.writeAsStringSync(publicKeyInPem);
      file2.writeAsStringSync(privateKeyInPem);

      var publicKeyFromFile = casperClient.loadPublicKeyFromFile(
          tempDir.path + '/public.pem', SignatureAlgorithm.Ed25519);
      var privateKeyFromFile = casperClient.loadPublicKeyFromFile(
          tempDir.path + '/private.pem', SignatureAlgorithm.Ed25519);

      var keyPairFromFile =
          Ed25519.parseKeyPair(publicKeyFromFile, privateKeyFromFile);

      expect(keyPairFromFile.publicKey.value(), edKeyPair.publicKey.value());
      expect(keyPairFromFile.privateKey, edKeyPair.privateKey);

      // load the keypair from pem file of private key
      var loadedKeyPair = casperClient.loadKeyPairFromPrivateFile(
          tempDir.path + '/private.pem', SignatureAlgorithm.Ed25519);
      expect(loadedKeyPair.publicKey.value(), edKeyPair.publicKey.value());
      expect(loadedKeyPair.privateKey, edKeyPair.privateKey);
    });

    test(
        'should generate new Secp256K1 key pair, and compute public key from private key',
        () {
      var edKeyPair = casperClient.newKeyPair(SignatureAlgorithm.Secp256K1);
      var publicKey = edKeyPair.publicKey.value();
      var privateKey = edKeyPair.privateKey;
      var convertFromPrivateKey = casperClient.privateToPublicKey(
          privateKey, SignatureAlgorithm.Secp256K1);
      expect(convertFromPrivateKey, publicKey);
    });

    test(
        'should generate PEM file for Secp256K1 and restore the key pair from PEM file correctly',
        () {
      var edKeyPair = casperClient.newKeyPair(SignatureAlgorithm.Secp256K1);
      var publicKeyInPem = edKeyPair.exportPublicKeyInPem();
      var privateKeyInPem = edKeyPair.exportPrivateKeyInPem();

      var tempDir = Directory.systemTemp;
      var file1 = File(tempDir.path + '/public.pem');
      var file2 = File(tempDir.path + '/private.pem');

      file1.writeAsStringSync(publicKeyInPem);
      file2.writeAsStringSync(privateKeyInPem);

      var publicKeyFromFile = casperClient.loadPublicKeyFromFile(
          tempDir.path + '/public.pem', SignatureAlgorithm.Secp256K1);
      var privateKeyFromFile = casperClient.loadPrivateKeyFromFile(
          tempDir.path + '/private.pem', SignatureAlgorithm.Secp256K1);

      var keyPairFromFile =
          Secp256K1.parseKeyPair(publicKeyFromFile, privateKeyFromFile, 'raw');

      expect(keyPairFromFile.publicKey.value(), edKeyPair.publicKey.value());
      expect(keyPairFromFile.privateKey, edKeyPair.privateKey);

      // load the keypair from pem file of private key
      var loadedKeyPair = casperClient.loadKeyPairFromPrivateFile(
          tempDir.path + '/private.pem', SignatureAlgorithm.Secp256K1);
      expect(loadedKeyPair.publicKey.value(), edKeyPair.publicKey.value());
      expect(loadedKeyPair.privateKey, edKeyPair.privateKey);
    });

    test('should create a HK wallet and derive child account correctly', () {
      var seed =
          'fffcf9f6f3f0edeae7e4e1dedbd8d5d2cfccc9c6c3c0bdbab7b4b1aeaba8a5a29f9c999693908d8a8784817e7b7875726f6c696663605d5a5754514e4b484542';
      var hdKey = casperClient.newHdWallet(decodeBase16(seed));
      var secpKey1 = hdKey.deriveIndex(1);
      var msg = Uint8List.fromList(('hello world').codeUnits);
      var signature = secpKey1.sign(msg);
      expect(secpKey1.verify(signature, msg), true);

      var secpKey2 = hdKey.deriveIndex(2);
      var signature2 = secpKey2.sign(msg);
      expect(secpKey2.verify(signature2, msg), true);
    });

    test('should create deploy from Deploy JSON with ttl in minutes', () {
      var json =
          '{"deploy":{"approvals":[{"signature":"130 chars","signer":"012d9dded24145247421eb8b904dda5cce8a7c77ae18de819a25628c4a01adbf76"}],"hash":"ceaaa76e7fb850a09d5c9d16ac995cb52eff2944066cfd8cac27f3595f11b652","header":{"account":"012d9dded24145247421eb8b904dda5cce8a7c77ae18de819a25628c4a01adbf76","body_hash":"0e68d66a9dfab19bb1898d5f4d11a4f55dd06a0cae3917afc1eae4a5b56352e7","chain_name":"casper-test","dependencies":[],"gas_price":1,"timestamp":"2021-05-06T07:49:32.583Z","ttl":"30m"},"payment":{"ModuleBytes":{"args":[["amount",{"bytes":"0500e40b5402","cl_type":"U512","parsed":"10000000000"}]],"module_bytes":""}},"session":{"Transfer":{"args":[["amount",{"bytes":"0500743ba40b","cl_type":"U512","parsed":"50000000000"}],["target",{"bytes":"1541566bdad3a3cfa9eb4cba3dcf33ee6583e0733ae4b2ccdfe92cd1bd92ee16","cl_type":{"ByteArray":32},"parsed":"1541566bdad3a3cfa9eb4cba3dcf33ee6583e0733ae4b2ccdfe92cd1bd92ee16"}],["id",{"bytes":"01a086010000000000","cl_type":{"Option":"U64"},"parsed":100000}]]}}}}';
      var res = casperClient.deployFromJson(jsonDecode(json));
      var fromJson = res.unwrap();
      expect(fromJson, isA<Deploy>());
    });
  });
}
