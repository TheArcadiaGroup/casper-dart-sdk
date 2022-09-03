// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'casper_service_by_json_rpc.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RpcResult _$RpcResultFromJson(Map<String, dynamic> json) =>
    RpcResult()..apiVersion = json['api_version'] as String;

Map<String, dynamic> _$RpcResultToJson(RpcResult instance) => <String, dynamic>{
      'api_version': instance.apiVersion,
    };

Peer _$PeerFromJson(Map<String, dynamic> json) => Peer(
      json['node_id'] as String,
      json['address'] as String,
    );

Map<String, dynamic> _$PeerToJson(Peer instance) => <String, dynamic>{
      'node_id': instance.nodeId,
      'address': instance.address,
    };

GetPeersResult _$GetPeersResultFromJson(Map<String, dynamic> json) =>
    GetPeersResult(
      (json['peers'] as List<dynamic>)
          .map((e) => Peer.fromJson(e as Map<String, dynamic>))
          .toList(),
    )..apiVersion = json['api_version'] as String;

Map<String, dynamic> _$GetPeersResultToJson(GetPeersResult instance) =>
    <String, dynamic>{
      'api_version': instance.apiVersion,
      'peers': instance.peers.map((e) => e.toJson()).toList(),
    };

LastAddedBlockInfo _$LastAddedBlockInfoFromJson(Map<String, dynamic> json) =>
    LastAddedBlockInfo(
      json['hash'] as String,
      json['timestamp'] as String,
      json['era_id'] as int,
      json['height'] as int,
      json['state_root_hash'] as String,
      json['creator'] as String,
    );

Map<String, dynamic> _$LastAddedBlockInfoToJson(LastAddedBlockInfo instance) =>
    <String, dynamic>{
      'hash': instance.hash,
      'timestamp': instance.timestamp,
      'era_id': instance.eraId,
      'height': instance.height,
      'state_root_hash': instance.stateRootHash,
      'creator': instance.creator,
    };

GetStatusResult _$GetStatusResultFromJson(Map<String, dynamic> json) =>
    GetStatusResult(
      (json['peers'] as List<dynamic>)
          .map((e) => Peer.fromJson(e as Map<String, dynamic>))
          .toList(),
    )
      ..apiVersion = json['api_version'] as String
      ..lastAddedBlockInfo = LastAddedBlockInfo.fromJson(
          json['last_added_block_info'] as Map<String, dynamic>)
      ..buildVersion = json['build_version'] as String;

Map<String, dynamic> _$GetStatusResultToJson(GetStatusResult instance) =>
    <String, dynamic>{
      'api_version': instance.apiVersion,
      'peers': instance.peers.map((e) => e.toJson()).toList(),
      'last_added_block_info': instance.lastAddedBlockInfo.toJson(),
      'build_version': instance.buildVersion,
    };

GetStateRootHashResult _$GetStateRootHashResultFromJson(
        Map<String, dynamic> json) =>
    GetStateRootHashResult(
      json['state_root_hash'] as String,
    )..apiVersion = json['api_version'] as String;

Map<String, dynamic> _$GetStateRootHashResultToJson(
        GetStateRootHashResult instance) =>
    <String, dynamic>{
      'api_version': instance.apiVersion,
      'state_root_hash': instance.stateRootHash,
    };

EffectJson _$EffectJsonFromJson(Map<String, dynamic> json) => EffectJson(
      (json['operations'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      (json['transforms'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$EffectJsonToJson(EffectJson instance) =>
    <String, dynamic>{
      'operations': instance.operations,
      'transforms': instance.transforms,
    };

ExecutionResultBody _$ExecutionResultBodyFromJson(Map<String, dynamic> json) =>
    ExecutionResultBody(
      json['cost'] as String,
      json['error_message'] as String?,
      (json['transfers'] as List<dynamic>).map((e) => e as String).toList(),
      json['effect'] == null
          ? null
          : EffectJson.fromJson(json['effect'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ExecutionResultBodyToJson(ExecutionResultBody instance) {
  final val = <String, dynamic>{
    'cost': instance.cost,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('error_message', instance.errorMessage);
  val['transfers'] = instance.transfers;
  writeNotNull('effect', instance.effect?.toJson());
  return val;
}

ExecutionResult _$ExecutionResultFromJson(Map<String, dynamic> json) =>
    ExecutionResult(
      json['Success'] == null
          ? null
          : ExecutionResultBody.fromJson(
              json['Success'] as Map<String, dynamic>),
      json['Failure'] == null
          ? null
          : ExecutionResultBody.fromJson(
              json['Failure'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ExecutionResultToJson(ExecutionResult instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('Success', instance.success?.toJson());
  writeNotNull('Failure', instance.failure?.toJson());
  return val;
}

JsonExecutionResult _$JsonExecutionResultFromJson(Map<String, dynamic> json) =>
    JsonExecutionResult(
      json['block_hash'] as String,
      ExecutionResult.fromJson(json['result'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$JsonExecutionResultToJson(
        JsonExecutionResult instance) =>
    <String, dynamic>{
      'block_hash': instance.blockHash,
      'result': instance.result.toJson(),
    };

GetDeployResult _$GetDeployResultFromJson(Map<String, dynamic> json) =>
    GetDeployResult(
      JsonDeploy.fromJson(json['deploy'] as Map<String, dynamic>),
    )
      ..apiVersion = json['api_version'] as String
      ..executionResults = (json['execution_results'] as List<dynamic>)
          .map((e) => JsonExecutionResult.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$GetDeployResultToJson(GetDeployResult instance) =>
    <String, dynamic>{
      'api_version': instance.apiVersion,
      'deploy': instance.deploy.toJson(),
      'execution_results':
          instance.executionResults.map((e) => e.toJson()).toList(),
    };

GetBlockResult _$GetBlockResultFromJson(Map<String, dynamic> json) =>
    GetBlockResult(
      json['block'] == null
          ? null
          : JsonBlock.fromJson(json['block'] as Map<String, dynamic>),
    )..apiVersion = json['api_version'] as String;

Map<String, dynamic> _$GetBlockResultToJson(GetBlockResult instance) =>
    <String, dynamic>{
      'api_version': instance.apiVersion,
      'block': instance.block?.toJson(),
    };

JsonSystemTransaction _$JsonSystemTransactionFromJson(
        Map<String, dynamic> json) =>
    JsonSystemTransaction(
      json['Slash'] as String?,
      (json['Reward'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as num),
      ),
    );

Map<String, dynamic> _$JsonSystemTransactionToJson(
        JsonSystemTransaction instance) =>
    <String, dynamic>{
      'Slash': instance.slash,
      'Reward': instance.reward,
    };

JsonDeployHeader _$JsonDeployHeaderFromJson(Map<String, dynamic> json) =>
    JsonDeployHeader(
      json['account'] as String,
      json['timestamp'] as String,
      json['ttl'] as String,
      json['gas_price'] as int,
      json['body_hash'] as String,
      (json['dependencies'] as List<dynamic>).map((e) => e as String).toList(),
      json['chain_name'] as String,
    );

Map<String, dynamic> _$JsonDeployHeaderToJson(JsonDeployHeader instance) =>
    <String, dynamic>{
      'account': instance.account,
      'timestamp': instance.timestamp,
      'ttl': instance.ttl,
      'gas_price': instance.gasPrice,
      'body_hash': instance.bodyHash,
      'dependencies': instance.dependencies,
      'chain_name': instance.chainName,
    };

JsonModuleBytes _$JsonModuleBytesFromJson(Map<String, dynamic> json) =>
    JsonModuleBytes(
      json['module_bytes'] as List<dynamic>,
      json['args'] as List<dynamic>,
    );

Map<String, dynamic> _$JsonModuleBytesToJson(JsonModuleBytes instance) =>
    <String, dynamic>{
      'module_bytes': instance.moduleBytes,
      'args': instance.args,
    };

JsonStoredContractByHash _$JsonStoredContractByHashFromJson(
        Map<String, dynamic> json) =>
    JsonStoredContractByHash(
      json['hash'] as String,
      json['entry_point'] as String,
      json['args'] as List<dynamic>,
    );

Map<String, dynamic> _$JsonStoredContractByHashToJson(
        JsonStoredContractByHash instance) =>
    <String, dynamic>{
      'hash': instance.hash,
      'args': instance.args,
      'entry_point': instance.entryPoint,
    };

JsonStoredContractByName _$JsonStoredContractByNameFromJson(
        Map<String, dynamic> json) =>
    JsonStoredContractByName(
      json['name'] as String,
      json['entry_point'] as String,
      json['args'] as List<dynamic>,
    )..hash = json['hash'] as String;

Map<String, dynamic> _$JsonStoredContractByNameToJson(
        JsonStoredContractByName instance) =>
    <String, dynamic>{
      'name': instance.name,
      'hash': instance.hash,
      'entry_point': instance.entryPoint,
      'args': instance.args,
    };

JsonStoredVersionedContractByName _$JsonStoredVersionedContractByNameFromJson(
        Map<String, dynamic> json) =>
    JsonStoredVersionedContractByName(
      json['name'] as String,
      json['version'] as num?,
      json['entry_point'] as String,
      json['args'] as List<dynamic>,
    );

Map<String, dynamic> _$JsonStoredVersionedContractByNameToJson(
        JsonStoredVersionedContractByName instance) =>
    <String, dynamic>{
      'name': instance.name,
      'version': instance.version,
      'entry_point': instance.entryPoint,
      'args': instance.args,
    };

JsonStoredVersionedContractByHash _$JsonStoredVersionedContractByHashFromJson(
        Map<String, dynamic> json) =>
    JsonStoredVersionedContractByHash(
      json['hash'] as String,
      json['version'] as num?,
      json['entry_point'] as String,
      json['args'] as List<dynamic>,
    );

Map<String, dynamic> _$JsonStoredVersionedContractByHashToJson(
        JsonStoredVersionedContractByHash instance) =>
    <String, dynamic>{
      'hash': instance.hash,
      'version': instance.version,
      'entry_point': instance.entryPoint,
      'args': instance.args,
    };

JsonTransfer _$JsonTransferFromJson(Map<String, dynamic> json) => JsonTransfer(
      json['args'] as List<dynamic>,
    );

Map<String, dynamic> _$JsonTransferToJson(JsonTransfer instance) =>
    <String, dynamic>{
      'args': instance.args,
    };

JsonExecutableDeployItem _$JsonExecutableDeployItemFromJson(
        Map<String, dynamic> json) =>
    JsonExecutableDeployItem()
      ..moduleBytes = json['ModuleBytes'] == null
          ? null
          : ModuleBytes.fromJson(json['ModuleBytes'] as Map<String, dynamic>)
      ..storedContractByHash = json['StoredContractByHash'] == null
          ? null
          : JsonStoredContractByHash.fromJson(
              json['StoredContractByHash'] as Map<String, dynamic>)
      ..storedContractByName = json['StoredContractByName'] == null
          ? null
          : JsonStoredContractByName.fromJson(
              json['StoredContractByName'] as Map<String, dynamic>)
      ..storedVersionedContractByHash =
          json['StoredVersionedContractByHash'] == null
              ? null
              : JsonStoredVersionedContractByHash.fromJson(
                  json['StoredVersionedContractByHash'] as Map<String, dynamic>)
      ..storedVersionedContractByName =
          json['StoredVersionedContractByName'] == null
              ? null
              : JsonStoredVersionedContractByName.fromJson(
                  json['StoredVersionedContractByName'] as Map<String, dynamic>)
      ..transfer = json['Transfer'] == null
          ? null
          : JsonTransfer.fromJson(json['Transfer'] as Map<String, dynamic>);

Map<String, dynamic> _$JsonExecutableDeployItemToJson(
    JsonExecutableDeployItem instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('ModuleBytes', instance.moduleBytes?.toJson());
  writeNotNull('StoredContractByHash', instance.storedContractByHash?.toJson());
  writeNotNull('StoredContractByName', instance.storedContractByName?.toJson());
  writeNotNull('StoredVersionedContractByHash',
      instance.storedVersionedContractByHash?.toJson());
  writeNotNull('StoredVersionedContractByName',
      instance.storedVersionedContractByName?.toJson());
  writeNotNull('Transfer', instance.transfer?.toJson());
  return val;
}

JsonApproval _$JsonApprovalFromJson(Map<String, dynamic> json) => JsonApproval(
      json['signer'] as String,
      json['signature'] as String,
    );

Map<String, dynamic> _$JsonApprovalToJson(JsonApproval instance) =>
    <String, dynamic>{
      'signer': instance.signer,
      'signature': instance.signature,
    };

JsonDeploy _$JsonDeployFromJson(Map<String, dynamic> json) => JsonDeploy(
      json['hash'] as String,
      JsonDeployHeader.fromJson(json['header'] as Map<String, dynamic>),
      JsonExecutableDeployItem.fromJson(
          json['payment'] as Map<String, dynamic>),
      JsonExecutableDeployItem.fromJson(
          json['session'] as Map<String, dynamic>),
      (json['approvals'] as List<dynamic>)
          .map((e) => JsonApproval.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$JsonDeployToJson(JsonDeploy instance) =>
    <String, dynamic>{
      'hash': instance.hash,
      'header': instance.header.toJson(),
      'payment': instance.payment.toJson(),
      'session': instance.session.toJson(),
      'approvals': instance.approvals.map((e) => e.toJson()).toList(),
    };

JsonHeader _$JsonHeaderFromJson(Map<String, dynamic> json) => JsonHeader(
      json['parent_hash'] as String,
      json['state_root_hash'] as String,
      json['body_hash'] as String,
      (json['deploy_hashes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      json['random_bit'] as bool,
      json['timestamp'] as String,
      (json['system_transactions'] as List<dynamic>?)
          ?.map(
              (e) => JsonSystemTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['era_id'] as int,
      json['height'] as int,
      json['proposer'] as String?,
      json['protocol_version'] as String,
      json['switch_block'] as bool?,
    );

Map<String, dynamic> _$JsonHeaderToJson(JsonHeader instance) =>
    <String, dynamic>{
      'parent_hash': instance.parentHash,
      'state_root_hash': instance.stateRootHash,
      'body_hash': instance.bodyHash,
      'deploy_hashes': instance.deployHashes,
      'random_bit': instance.randomBit,
      'switch_block': instance.switchBlock,
      'timestamp': instance.timestamp,
      'system_transactions':
          instance.systemTransactions?.map((e) => e.toJson()).toList(),
      'era_id': instance.eraId,
      'height': instance.height,
      'proposer': instance.proposer,
      'protocol_version': instance.protocolVersion,
    };

JsonBlock _$JsonBlockFromJson(Map<String, dynamic> json) => JsonBlock(
      json['hash'] as String,
      JsonHeader.fromJson(json['header'] as Map<String, dynamic>),
      json['proofs'] as List<dynamic>,
    );

Map<String, dynamic> _$JsonBlockToJson(JsonBlock instance) => <String, dynamic>{
      'hash': instance.hash,
      'header': instance.header.toJson(),
      'proofs': instance.proofs,
    };

BidInfo _$BidInfoFromJson(Map<String, dynamic> json) => BidInfo(
      json['bonding_purse'] as String,
      json['staked_amount'] as String,
      json['delegation_rate'] as num,
      json['funds_locked'] as String?,
    );

Map<String, dynamic> _$BidInfoToJson(BidInfo instance) => <String, dynamic>{
      'bonding_purse': instance.bondingPurse,
      'staked_amount': instance.stakedAmount,
      'delegation_rate': instance.delegationRate,
      'funds_locked': instance.fundsLocked,
    };

ValidatorWeight _$ValidatorWeightFromJson(Map<String, dynamic> json) =>
    ValidatorWeight(
      json['public_key'] as String,
      json['weight'] as String,
    );

Map<String, dynamic> _$ValidatorWeightToJson(ValidatorWeight instance) =>
    <String, dynamic>{
      'public_key': instance.publicKey,
      'weight': instance.weight,
    };

EraSummary _$EraSummaryFromJson(Map<String, dynamic> json) => EraSummary(
      json['block_hash'] as String,
      json['era_id'] as int,
      StoredValue.fromJson(json['stored_value'] as Map<String, dynamic>),
      json['state_root_hash'] as String,
    );

Map<String, dynamic> _$EraSummaryToJson(EraSummary instance) =>
    <String, dynamic>{
      'block_hash': instance.blockHash,
      'era_id': instance.eraId,
      'stored_value': instance.storedValue.toJson(),
      'state_root_hash': instance.stateRootHash,
    };

EraValidators _$EraValidatorsFromJson(Map<String, dynamic> json) =>
    EraValidators(
      json['era_id'] as int,
      (json['validator_weights'] as List<dynamic>)
          .map((e) => ValidatorWeight.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EraValidatorsToJson(EraValidators instance) =>
    <String, dynamic>{
      'era_id': instance.eraId,
      'validator_weights':
          instance.validatorWeights.map((e) => e.toJson()).toList(),
    };

Bid _$BidFromJson(Map<String, dynamic> json) => Bid(
      json['bonding_purse'] as String,
      json['staked_amount'] as String,
      json['delegation_rate'] as num,
      json['inactive'] as bool,
      json['reward'] as String?,
      (json['delegators'] as List<dynamic>)
          .map((e) => Delegators.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BidToJson(Bid instance) => <String, dynamic>{
      'bonding_purse': instance.bondingPurse,
      'staked_amount': instance.stakedAmount,
      'delegation_rate': instance.delegationRate,
      'inactive': instance.inactive,
      'reward': instance.reward,
      'delegators': instance.delegators.map((e) => e.toJson()).toList(),
    };

Delegators _$DelegatorsFromJson(Map<String, dynamic> json) => Delegators(
      json['bonding_purse'] as String,
      json['delegatee'] as String,
      json['staked_amount'] as String,
      json['public_key'] as String,
    );

Map<String, dynamic> _$DelegatorsToJson(Delegators instance) =>
    <String, dynamic>{
      'bonding_purse': instance.bondingPurse,
      'delegatee': instance.delegatee,
      'staked_amount': instance.stakedAmount,
      'public_key': instance.publicKey,
    };

DelegatorInfo _$DelegatorInfoFromJson(Map<String, dynamic> json) =>
    DelegatorInfo(
      json['bonding_purse'] as String,
      json['delegatee'] as String,
      json['reward'] as String,
    )..stakedAmount = json['staked_amount'] as String;

Map<String, dynamic> _$DelegatorInfoToJson(DelegatorInfo instance) =>
    <String, dynamic>{
      'bonding_purse': instance.bondingPurse,
      'delegatee': instance.delegatee,
      'reward': instance.reward,
      'staked_amount': instance.stakedAmount,
    };

ValidatorBid _$ValidatorBidFromJson(Map<String, dynamic> json) => ValidatorBid(
      json['public_key'] as String,
      Bid.fromJson(json['bid'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ValidatorBidToJson(ValidatorBid instance) =>
    <String, dynamic>{
      'public_key': instance.publicKey,
      'bid': instance.bid.toJson(),
    };

AuctionState _$AuctionStateFromJson(Map<String, dynamic> json) => AuctionState(
      json['state_root_hash'] as String,
      json['block_height'] as int,
      (json['era_validators'] as List<dynamic>)
          .map((e) => EraValidators.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['bids'] as List<dynamic>)
          .map((e) => ValidatorBid.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AuctionStateToJson(AuctionState instance) =>
    <String, dynamic>{
      'state_root_hash': instance.stateRootHash,
      'block_height': instance.blockHeight,
      'era_validators': instance.eraValidators.map((e) => e.toJson()).toList(),
      'bids': instance.bids.map((e) => e.toJson()).toList(),
    };

ValidatorsInfoResult _$ValidatorsInfoResultFromJson(
        Map<String, dynamic> json) =>
    ValidatorsInfoResult(
      AuctionState.fromJson(json['auction_state'] as Map<String, dynamic>),
    )..apiVersion = json['api_version'] as String;

Map<String, dynamic> _$ValidatorsInfoResultToJson(
        ValidatorsInfoResult instance) =>
    <String, dynamic>{
      'api_version': instance.apiVersion,
      'auction_state': instance.auctionState.toJson(),
    };
