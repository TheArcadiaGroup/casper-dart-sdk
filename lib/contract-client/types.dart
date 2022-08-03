// ignore: constant_identifier_names
// ignore_for_file: non_constant_identifier_names

import 'dart:typed_data';

import 'package:casper_dart_sdk/classes/classes.dart';

var DEFAULT_TTL = 600000;

class PendingDeploy {
  late String deployHash;
  late dynamic deployType;

  PendingDeploy({
    required this.deployHash,
    required this.deployType,
  });
}

class ContractClientCallParams {
  late AsymmetricKey keys;
  late String entryPoint;
  late RuntimeArgs runtimeArgs;
  late String paymentAmount;
  late int ttl = DEFAULT_TTL;
  Function(String deployHash)? callback;
  List<String>? dependencies;

  ContractClientCallParams({
    required this.keys,
    required this.entryPoint,
    required this.runtimeArgs,
    required this.paymentAmount,
    required this.ttl,
    this.callback,
    this.dependencies,
  });
}

class ContractClientCallParamsUnsigned {
  late CLPublicKey publicKey;
  late String entryPoint;
  late RuntimeArgs runtimeArgs;
  late String paymentAmount;
  late int ttl = DEFAULT_TTL;
  Function(String deployHash)? callback;
  List<String>? dependencies;

  ContractClientCallParamsUnsigned({
    required this.publicKey,
    required this.entryPoint,
    required this.runtimeArgs,
    required this.paymentAmount,
    required this.ttl,
    this.callback,
    this.dependencies,
  });
}

class ContractCallParams {
  late String nodeAddress;
  late AsymmetricKey keys;
  late String chainName;
  late String contractHash;
  late String entryPoint;
  late RuntimeArgs runtimeArgs;
  late String paymentAmount;
  late int ttl = DEFAULT_TTL;
  List<String>? dependencies;

  ContractCallParams({
    required this.nodeAddress,
    required this.keys,
    required this.chainName,
    required this.contractHash,
    required this.entryPoint,
    required this.runtimeArgs,
    required this.paymentAmount,
    required this.ttl,
    this.dependencies,
  });
}

class ContractCallParamsUnsigned {
  late String nodeAddress;
  late CLPublicKey publicKey;
  late String chainName;
  late String contractHash;
  late String entryPoint;
  late RuntimeArgs runtimeArgs;
  late String paymentAmount;
  late int ttl = DEFAULT_TTL;
  List<String>? dependencies;

  ContractCallParamsUnsigned({
    required this.nodeAddress,
    required this.publicKey,
    required this.chainName,
    required this.contractHash,
    required this.entryPoint,
    required this.runtimeArgs,
    required this.paymentAmount,
    required this.ttl,
    this.dependencies,
  });
}

class AppendSignature {
  late String nodeAddress;
  late CLPublicKey publicKey;
  late Deploy deploy;
  late Uint8List signature;

  AppendSignature({
    required this.nodeAddress,
    required this.publicKey,
    required this.deploy,
    required this.signature,
  });
}
