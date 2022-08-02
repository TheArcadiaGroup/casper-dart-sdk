import 'package:casper_dart_sdk/classes/CLValue/utils.dart';
import 'package:json_annotation/json_annotation.dart';
import 'CLValue/abstract.dart';

part 'stored_value.g.dart';

@JsonSerializable(explicitToJson: true)
class NamedKey {
  late String name;
  late String key;

  NamedKey(this.name, this.key);

  factory NamedKey.fromJson(Map<String, dynamic> json) =>
      _$NamedKeyFromJson(json);
  Map<String, dynamic> toJson() => _$NamedKeyToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AssociatedKey {
  @JsonKey(name: 'account_hash')
  late String accountHash;
  late int weight;

  AssociatedKey(this.accountHash, this.weight);

  factory AssociatedKey.fromJson(Map<String, dynamic> json) =>
      _$AssociatedKeyFromJson(json);
  Map<String, dynamic> toJson() => _$AssociatedKeyToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ActionThresholds {
  late int deployment;

  @JsonKey(name: 'key_management')
  late int keyManagement;

  ActionThresholds(this.deployment, this.keyManagement);

  factory ActionThresholds.fromJson(Map<String, dynamic> json) =>
      _$ActionThresholdsFromJson(json);
  Map<String, dynamic> toJson() => _$ActionThresholdsToJson(this);
}

@JsonSerializable(explicitToJson: true)
class AccountJson {
  @JsonKey(name: 'account_hash')
  late String accountHash;

  @JsonKey(name: 'named_keys')
  late List<NamedKey> namedKeys;

  @JsonKey(name: 'main_purse')
  late String mainPurse;

  @JsonKey(name: 'associated_keys')
  late List<AssociatedKey> associatedKeys;

  @JsonKey(name: 'action_thresholds')
  late ActionThresholds actionThresholds;

  AccountJson(this.accountHash, this.namedKeys, this.mainPurse,
      this.associatedKeys, this.actionThresholds);

  factory AccountJson.fromJson(Map<String, dynamic> json) =>
      _$AccountJsonFromJson(json);
  Map<String, dynamic> toJson() => _$AccountJsonToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TransferJson {
  @JsonKey(name: 'deploy_hash')
  late String deployHash;
  late String from;
  late String source;
  late String target;
  late String amount;
  late String gas;
  late int? id;

  TransferJson(this.deployHash, this.from, this.source, this.target,
      this.amount, this.gas);

  factory TransferJson.fromJson(Map<String, dynamic> json) =>
      _$TransferJsonFromJson(json);
  Map<String, dynamic> toJson() => _$TransferJsonToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Transfers {
  late List<TransferJson> transfers;

  Transfers(this.transfers);

  factory Transfers.fromJson(Map<String, dynamic> json) =>
      _$TransfersFromJson(json);
  Map<String, dynamic> toJson() => _$TransfersToJson(this);
}

@JsonSerializable(explicitToJson: true)
class DeployInfoJson {
  @JsonKey(name: 'deploy_hash')
  late String deployHash;
  late List<String> transfers;
  late String from;
  late String source;

  // Gas cost of executing the Deploy.
  late String gas;

  DeployInfoJson(this.deployHash, this.transfers, this.from, this.source);

  factory DeployInfoJson.fromJson(Map<String, dynamic> json) =>
      _$DeployInfoJsonFromJson(json);
  Map<String, dynamic> toJson() => _$DeployInfoJsonToJson(this);
}

/// Info about a seigniorage allocation for a validator
@JsonSerializable(explicitToJson: true)
class Validator {
  @JsonKey(name: 'validator_public_key')
  late String validatorPublicKey;

  // Allocated amount
  late String amount;

  Validator(this.validatorPublicKey, this.amount);

  factory Validator.fromJson(Map<String, dynamic> json) =>
      _$ValidatorFromJson(json);
  Map<String, dynamic> toJson() => _$ValidatorToJson(this);
}

/// Info about a seigniorage allocation for a delegator
@JsonSerializable(explicitToJson: true)
class Delegator {
  @JsonKey(name: 'delegator_public_key')
  late String delegatorPublicKey;

  @JsonKey(name: 'validator_public_key')
  late String validatorPublicKey;

  // Allocated amount
  late String amount;

  Delegator(this.delegatorPublicKey, this.validatorPublicKey, this.amount);

  factory Delegator.fromJson(Map<String, dynamic> json) =>
      _$DelegatorFromJson(json);
  Map<String, dynamic> toJson() => _$DelegatorToJson(this);
}

/// Information about a seigniorage allocation
@JsonSerializable(explicitToJson: true)
class SeigniorageAllocation {
  late Validator? validator;
  late Delegator? delegator;

  SeigniorageAllocation(this.validator, this.delegator);

  factory SeigniorageAllocation.fromJson(Map<String, dynamic> json) =>
      _$SeigniorageAllocationFromJson(json);
  Map<String, dynamic> toJson() => _$SeigniorageAllocationToJson(this);
}

/// Auction metadata. Intended to be recorded at each era.
@JsonSerializable(explicitToJson: true)
class EraInfoJson {
  @JsonKey(name: 'seigniorage_allocations')
  late List<SeigniorageAllocation> seigniorageAllocations;

  EraInfoJson(this.seigniorageAllocations);

  factory EraInfoJson.fromJson(Map<String, dynamic> json) =>
      _$EraInfoJsonFromJson(json);
  Map<String, dynamic> toJson() => _$EraInfoJsonToJson(this);
}

/// Named CLType arguments
@JsonSerializable(explicitToJson: true)
class NamedCLTypeArg {
  late String name;

  @JsonKey(name: 'cl_type', fromJson: _getCLType, toJson: _clTypeToJSON)
  late CLType clType;

  static CLType _getCLType(String clType) {
    return matchTypeToCLType(clType);
  }

  static String _clTypeToJSON(CLType clType) {
    return clType.toJson();
  }

  NamedCLTypeArg(this.name, this.clType);

  factory NamedCLTypeArg.fromJson(Map<String, dynamic> json) =>
      _$NamedCLTypeArgFromJson(json);
  Map<String, dynamic> toJson() => _$NamedCLTypeArgToJson(this);
}

/// Entry point metadata
@JsonSerializable(explicitToJson: true)
class EntryPoint {
  late String access;

  @JsonKey(name: 'entry_point_type')
  late String entryPointType;
  late String name;

  @JsonKey(name: 'ret', fromJson: _getCLType, toJson: _clTypeToJSON)
  late CLType ret;
  late List<NamedCLTypeArg> args;

  static CLType _getCLType(String clType) {
    return matchTypeToCLType(clType);
  }

  static String _clTypeToJSON(CLType clType) {
    return clType.toJson();
  }

  EntryPoint(this.access, this.entryPointType, this.name, this.ret, this.args);

  factory EntryPoint.fromJson(Map<String, dynamic> json) =>
      _$EntryPointFromJson(json);
  Map<String, dynamic> toJson() => _$EntryPointToJson(this);
}

/// Contract metadata.
@JsonSerializable(explicitToJson: true)
class ContractMetadataJson {
  @JsonKey(name: 'contract_package_hash')
  late String contractPackageHash;

  @JsonKey(name: 'contract_wasm_hash')
  late String contractWasmHash;

  @JsonKey(name: 'entry_points')
  late List<EntryPoint>? entrypoints;

  @JsonKey(name: 'protocol_version')
  late String protocolVersion;

  @JsonKey(name: 'named_keys')
  late List<NamedKey>? namedKeys;

  ContractMetadataJson(this.contractPackageHash, this.contractWasmHash,
      this.entrypoints, this.protocolVersion, this.namedKeys);

  factory ContractMetadataJson.fromJson(Map<String, dynamic> json) =>
      _$ContractMetadataJsonFromJson(json);
  Map<String, dynamic> toJson() => _$ContractMetadataJsonToJson(this);
}

/// Contract Version.
@JsonSerializable(explicitToJson: true)
class ContractVersionJson {
  @JsonKey(name: 'protocol_version_major')
  late int protocolVersionMajor;

  @JsonKey(name: 'contract_version')
  late int contractVersion;

  @JsonKey(name: 'contract_hash')
  late int contractHash;

  ContractVersionJson(
      this.protocolVersionMajor, this.contractVersion, this.contractHash);

  factory ContractVersionJson.fromJson(Map<String, dynamic> json) =>
      _$ContractVersionJsonFromJson(json);
  Map<String, dynamic> toJson() => _$ContractVersionJsonToJson(this);
}

/// Disabled Version.
@JsonSerializable(explicitToJson: true)
class DisabledVersionJson {
  @JsonKey(name: 'protocol_version_major')
  late int accessKey;

  @JsonKey(name: 'contract_version')
  late int contractVersion;

  DisabledVersionJson(this.accessKey, this.contractVersion);

  factory DisabledVersionJson.fromJson(Map<String, dynamic> json) =>
      _$DisabledVersionJsonFromJson(json);
  Map<String, dynamic> toJson() => _$DisabledVersionJsonToJson(this);
}

/// Groups.
@JsonSerializable(explicitToJson: true)
class GroupsJson {
  late String group;
  late String keys;

  GroupsJson(this.group, this.keys);

  factory GroupsJson.fromJson(Map<String, dynamic> json) =>
      _$GroupsJsonFromJson(json);
  Map<String, dynamic> toJson() => _$GroupsJsonToJson(this);
}

/// Contract Package.
@JsonSerializable(explicitToJson: true)
class ContractPackageJson {
  @JsonKey(name: 'access_key')
  late String accessKey;
  late List<ContractVersionJson> versions;

  @JsonKey(name: 'disabled_versions')
  late List<DisabledVersionJson> disabledVersions;
  late List<GroupsJson> groups;

  ContractPackageJson(
      this.accessKey, this.versions, this.disabledVersions, this.groups);

  factory ContractPackageJson.fromJson(Map<String, dynamic> json) =>
      _$ContractPackageJsonFromJson(json);
  Map<String, dynamic> toJson() => _$ContractPackageJsonToJson(this);
}

@JsonSerializable(explicitToJson: true)
class StoredValue {
  @JsonKey(name: 'CLValue', fromJson: _getCLValue, toJson: _clValueToJSON)
  late CLValue? clValue;

  // An account
  @JsonKey(name: 'Account')
  late AccountJson? account;

  // A contract's Wasm
  @JsonKey(name: 'ContractWASM')
  late String? contractWASM;

  // Methods and type signatures supported by a contract
  @JsonKey(name: 'Contract')
  late ContractMetadataJson? contract;

  // A contract definition, metadata, and security container
  @JsonKey(name: 'ContractPackage')
  late ContractPackageJson? contractPackage;

  // A record of a transfer
  @JsonKey(name: 'Transfer')
  late TransferJson? transfer;

  // A record of a deploy
  @JsonKey(name: 'DeployInfo')
  late DeployInfoJson? deployInfo;

  @JsonKey(name: 'EraInfoJson')
  late EraInfoJson? eraInfo;

  static CLValue? _getCLValue(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    return CLValueParsers.fromJSON(json).unwrap();
  }

  static String _clValueToJSON(CLValue? clValue) {
    return clValue != null ? clValue.toString() : '';
  }

  StoredValue({
    this.clValue,
    this.account,
    this.contractWASM,
    this.contract,
    this.contractPackage,
    this.transfer,
    this.deployInfo,
    this.eraInfo,
  });

  factory StoredValue.fromJson(Map<String, dynamic> json) =>
      _$StoredValueFromJson(json);
  Map<String, dynamic> toJson() => _$StoredValueToJson(this);
}
