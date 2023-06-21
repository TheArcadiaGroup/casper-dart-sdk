import 'dart:convert';

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
    // var casperClient = CasperClient('https://casper-node.tor.us');

    // test(
    //     'should generate new Ed25519 key pair, and compute public key from private key',
    //     () {
    //   var edKeyPair = CasperClient.newKeyPair(SignatureAlgorithm.Ed25519);
    //   var publicKey = edKeyPair.publicKey.value();
    //   var privateKey = edKeyPair.privateKey;
    //   var convertFromPrivateKey = CasperClient.privateToPublicKey(
    //       privateKey, SignatureAlgorithm.Ed25519);
    //   expect(convertFromPrivateKey, publicKey);
    // });

    test('should generate new hex private key', () {
      // edd25519 - 64 bytes
      var edKeyPair = CasperClient.newKeyPair(SignatureAlgorithm.Ed25519);
      var publicKey = edKeyPair.publicKey.value();
      var privateKey = edKeyPair.privateKey;
      var convertFromPrivateKey = CasperClient.privateToPublicKey(
          privateKey, SignatureAlgorithm.Ed25519);
      var base64PK = edKeyPair.exportPrivateKeyInPem();
      var hexPK = edKeyPair.exportPrivateKeyHex();
      // print(edKeyPair.publicKey.toHex());
      // print('base64PK: ${base64PK}');

      // Secp256K1 - 32bytes
      // var secpKeyPair = CasperClient.newKeyPair(SignatureAlgorithm.Secp256K1);
      // var publicKey1 = secpKeyPair.publicKey.value();
      // var privateKey1 = secpKeyPair.privateKey;
      // var convertFromPrivateKey1 = CasperClient.privateToPublicKey(
      //     privateKey, SignatureAlgorithm.Secp256K1);
      // var base64PK1 = secpKeyPair.exportPrivateKeyInPem();
      // var hexPK1 = secpKeyPair.exportPrivateKeyHex();
      // // print(base64PK1);
      // print(hexPK1);
    });

    // 9bbadffd8b9911f7b3416732b924b24554475851a8ba4733c79c737760dcfde15d90f8a52f154a4a634fefa03a54b261b17dd8099e684f30e4893cbca6b3fdd0
    test('should read public key from private key hex (Ed25519)', () {
      var publicKeyStr =
          '015d90f8a52f154a4a634fefa03a54b261b17dd8099e684f30e4893cbca6b3fdd0';
      var privateKeyStr =
          '9bbadffd8b9911f7b3416732b924b24554475851a8ba4733c79c737760dcfde15d90f8a52f154a4a634fefa03a54b261b17dd8099e684f30e4893cbca6b3fdd0';
      var bytes = base16Decode(privateKeyStr);
      var publicKey = Ed25519.privateToPublicKey(bytes);

      var base64PK =
          'MC4CAQAwBQYDK2VwBCIEIJu63/2LmRH3s0FnMrkkskVUR1hRqLpHM8ecc3dg3P3h';
      var base64Bytes = base64Decode(base64PK);
      var publicKey2 = Ed25519.privateToPublicKey(base64Bytes);

      expect(publicKey, publicKey2);
      expect(Ed25519.accountHexStr(publicKey), publicKeyStr);
    });

    test('should read public key from private key hex (Secp256k1)', () {
      var publicKeyStr =
          '020341d8034c070a8fff654c83f070aa4f636431c3b110d1bdb2e85d6f74983f06ed';
      var privateKeyStr =
          '2b7289542e66f93df24d03f0581fd88dd381b08375a6101e0eb3af586860e666';
      var privateKeyBytes = base16Decode(privateKeyStr);
      var publicKey = Secp256K1.privateToPublicKey(privateKeyBytes);
      expect(Secp256K1.accountHexStr(publicKey), publicKeyStr);
    });

    // test('should generate PEM file for Ed25519 correctly', () {
    //   var edKeyPair = CasperClient.newKeyPair(SignatureAlgorithm.Ed25519);
    //   var publicKeyInPem = edKeyPair.exportPublicKeyInPem();
    //   var privateKeyInPem = edKeyPair.exportPrivateKeyInPem();

    //   var tempDir = Directory.systemTemp;
    //   var file1 = File(tempDir.path + '/public.pem');
    //   var file2 = File(tempDir.path + '/private.pem');

    //   file1.writeAsStringSync(publicKeyInPem);
    //   file2.writeAsStringSync(privateKeyInPem);

    //   var publicKeyFromFile = CasperClient.loadPublicKeyFromFile(
    //       tempDir.path + '/public.pem', SignatureAlgorithm.Ed25519);
    //   var privateKeyFromFile = CasperClient.loadPublicKeyFromFile(
    //       tempDir.path + '/private.pem', SignatureAlgorithm.Ed25519);

    //   var keyPairFromFile =
    //       Ed25519.parseKeyPair(publicKeyFromFile, privateKeyFromFile);

    //   expect(keyPairFromFile.publicKey.value(), edKeyPair.publicKey.value());
    //   expect(keyPairFromFile.privateKey, edKeyPair.privateKey);

    //   // load the keypair from pem file of private key
    //   var loadedKeyPair = CasperClient.loadKeyPairFromPrivateFile(
    //       tempDir.path + '/private.pem', SignatureAlgorithm.Ed25519);
    //   expect(loadedKeyPair.publicKey.value(), edKeyPair.publicKey.value());
    //   expect(loadedKeyPair.privateKey, edKeyPair.privateKey);
    // });

    // test(
    //     'should generate new Secp256K1 key pair, and compute public key from private key',
    //     () {
    //   var edKeyPair = CasperClient.newKeyPair(SignatureAlgorithm.Secp256K1);
    //   var publicKey = edKeyPair.publicKey.value();
    //   var privateKey = edKeyPair.privateKey;
    //   var convertFromPrivateKey = CasperClient.privateToPublicKey(
    //       privateKey, SignatureAlgorithm.Secp256K1);
    //   expect(convertFromPrivateKey, publicKey);
    // });

    // test(
    //     'should generate PEM file for Secp256K1 and restore the key pair from PEM file correctly',
    //     () {
    //   var edKeyPair = CasperClient.newKeyPair(SignatureAlgorithm.Secp256K1);
    //   var publicKeyInPem = edKeyPair.exportPublicKeyInPem();
    //   var privateKeyInPem = edKeyPair.exportPrivateKeyInPem();

    //   var tempDir = Directory.systemTemp;
    //   var file1 = File(tempDir.path + '/public.pem');
    //   var file2 = File(tempDir.path + '/private.pem');

    //   file1.writeAsStringSync(publicKeyInPem);
    //   file2.writeAsStringSync(privateKeyInPem);

    //   var publicKeyFromFile = CasperClient.loadPublicKeyFromFile(
    //       tempDir.path + '/public.pem', SignatureAlgorithm.Secp256K1);
    //   var privateKeyFromFile = CasperClient.loadPrivateKeyFromFile(
    //       tempDir.path + '/private.pem', SignatureAlgorithm.Secp256K1);

    //   var keyPairFromFile =
    //       Secp256K1.parseKeyPair(publicKeyFromFile, privateKeyFromFile, 'raw');

    //   expect(keyPairFromFile.publicKey.value(), edKeyPair.publicKey.value());
    //   expect(keyPairFromFile.privateKey, edKeyPair.privateKey);

    //   // load the keypair from pem file of private key
    //   var loadedKeyPair = CasperClient.loadKeyPairFromPrivateFile(
    //       tempDir.path + '/private.pem', SignatureAlgorithm.Secp256K1);
    //   expect(loadedKeyPair.publicKey.value(), edKeyPair.publicKey.value());
    //   expect(loadedKeyPair.privateKey, edKeyPair.privateKey);
    // });

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
    //       '2ed9521992e102eedfd3a0da7cd7904f23b0595db81b8cd4d8526a7e10d3a8dc';
    //   var res = await casperClient.getDeploy(deployHash);
    //   expect(res, isNotNull);
    //   expect(base16Encode(res.keys.first.hash), deployHash);
    // });

    // test('putDeploy', () async {
    //   var publicKey = CLPublicKey.fromHex(
    //       '02025d0f7d345c9863814ff3ccd934664bbd28fb911d8320b7cab9828f021341705d');
    //   var privateKey = Secp256K1.readBase64WithPEM(
    //       '-----BEGIN EC PRIVATE KEY-----\n'
    //       'MHQCAQEEIPCR7Cs+AzPFATVPvp/K1zOBQX5ifxfGuCX1kzwy24uXoAcGBSuBBAAK\n'
    //       'oUQDQgAEXQ99NFyYY4FP88zZNGZLvSj7kR2DILfKuYKPAhNBcF3ZZgQHUXxT0lb8\n'
    //       'teHP8hv36fe9171dQuZZbo7V1Wej8A==\n'
    //       '-----END EC PRIVATE KEY-----');

    //   var senderKey = Secp256K1.parseKeyPair(publicKey.value(), privateKey);
    //   // var rPublicKey = CLPublicKey.fromHex(
    //   //     '0202f92c9b79232db38584ad558cf5becf5bfd23987e4e1d36d49166289ed8208f5f');
    //   // var rPrivateKey = Secp256K1.readBase64WithPEM(
    //   //     '-----BEGIN EC PRIVATE KEY-----\n'
    //   //     'MHQCAQEEIDpnUqsnv+AL1x+SYTVRsELPireo3FfeMWcCP1y09SMfoAcGBSuBBAAK\n'
    //   //     'oUQDQgAE8FqNVHqbed1ecbK+S3NLA9eYXyzqVHDqVJjZ04w33ebGhwVAsdfsY7UK\n'
    //   //     'fgSuGSxCLw6dmx8h2Eo+fl0M1iDCEQ==\n'
    //   //     '-----END EC PRIVATE KEY-----');
    //   // var recipientKey =
    //   //     Secp256K1.parseKeyPair(rPublicKey.value(), rPrivateKey);
    //   var rPublicKey = CLPublicKey.fromHex(
    //       '0164f74cb5134b1bafab03b60f6f1ec9ec8a7e68c90dcabadcb020ce27d3974b47');

    //   var networkName = 'casper-test';
    //   var paymentAmount = 1000000000;
    //   var transferAmount = 2500000000;
    //   var transferId = 34;

    //   var deployParams = DeployParams(publicKey, networkName);
    //   var session = ExecutableDeployItem.newTransfer(
    //       BigNumber.from(transferAmount),
    //       rPublicKey,
    //       null,
    //       BigNumber.from(transferId));

    //   var payment = standardPayment(BigNumber.from(paymentAmount));
    //   var deploy = makeDeploy(deployParams, session, payment);
    //   deploy = signDeploy(deploy, senderKey);
    //   var res = await casperClient.putDeploy(deploy);

    //   expect(res, base16Encode(deploy.hash));
    // });

    // makeTransferDeploy
    test('makeTransferDeploy', () async {
      var publicKey1 = CLPublicKey.fromHex(
          '0164f74cb5134b1bafab03b60f6f1ec9ec8a7e68c90dcabadcb020ce27d3974b47');
      var privateKey1 = Secp256K1.readBase64WithPEM(
          '-----BEGIN PRIVATE KEY-----\n'
          'MC4CAQAwBQYDK2VwBCIEIMETiRtNoIHRUQenbj2SxaJWVVToaKw/xLKSvo+pS9Fj\n'
          '-----END PRIVATE KEY-----');
      
      var publicKey2 = CLPublicKey.fromHex(
          '02025d0f7d345c9863814ff3ccd934664bbd28fb911d8320b7cab9828f021341705d');
      var privateKey2 = Secp256K1.readBase64WithPEM(
          '-----BEGIN EC PRIVATE KEY-----\n'
          'MHQCAQEEIPCR7Cs+AzPFATVPvp/K1zOBQX5ifxfGuCX1kzwy24uXoAcGBSuBBAAK\n'
          'oUQDQgAEXQ99NFyYY4FP88zZNGZLvSj7kR2DILfKuYKPAhNBcF3ZZgQHUXxT0lb8\n'
          'teHP8hv36fe9171dQuZZbo7V1Wej8A==\n'
          '-----END EC PRIVATE KEY-----');

      var senderKey1 = Ed25519.parseKeyPair(publicKey1.value(), privateKey1);
      var senderKey2 = Secp256K1.parseKeyPair(publicKey2.value(), privateKey2);
      
      var rPublicKey1 = CLPublicKey.fromHex(
          '02025d0f7d345c9863814ff3ccd934664bbd28fb911d8320b7cab9828f021341705d');
      var rPublicKey2 = CLPublicKey.fromHex(
          '0164f74cb5134b1bafab03b60f6f1ec9ec8a7e68c90dcabadcb020ce27d3974b47');

      var networkName = 'casper-test';
      var paymentAmount = 1000000000;
      var transferAmount = 2500000000;
      var transferId = 1;

      var deployParams1 = DeployParams(publicKey1, networkName);
      var session1 = ExecutableDeployItem.newTransfer(
          BigNumber.from(transferAmount),
          rPublicKey1,
          null,
          BigNumber.from(transferId));

      var payment = standardPayment(BigNumber.from(paymentAmount));
      var transperDeploy1 =
          casperClient.makeTransferDeploy(deployParams1, session1, payment);
      transperDeploy1 = signDeploy(transperDeploy1, senderKey1);

      var tryTimes = 5;
      while (tryTimes > 0) {
        try {
          var res = await casperClient.putDeploy(transperDeploy1);
          expect(res, base16Encode(transperDeploy1.hash));
          print(base16Encode(transperDeploy1.hash));
          break;
        } catch (e) {
          tryTimes--;
          print(e);
        }
      }

      var deployParams2 = DeployParams(publicKey2, networkName);
      var session2 = ExecutableDeployItem.newTransfer(
          BigNumber.from(transferAmount),
          rPublicKey2,
          null,
          BigNumber.from(transferId));

      var transperDeploy2 =
          casperClient.makeTransferDeploy(deployParams2, session2, payment);
      transperDeploy2 = signDeploy(transperDeploy2, senderKey2);

      var tryTimes2 = 5;
      while (tryTimes2 > 0) {
        try {
          var res = await casperClient.putDeploy(transperDeploy2);
          expect(res, base16Encode(transperDeploy2.hash));
          print(base16Encode(transperDeploy2.hash));
          break;
        } catch (e) {
          tryTimes2--;
          print("error here");
          print(e);
        }
      }
    });

    // test('get total stake', () async {
    //   var publicKey = CLPublicKey.fromHex(
    //       '0202f92c9b79232db38584ad558cf5becf5bfd23987e4e1d36d49166289ed8208f5f');
    //   var totalStake = await casperClient.getTotalStake(publicKey);
    //   print(CasperClient.fromWei(totalStake));
    // });
  });
}
