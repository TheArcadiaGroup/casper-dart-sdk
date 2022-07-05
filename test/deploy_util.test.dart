import 'dart:typed_data';

import 'package:casper_dart_sdk/classes/CLValue/abstract.dart';
import 'package:casper_dart_sdk/classes/CLValue/public_key.dart';
import 'package:casper_dart_sdk/classes/bignumber.dart';
import 'package:casper_dart_sdk/classes/deploy_util.dart';
import 'package:casper_dart_sdk/classes/keys.dart';
import 'package:oxidized/oxidized.dart';
import 'package:test/test.dart';

Deploy testDeploy() {
  var senderKey = Ed25519.newKey();
  var recipientKey = Ed25519.newKey();
  var networkName = 'test-network';
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
          'test-network');

      var json = deployHeader.toJson();
      var deployHeader1 = DeployHeader.fromJson(json);
      expect(deployHeader1, deployHeader);
    });
  });

  test('should allow to extract data from Transfer', () {
    var senderKey = Ed25519.newKey();
    var recipientKey = Ed25519.newKey();
    var networkName = 'test-network';
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

    var _id = deploy2.session.getArgByName('id')?.value() as Some<CLValue>;
    expect((_id.unwrap().value() as BigNumber).toNumber(), id);

    expect(deploy.approvals[0].signer, senderKey.accountHex());
    expect(deploy.approvals[1].signer, recipientKey.accountHex());
    expect(deploy, deploy2);
  });
}
