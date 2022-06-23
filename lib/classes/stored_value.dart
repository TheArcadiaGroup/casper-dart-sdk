import 'CLValue/abstract.dart';

class NamedKey {
  late String name;
  late String key;
}

class AssociatedKey {
  late String accountHash;
  late num weight;
}

class ActionThresholds {
  late num deployment;
  late num keyManagement;
}

class AccountJson {
  late String _accountHash;
  late List<NamedKey> namedKeys;
  late String mainPurse;
  late List<AssociatedKey> associatedKeys;
  late ActionThresholds actionThresholds;

  String accountHash() {
    return _accountHash;
  }
}

class TransferJson {
  late String deployHash;
  late String from;
  late String source;
  late String target;
  late String amount;
  late String gas;
  late num id;
}

class Transfers {
  late List<TransferJson> transfers;
}

class DeployInfoJson {
  late String deployHash;
  late List<String> transfers;
  late String from;
  late String source;

  // Gas cost of executing the Deploy.
  late String gas;
}

/// Info about a seigniorage allocation for a validator
class Validator {
  late String validatorPublicKey;

  // Allocated amount
  late String amount;
}

/// Info about a seigniorage allocation for a delegator
class Delegator {
  late String delegatorPublicKey;
  late String validatorPublicKey;

  // Allocated amount
  late String amount;
}

/// Information about a seigniorage allocation
class SeigniorageAllocation {
  late Validator? validator;
  late Delegator? delegator;
}

/// Auction metadata. Intended to be recorded at each era.
class EraInfoJson {
  late List<SeigniorageAllocation> seigniorageAllocations;
}

/// Named CLType arguments
class NamedCLTypeArg {
  late String name;
  late CLType clType;
}

/// Entry point metadata
class EntryPoint {
  late String access;
  late String entryPointType;
  late String name;
  late String ret;
  late List<NamedCLTypeArg> args;
}

/// Contract metadata.
class ContractMetadataJson {
  late String contractPackageHash;
  late String contractWasmHash;
  late List<EntryPoint> entrypoints;
  late String protocolVersion;
  late List<NamedKey> namedKeys;
}

/// Contract Version.
class ContractVersionJson {
  late num protocolVersionMajor;
  late num contractVersion;
  late num contractHash;
}

/// Disabled Version.
class DisabledVersionJson {
  late num accessKey;
  late num contractVersion;
}

/// Groups.
class GroupsJson {
  late String group;
  late String keys;
}

/// Contract Package.
class ContractPackageJson {
  late String accessKey;
  late List<ContractVersionJson> versions;
  late List<DisabledVersionJson> disabledVersions;
  late List<GroupsJson> groups;
}

class StoredValue {
  late CLValue? cLValue;

  // An account
  late AccountJson? account;

  // A contract's Wasm
  late String? contractWASM;

  // Methods and type signatures supported by a contract
  late ContractMetadataJson? contract;

  // A contract definition, metadata, and security container
  late ContractPackageJson? contractPackage;

  // A record of a transfer
  late TransferJson? transfer;

  // A record of a deploy
  late DeployInfoJson? deployInfo;

  late EraInfoJson? eraInfo;
}
