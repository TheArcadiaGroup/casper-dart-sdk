import 'package:casper_dart_sdk/casper_dart_sdk.dart';

import 'package:casper_dart_sdk/contract-client/helpers/utils.dart' as utils;
import 'types.dart';

export './helpers/helpers.dart';

class ContractClient {
  String? contractHash;
  String? contractPackageHash;
  dynamic _namedKeys;
  bool _isListening = false;
  List<PendingDeploy> pendingDeploys = List.empty(growable: true);

  late String nodeAddress;
  late String chainName;
  late String eventStreamAddress;

  ContractClient(this.nodeAddress, this.chainName, this.eventStreamAddress);

  Future<String> contractCall(ContractClientCallParams params) async {
    try {
      var _contractParams = ContractCallParams(
        nodeAddress: nodeAddress,
        keys: params.keys,
        chainName: chainName,
        contractHash: contractHash!,
        entryPoint: params.entryPoint,
        runtimeArgs: params.runtimeArgs,
        paymentAmount: params.paymentAmount,
        ttl: params.ttl,
      );
      var deployHash = await contractCallFn(_contractParams);

      if (params.callback != null) {
        params.callback;
      }

      return deployHash;
    } catch (e) {
      rethrow;
    }
  }

  Future<Deploy> createUnsignedContractCall(
      ContractClientCallParamsUnsigned params) async {
    try {
      var _contractParams = ContractCallParamsUnsigned(
        nodeAddress: nodeAddress,
        publicKey: params.publicKey,
        chainName: chainName,
        contractHash: contractHash!,
        entryPoint: params.entryPoint,
        runtimeArgs: params.runtimeArgs,
        paymentAmount: params.paymentAmount,
        ttl: params.ttl,
      );
      var deploy = await createUnsignedContractCallFn(_contractParams);

      return deploy;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> putSignatureAndSend(AppendSignature sig) async {
    try {
      var client = CasperClient(nodeAddress);
      var approval = Approval();
      approval.signer = sig.publicKey.toHex();
      if (sig.publicKey.isEd25519()) {
        approval.signature = Ed25519.accountHexStr(sig.signature);
      } else {
        approval.signature = Secp256K1.accountHexStr(sig.signature);
      }

      sig.deploy.approvals.add(approval);

      var deployHash = await client.putDeploy(sig.deploy);

      return {
        'deploy': sig.deploy,
        'deployHash': deployHash,
      };
    } catch (e) {
      rethrow;
    }
  }

  void addPendingDeploy(deployType, String deployHash) {
    pendingDeploys
        .add(PendingDeploy(deployHash: deployHash, deployType: deployType));
  }

  Map<String, dynamic> handleEvents(
    List<String> eventNames,
    Function(dynamic eventName, Map<String, dynamic> deployStatus,
            dynamic result)
        callback,
  ) {
    if (eventStreamAddress.isEmpty) {
      throw Exception('Please set eventStreamAddress before!');
    }

    if (_isListening) {
      throw Exception(
          'Only one event listener can be create at a time. Remove the previous one and start new.');
    }

    var es = EventStream(eventStreamAddress);
    _isListening = true;

    es.subscribe(EventName.DeployProcessed, (value) {
      var deployHash = value['body']['DeployProcessed']['deploy_hash'];
      var pendingDeloy = pendingDeploys.firstWhere(
        (p) => p.deployHash == deployHash,
        orElse: () => PendingDeploy(deployHash: '', deployType: ''),
      );

      if (pendingDeloy.deployHash != '') {
        return;
      }

      var parsedEvent = utils.parseEvent(
        contractPackageHash!,
        eventNames,
        _namedKeys!['events'],
        value,
      );

      if (parsedEvent['error'] != null) {
        callback(
          pendingDeloy.deployType,
          {
            'deployHash': deployHash,
            'error': parsedEvent['error'],
            'success': false,
          },
          null,
        );
      } else {
        parsedEvent['data'].forEach(
          (d) => callback(
            d.name,
            {
              'deployHash': deployHash,
              'error': null,
              'success': true,
            },
            d.clValue,
          ),
        );
      }

      pendingDeploys = pendingDeploys
          .where(
            (pending) => pending.deployHash != deployHash,
          )
          .toList();
    });

    es.start();

    return {
      'stopListening': () {
        es.unsubscribe(EventName.DeployProcessed);
        es.stop();
        _isListening = false;
        pendingDeploys.clear();
      }
    };
  }
}
