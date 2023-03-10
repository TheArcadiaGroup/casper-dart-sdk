import 'dart:convert';
import 'dart:typed_data';
import 'package:casper_dart_sdk/classes/CLValue/abstract.dart';
import 'package:casper_dart_sdk/classes/CLValue/builders.dart';
import 'package:casper_dart_sdk/classes/CLValue/public_key.dart';
import 'package:casper_dart_sdk/classes/bignumber.dart';
import 'package:casper_dart_sdk/classes/deploy_util.dart';
import 'package:casper_dart_sdk/classes/keys.dart';
import 'package:oxidized/oxidized.dart';
import 'package:convert/convert.dart';
import 'package:test/test.dart';

Deploy testDeploy() {
  var senderKey = Ed25519.newKey();
  var recipientKey = Ed25519.newKey();
  var networkName = 'casper-test';
  var paymentAmount = 10000000000000;
  var transferAmount = 10;
  var transferId = 34;

  var deployParams = DeployParams(senderKey.publicKey, networkName);
  var session = ExecutableDeployItem.newTransfer(BigNumber.from(transferAmount),
      recipientKey.publicKey, null, BigNumber.from(transferId));

  var payment = standardPayment(BigNumber.from(paymentAmount));
  var deploy = makeDeploy(deployParams, session, payment);
  deploy = signDeploy(deploy, senderKey);
  return deploy;
}

void main() {
  group('DeployUtil', () {
    test('should stringify/parse DeployHeader correctly', () {
      var ed25519Key = Ed25519.newKey();
      var deployHeader = DeployHeader(
          ed25519Key.publicKey,
          123456,
          654321,
          10,
          Uint8List.fromList(List.filled(32, 42)),
          [Uint8List.fromList(List.filled(32, 2))],
          '');

      var json = deployHeader.toJson();
      var deployHeader1 = DeployHeader.fromJson(json);
      expect(deployHeader1, deployHeader);
    });

    test('should allow to extract data from Transfer', () {
      var senderKey = Ed25519.newKey();
      var recipientKey = Ed25519.newKey();
      var networkName = 'casper-test';
      var paymentAmount = 10000000000000;
      var transferAmount = 10;
      var id = 34;

      var deployParams = DeployParams(senderKey.publicKey, networkName);
      var session = ExecutableDeployItem.newTransfer(
          BigNumber.from(transferAmount),
          recipientKey.publicKey,
          null,
          BigNumber.from(id));
      var payment = standardPayment(BigNumber.from(paymentAmount));
      var deploy = makeDeploy(deployParams, session, payment);
      deploy = signDeploy(deploy, senderKey);
      deploy = signDeploy(deploy, recipientKey);

      var json = deployToJson(deploy);

      var deploy2 = deployFromJson(json).unwrap();

      expect(deploy.isTransfer(), true);
      expect(deploy.isStandardPayment(), true);
      expect(deploy.header.account, senderKey.publicKey);
      expect(
          (deploy.payment.getArgByName('amount')?.value() as BigNumber)
              .toNumber(),
          paymentAmount);
      expect(
          (deploy.session.getArgByName('amount')?.value() as BigNumber)
              .toNumber(),
          transferAmount);
      expect(deploy.session.getArgByName('target') as CLPublicKey,
          recipientKey.publicKey);

      var _id = deploy.session.getArgByName('id')?.value() as Some<CLValue>;
      expect((_id.unwrap().value() as BigNumber).toNumber(), id);

      expect(deploy.approvals[0].signer, senderKey.accountHex());
      expect(deploy.approvals[1].signer, recipientKey.accountHex());
      expect(deploy, deploy2);
    });

    test('should allow to add arg to Deploy', () {
      var senderKey = Ed25519.newKey();
      var recipientKey = Ed25519.newKey();
      var networkName = 'casper-test';
      var paymentAmount = 10000000000000;
      var transferAmount = 10;
      var id = 34;
      var customId = 60;

      var deployParams = DeployParams(senderKey.publicKey, networkName);
      var session = ExecutableDeployItem.newTransfer(
          BigNumber.from(transferAmount),
          recipientKey.publicKey,
          null,
          BigNumber.from(id));
      var payment = standardPayment(BigNumber.from(paymentAmount));
      var oldDeploy = makeDeploy(deployParams, session, payment);

      // Add new argument.
      var deploy =
          addArgToDeploy(oldDeploy, 'custom_id', CLValueBuilder.u32(customId));
      expect(
          (deploy.session.getArgByName('custom_id')?.value() as BigNumber)
              .toNumber(),
          customId);
      expect(deploy.isTransfer(), true);
      expect(deploy.isStandardPayment(), true);
      expect(deploy.header.account, senderKey.publicKey);
      expect(
          (deploy.payment.getArgByName('amount')?.value() as BigNumber)
              .toNumber(),
          paymentAmount);
      expect(deploy.session.getArgByName('target') as CLPublicKey,
          recipientKey.publicKey);
      var _id = deploy.session.getArgByName('id')?.value() as Some<CLValue>;
      expect((_id.unwrap().value() as BigNumber).toNumber(), id);

      expect(oldDeploy.hash, isNot(deploy.hash));
      expect(oldDeploy.header.bodyHash, isNot(deploy.header.bodyHash));
    });

    test('should not allow to add arg to a signed Deploy', () {
      var senderKey = Ed25519.newKey();
      var recipientKey = Ed25519.newKey();
      var networkName = 'casper-test';
      var paymentAmount = 10000000000000;
      var transferAmount = 10;
      var id = 34;
      var customId = 60;

      var deployParams = DeployParams(senderKey.publicKey, networkName);
      var session = ExecutableDeployItem.newTransfer(
          BigNumber.from(transferAmount),
          recipientKey.publicKey,
          null,
          BigNumber.from(id));
      var payment = standardPayment(BigNumber.from(paymentAmount));
      var deploy = makeDeploy(deployParams, session, payment);
      deploy = signDeploy(deploy, senderKey);

      try {
        addArgToDeploy(deploy, 'custom_id', CLValueBuilder.u32(customId));
      } catch (e) {
        expect(
            e.toString(),
            Exception('Can not add argument to already signed deploy.')
                .toString());
      }
    });

    test('should allow to extract additional args from Transfer.', () {
      var from = Secp256K1.newKey();
      var to = Ed25519.newKey();
      var networkName = 'casper-test';
      var paymentAmount = 10000000000000;
      var transferAmount = 10;
      var id = 34;

      var deployParams = DeployParams(from.publicKey, networkName);
      var session = ExecutableDeployItem.newTransfer(
          BigNumber.from(transferAmount),
          to.publicKey,
          null,
          BigNumber.from(id));
      var payment = standardPayment(BigNumber.from(paymentAmount));
      var deploy = makeDeploy(deployParams, session, payment);

      var transferDeploy =
          addArgToDeploy(deploy, 'fromPublicKey', from.publicKey);

      expect(
          transferDeploy.session.getArgByName('fromPublicKey'), from.publicKey);

      var newTransferDeploy =
          deployFromJson(deployToJson(transferDeploy)).unwrap();

      expect(newTransferDeploy.session.getArgByName('fromPublicKey'),
          from.publicKey);
    });

    test(
        'Should not allow for to deserialize a deploy from JSON with a wrong deploy hash',
        () {
      var deploy = testDeploy();
      var json = deployToJson(deploy);
      json['deploy']['hash'] =
          'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff';
      expect(deployFromJson(json).isErr(), true);
    });

    test(
        'Should not allow for to deserialize a deploy from JSON with a wrong body_hash',
        () {
      var deploy = testDeploy();
      var json = deployToJson(deploy);
      var header = json['deploy']['header'];
      header['body_hash'] =
          "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff";
      json['deploy']['header'] = header;
      expect(deployFromJson(json).isErr(), true);
    });

    test('Should convert ms to humanized string', () {
      var strTtl30m = humanizerTTL(1800000);
      var strTtl45m = humanizerTTL(2700000);
      var strTtl1h = humanizerTTL(3600000);
      var strTtl1h30m = humanizerTTL(5400000);
      var strTtl1day = humanizerTTL(86400000);
      var strTtlCustom = humanizerTTL(86103000);

      expect(strTtl30m, '30m');
      expect(strTtl45m, '45m');
      expect(strTtl1h, '1h');
      expect(strTtl1h30m, '1h 30m');
      expect(strTtl1day, '1day');
      expect(strTtlCustom, '23h 55m 3s');
    });

    test('Should convert humanized string to ms', () {
      var msTtl30m = dehumanizerTTL("30m");
      var msTtl45m = dehumanizerTTL("45m");
      var msTtl1h = dehumanizerTTL("1h");
      var msTtl1h30m = dehumanizerTTL("1h 30m");
      var msTtl1day = dehumanizerTTL("1day");
      var msTtlCustom = dehumanizerTTL("23h 55m 3s");

      expect(msTtl30m, 1800000);
      expect(msTtl45m, 2700000);
      expect(msTtl1h, 3600000);
      expect(msTtl1h30m, 5400000);
      expect(msTtl1day, 86400000);
      expect(msTtlCustom, 86103000);
    });

    test(
        'Should be able create new transfer without providing transfer-id using newTransferWithOptionalTransferId()',
        () {
      var recipientKey = Ed25519.newKey();
      var transferAmount = 10;
      ExecutableDeployItem.newTransferWithOptionalTransferId(
        BigNumber.from(transferAmount),
        recipientKey.publicKey,
      );
    });

    test('newTransferToUniqAddress should construct proper deploy', () {
      var senderKey = Ed25519.newKey();
      var recipientKey = Ed25519.newKey();
      var networkName = 'casper-test';
      var paymentAmount = 10000000000000;
      var transferAmount = 10;
      var transferId = 34;

      var uniqAddress =
          UniqAddress(recipientKey.publicKey, BigNumber.from(transferId));

      var deploy = ExecutableDeployItem.newTransferToUniqAddress(
          senderKey.publicKey,
          uniqAddress,
          BigNumber.from(transferAmount),
          BigNumber.from(paymentAmount),
          networkName,
          null);

      deploy = signDeploy(deploy, senderKey);

      expect(deploy.isTransfer(), true);
      expect(deploy.isStandardPayment(), true);
      expect(deploy.header.account, senderKey.publicKey);
      expect(
          (deploy.payment.getArgByName('amount')!.value() as BigNumber)
              .toNumber(),
          paymentAmount);
      expect(
          (deploy.session.getArgByName('amount')!.value() as BigNumber)
              .toNumber(),
          transferAmount);
      expect(deploy.session.getArgByName('target'), recipientKey.publicKey);

      var _id = deploy.session.getArgByName('id')?.value() as Some<CLValue>;
      expect(_id.unwrap().value().toNumber(), transferId);
    });

    test('DeployUtil.UniqAddress should serialize and deserialize', () {
      var recipientKey = Ed25519.newKey();
      var hexAddress = recipientKey.publicKey.toHex();
      var transferId = "80172309";
      var transferIdHex = "0x04c75515";

      var uniqAddress =
          UniqAddress(recipientKey.publicKey, BigNumber.from(transferId));

      expect(uniqAddress, isA<UniqAddress>());
      expect(uniqAddress.toString(), '$hexAddress-$transferIdHex');
    });

    test('DeployUtil.deployToBytes should produce correct byte representation.',
        () {
      var json =
          '{"deploy":{"hash":"d7a68bbe656a883d04bba9f26aa340dbe3f8ec99b2adb63b628f2bc920431998","header":{"account":"017f747b67bd3fe63c2a736739dfe40156d622347346e70f68f51c178a75ce5537","timestamp":"2021-05-04T14:20:35.104Z","ttl":"30m","gas_price":2,"body_hash":"f2e0782bba4a0a9663cafc7d707fd4a74421bc5bfef4e368b7e8f38dfab87db8","dependencies":["0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f","1010101010101010101010101010101010101010101010101010101010101010"],"chain_name":"mainnet"},"payment":{"ModuleBytes":{"module_bytes":"","args":[["amount",{"cl_type":"U512","bytes":"0400ca9a3b","parsed":"1000000000"}]]}},"session":{"Transfer":{"args":[["amount",{"cl_type":"U512","bytes":"05005550b405","parsed":"24500000000"}],["target",{"cl_type":{"ByteArray":32},"bytes":"0101010101010101010101010101010101010101010101010101010101010101","parsed":"0101010101010101010101010101010101010101010101010101010101010101"}],["id",{"cl_type":{"Option":"U64"},"bytes":"01e703000000000000","parsed":999}],["additional_info",{"cl_type":"String","bytes":"1000000074686973206973207472616e73666572","parsed":"this is transfer"}]]}},"approvals":[{"signer":"017f747b67bd3fe63c2a736739dfe40156d622347346e70f68f51c178a75ce5537","signature":"0195a68b1a05731b7014e580b4c67a506e0339a7fffeaded9f24eb2e7f78b96bdd900b9be8ca33e4552a9a619dc4fc5e4e3a9f74a4b0537c14a5a8007d62a5dc06"}]}}';
      var deploy = deployFromJson(jsonDecode(json)).unwrap();
      var expected =
          '017f747b67bd3fe63c2a736739dfe40156d622347346e70f68f51c178a75ce5537a087c0377901000040771b00000000000200000000000000f2e0782bba4a0a9663cafc7d707fd4a74421bc5bfef4e368b7e8f38dfab87db8020000000f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f1010101010101010101010101010101010101010101010101010101010101010070000006d61696e6e6574d7a68bbe656a883d04bba9f26aa340dbe3f8ec99b2adb63b628f2bc92043199800000000000100000006000000616d6f756e74050000000400ca9a3b08050400000006000000616d6f756e740600000005005550b40508060000007461726765742000000001010101010101010101010101010101010101010101010101010101010101010f200000000200000069640900000001e7030000000000000d050f0000006164646974696f6e616c5f696e666f140000001000000074686973206973207472616e736665720a01000000017f747b67bd3fe63c2a736739dfe40156d622347346e70f68f51c178a75ce55370195a68b1a05731b7014e580b4c67a506e0339a7fffeaded9f24eb2e7f78b96bdd900b9be8ca33e4552a9a619dc4fc5e4e3a9f74a4b0537c14a5a8007d62a5dc06';
      var result = hex.encode(deployToBytes(deploy));
      expect(expected, result);
    });

    test('Is possible to chain deploys using dependencies', () {
      var senderKey = Ed25519.newKey();
      var recipientKey = Ed25519.newKey();
      var networkName = 'casper-test';
      var paymentAmount = 10000000000000;
      var transferAmount = 10;
      var transferId = 35;
      var payment = standardPayment(BigNumber.from(paymentAmount));
      var session = ExecutableDeployItem.newTransfer(
          BigNumber.from(transferAmount),
          recipientKey.publicKey,
          null,
          BigNumber.from(transferId));

      // Build first deploy.
      var firstDeployParams = DeployParams(senderKey.publicKey, networkName);
      var firstDeploy = makeDeploy(firstDeployParams, session, payment);

      // Build second deploy with the first one as a dependency.
      var gasPrice = 2.5;
      var ttl = 1800000;
      var dependencies = [firstDeploy.hash];
      var secondDeployParams = DeployParams(
          senderKey.publicKey, networkName, gasPrice, ttl, dependencies);

      var secondDeploy = makeDeploy(secondDeployParams, session, payment);

      expect(secondDeploy.header.dependencies, [firstDeploy.hash]);
    });
  });
}
