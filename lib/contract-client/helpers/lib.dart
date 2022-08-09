import 'package:casper_dart_sdk/casper_dart_sdk.dart';
import 'package:casper_dart_sdk/contract-client/types.dart';
import 'package:pinenacl/ed25519.dart';

CLKey createRecipientAddress(CLValue recipient) {
  if (recipient is CLPublicKey ||
      recipient is CLAccountHash ||
      recipient is CLByteArray) {
    if (recipient.clType().toString() == PUBLIC_KEY_ID) {
      return CLKey(
        CLAccountHash((recipient as CLPublicKey).toAccountHash()),
      );
    } else {
      return CLKey(recipient);
    }
  } else {
    throw Exception(
        'Invalid recipient type: ${recipient.clType()}. Recipient type is should be CLPublicKey, CLAccountHash or CLByteArray');
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

Future<String> installContract(InstallParams params) async {
  return await installWasmFile(params);
}

Future<Map<String, dynamic>> setClient(String nodeAddress, String contractHash,
    List<String> listOfNamedKeys) async {
  var stateRootHash = await getStateRootHash(nodeAddress);
  var contractData =
      await getContractData(nodeAddress, stateRootHash, contractHash, []);

  var contractPackageHash = contractData.contract?.contractPackageHash;
  var namedKeys = contractData.contract?.namedKeys ?? List.empty();

  Map<String, dynamic> namedKeysParsed = {};

  for (var val in namedKeys) {
    if (listOfNamedKeys.contains(val.name)) {
      namedKeysParsed.addAll({camelCased(val.name): val.key});
    }
  }

  return {
    'contractPackageHash': contractPackageHash,
    'namedKeys': namedKeysParsed,
  };
}

Future<dynamic> contractSimpleGetter(
  String nodeAddress,
  String contractHash,
  List<String> key,
) async {
  var stateRootHash = await getStateRootHash(nodeAddress);
  var clValue = await getContractData(
    nodeAddress,
    stateRootHash,
    contractHash,
    key,
  );

  if (clValue.clValue is CLValue) {
    return clValue.clValue!.value();
  } else {
    throw Exception('Invalid stored value');
  }
}

Future<String> contractCallFn(ContractCallParams params) async {
  var client = CasperClient(params.nodeAddress);
  var contractHashAsByteArray = contractHashToByteArray(params.contractHash);

  List<Uint8List> dependenciesBytes = List.empty(growable: true);

  if (params.dependencies != null) {
    for (var d in params.dependencies!) {
      dependenciesBytes.add(base16Decode(d));
    }
  }

  var deploy = makeDeploy(
    DeployParams(
      params.keys.publicKey,
      params.chainName,
      1,
      params.ttl,
      dependenciesBytes,
    ),
    ExecutableDeployItem.newStoredContractByHash(
      contractHashAsByteArray,
      params.entryPoint,
      params.runtimeArgs,
    ),
    standardPayment(BigNumber.from(params.paymentAmount)),
  );

  // Sign deploy.
  deploy = client.signDeploy(deploy, params.keys);

  // Dispatch deploy to node.
  var deployHash = await client.putDeploy(deploy);

  return deployHash;
}

Future<Deploy> createUnsignedContractCallFn(
    ContractCallParamsUnsigned params) async {
  var contractHashAsByteArray = contractHashToByteArray(params.contractHash);

  List<Uint8List> dependenciesBytes = List.empty(growable: true);

  if (params.dependencies != null) {
    for (var d in params.dependencies!) {
      dependenciesBytes.add(base16Decode(d));
    }
  }

  var deploy = makeDeploy(
    DeployParams(
      params.publicKey,
      params.chainName,
      1,
      params.ttl,
      dependenciesBytes,
    ),
    ExecutableDeployItem.newStoredContractByHash(
      contractHashAsByteArray,
      params.entryPoint,
      params.runtimeArgs,
    ),
    standardPayment(BigNumber.from(params.paymentAmount)),
  );

  return deploy;
}

Future<Map<String, dynamic>> appendSignatureToUnsignedDeployAndSend(
    AppendSignature params) async {
  var client = CasperClient(params.nodeAddress);
  var approval = Approval();

  approval.signer = params.publicKey.toHex();
  if (params.publicKey.isEd25519()) {
    approval.signature = Ed25519.accountHexStr(params.signature);
  } else {
    approval.signature = Secp256K1.accountHexStr(params.signature);
  }

  params.deploy.approvals.add(approval);

  var deployHash = await client.putDeploy(params.deploy);

  return {
    'deploy': params.deploy,
    'deployHash': deployHash,
  };
}
