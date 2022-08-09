import 'dart:io';
import 'dart:typed_data';

import 'package:casper_dart_sdk/classes/classes.dart';
import 'package:casper_dart_sdk/services/services.dart';

String camelCased(String str) => str.replaceAllMapped(RegExp(r'^([a-z])|[A-Z]'),
    (Match m) => m[1] == null ? ' ${m[0]}' : m[1]!.toUpperCase());

/// Returns an ECC key pair mapped to an NCTL faucet account.
/// @param pathToFaucet - Path to NCTL faucet directory.
AsymmetricKey getKeyPairOfContract(String pathToFaucet) =>
    Ed25519.parseKeyFiles(
      '$pathToFaucet/public_key.pem',
      '$pathToFaucet/secret_key.pem',
    );

/// Returns a binary as u8 array.
/// @param pathToBinary - Path to binary file to be loaded into memory.
/// @return Uint8Array Byte array.
Uint8List getBinary(String pathToBinary) {
  File file = File(pathToBinary);
  var bytes = file.readAsBytesSync();
  return Uint8List.fromList(bytes);
}

/// Returns global state root hash at current block.
/// @param {Object} client - JS SDK client for interacting with a node.
/// @return {String} Root hash of global state at most recent block.
Future<String> getStateRootHash(String nodeAddress) async {
  var client = CasperServiceByJsonRPC(nodeAddress);
  return await client.getStateRootHash();
}

Future<AccountJson?> getAccountInfo(
    String nodeAddress, CLPublicKey publicKey) async {
  var stateRootHash = await getStateRootHash(nodeAddress);
  var client = CasperServiceByJsonRPC(nodeAddress);
  var accountHash = publicKey.toAccountHashStr();
  var blockState = await client.getBlockState(stateRootHash, accountHash, []);
  return blockState.account;
}

/// Returns a value under an on-chain account's storage.
/// @param accountInfo - On-chain account's info.
/// @param namedKey - A named key associated with an on-chain account.
Future<String?> getAccountNamedKeyValue(
    AccountJson accountInfo, String namedKey) async {
  var found = accountInfo.namedKeys.firstWhere(
      (element) => element.name == namedKey,
      orElse: () => NamedKey('', ''));
  if (found.key.isNotEmpty) {
    return found.key;
  }
  return null;
}

Future<StoredValue> getContractData(String nodeAddress, String stateRootHash,
    String contractHash, List<String> path) async {
  var client = CasperServiceByJsonRPC(nodeAddress);
  var blockState =
      await client.getBlockState(stateRootHash, 'hash-$contractHash', path);
  return blockState;
}

Future<dynamic> contractDictionaryGetter(
    String nodeAddress, String dictionaryItemKey, String seedUref) async {
  var stateRootHash = await getStateRootHash(nodeAddress);
  var client = CasperServiceByJsonRPC(nodeAddress);
  var storedValue = await client.getDictionaryItemByURef(
      stateRootHash, dictionaryItemKey, seedUref);

  if (storedValue.clValue is CLValue) {
    return storedValue.clValue!.value();
  } else {
    throw Exception('Invalid stored value');
  }
}

Uint8List contractHashToByteArray(String contractHash) =>
    base16Decode(contractHash);

Future sleep(int milisecond) =>
    Future.delayed(Duration(milliseconds: milisecond));

Map<String, dynamic> parseEvent(String contractPackageHash,
    List<String> eventNames, String eventsURef, Map<dynamic, dynamic> value) {
  if (value['body']['DeployProcessed']['execution_result']['Failure'] != null) {
    return {
      'error': value['body']['DeployProcessed']['execution_result']['Failure']
          ['error_message'],
      'success': false
    };
  } else {
    var transforms = value['body']['DeployProcessed']['execution_result']
        ['Success']['effect']['transforms'] as List<dynamic>;

    List<dynamic> cep47Events = transforms.reduce((acc, val) {
      if (val['transform']['WriteCLValue'] != null &&
          val['transform']['WriteCLValue']['parsed'] != null) {
        var maybeCLValue =
            CLValueParsers.fromJSON(val['transform']['WriteCLValue']);
        var clValue = maybeCLValue.unwrap();

        if (clValue is CLMap) {
          var hash =
              clValue.get(CLValueBuilder.string('contract_package_hash'));
          var event = clValue.get(CLValueBuilder.string('event_type'));

          if (hash != null &&
              hash.value() == contractPackageHash.toLowerCase() &&
              event != null &&
              eventNames.contains(event.value())) {
            acc = [
              ...acc,
              {'name': event.value(), 'clValue': clValue}
            ];
          }
        }
      }

      return acc;
    });

    return {
      'error': null,
      'success': cep47Events.isNotEmpty,
      'data': cep47Events
    };
  }
}

class InstallParams {
  late String nodeAddress;
  late AsymmetricKey keys;
  late String chainName;
  late String pathToContract;
  late RuntimeArgs runtimeArgs;
  late String paymentAmount;

  InstallParams({
    required this.nodeAddress,
    required this.keys,
    required this.chainName,
    required this.pathToContract,
    required this.runtimeArgs,
    required this.paymentAmount,
  });
}

Future<String> installWasmFile(InstallParams params) async {
  var client = CasperClient(params.nodeAddress);

  // Set contract installation deploy (unsigned).
  var deploy = makeDeploy(
      DeployParams(
          CLPublicKey.fromHex(params.keys.publicKey.toHex()), params.chainName),
      ExecutableDeployItem.newModuleBytes(
          getBinary(params.pathToContract), params.runtimeArgs),
      standardPayment(BigNumber.from(params.paymentAmount)));

  // Sign deploy.
  deploy = client.signDeploy(deploy, params.keys);

  // Dispatch deploy to node.
  return await client.putDeploy(deploy);
}

String toAccountHashString(Uint8List hash) => base16Encode(hash);

String getDictionaryKeyHash(String uref, String id) {
  var eventsUref = CLURef.fromFormattedStr(uref);
  var eventsUrefBytes = eventsUref.value().data;
  var idNum = Uint8List.fromList(base16Decode(id));
  var finalBytes = Uint8List.fromList([...eventsUrefBytes, ...idNum]);
  var blaked = byteHash(finalBytes);
  var str = base16Encode(blaked);

  return 'dictionary-$str';
}
