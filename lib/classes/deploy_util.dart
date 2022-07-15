import 'package:casper_dart_sdk/classes/CLValue/numeric.dart';
import 'package:casper_dart_sdk/classes/CLValue/option.dart';
import 'package:duration/duration.dart';
import 'package:duration/locale.dart';
import 'package:collection/collection.dart';
import 'package:pinenacl/digests.dart';

import 'package:json_annotation/json_annotation.dart';
import 'package:oxidized/oxidized.dart';
import 'package:pinenacl/ed25519.dart';

import 'CLValue/abstract.dart';
import 'CLValue/builders.dart';
import 'CLValue/constants.dart';
import 'CLValue/public_key.dart';
import 'CLValue/uref.dart';
import 'bignumber.dart';
import 'byte_converters.dart';
import 'casper_client.dart';
import 'conversions.dart';
import 'keys.dart' as keys;
import 'runtime_args.dart';

part 'deploy_util.g.dart';

String byteArrayJsonSerializer(Uint8List bytes) {
  return base16Encode(bytes);
}

Uint8List byteArrayJsonDeserializer(String str) {
  return base16Decode(str);
}

class ShortEnDurationLocale extends EnglishDurationLocale {
  @override
  String day(int amount, [bool abbreviated = true]) {
    return 'day';
  }

  @override
  String hour(int amount, [bool abbreviated = true]) {
    return 'h';
  }

  @override
  String minute(int amount, [bool abbreviated = true]) {
    return 'm';
  }

  @override
  String second(int amount, [bool abbreviated = true]) {
    return 's';
  }

  @override
  String millisecond(int amount, [bool abbreviated = true]) {
    return 'ms';
  }
}

/// Returns a humanizer duration
/// @param ttl in milliseconds
String humanizerTTL(int ttl) {
  var duration = Duration(milliseconds: ttl);
  return prettyDuration(duration, locale: ShortEnDurationLocale(), spacer: '');
}

int dehumanizeUnit(String s) {
  if (s.contains('ms')) {
    return int.parse(s.replaceAll('ms', ''));
  }
  if (s.contains('s') && !s.contains('m')) {
    return int.parse(s.replaceAll('s', '')) * 1000;
  }
  if (s.contains('m') && !s.contains('s')) {
    return int.parse(s.replaceAll('m', '')) * 60 * 1000;
  }
  if (s.contains('h')) {
    return int.parse(s.replaceAll('h', '')) * 60 * 60 * 1000;
  }
  if (s.contains('day')) {
    return int.parse(s.replaceAll('day', '')) * 24 * 60 * 60 * 1000;
  }
  throw Exception('Unsuported TTL unit');
}

int dehumanizerTTL(String ttl) {
  var strArray = ttl.split(' ');
  List<int> units = List.empty(growable: true);

  for (var i = 0; i < strArray.length; i++) {
    var t = dehumanizeUnit(strArray[i]);
    units.add(t);
  }

  return units.reduce((value, element) => (value + element));
}

class UniqAddress {
  late CLPublicKey publicKey;
  late BigNumber transferId;

  UniqAddress(this.publicKey, this.transferId);

  @override

  /// Returns string in format "accountHex-transferIdHex"
  /// @param ttl in humanized string
  String toString() {
    return '${publicKey.toHex()}-${transferId.toHexString()}';
  }

  /// Builds UniqAddress from string
  /// @param value value returned from UniqAddress.toString()
  static UniqAddress fromString(String value) {
    var parts = value.split('-');
    var accountHex = parts[0];
    var transferHex = parts[1];
    var publicKey = CLPublicKey.fromHex(accountHex);
    return UniqAddress(publicKey, BigNumber.from(transferHex));
  }
}

@JsonSerializable(explicitToJson: true)
class DeployHeader implements ToBytes {
  @JsonKey(fromJson: fromHex, toJson: toHex)
  late CLPublicKey account;

  @JsonKey(fromJson: timestampFromJson, toJson: timestampToJson)
  late int timestamp;

  @JsonKey(fromJson: dehumanizerTTL, toJson: humanizerTTL)
  late int ttl;

  @JsonKey(name: 'gas_price')
  late int gasPrice;

  @JsonKey(
      name: 'body_hash',
      fromJson: byteArrayJsonDeserializer,
      toJson: byteArrayJsonSerializer)
  late Uint8List bodyHash;

  @JsonKey(fromJson: dependenciesFromJson, toJson: dependenciesToJson)
  late List<Uint8List> dependencies;

  @JsonKey(name: 'chain_name')
  late String chainName;

  static String toHex(CLPublicKey account) {
    return account.toHex();
  }

  static CLPublicKey fromHex(String hexStr) {
    return CLPublicKey.fromHex(hexStr);
  }

  static int timestampFromJson(String json) {
    return DateTime.parse(json).millisecondsSinceEpoch;
  }

  static String timestampToJson(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true)
        .toIso8601String();
  }

  static List<Uint8List> dependenciesFromJson(List<dynamic> json) {
    List<Uint8List> result = List.empty(growable: true);
    for (var i = 0; i < json.length; i++) {
      result.add(byteArrayJsonDeserializer(json[i]));
    }
    return result;
  }

  static List<String> dependenciesToJson(List<Uint8List> list) {
    List<String> result = List.empty(growable: true);
    for (var i = 0; i < list.length; i++) {
      result.add(byteArrayJsonSerializer(list[i]));
    }
    return result;
  }

  @override
  Result<Uint8List, CLErrorCodes> toBytes() {
    List<DeployHash> deployHashList = List.empty(growable: true);
    for (var i = 0; i < dependencies.length; i++) {
      deployHashList.add(DeployHash(dependencies[i]));
    }
    return Ok(Uint8List.fromList([
      ...CLValueParsers.toBytes(account).unwrap(),
      ...toBytesU64(timestamp),
      ...toBytesU64(ttl),
      ...toBytesU64(gasPrice),
      ...bodyHash,
      ...toBytesVector(deployHashList),
      ...toBytesString(chainName)
    ]));
  }

  DeployHeader(this.account, this.timestamp, this.ttl, this.gasPrice,
      this.bodyHash, this.dependencies, this.chainName);

  factory DeployHeader.fromJson(Map<String, dynamic> json) =>
      _$DeployHeaderFromJson(json);
  Map<String, dynamic> toJson() => _$DeployHeaderToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other.runtimeType != runtimeType) return false;

    other as DeployHeader;
    return toJson().toString() == other.toJson().toString();
  }

  @override
  int get hashCode => Object.hash(bodyHash, account);
}

/// The cryptographic hash of a Deploy.
class DeployHash implements ToBytes {
  late Uint8List hash;

  DeployHash(this.hash);

  @override
  Result<Uint8List, CLErrorCodes> toBytes() {
    return Ok(hash);
  }
}

/// A struct containing a signature and the public key of the signer.
@JsonSerializable(explicitToJson: true)
class Approval {
  late String signer;
  late String signature;

  Approval(this.signer, this.signature);

  factory Approval.fromJson(Map<String, dynamic> json) =>
      _$ApprovalFromJson(json);
  Map<String, dynamic> toJson() => _$ApprovalToJson(this);
}

abstract class ExecutableDeployItemInternal implements ToBytes {
  abstract int tag;

  abstract RuntimeArgs args;

  @override
  Result<Uint8List, CLErrorCodes> toBytes();

  CLValue? getArgByName(String name) {
    return args.args.containsKey(name) ? args.args[name] : null;
  }

  void setArg(String name, CLValue value) {
    args.args[name] = value;
  }
}

RuntimeArgs desRuntimeArgs(List<dynamic> data) {
  List<List<dynamic>> list = [];
  for (var item in data) {
    List<dynamic> subList = [];
    subList.add(item[0]);
    subList.add(item[1]);

    list.add(subList);
  }
  return RuntimeArgs.fromJson({'args': list});
}

List<List<dynamic>> serRuntimeArgs(RuntimeArgs ra) {
  List<List<dynamic>> result = List.empty(growable: true);
  var raSerialzier = ra.args;
  for (var arg in raSerialzier.entries) {
    var subList = List.empty(growable: true);

    subList.addAll([arg.key, CLValueParsers.toJSON(arg.value).unwrap()]);
    result.add(subList);
  }
  return result;
}

@JsonSerializable(explicitToJson: true)
class ModuleBytes extends ExecutableDeployItemInternal {
  @override
  @JsonKey(ignore: true)
  int tag = 0;

  @JsonKey(
      name: 'module_bytes',
      fromJson: byteArrayJsonDeserializer,
      toJson: byteArrayJsonSerializer)
  late Uint8List moduleBytes;

  @JsonKey(fromJson: desRuntimeArgs, toJson: serRuntimeArgs)
  @override
  late RuntimeArgs args;

  ModuleBytes(this.moduleBytes, this.args);

  @override
  Result<Uint8List, CLErrorCodes> toBytes() {
    return Ok(Uint8List.fromList([
      ...Uint8List.fromList([tag]),
      ...toBytesArrayU8(moduleBytes),
      ...args.toBytes().unwrap()
    ]));
  }

  factory ModuleBytes.fromJson(Map<String, dynamic> json) {
    json['tag'] = 0;
    return _$ModuleBytesFromJson(json);
  }
  Map<String, dynamic> toJson() => _$ModuleBytesToJson(this);
}

@JsonSerializable(explicitToJson: true)
class StoredContractByHash extends ExecutableDeployItemInternal {
  @override
  @JsonKey(ignore: true)
  int tag = 1;

  @JsonKey(fromJson: desRuntimeArgs, toJson: serRuntimeArgs)
  @override
  late RuntimeArgs args;

  @JsonKey(fromJson: byteArrayJsonDeserializer, toJson: byteArrayJsonSerializer)
  late Uint8List hash;

  @JsonKey(name: 'entry_point')
  late String entryPoint;

  StoredContractByHash(this.hash, this.entryPoint, this.args);

  @override
  Result<Uint8List, CLErrorCodes> toBytes() {
    return Ok(Uint8List.fromList([
      ...Uint8List.fromList([tag]),
      ...hash,
      ...toBytesString(entryPoint),
      ...args.toBytes().unwrap()
    ]));
  }

  factory StoredContractByHash.fromJson(Map<String, dynamic> json) {
    json['tag'] = 1;
    return _$StoredContractByHashFromJson(json);
  }
  Map<String, dynamic> toJson() => _$StoredContractByHashToJson(this);
}

@JsonSerializable(explicitToJson: true)
class StoredContractByName extends ExecutableDeployItemInternal {
  @override
  @JsonKey(ignore: true)
  int tag = 2;

  late String name;

  @JsonKey(name: 'entry_point')
  late String entryPoint;

  @JsonKey(fromJson: desRuntimeArgs, toJson: serRuntimeArgs)
  @override
  late RuntimeArgs args;

  StoredContractByName(this.name, this.entryPoint, this.args);

  @override
  Result<Uint8List, CLErrorCodes> toBytes() {
    return Ok(Uint8List.fromList([
      ...Uint8List.fromList([tag]),
      ...toBytesString(name),
      ...toBytesString(entryPoint),
      ...args.toBytes().unwrap()
    ]));
  }

  factory StoredContractByName.fromJson(Map<String, dynamic> json) {
    json['tag'] = 2;
    return _$StoredContractByNameFromJson(json);
  }
  Map<String, dynamic> toJson() => _$StoredContractByNameToJson(this);
}

@JsonSerializable(explicitToJson: true)
class StoredVersionedContractByName extends ExecutableDeployItemInternal {
  @override
  @JsonKey(ignore: true)
  int tag = 4;

  late String name;

  late num? version;

  @JsonKey(name: 'entry_point')
  late String entryPoint;

  @JsonKey(fromJson: desRuntimeArgs, toJson: serRuntimeArgs)
  @override
  late RuntimeArgs args;

  StoredVersionedContractByName(
      this.name, this.version, this.entryPoint, this.args);

  @override
  Result<Uint8List, CLErrorCodes> toBytes() {
    CLOption<CLValue> serializedVersion;
    if (version == null) {
      serializedVersion = CLOption(const None<CLValue>(), CLU32Type());
    } else {
      serializedVersion = CLOption(Some(CLU32(version)));
    }
    return Ok(Uint8List.fromList([
      ...Uint8List.fromList([tag]),
      ...toBytesString(name),
      ...CLValueParsers.toBytes(serializedVersion).unwrap(),
      ...toBytesString(entryPoint),
      ...args.toBytes().unwrap()
    ]));
  }

  factory StoredVersionedContractByName.fromJson(Map<String, dynamic> json) {
    json['tag'] = 4;
    return _$StoredVersionedContractByNameFromJson(json);
  }
  Map<String, dynamic> toJson() => _$StoredVersionedContractByNameToJson(this);
}

@JsonSerializable(explicitToJson: true)
class StoredVersionedContractByHash extends ExecutableDeployItemInternal {
  @override
  @JsonKey(ignore: true)
  int tag = 3;

  @JsonKey(fromJson: byteArrayJsonDeserializer, toJson: byteArrayJsonSerializer)
  late Uint8List hash;

  late num? version;

  @JsonKey(name: 'entry_point')
  late String entryPoint;

  @JsonKey(fromJson: desRuntimeArgs, toJson: serRuntimeArgs)
  @override
  late RuntimeArgs args;

  StoredVersionedContractByHash(
      this.hash, this.version, this.entryPoint, this.args);

  @override
  Result<Uint8List, CLErrorCodes> toBytes() {
    CLOption<CLValue> serializedVersion;
    if (version == null) {
      serializedVersion = CLOption(const None<CLValue>(), CLU32Type());
    } else {
      serializedVersion = CLOption(Some(CLU32(version)));
    }
    return Ok(Uint8List.fromList([
      ...Uint8List.fromList([tag]),
      ...hash,
      ...CLValueParsers.toBytes(serializedVersion).unwrap(),
      ...toBytesString(entryPoint),
      ...args.toBytes().unwrap()
    ]));
  }

  factory StoredVersionedContractByHash.fromJson(Map<String, dynamic> json) {
    json['tag'] = 3;
    return _$StoredVersionedContractByHashFromJson(json);
  }
  Map<String, dynamic> toJson() => _$StoredVersionedContractByHashToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Transfer extends ExecutableDeployItemInternal {
  @override
  @JsonKey(ignore: true)
  int tag = 5;

  @JsonKey(fromJson: desRuntimeArgs, toJson: serRuntimeArgs)
  @override
  late RuntimeArgs args;

  Transfer(this.args);

  @override
  Result<Uint8List, CLErrorCodes> toBytes() {
    return Ok(Uint8List.fromList([
      ...Uint8List.fromList([tag]),
      ...args.toBytes().unwrap()
    ]));
  }

  factory Transfer.fromJson(Map<String, dynamic> json) {
    json['tag'] = 5;
    return _$TransferFromJson(json);
  }
  Map<String, dynamic> toJson() => _$TransferToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ExecutableDeployItem implements ToBytes {
  @JsonKey(name: 'ModuleBytes', includeIfNull: false)
  ModuleBytes? moduleBytes;

  @JsonKey(name: 'StoredContractByHash', includeIfNull: false)
  StoredContractByHash? storedContractByHash;

  @JsonKey(name: 'StoredContractByName', includeIfNull: false)
  StoredContractByName? storedContractByName;

  @JsonKey(name: 'StoredVersionedContractByHash', includeIfNull: false)
  StoredVersionedContractByHash? storedVersionedContractByHash;

  @JsonKey(name: 'StoredVersionedContractByName', includeIfNull: false)
  StoredVersionedContractByName? storedVersionedContractByName;

  @JsonKey(name: 'Transfer', includeIfNull: false)
  Transfer? transfer;

  ExecutableDeployItem();

  factory ExecutableDeployItem.fromJson(Map<String, dynamic> json) =>
      _$ExecutableDeployItemFromJson(json);
  Map<String, dynamic> toJson() => _$ExecutableDeployItemToJson(this);

  @override
  Result<Uint8List, CLErrorCodes> toBytes() {
    if (isModuleBytes()) {
      return moduleBytes!.toBytes();
    } else if (isStoredContractByHash()) {
      return storedContractByHash!.toBytes();
    } else if (isStoredContractByName()) {
      return storedContractByName!.toBytes();
    } else if (isStoredVersionContractByHash()) {
      return storedVersionedContractByHash!.toBytes();
    } else if (isStoredVersionContractByName()) {
      return storedVersionedContractByName!.toBytes();
    } else if (isTransfer()) {
      return transfer!.toBytes();
    }
    throw Exception('failed to serialize ExecutableDeployItemJsonWrapper');
  }

  CLValue? getArgByName(String name) {
    if (isModuleBytes()) {
      return moduleBytes!.getArgByName(name);
    } else if (isStoredContractByHash()) {
      return storedContractByHash!.getArgByName(name);
    } else if (isStoredContractByName()) {
      return storedContractByName!.getArgByName(name);
    } else if (isStoredVersionContractByHash()) {
      return storedVersionedContractByHash!.getArgByName(name);
    } else if (isStoredVersionContractByName()) {
      return storedVersionedContractByName!.getArgByName(name);
    } else if (isTransfer()) {
      return transfer!.getArgByName(name);
    }
    throw Exception('failed to serialize ExecutableDeployItemJsonWrapper');
  }

  void setArg(String name, CLValue value) {
    if (isModuleBytes()) {
      return moduleBytes!.setArg(name, value);
    } else if (isStoredContractByHash()) {
      return storedContractByHash!.setArg(name, value);
    } else if (isStoredContractByName()) {
      return storedContractByName!.setArg(name, value);
    } else if (isStoredVersionContractByHash()) {
      return storedVersionedContractByHash!.setArg(name, value);
    } else if (isStoredVersionContractByName()) {
      return storedVersionedContractByName!.setArg(name, value);
    } else if (isTransfer()) {
      return transfer!.setArg(name, value);
    }
    throw Exception('failed to serialize ExecutableDeployItemJsonWrapper');
  }

  static ExecutableDeployItem fromExecutableDeployItemInternal(
      ExecutableDeployItemInternal item) {
    var result = ExecutableDeployItem();
    switch (item.tag) {
      case 0:
        result.moduleBytes = item as ModuleBytes;
        break;
      case 1:
        result.storedContractByHash = item as StoredContractByHash;
        break;
      case 2:
        result.storedContractByName = item as StoredContractByName;
        break;
      case 3:
        result.storedVersionedContractByHash =
            item as StoredVersionedContractByHash;
        break;
      case 4:
        result.storedVersionedContractByName =
            item as StoredVersionedContractByName;
        break;
      case 5:
        result.transfer = item as Transfer;
        break;
    }
    return result;
  }

  static ExecutableDeployItem newModuleBytes(
      Uint8List moduleBytes, RuntimeArgs args) {
    return ExecutableDeployItem.fromExecutableDeployItemInternal(
        ModuleBytes(moduleBytes, args));
  }

  static ExecutableDeployItem newStoredContractByHash(
      Uint8List hash, String entryPoint, RuntimeArgs args) {
    return ExecutableDeployItem.fromExecutableDeployItemInternal(
        StoredContractByHash(hash, entryPoint, args));
  }

  static ExecutableDeployItem newStoredContractByName(
      String name, String entryPoint, RuntimeArgs args) {
    return ExecutableDeployItem.fromExecutableDeployItemInternal(
        StoredContractByName(name, entryPoint, args));
  }

  static ExecutableDeployItem newStoredVersionContractByHash(
      Uint8List hash, num? version, String entryPoint, RuntimeArgs args) {
    return ExecutableDeployItem.fromExecutableDeployItemInternal(
        StoredVersionedContractByHash(hash, version, entryPoint, args));
  }

  static ExecutableDeployItem newStoredVersionContractByName(
      String name, num? version, String entryPoint, RuntimeArgs args) {
    return ExecutableDeployItem.fromExecutableDeployItemInternal(
        StoredVersionedContractByName(name, version, entryPoint, args));
  }

  /// Constructor for Transfer deploy item.
  /// @param amount The number of motes to transfer
  /// @param target URef of the target purse or the public key of target account. You could generate this public key from accountHex by CLPublicKey.fromHex
  /// @param sourcePurse URef of the source purse. If this is omitted, the main purse of the account creating this \
  /// transfer will be used as the source purse
  /// @param id user-defined transfer id. This parameter is required.
  static ExecutableDeployItem newTransfer(
      BigNumber amount, dynamic target, CLURef? sourcePurse, BigNumber id) {
    var runtimeArgs = RuntimeArgs.fromMap({});
    runtimeArgs.insert('amount', CLValueBuilder.u512(amount));
    if (sourcePurse != null) {
      runtimeArgs.insert('source', sourcePurse);
    }
    if (target is CLURef) {
      runtimeArgs.insert('target', target);
    } else if (target is CLPublicKey) {
      runtimeArgs.insert('target', target);
    } else {
      throw Exception('Please specify target');
    }

    runtimeArgs.insert(
        'id', CLValueBuilder.option(Some(CLU64(id)), CLU64Type()));
    return ExecutableDeployItem.fromExecutableDeployItemInternal(
        Transfer(runtimeArgs));
  }

  /// Constructor for Transfer deploy item without obligatory transfer-id.
  /// @param amount The number of motes to transfer
  /// @param target URef of the target purse or the public key of target account. You could generate this public key from accountHex by PublicKey.fromHex
  /// @param sourcePurse URef of the source purse. If this is omitted, the main purse of the account creating this \
  /// transfer will be used as the source purse
  /// @param id user-defined transfer id. This parameter is optional.
  static ExecutableDeployItem newTransferWithOptionalTransferId(
      BigNumber amount, dynamic target,
      [CLURef? sourcePurse, BigNumber? id]) {
    var runtimeArgs = RuntimeArgs.fromMap({});
    runtimeArgs.insert('amount', CLValueBuilder.u512(amount));
    if (sourcePurse != null) {
      runtimeArgs.insert('source', sourcePurse);
    }
    if (target is CLURef) {
      runtimeArgs.insert('target', target);
    } else if (target is CLPublicKey) {
      runtimeArgs.insert(
          'target', CLValueBuilder.byteArray(target.toAccountHash()));
    } else {
      throw Exception('Please specify target');
    }
    if (id != null) {
      runtimeArgs.insert(
          'id',
          CLValueBuilder.option(
              Some(CLValueBuilder.u64(id)), CLTypeBuilder.u64()));
    } else {
      runtimeArgs.insert('id',
          CLValueBuilder.option(const None<CLValue>(), CLTypeBuilder.u64()));
    }

    return ExecutableDeployItem.fromExecutableDeployItemInternal(
        Transfer(runtimeArgs));
  }

  /// Constructor for Transfer deploy item using UniqAddress.
  /// @param source PublicKey of source account
  /// @param target UniqAddress of target account
  /// @param amount The number of motes to transfer
  /// @param paymentAmount the number of motes paying to execution engine
  /// @param chainName Name of the chain, to avoid the `Deploy` from being accidentally or maliciously included in a different chain.
  /// @param gasPrice Conversion rate between the cost of Wasm opcodes and the motes sent by the payment code.
  /// @param ttl Time that the `Deploy` will remain valid for, in milliseconds. The default value is 1800000, which is 30 minutes
  /// @param sourcePurse URef of the source purse. If this is omitted, the main purse of the account creating this \
  /// transfer will be used as the source purse
  static Deploy newTransferToUniqAddress(
      CLPublicKey source,
      UniqAddress target,
      BigNumber amount,
      BigNumber paymentAmount,
      String chainName,
      CLURef? sourcePurse,
      [int gasPrice = 1,
      ttl = 1800000]) {
    var deployParams = DeployParams(
        source, chainName, gasPrice, ttl, List.empty(growable: true));
    var payment = standardPayment(paymentAmount);
    var session = ExecutableDeployItem.newTransfer(
        amount, target.publicKey, sourcePurse, target.transferId);

    return makeDeploy(deployParams, session, payment);
  }

  bool isModuleBytes() {
    return moduleBytes != null;
  }

  ModuleBytes? asModuleBytes() {
    return moduleBytes;
  }

  bool isStoredContractByHash() {
    return storedContractByHash != null;
  }

  StoredContractByHash? asStoredContractByHash() {
    return storedContractByHash;
  }

  bool isStoredContractByName() {
    return storedContractByName != null;
  }

  StoredContractByName? asStoredContractByName() {
    return storedContractByName;
  }

  bool isStoredVersionContractByName() {
    return storedVersionedContractByName != null;
  }

  StoredVersionedContractByName? asStoredVersionContractByName() {
    return storedVersionedContractByName;
  }

  bool isStoredVersionContractByHash() {
    return storedVersionedContractByHash != null;
  }

  StoredVersionedContractByHash? asStoredVersionContractByHash() {
    return storedVersionedContractByHash;
  }

  bool isTransfer() {
    return transfer != null;
  }

  Transfer? asTransfer() {
    return transfer;
  }
}

@JsonSerializable(explicitToJson: true)
class Deploy {
  @JsonKey(fromJson: byteArrayJsonDeserializer, toJson: byteArrayJsonSerializer)
  late Uint8List hash;

  late DeployHeader header;
  late ExecutableDeployItem payment;
  late ExecutableDeployItem session;
  late List<Approval> approvals;

  ///
  /// @param hash The DeployHash identifying this Deploy
  /// @param header The deployHeader
  /// @param payment The ExecutableDeployItem for payment code.
  /// @param session the ExecutableDeployItem for session code.
  /// @param approvals  An array of signature and public key of the signers, who approve this deploy
  Deploy(this.hash, this.header, this.payment, this.session, this.approvals);

  factory Deploy.fromJson(Map<String, dynamic> json) => _$DeployFromJson(json);
  Map<String, dynamic> toJson() => _$DeployToJson(this);

  bool isTransfer() {
    return session.isTransfer();
  }

  bool isStandardPayment() {
    if (payment.isModuleBytes()) {
      return payment.asModuleBytes() != null
          ? payment.asModuleBytes()!.moduleBytes.isEmpty
          : false;
    }
    return false;
  }

  Future<String> send(String nodeUrl) async {
    var client = CasperClient(nodeUrl);
    var deployHash = client.putDeploy(this);
    return deployHash;
  }

  Deploy sign(List<keys.AsymmetricKey> keys) {
    var signedDeploy = this;
    for (var key in keys) {
      signedDeploy = signDeploy(signedDeploy, key);
    }
    return signedDeploy;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other.runtimeType != runtimeType) return false;

    other as Deploy;
    return toJson().toString() == other.toJson().toString();
  }

  @override
  int get hashCode => Object.hash(hash, header);
}

/// Serialize deployHeader into a array of bytes
/// @param deployHeader
Result<Uint8List, CLErrorCodes> serializeHeader(DeployHeader deployHeader) {
  return deployHeader.toBytes();
}

Uint8List serializeBody(
    ExecutableDeployItem payment, ExecutableDeployItem session) {
  return Uint8List.fromList(
      [...payment.toBytes().unwrap(), ...session.toBytes().unwrap()]);
}

Uint8List serializeApprovals(List<Approval> approvals) {
  var len = toBytesU32(approvals.length);
  var bytes = List.empty(growable: true);

  for (var approval in approvals) {
    var list = Uint8List.fromList([
      ...base16Decode(approval.signer),
      ...base16Decode(approval.signature),
    ]);

    bytes.addAll(list);
  }

  return Uint8List.fromList([
    ...len,
    ...bytes,
  ]);
}

// ignore: constant_identifier_names
enum ContractType { WASM, Hash, Name }

extension ContractTypeExtension on ContractType {
  String get value {
    switch (this) {
      case ContractType.WASM:
        return 'WASM';
      case ContractType.Hash:
        return 'Hash';
      case ContractType.Name:
        return 'Name';
      default:
        return 'WASM';
    }
  }
}

class DeployParams {
  late CLPublicKey accountPublicKey;
  late String chainName;
  late int gasPrice = 1;
  late int ttl = 1800000;
  late List<Uint8List> dependencies;
  int? timestamp;

  /// Container for `Deploy` construction options.
  /// @param accountPublicKey
  /// @param chainName Name of the chain, to avoid the `Deploy` from being accidentally or maliciously included in a different chain.
  /// @param gasPrice Conversion rate between the cost of Wasm opcodes and the motes sent by the payment code.
  /// @param ttl Time that the `Deploy` will remain valid for, in milliseconds. The default value is 1800000, which is 30 minutes
  /// @param dependencies Hex-encoded `Deploy` hashes of deploys which must be executed before this one.
  /// @param timestamp  If `timestamp` is empty, the current time will be used. Note that timestamp is UTC, not local.
  DeployParams(this.accountPublicKey, this.chainName,
      [int? gasPrice,
      int? ttl,
      List<Uint8List>? dependencies,
      int? timestamp]) {
    if (dependencies != null) {
      this.dependencies = dependencies
          .where((d) =>
              dependencies
                  .where((t) =>
                      base16Encode(Uint8List.fromList(d)) ==
                      base16Encode(Uint8List.fromList(t)))
                  .toList()
                  .length <
              2)
          .toList();
    } else {
      this.dependencies = [];
    }
    this.timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;
  }
}

/// Makes Deploy message
Deploy makeDeploy(DeployParams deployParams, ExecutableDeployItem session,
    ExecutableDeployItem payment) {
  var serializedBody = serializeBody(payment, session);
  var hasher = Hash.blake2b;
  var bodyHash = hasher(serializedBody, digestSize: 32);

  DeployHeader header = DeployHeader(
      deployParams.accountPublicKey,
      deployParams.timestamp!,
      deployParams.ttl,
      deployParams.gasPrice,
      bodyHash,
      deployParams.dependencies,
      deployParams.chainName);
  var serializedHeader = serializeHeader(header);
  var deployHash = hasher(serializedHeader.unwrap(), digestSize: 32);
  return Deploy(deployHash, header, payment, session, []);
}

/// Uses the provided key pair to sign the Deploy message
///
/// @param deploy
/// @param signingKey the keyPair to sign deploy
Deploy signDeploy(Deploy deploy, keys.AsymmetricKey signingKey) {
  var signer = signingKey.accountHex();
  var signatureBytes = signingKey.sign(deploy.hash);
  var signature = '';

  switch (signingKey.signatureAlgorithm) {
    case keys.SignatureAlgorithm.Ed25519:
      signature = keys.Ed25519.accountHexStr(signatureBytes);
      break;
    case keys.SignatureAlgorithm.Secp256K1:
      signature = keys.Secp256K1.accountHexStr(signatureBytes);
      break;
  }
  var approval = Approval(signer, signature);
  deploy.approvals.add(approval);

  return deploy;
}

/// Sets the already generated Ed25519 signature for the Deploy message
///
/// @param deploy
/// @param sig the Ed25519 signature
/// @param publicKey the public key used to generate the Ed25519 signature
Deploy setSignature(Deploy deploy, Uint8List sig, CLPublicKey publicKey) {
  var signer = publicKey.toHex();
  var signature = '';

  // TBD: Make sure it is proper
  if (publicKey.isEd25519()) {
    signature = keys.Ed25519.accountHexStr(sig);
  }
  if (publicKey.isSecp256K1()) {
    signature = keys.Secp256K1.accountHexStr(sig);
  }
  var approval = Approval(signer, signature);
  deploy.approvals.add(approval);
  return deploy;
}

/// Standard payment code.
///
/// @param paymentAmount the number of motes paying to execution engine
ExecutableDeployItem standardPayment(BigNumber paymentAmount) {
  var paymentArgs = RuntimeArgs.fromMap(
      {'amount': CLValueBuilder.u512(paymentAmount.toString())});

  return ExecutableDeployItem.newModuleBytes(
      Uint8List.fromList([]), paymentArgs);
}

/// Convert the deploy object to json
///
/// @param deploy
Map<String, dynamic> deployToJson(Deploy deploy) {
  return {'deploy': deploy.toJson()};
}

/// Convert the json to deploy object
///
/// @param json
Result<Deploy, Exception> deployFromJson(dynamic json) {
  if (json['deploy'] == null) {
    return Err(Exception("The Deploy JSON doesn't have 'deploy' field."));
  }
  Deploy deploy;
  try {
    deploy = Deploy.fromJson(json['deploy']);
  } catch (serializationError) {
    return Err(
        Exception('Serialization Error: ' + serializationError.toString()));
  }

  var valid = validateDeploy(deploy);
  if (valid.isErr()) {
    return Err(Exception(valid.unwrapErr()));
  }

  return Ok(deploy);
}

Deploy addArgToDeploy(Deploy deploy, String name, CLValue value) {
  if (deploy.approvals.isNotEmpty) {
    throw Exception('Can not add argument to already signed deploy.');
  }

  var deployParams = DeployParams(
      deploy.header.account,
      deploy.header.chainName,
      deploy.header.gasPrice,
      deploy.header.ttl,
      deploy.header.dependencies,
      deploy.header.timestamp);

  var session = deploy.session;
  session.setArg(name, value);

  return makeDeploy(deployParams, session, deploy.payment);
}

int deploySizeInBytes(Deploy deploy) {
  var hashSize = deploy.hash.length;
  var bodySize = serializeBody(deploy.payment, deploy.session).length;
  var headerSize = serializeHeader(deploy.header).unwrap().length;
  var approvalsSize = 0;
  List<int> list = List.empty(growable: true);

  for (var approval in deploy.approvals) {
    list.add((approval.signature.length + approval.signature.length) ~/ 2);
  }

  approvalsSize = list.reduce((a, b) => a + b);

  return hashSize + headerSize + bodySize + approvalsSize;
}

Result<Deploy, String> validateDeploy(Deploy deploy) {
  var serializedBody = serializeBody(deploy.payment, deploy.session);
  var hasher = Hash.blake2b;
  var bodyHash = hasher(serializedBody, digestSize: 32);
  Function eq = const ListEquality().equals;

  if (!eq(deploy.header.bodyHash, bodyHash)) {
    return Err(
        'Invalid deploy: bodyHash missmatch. Expected: $bodyHash, got: ${deploy.header.bodyHash}.');
  }

  var serializedHeader = serializeHeader(deploy.header).unwrap();
  var deployHash = hasher(serializedHeader, digestSize: 32);

  if (!eq(deploy.hash, deployHash)) {
    return Err(
        'Invalid deploy: hash missmatch. Expected: $deployHash, got: ${deploy.hash}.');
  }

  return Ok(deploy);
}

Uint8List deployToBytes(Deploy deploy) {
  return Uint8List.fromList([
    ...serializeHeader(deploy.header).unwrap(),
    ...deploy.hash,
    ...serializeBody(deploy.payment, deploy.session),
    ...serializeApprovals(deploy.approvals)
  ]);
}
