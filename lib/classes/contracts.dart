import 'dart:typed_data';
import 'package:casper_dart_sdk/classes/CLValue/abstract.dart';
import 'package:casper_dart_sdk/contract-client/helpers/utils.dart';
import 'package:dart_bignumber/dart_bignumber.dart';

import '../classes/CLValue/public_key.dart';
import '../classes/casper_client.dart';
import '../classes/deploy_util.dart';
import '../classes/keys.dart';
import '../classes/runtime_args.dart';
import 'stored_value.dart';

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

    if (contractData.clValue?.isCLValue ?? false) {
      return StoredValue(clValue: contractData.clValue);
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
