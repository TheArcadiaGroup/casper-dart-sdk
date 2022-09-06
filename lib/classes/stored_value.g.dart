// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stored_value.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NamedKey _$NamedKeyFromJson(Map<String, dynamic> json) => NamedKey(
      json['name'] as String,
      json['key'] as String,
    );

Map<String, dynamic> _$NamedKeyToJson(NamedKey instance) => <String, dynamic>{
      'name': instance.name,
      'key': instance.key,
    };

AssociatedKey _$AssociatedKeyFromJson(Map<String, dynamic> json) =>
    AssociatedKey(
      json['account_hash'] as String,
      json['weight'] as int,
    );

Map<String, dynamic> _$AssociatedKeyToJson(AssociatedKey instance) =>
    <String, dynamic>{
      'account_hash': instance.accountHash,
      'weight': instance.weight,
    };

ActionThresholds _$ActionThresholdsFromJson(Map<String, dynamic> json) =>
    ActionThresholds(
      json['deployment'] as int,
      json['key_management'] as int,
    );

Map<String, dynamic> _$ActionThresholdsToJson(ActionThresholds instance) =>
    <String, dynamic>{
      'deployment': instance.deployment,
      'key_management': instance.keyManagement,
    };

AccountJson _$AccountJsonFromJson(Map<String, dynamic> json) => AccountJson(
      json['account_hash'] as String,
      (json['named_keys'] as List<dynamic>)
          .map((e) => NamedKey.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['main_purse'] as String,
      (json['associated_keys'] as List<dynamic>)
          .map((e) => AssociatedKey.fromJson(e as Map<String, dynamic>))
          .toList(),
      ActionThresholds.fromJson(
          json['action_thresholds'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AccountJsonToJson(AccountJson instance) =>
    <String, dynamic>{
      'account_hash': instance.accountHash,
      'named_keys': instance.namedKeys.map((e) => e.toJson()).toList(),
      'main_purse': instance.mainPurse,
      'associated_keys':
          instance.associatedKeys.map((e) => e.toJson()).toList(),
      'action_thresholds': instance.actionThresholds.toJson(),
    };

TransferJson _$TransferJsonFromJson(Map<String, dynamic> json) => TransferJson(
      json['deploy_hash'] as String,
      json['from'] as String,
      json['source'] as String,
      json['target'] as String,
      json['amount'] as String,
      json['gas'] as String,
    )..id = json['id'] as int?;

Map<String, dynamic> _$TransferJsonToJson(TransferJson instance) =>
    <String, dynamic>{
      'deploy_hash': instance.deployHash,
      'from': instance.from,
      'source': instance.source,
      'target': instance.target,
      'amount': instance.amount,
      'gas': instance.gas,
      'id': instance.id,
    };

Transfers _$TransfersFromJson(Map<String, dynamic> json) => Transfers(
      (json['transfers'] as List<dynamic>)
          .map((e) => TransferJson.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TransfersToJson(Transfers instance) => <String, dynamic>{
      'transfers': instance.transfers.map((e) => e.toJson()).toList(),
    };

DeployInfoJson _$DeployInfoJsonFromJson(Map<String, dynamic> json) =>
    DeployInfoJson(
      json['deploy_hash'] as String,
      (json['transfers'] as List<dynamic>).map((e) => e as String).toList(),
      json['from'] as String,
      json['source'] as String,
    )..gas = json['gas'] as String;

Map<String, dynamic> _$DeployInfoJsonToJson(DeployInfoJson instance) =>
    <String, dynamic>{
      'deploy_hash': instance.deployHash,
      'transfers': instance.transfers,
      'from': instance.from,
      'source': instance.source,
      'gas': instance.gas,
    };

Validator _$ValidatorFromJson(Map<String, dynamic> json) => Validator(
      json['validator_public_key'] as String,
      json['amount'] as String,
    );

Map<String, dynamic> _$ValidatorToJson(Validator instance) => <String, dynamic>{
      'validator_public_key': instance.validatorPublicKey,
      'amount': instance.amount,
    };

Delegator _$DelegatorFromJson(Map<String, dynamic> json) => Delegator(
      json['delegator_public_key'] as String,
      json['validator_public_key'] as String,
      json['amount'] as String,
    );

Map<String, dynamic> _$DelegatorToJson(Delegator instance) => <String, dynamic>{
      'delegator_public_key': instance.delegatorPublicKey,
      'validator_public_key': instance.validatorPublicKey,
      'amount': instance.amount,
    };

SeigniorageAllocation _$SeigniorageAllocationFromJson(
        Map<String, dynamic> json) =>
    SeigniorageAllocation(
      json['validator'] == null
          ? null
          : Validator.fromJson(json['validator'] as Map<String, dynamic>),
      json['delegator'] == null
          ? null
          : Delegator.fromJson(json['delegator'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SeigniorageAllocationToJson(
        SeigniorageAllocation instance) =>
    <String, dynamic>{
      'validator': instance.validator?.toJson(),
      'delegator': instance.delegator?.toJson(),
    };

EraInfoJson _$EraInfoJsonFromJson(Map<String, dynamic> json) => EraInfoJson(
      (json['seigniorage_allocations'] as List<dynamic>)
          .map((e) => SeigniorageAllocation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EraInfoJsonToJson(EraInfoJson instance) =>
    <String, dynamic>{
      'seigniorage_allocations':
          instance.seigniorageAllocations.map((e) => e.toJson()).toList(),
    };

NamedCLTypeArg _$NamedCLTypeArgFromJson(Map<String, dynamic> json) =>
    NamedCLTypeArg(
      json['name'] as String,
      NamedCLTypeArg._getCLType(json['cl_type']),
    );

Map<String, dynamic> _$NamedCLTypeArgToJson(NamedCLTypeArg instance) =>
    <String, dynamic>{
      'name': instance.name,
      'cl_type': NamedCLTypeArg._clTypeToJSON(instance.clType),
    };

EntryPoint _$EntryPointFromJson(Map<String, dynamic> json) => EntryPoint(
      json['access'],
      json['entry_point_type'] as String,
      json['name'] as String,
      EntryPoint._getCLType(json['ret']),
      (json['args'] as List<dynamic>)
          .map((e) => NamedCLTypeArg.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EntryPointToJson(EntryPoint instance) =>
    <String, dynamic>{
      'access': instance.access,
      'entry_point_type': instance.entryPointType,
      'name': instance.name,
      'ret': EntryPoint._clTypeToJSON(instance.ret),
      'args': instance.args.map((e) => e.toJson()).toList(),
    };

ContractMetadataJson _$ContractMetadataJsonFromJson(
        Map<String, dynamic> json) =>
    ContractMetadataJson(
      json['contract_package_hash'] as String,
      json['contract_wasm_hash'] as String,
      (json['entry_points'] as List<dynamic>?)
          ?.map((e) => EntryPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['protocol_version'] as String,
      (json['named_keys'] as List<dynamic>?)
          ?.map((e) => NamedKey.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ContractMetadataJsonToJson(
        ContractMetadataJson instance) =>
    <String, dynamic>{
      'contract_package_hash': instance.contractPackageHash,
      'contract_wasm_hash': instance.contractWasmHash,
      'entry_points': instance.entrypoints?.map((e) => e.toJson()).toList(),
      'protocol_version': instance.protocolVersion,
      'named_keys': instance.namedKeys?.map((e) => e.toJson()).toList(),
    };

ContractVersionJson _$ContractVersionJsonFromJson(Map<String, dynamic> json) =>
    ContractVersionJson(
      json['protocol_version_major'] as int,
      json['contract_version'] as int,
      json['contract_hash'] as String,
    );

Map<String, dynamic> _$ContractVersionJsonToJson(
        ContractVersionJson instance) =>
    <String, dynamic>{
      'protocol_version_major': instance.protocolVersionMajor,
      'contract_version': instance.contractVersion,
      'contract_hash': instance.contractHash,
    };

DisabledVersionJson _$DisabledVersionJsonFromJson(Map<String, dynamic> json) =>
    DisabledVersionJson(
      json['protocol_version_major'] as int,
      json['contract_version'] as int,
    );

Map<String, dynamic> _$DisabledVersionJsonToJson(
        DisabledVersionJson instance) =>
    <String, dynamic>{
      'protocol_version_major': instance.accessKey,
      'contract_version': instance.contractVersion,
    };

GroupsJson _$GroupsJsonFromJson(Map<String, dynamic> json) => GroupsJson(
      json['group'] as String,
      json['keys'] as String,
    );

Map<String, dynamic> _$GroupsJsonToJson(GroupsJson instance) =>
    <String, dynamic>{
      'group': instance.group,
      'keys': instance.keys,
    };

ContractPackageJson _$ContractPackageJsonFromJson(Map<String, dynamic> json) =>
    ContractPackageJson(
      json['access_key'] as String,
      (json['versions'] as List<dynamic>)
          .map((e) => ContractVersionJson.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['disabled_versions'] as List<dynamic>)
          .map((e) => DisabledVersionJson.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['groups'] as List<dynamic>)
          .map((e) => GroupsJson.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ContractPackageJsonToJson(
        ContractPackageJson instance) =>
    <String, dynamic>{
      'access_key': instance.accessKey,
      'versions': instance.versions.map((e) => e.toJson()).toList(),
      'disabled_versions':
          instance.disabledVersions.map((e) => e.toJson()).toList(),
      'groups': instance.groups.map((e) => e.toJson()).toList(),
    };

StoredValue _$StoredValueFromJson(Map<String, dynamic> json) => StoredValue(
      clValue:
          StoredValue._getCLValue(json['CLValue'] as Map<String, dynamic>?),
      account: json['Account'] == null
          ? null
          : AccountJson.fromJson(json['Account'] as Map<String, dynamic>),
      contractWASM: json['ContractWASM'] as String?,
      contract: json['Contract'] == null
          ? null
          : ContractMetadataJson.fromJson(
              json['Contract'] as Map<String, dynamic>),
      contractPackage: json['ContractPackage'] == null
          ? null
          : ContractPackageJson.fromJson(
              json['ContractPackage'] as Map<String, dynamic>),
      transfer: json['Transfer'] == null
          ? null
          : TransferJson.fromJson(json['Transfer'] as Map<String, dynamic>),
      deployInfo: json['DeployInfo'] == null
          ? null
          : DeployInfoJson.fromJson(json['DeployInfo'] as Map<String, dynamic>),
      eraInfo: json['EraInfoJson'] == null
          ? null
          : EraInfoJson.fromJson(json['EraInfoJson'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StoredValueToJson(StoredValue instance) =>
    <String, dynamic>{
      'CLValue': StoredValue._clValueToJSON(instance.clValue),
      'Account': instance.account?.toJson(),
      'ContractWASM': instance.contractWASM,
      'Contract': instance.contract?.toJson(),
      'ContractPackage': instance.contractPackage?.toJson(),
      'Transfer': instance.transfer?.toJson(),
      'DeployInfo': instance.deployInfo?.toJson(),
      'EraInfoJson': instance.eraInfo?.toJson(),
    };
