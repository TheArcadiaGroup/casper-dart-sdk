import 'dart:typed_data';
import 'package:casper_dart_sdk/classes/CLValue/abstract.dart';
import 'package:casper_dart_sdk/classes/bignumber.dart';
import 'package:pinenacl/digests.dart';

import '../classes/CLValue/public_key.dart';
import '../classes/casper_client.dart';
import '../classes/deploy_util.dart';
import '../classes/keys.dart';
import '../classes/runtime_args.dart';
import 'CLValue/builders.dart';
import 'CLValue/map.dart';
import 'conversions.dart';
import 'stored_value.dart';

Uint8List byteHash(Uint8List x) {
  var hasher = Hash.blake2b;
  return hasher(x, digestSize: 32);
}

Uint8List contractHashToByteArray(String contractHash) {
  return Uint8List.fromList(base16Decode(contractHash));
}

// ignore: non_constant_identifier_names
String NO_CLIENT_ERR =
    'You need to either create Contract instance with casperClient or pass it as parameter to this function';

class Contract {
  late String? contractHash;
  late String? contractPackageHash;
  late CasperClient? casperClient;

  Contract(this.casperClient);

  void setContractHash(String contractHash, [String? contractPackageHash]) {
    if (!contractHash.startsWith('hash-') ||
        (contractPackageHash != null &&
            !contractPackageHash.startsWith('hash-'))) {
      throw Exception(
          'Please provide contract hash in a format that contains hash- prefix.');
    }

    this.contractHash = contractHash;
    this.contractPackageHash = contractPackageHash;
  }

  Deploy install(Uint8List wasm, RuntimeArgs args, String paymentAmount,
      CLPublicKey sender, String chainName, List<AsymmetricKey> signingKeys) {
    var deploy = makeDeploy(
        DeployParams(sender, chainName),
        ExecutableDeployItem.newModuleBytes(wasm, args),
        standardPayment(BigNumber.from(paymentAmount)));

    return deploy.sign(signingKeys);
  }

  bool checkSetup() {
    if (contractHash != null) return true;
    throw Exception('You need to setContract before running this method.');
  }

  Deploy callEntrypoint(String entryPoint, RuntimeArgs args, CLPublicKey sender,
      String chainName, String paymentAmount, List<AsymmetricKey> signingKeys,
      [int ttl = 1800000]) {
    checkSetup();

    var contractHashAsByteArray =
        contractHashToByteArray(contractHash!.substring(5));

    var deploy = makeDeploy(
        DeployParams(sender, chainName, 1, ttl),
        ExecutableDeployItem.newStoredContractByHash(
            contractHashAsByteArray, entryPoint, args),
        standardPayment(BigNumber.from(paymentAmount)));

    return deploy.sign(signingKeys);
  }

  Future<StoredValue> queryContractData(List<String> path,
      [CasperClient? casperClient, String? stateRootHash]) async {
    var client = casperClient ?? this.casperClient;

    if (client == null) {
      throw Exception(NO_CLIENT_ERR);
    }

    var stateRootHashToUse =
        stateRootHash ?? (await client.nodeClient.getStateRootHash());

    var contractData = await client.nodeClient
        .getBlockState(stateRootHashToUse.toString(), contractHash!, path);

    if (contractData.clValue?.isCLValue != null) {
      return contractData.clValue?.value();
    } else {
      throw Exception('Invalid stored value');
    }
  }

  Future<CLValue?> queryContractDictionary(
      String dictionaryName, String dictionaryItemKey,
      [String? stateRootHash, CasperClient? casperClient]) async {
    checkSetup();

    var client = casperClient ?? this.casperClient;
    if (client == null) throw Exception(NO_CLIENT_ERR);

    var stateRootHashToUse =
        stateRootHash ?? (await client.nodeClient.getStateRootHash());

    var storedValue = await client.nodeClient.getDictionaryItemByName(
        stateRootHashToUse.toString(),
        contractHash!,
        dictionaryName,
        dictionaryItemKey);

    if (storedValue.clValue?.isCLValue != null) {
      return storedValue.clValue;
    } else {
      throw Exception('Invalid stored value');
    }
  }
}

CLMap<CLValue, CLValue> toCLMap(Map<String, String> map) {
  var clMap = CLValueBuilder.mapfromMap(
      {CLTypeBuilder.string(): CLTypeBuilder.string()});

  for (var entry in map.entries) {
    clMap.set(
        CLValueBuilder.string(entry.key), CLValueBuilder.string(entry.value));
  }

  return clMap;
}

Map<CLValue, CLValue> fromCLMap(List<Map<CLValue, CLValue>> map) {
  Map<CLValue, CLValue> clMap = {};

  for (var item in map) {
    clMap[item.keys.first.value()] = item.values.first.value();
  }

  return clMap;
}
