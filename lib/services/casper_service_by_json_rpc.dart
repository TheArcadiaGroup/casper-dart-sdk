import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:json_annotation/json_annotation.dart';

import '../classes/CLValue/public_key.dart';
import '../classes/bignumber.dart';
import '../classes/conversions.dart';
import '../classes/deploy_util.dart';
import '../classes/stored_value.dart';

part 'casper_service_by_json_rpc.g.dart';

@JsonSerializable(explicitToJson: true)
class RpcResult {
  @JsonKey(name: 'api_version')
  String apiVersion = '2.0';

  RpcResult();

  factory RpcResult.fromJson(Map<String, dynamic> json) =>
      _$RpcResultFromJson(json);
  Map<String, dynamic> toJson() => _$RpcResultToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Peer {
  @JsonKey(name: 'node_id')
  late String nodeId;
  late String address;

  Peer(this.nodeId, this.address);

  factory Peer.fromJson(Map<String, dynamic> json) => _$PeerFromJson(json);
  Map<String, dynamic> toJson() => _$PeerToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetPeersResult extends RpcResult {
  late List<Peer> peers;

  GetPeersResult(this.peers);

  factory GetPeersResult.fromJson(Map<String, dynamic> json) =>
      _$GetPeersResultFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$GetPeersResultToJson(this);
}

@JsonSerializable(explicitToJson: true)
class LastAddedBlockInfo {
  late String hash;
  late String timestamp;

  @JsonKey(name: 'era_id')
  late int eraId;

  late int height;

  @JsonKey(name: 'state_root_hash')
  late String stateRootHash;
  late String creator;

  LastAddedBlockInfo(this.hash, this.timestamp, this.eraId, this.height,
      this.stateRootHash, this.creator);

  factory LastAddedBlockInfo.fromJson(Map<String, dynamic> json) =>
      _$LastAddedBlockInfoFromJson(json);
  Map<String, dynamic> toJson() => _$LastAddedBlockInfoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetStatusResult extends GetPeersResult {
  @JsonKey(name: 'last_added_block_info')
  late LastAddedBlockInfo lastAddedBlockInfo;

  @JsonKey(name: 'build_version')
  late String buildVersion;

  GetStatusResult(List<Peer> peers) : super(peers);

  factory GetStatusResult.fromJson(Map<String, dynamic> json) =>
      _$GetStatusResultFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$GetStatusResultToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetStateRootHashResult extends RpcResult {
  @JsonKey(name: 'state_root_hash')
  late String stateRootHash;

  GetStateRootHashResult(this.stateRootHash);

  factory GetStateRootHashResult.fromJson(Map<String, dynamic> json) =>
      _$GetStateRootHashResultFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$GetStateRootHashResultToJson(this);
}

@JsonSerializable(explicitToJson: true)
class EffectJson {
  late List<Map<String, dynamic>> operations;
  late List<Map<String, dynamic>> transforms;

  EffectJson(this.operations, this.transforms);

  factory EffectJson.fromJson(Map<String, dynamic> json) =>
      _$EffectJsonFromJson(json);
  Map<String, dynamic> toJson() => _$EffectJsonToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ExecutionResultBody {
  late String cost;

  @JsonKey(name: 'error_message', includeIfNull: false)
  late String? errorMessage;
  late List<String> transfers;

  @JsonKey(includeIfNull: false)
  late EffectJson? effect;

  ExecutionResultBody(
      this.cost, this.errorMessage, this.transfers, this.effect);

  factory ExecutionResultBody.fromJson(Map<String, dynamic> json) =>
      _$ExecutionResultBodyFromJson(json);
  Map<String, dynamic> toJson() => _$ExecutionResultBodyToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ExecutionResult {
  @JsonKey(name: 'Success', includeIfNull: false)
  late ExecutionResultBody? success;
  @JsonKey(name: 'Failure', includeIfNull: false)
  late ExecutionResultBody? failure;

  ExecutionResult(this.success, this.failure);

  factory ExecutionResult.fromJson(Map<String, dynamic> json) =>
      _$ExecutionResultFromJson(json);
  Map<String, dynamic> toJson() => _$ExecutionResultToJson(this);
}

@JsonSerializable(explicitToJson: true)
class JsonExecutionResult {
  @JsonKey(name: 'block_hash')
  late String blockHash;

  late ExecutionResult result;

  JsonExecutionResult(this.blockHash, this.result);

  factory JsonExecutionResult.fromJson(Map<String, dynamic> json) =>
      _$JsonExecutionResultFromJson(json);
  Map<String, dynamic> toJson() => _$JsonExecutionResultToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetDeployResult extends RpcResult {
  late JsonDeploy deploy;

  @JsonKey(name: 'execution_results')
  late List<JsonExecutionResult> executionResults;

  GetDeployResult(this.deploy);

  factory GetDeployResult.fromJson(Map<String, dynamic> json) =>
      _$GetDeployResultFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$GetDeployResultToJson(this);
}

@JsonSerializable(explicitToJson: true)
class GetBlockResult extends RpcResult {
  JsonBlock? block;

  GetBlockResult(this.block);

  factory GetBlockResult.fromJson(Map<String, dynamic> json) =>
      _$GetBlockResultFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$GetBlockResultToJson(this);
}

@JsonSerializable(explicitToJson: true)
class JsonSystemTransaction {
  @JsonKey(name: 'Slash')
  String? slash;

  @JsonKey(name: 'Reward')
  Map<String, num>? reward;

  JsonSystemTransaction(this.slash, this.reward);

  factory JsonSystemTransaction.fromJson(Map<String, dynamic> json) =>
      _$JsonSystemTransactionFromJson(json);
  Map<String, dynamic> toJson() => _$JsonSystemTransactionToJson(this);
}

@JsonSerializable(explicitToJson: true)
class JsonDeployHeader {
  late String account;
  late String timestamp;
  late String ttl;

  @JsonKey(name: 'gas_price')
  late int gasPrice;

  @JsonKey(name: 'body_hash')
  late String bodyHash;

  late List<String> dependencies;

  @JsonKey(name: 'chain_name')
  late String chainName;

  JsonDeployHeader(this.account, this.timestamp, this.ttl, this.gasPrice,
      this.bodyHash, this.dependencies, this.chainName);

  factory JsonDeployHeader.fromJson(Map<String, dynamic> json) =>
      _$JsonDeployHeaderFromJson(json);
  Map<String, dynamic> toJson() => _$JsonDeployHeaderToJson(this);
}

@JsonSerializable(explicitToJson: true)
class JsonModuleBytes {
  @JsonKey(name: 'module_bytes')
  late List<dynamic> moduleBytes;

  late List<dynamic> args;

  JsonModuleBytes(this.moduleBytes, this.args);

  factory JsonModuleBytes.fromJson(Map<String, dynamic> json) =>
      _$JsonModuleBytesFromJson(json);
  Map<String, dynamic> toJson() => _$JsonModuleBytesToJson(this);
}

@JsonSerializable(explicitToJson: true)
class JsonStoredContractByHash {
  late String hash;

  late List<dynamic> args;

  @JsonKey(name: 'entry_point')
  late String entryPoint;

  JsonStoredContractByHash(this.hash, this.entryPoint, this.args);

  factory JsonStoredContractByHash.fromJson(Map<String, dynamic> json) =>
      _$JsonStoredContractByHashFromJson(json);
  Map<String, dynamic> toJson() => _$JsonStoredContractByHashToJson(this);
}

@JsonSerializable(explicitToJson: true)
class JsonStoredContractByName {
  late String name;
  late String hash;

  @JsonKey(name: 'entry_point')
  late String entryPoint;

  late List<dynamic> args;

  JsonStoredContractByName(this.name, this.entryPoint, this.args);

  factory JsonStoredContractByName.fromJson(Map<String, dynamic> json) =>
      _$JsonStoredContractByNameFromJson(json);
  Map<String, dynamic> toJson() => _$JsonStoredContractByNameToJson(this);
}

@JsonSerializable(explicitToJson: true)
class JsonStoredVersionedContractByName {
  late String name;

  late num? version;

  @JsonKey(name: 'entry_point')
  late String entryPoint;

  late List<dynamic> args;

  JsonStoredVersionedContractByName(
      this.name, this.version, this.entryPoint, this.args);

  factory JsonStoredVersionedContractByName.fromJson(
          Map<String, dynamic> json) =>
      _$JsonStoredVersionedContractByNameFromJson(json);
  Map<String, dynamic> toJson() =>
      _$JsonStoredVersionedContractByNameToJson(this);
}

@JsonSerializable(explicitToJson: true)
class JsonStoredVersionedContractByHash {
  late String hash;

  late num? version;

  @JsonKey(name: 'entry_point')
  late String entryPoint;

  late List<dynamic> args;

  JsonStoredVersionedContractByHash(
      this.hash, this.version, this.entryPoint, this.args);

  factory JsonStoredVersionedContractByHash.fromJson(
          Map<String, dynamic> json) =>
      _$JsonStoredVersionedContractByHashFromJson(json);
  Map<String, dynamic> toJson() =>
      _$JsonStoredVersionedContractByHashToJson(this);
}

@JsonSerializable(explicitToJson: true)
class JsonTransfer {
  late List<dynamic> args;

  JsonTransfer(this.args);

  factory JsonTransfer.fromJson(Map<String, dynamic> json) =>
      _$JsonTransferFromJson(json);
  Map<String, dynamic> toJson() => _$JsonTransferToJson(this);
}

@JsonSerializable(explicitToJson: true)
class JsonExecutableDeployItem {
  @JsonKey(name: 'ModuleBytes', includeIfNull: false)
  late ModuleBytes? moduleBytes;

  @JsonKey(name: 'StoredContractByHash', includeIfNull: false)
  JsonStoredContractByHash? storedContractByHash;

  @JsonKey(name: 'StoredContractByName', includeIfNull: false)
  JsonStoredContractByName? storedContractByName;

  @JsonKey(name: 'StoredVersionedContractByHash', includeIfNull: false)
  JsonStoredVersionedContractByHash? storedVersionedContractByHash;

  @JsonKey(name: 'StoredVersionedContractByName', includeIfNull: false)
  JsonStoredVersionedContractByName? storedVersionedContractByName;

  @JsonKey(name: 'Transfer', includeIfNull: false)
  JsonTransfer? transfer;

  JsonExecutableDeployItem();

  factory JsonExecutableDeployItem.fromJson(Map<String, dynamic> json) =>
      _$JsonExecutableDeployItemFromJson(json);
  Map<String, dynamic> toJson() => _$JsonExecutableDeployItemToJson(this);
}

@JsonSerializable(explicitToJson: true)
class JsonApproval {
  late String signer;
  late String signature;

  JsonApproval(this.signer, this.signature);

  factory JsonApproval.fromJson(Map<String, dynamic> json) =>
      _$JsonApprovalFromJson(json);
  Map<String, dynamic> toJson() => _$JsonApprovalToJson(this);
}

@JsonSerializable(explicitToJson: true)
class JsonDeploy {
  late String hash;
  late JsonDeployHeader header;
  late JsonExecutableDeployItem payment;
  late JsonExecutableDeployItem session;
  late List<JsonApproval> approvals;

  JsonDeploy(
      this.hash, this.header, this.payment, this.session, this.approvals);

  factory JsonDeploy.fromJson(Map<String, dynamic> json) =>
      _$JsonDeployFromJson(json);
  Map<String, dynamic> toJson() => _$JsonDeployToJson(this);
}

@JsonSerializable(explicitToJson: true)
class JsonHeader {
  @JsonKey(name: 'parent_hash')
  late String parentHash;

  @JsonKey(name: 'state_root_hash')
  late String stateRootHash;

  @JsonKey(name: 'body_hash')
  late String bodyHash;

  @JsonKey(name: 'deploy_hashes')
  late List<String>? deployHashes;

  @JsonKey(name: 'random_bit')
  late bool randomBit;

  @JsonKey(name: 'switch_block')
  late bool? switchBlock;
  late String timestamp;

  @JsonKey(name: 'system_transactions')
  late List<JsonSystemTransaction>? systemTransactions;

  @JsonKey(name: 'era_id')
  late int eraId;
  late int height;
  late String? proposer;

  @JsonKey(name: 'protocol_version')
  late String protocolVersion;

  JsonHeader(
      this.parentHash,
      this.stateRootHash,
      this.bodyHash,
      this.deployHashes,
      this.randomBit,
      this.timestamp,
      this.systemTransactions,
      this.eraId,
      this.height,
      this.proposer,
      this.protocolVersion,
      this.switchBlock);

  factory JsonHeader.fromJson(Map<String, dynamic> json) =>
      _$JsonHeaderFromJson(json);
  Map<String, dynamic> toJson() => _$JsonHeaderToJson(this);
}

@JsonSerializable(explicitToJson: true)
class JsonBlock {
  late String hash;
  late JsonHeader header;
  late List<dynamic> proofs;

  JsonBlock(this.hash, this.header, this.proofs);

  factory JsonBlock.fromJson(Map<String, dynamic> json) =>
      _$JsonBlockFromJson(json);
  Map<String, dynamic> toJson() => _$JsonBlockToJson(this);
}

@JsonSerializable(explicitToJson: true)
class BidInfo {
  @JsonKey(name: 'bonding_purse')
  late String bondingPurse;

  @JsonKey(name: 'staked_amount')
  late String stakedAmount;

  @JsonKey(name: 'delegation_rate')
  late num delegationRate;

  @JsonKey(name: 'funds_locked')
  late String? fundsLocked;

  BidInfo(this.bondingPurse, this.stakedAmount, this.delegationRate,
      this.fundsLocked);

  factory BidInfo.fromJson(Map<String, dynamic> json) =>
      _$BidInfoFromJson(json);
  Map<String, dynamic> toJson() => _$BidInfoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ValidatorWeight {
  @JsonKey(name: 'public_key')
  late String publicKey;

  late String weight;

  ValidatorWeight(this.publicKey, this.weight);

  factory ValidatorWeight.fromJson(Map<String, dynamic> json) =>
      _$ValidatorWeightFromJson(json);
  Map<String, dynamic> toJson() => _$ValidatorWeightToJson(this);
}

@JsonSerializable(explicitToJson: true)
class EraSummary {
  @JsonKey(name: 'block_hash')
  late String blockHash;

  @JsonKey(name: 'era_id')
  late int eraId;

  @JsonKey(name: 'stored_value')
  late StoredValue storedValue;

  @JsonKey(name: 'state_root_hash')
  late String stateRootHash;

  EraSummary(this.blockHash, this.eraId, this.storedValue, this.stateRootHash);

  factory EraSummary.fromJson(Map<String, dynamic> json) =>
      _$EraSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$EraSummaryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class EraValidators {
  @JsonKey(name: 'era_id')
  late int eraId;

  @JsonKey(name: 'validator_weights')
  late List<ValidatorWeight> validatorWeights;

  EraValidators(this.eraId, this.validatorWeights);

  factory EraValidators.fromJson(Map<String, dynamic> json) =>
      _$EraValidatorsFromJson(json);
  Map<String, dynamic> toJson() => _$EraValidatorsToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Bid {
  @JsonKey(name: 'bonding_purse')
  late String bondingPurse;

  @JsonKey(name: 'staked_amount')
  late String stakedAmount;

  @JsonKey(name: 'delegation_rate')
  late num delegationRate;

  late bool inactive;
  late String? reward;
  late List<Delegators> delegators;

  Bid(this.bondingPurse, this.stakedAmount, this.delegationRate, this.inactive,
      this.reward, this.delegators);

  factory Bid.fromJson(Map<String, dynamic> json) => _$BidFromJson(json);
  Map<String, dynamic> toJson() => _$BidToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Delegators {
  @JsonKey(name: 'bonding_purse')
  late String bondingPurse;

  late String delegatee;

  @JsonKey(name: 'staked_amount')
  late String stakedAmount;

  @JsonKey(name: 'public_key')
  late String publicKey;

  Delegators(
      this.bondingPurse, this.delegatee, this.stakedAmount, this.publicKey);

  factory Delegators.fromJson(Map<String, dynamic> json) =>
      _$DelegatorsFromJson(json);
  Map<String, dynamic> toJson() => _$DelegatorsToJson(this);
}

@JsonSerializable(explicitToJson: true)
class DelegatorInfo {
  @JsonKey(name: 'bonding_purse')
  late String bondingPurse;

  late String delegatee;
  late String reward;

  @JsonKey(name: 'staked_amount')
  late String stakedAmount;

  DelegatorInfo(this.bondingPurse, this.delegatee, this.reward);

  factory DelegatorInfo.fromJson(Map<String, dynamic> json) =>
      _$DelegatorInfoFromJson(json);
  Map<String, dynamic> toJson() => _$DelegatorInfoToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ValidatorBid {
  @JsonKey(name: 'public_key')
  late String publicKey;
  late Bid bid;

  ValidatorBid(this.publicKey, this.bid);

  factory ValidatorBid.fromJson(Map<String, dynamic> json) =>
      _$ValidatorBidFromJson(json);
  Map<String, dynamic> toJson() => _$ValidatorBidToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AuctionState {
  @JsonKey(name: 'state_root_hash')
  late String stateRootHash;

  @JsonKey(name: 'block_height')
  late int blockHeight;

  @JsonKey(name: 'era_validators')
  late List<EraValidators> eraValidators;

  late List<ValidatorBid> bids;

  AuctionState(
      this.stateRootHash, this.blockHeight, this.eraValidators, this.bids);

  factory AuctionState.fromJson(Map<String, dynamic> json) =>
      _$AuctionStateFromJson(json);
  Map<String, dynamic> toJson() => _$AuctionStateToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ValidatorsInfoResult extends RpcResult {
  @JsonKey(name: 'auction_state')
  late AuctionState auctionState;

  ValidatorsInfoResult(this.auctionState);

  factory ValidatorsInfoResult.fromJson(Map<String, dynamic> json) =>
      _$ValidatorsInfoResultFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$ValidatorsInfoResultToJson(this);
}

class CasperServiceByJsonRPC {
  final String rpcUrl;
  int _currentRequestId = 0;

  CasperServiceByJsonRPC(this.rpcUrl);

  Future<Map<String, dynamic>> call(String function,
      [Map<String, dynamic>? params]) async {
    params ??= {};

    final requestPayload = {
      'jsonrpc': '2.0',
      'method': function,
      'params': params,
      'id': _currentRequestId++,
    };

    var request = http.Request('POST', Uri.parse(rpcUrl));
    request.body = jsonEncode(requestPayload);
    // we have add the
    request.headers.addAll({'Content-Type': 'application/json'});

    final stream = await request.send();
    final response = await http.Response.fromStream(stream);
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data.containsKey('error')) {
      final error = data['error'];

      final code = error['code'] as int;
      final message = error['message'] as String;
      final errorData = error['data'];

      throw RPCError(code, message, errorData);
    }

    final result = data['result'];
    return result;
  }

  Future<Map<String, dynamic>> _makeRPCCall(String function,
      [Map<String, dynamic>? params]) async {
    try {
      final data = await call(function, params);
      if (data is Error || data is Exception) throw data;
      return data;
    } catch (e) {
      rethrow;
    }
  }

  /// Get information about a single deploy by hash.
  ///
  /// @param deployHashBase16
  Future<GetDeployResult> getDeployInfo(String deployHashBase16) async {
    try {
      var res = await _makeRPCCall(
          'info_get_deploy', {'deploy_hash': deployHashBase16});
      return GetDeployResult.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  /// Get information about a block by hash.
  ///
  /// @param blockHashBase16
  Future<GetBlockResult> getBlockInfo(String blockHashBase16) async {
    try {
      var response = await _makeRPCCall('chain_get_block', {
        'block_identifier': {'Hash': blockHashBase16}
      });

      var blockResult = GetBlockResult.fromJson(response);
      if (blockResult.block != null &&
          blockResult.block?.hash.toLowerCase() !=
              blockHashBase16.toLowerCase()) {
        throw Exception('Returned block does not have a matching hash.');
      }

      return blockResult;
    } catch (e) {
      rethrow;
    }
  }

  Future<GetBlockResult> getBlockInfoByHeight(num height) async {
    var response = await _makeRPCCall('chain_get_block', {
      'block_identifier': {'Height': height}
    });

    var blockResult = GetBlockResult.fromJson(response);
    if (blockResult.block != null &&
        blockResult.block?.header.height != height) {
      throw Exception('Returned block does not have a matching height.');
    }

    return blockResult;
  }

  Future<GetBlockResult> getLatestBlockInfo() async {
    return GetBlockResult.fromJson(await _makeRPCCall('chain_get_block'));
  }

  Future<GetPeersResult> getPeers() async {
    return GetPeersResult.fromJson(await _makeRPCCall('info_get_peers'));
  }

  Future<GetStatusResult> getStatus() async {
    return GetStatusResult.fromJson(await _makeRPCCall('info_get_status'));
  }

  Future<ValidatorsInfoResult> getValidatorsInfo() async {
    return ValidatorsInfoResult.fromJson(
        await _makeRPCCall('state_get_auction_info'));
  }

  Future<ValidatorsInfoResult> getValidatorsInfoByBlockHeight(
      int blockHeight) async {
    return ValidatorsInfoResult.fromJson(
        await _makeRPCCall('state_get_auction_info', {
      'block_identifier': {
        blockHeight >= 0 ? {'Height': blockHeight} : null
      }
    }));
  }

  /// Get the reference to the balance so we can cache it.
  Future<String?> getAccountBalanceUrefByPublicKeyHash(
      String stateRootHash, String accountHash) async {
    try {
      var res =
          await getBlockState(stateRootHash, 'account-hash-$accountHash', []);
      var account = res.account;
      return account?.mainPurse;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getAccountBalanceUrefByPublicKey(
      String stateRootHash, CLPublicKey publicKey) async {
    return getAccountBalanceUrefByPublicKeyHash(
        stateRootHash, base16Encode(publicKey.toAccountHash()));
  }

  Future<BigNumber> getAccountBalance(
      String stateRootHash, String balanceUref) async {
    try {
      var res = await _makeRPCCall('state_get_balance',
          {'state_root_hash': stateRootHash, 'purse_uref': balanceUref});
      return BigNumber.from(res['balance_value']);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getStateRootHash([String? blockHashBase16]) async {
    var res = await _makeRPCCall(
        'chain_get_state_root_hash', {'block_hash': blockHashBase16});

    var data = GetStateRootHashResult.fromJson(res);
    return data.stateRootHash;
  }

  Future<StoredValue> getBlockState(
      String stateRootHash, String key, List<String> path) async {
    var res = await _makeRPCCall('state_get_item',
        {'state_root_hash': stateRootHash, 'key': key, 'path': path});

    try {
      var storedValueJson = res['stored_value'];
      var storedValue = StoredValue.fromJson(storedValueJson);
      return storedValue;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deploy(Deploy signedDeploy) async {
    var oneMegaByte = 1048576;
    var size = deploySizeInBytes(signedDeploy);
    if (size > oneMegaByte) {
      throw Exception(
          'Deploy can not be send, because it\'s too large: $size bytes. Max size is 1 megabyte.');
    }
    return await _makeRPCCall('account_put_deploy', deployToJson(signedDeploy));
  }

  /// Retrieves all transfers for a block from the network
  /// @param blockIdentifier Hex-encoded block hash or height of the block. If not given, the last block added to the chain as known at the given node will be used. If not provided it will retrieve by latest block.
  Future<Transfers> getBlockTransfers(String? blockHash) async {
    var res = await _makeRPCCall('chain_get_block_transfers', {
      'block_identifier': blockHash != null ? {'Hash': blockHash} : null
    });

    try {
      var storedValueJson = res;
      var storedValue = Transfers.fromJson(storedValueJson);
      return storedValue;
    } catch (e) {
      rethrow;
    }
  }

  /// Retrieve era information by block hash.
  /// @param blockIdentifier Hex-encoded block hash or height of the block. If not given, the last block added to the chain as known at the given node will be used. If not provided it will retrieve by latest block.
  Future<EraSummary> getEraInfoBySwitchBlock(String? blockHash) async {
    var res = await _makeRPCCall('chain_get_era_info_by_switch_block', {
      'block_identifier': blockHash != null ? {'Hash': blockHash} : null
    });

    try {
      var storedValueJson = res['era_summary'];
      var storedValue = EraSummary.fromJson(storedValueJson);
      return storedValue;
    } catch (e) {
      rethrow;
    }
  }

  /// Retrieve era information by block height
  /// @param blockHeight
  Future<EraSummary> getEraInfoBySwitchBlockHeight(int height) async {
    var res = await _makeRPCCall('chain_get_era_info_by_switch_block', {
      'block_identifier': {'Height': height}
    });

    try {
      var storedValueJson = res['era_summary'];
      var storedValue = EraSummary.fromJson(storedValueJson);
      return storedValue;
    } catch (e) {
      rethrow;
    }
  }

  /// get dictionary item by URef
  /// @param stateRootHash
  /// @param dictionaryItemKey
  /// @param seedUref
  Future<StoredValue> getDictionaryItemByURef(
    String stateRootHash,
    String dictionaryItemKey,
    String seedUref,
  ) async {
    var res = await _makeRPCCall('state_get_dictionary_item', {
      'state_root_hash': stateRootHash,
      'dictionary_identifier': {
        'URef': {
          'seed_uref': seedUref,
          'dictionary_item_key': dictionaryItemKey
        }
      }
    });

    try {
      var storedValueJson = res['stored_value'];
      var storedValue = StoredValue.fromJson(storedValueJson);
      return storedValue;
    } catch (e) {
      rethrow;
    }
  }

  /// get dictionary item by name
  /// @param stateRootHash
  /// @param dictionaryItemKey
  Future<StoredValue> getDictionaryItemByName(
      String stateRootHash,
      String contractHash,
      String dictionaryName,
      String dictionaryItemKey) async {
    var res = await _makeRPCCall('state_get_dictionary_item', {
      'state_root_hash': stateRootHash,
      'dictionary_identifier': {
        'ContractNamedKey': {
          'key': contractHash,
          'dictionary_name': dictionaryName,
          'dictionary_item_key': dictionaryItemKey
        }
      }
    });

    try {
      var storedValueJson = res['stored_value'];
      var storedValue = StoredValue.fromJson(storedValueJson);
      return storedValue;
    } catch (e) {
      rethrow;
    }
  }

  Future<AuctionState> getAunctionStateInfo() async {
    var res = await _makeRPCCall('state_get_auction_info');
    try {
      var auctionState = AuctionState.fromJson(res['auction_state']);
      return auctionState;
    } catch (e) {
      rethrow;
    }
  }
}

/// Exception thrown when an the server returns an error code to an rpc request.
class RPCError implements Exception {
  const RPCError(this.errorCode, this.message, this.data);

  final int errorCode;
  final String message;
  final dynamic data;

  @override
  String toString() {
    return 'RPCError: got code $errorCode with msg "$message".';
  }
}
