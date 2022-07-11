import 'dart:io';
import 'dart:typed_data';

import 'package:casper_dart_sdk/classes/CLValue/public_key.dart';
import 'package:casper_dart_sdk/classes/bignumber.dart';
import 'package:casper_dart_sdk/classes/casper_client.dart';
import 'package:casper_dart_sdk/classes/conversions.dart';
import 'package:casper_dart_sdk/classes/deploy_util.dart';
import 'package:casper_dart_sdk/classes/keys.dart';
import 'package:test/test.dart';

void main() {
  group('CasperClient', () {
    var casperClient = CasperClient('https://testnet.casper-node.tor.us');

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

    // test('should create a HK wallet and derive child account correctly', () {
    //   var seed =
    //       'fffcf9f6f3f0edeae7e4e1dedbd8d5d2cfccc9c6c3c0bdbab7b4b1aeaba8a5a29f9c999693908d8a8784817e7b7875726f6c696663605d5a5754514e4b484542';
    //   var hdKey = casperClient.newHdWallet(decodeBase16(seed));
    //   var secpKey1 = hdKey.deriveIndex(1);
    //   var msg = Uint8List.fromList(('hello world').codeUnits);
    //   var signature = secpKey1.sign(msg);
    //   expect(secpKey1.verify(signature, msg), true);

    //   var secpKey2 = hdKey.deriveIndex(2);
    //   var signature2 = secpKey2.sign(msg);
    //   expect(secpKey2.verify(signature2, msg), true);
    // });

    // test('should create deploy from Deploy JSON with ttl in minutes', () {
    //   var json =
    //       '{"deploy":{"approvals":[{"signature":"130 chars","signer":"012d9dded24145247421eb8b904dda5cce8a7c77ae18de819a25628c4a01adbf76"}],"hash":"ceaaa76e7fb850a09d5c9d16ac995cb52eff2944066cfd8cac27f3595f11b652","header":{"account":"012d9dded24145247421eb8b904dda5cce8a7c77ae18de819a25628c4a01adbf76","body_hash":"0e68d66a9dfab19bb1898d5f4d11a4f55dd06a0cae3917afc1eae4a5b56352e7","chain_name":"casper-test","dependencies":[],"gas_price":1,"timestamp":"2021-05-06T07:49:32.583Z","ttl":"30m"},"payment":{"ModuleBytes":{"args":[["amount",{"bytes":"0500e40b5402","cl_type":"U512","parsed":"10000000000"}]],"module_bytes":""}},"session":{"Transfer":{"args":[["amount",{"bytes":"0500743ba40b","cl_type":"U512","parsed":"50000000000"}],["target",{"bytes":"1541566bdad3a3cfa9eb4cba3dcf33ee6583e0733ae4b2ccdfe92cd1bd92ee16","cl_type":{"ByteArray":32},"parsed":"1541566bdad3a3cfa9eb4cba3dcf33ee6583e0733ae4b2ccdfe92cd1bd92ee16"}],["id",{"bytes":"01a086010000000000","cl_type":{"Option":"U64"},"parsed":100000}]]}}}}';
    //   var res = casperClient.deployFromJson(jsonDecode(json));
    //   var fromJson = res.unwrap();
    //   expect(fromJson, isA<Deploy>());
    // });

    // test('getBalance', () async {
    //   var publicKey = CLPublicKey.fromHex(
    //       '02025d0f7d345c9863814ff3ccd934664bbd28fb911d8320b7cab9828f021341705d');
    //   var accountHash = publicKey.toAccountHash();
    //   var balance1 = await casperClient.balanceOfByPublicKey(publicKey);
    //   var balance2 =
    //       await casperClient.balanceOfByAccountHash(encodeBase16(accountHash));
    //   var uref = await casperClient.getAccountMainPurseUref(publicKey);

    //   var balanceFromWei = CasperClient.fromWei(balance1);
    //   var balanceToWei = CasperClient.toWei(balanceFromWei);

    //   expect(balance1, balance2);
    //   expect(balance1, balanceToWei);
    //   expect(uref,
    //       'uref-06f0da0c9284f0a59fbaed773bd411b2370350225407af6d0db08ebd90077250-007');
    // });

    // test('getDeploy', () async {
    //   var deployHash =
    //       'd9a7a80869d31bba809bc3fa9eebb5cb4408b34a63d26133a342a6b57b345575';
    //   var res = await casperClient.getDeploy(deployHash);
    //   expect(res, isNotNull);
    //   expect(encodeBase16(res.keys.first.hash), deployHash);
    // });

    test('putDeploy', () async {
      var publicKey = CLPublicKey.fromHex(
          '02025d0f7d345c9863814ff3ccd934664bbd28fb911d8320b7cab9828f021341705d');
      var privateKey = Secp256K1.readBase64WithPEM(
          '-----BEGIN EC PRIVATE KEY-----\n'
          'MHQCAQEEIPCR7Cs+AzPFATVPvp/K1zOBQX5ifxfGuCX1kzwy24uXoAcGBSuBBAAK\n'
          'oUQDQgAEXQ99NFyYY4FP88zZNGZLvSj7kR2DILfKuYKPAhNBcF3ZZgQHUXxT0lb8\n'
          'teHP8hv36fe9171dQuZZbo7V1Wej8A==\n'
          '-----END EC PRIVATE KEY-----');

      var senderKey = Secp256K1.parseKeyPair(publicKey.value(), privateKey);
      // var rPublicKey = CLPublicKey.fromHex(
      //     '0202f92c9b79232db38584ad558cf5becf5bfd23987e4e1d36d49166289ed8208f5f');
      // var rPrivateKey = Secp256K1.readBase64WithPEM(
      //     '-----BEGIN EC PRIVATE KEY-----\n'
      //     'MHQCAQEEIFdwNR0N0/jzDapOxUyAogabZoo8Lrf2NchG6mbb/cZfoAcGBSuBBAAK\n'
      //     'oUQDQgAE+SybeSMts4WErVWM9b7PW/0jmH5OHTbUkWYontggj19K4f0mxk8SHeaq\n'
      //     '2+qhoeqk+tDN6XZ6YBvi01pPBGSkQA==\n'
      //     '-----END EC PRIVATE KEY-----');
      // var recipientKey =
      //     Secp256K1.parseKeyPair(rPublicKey.value(), rPrivateKey);
      var rPublicKey = CLPublicKey.fromHex(
          '0164f74cb5134b1bafab03b60f6f1ec9ec8a7e68c90dcabadcb020ce27d3974b47');

      var networkName = 'casper-test';
      var paymentAmount = 1000000000;
      var transferAmount = 2500000000;
      var transferId = 34;

      var deployParams = DeployParams(publicKey, networkName);
      var session = ExecutableDeployItem.newTransfer(
          BigNumber.from(transferAmount),
          rPublicKey,
          null,
          BigNumber.from(transferId));

      var payment = standardPayment(BigNumber.from(paymentAmount));
      var deploy = makeDeploy(deployParams, session, payment);
      deploy = signDeploy(deploy, senderKey);
      var res = await casperClient.putDeploy(deploy);

      print(res);
    });

    // makeTransferDeploy
  });
}
