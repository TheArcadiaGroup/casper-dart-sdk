// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deploy_util.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeployHeader _$DeployHeaderFromJson(Map<String, dynamic> json) => DeployHeader(
      DeployHeader.fromHex(json['account'] as String),
      DeployHeader.timestampFromJson(json['timestamp'] as String),
      dehumanizerTTL(json['ttl'] as String),
      json['gas_price'] as int,
      byteArrayJsonDeserializer(json['body_hash'] as String),
      DeployHeader.dependenciesFromJson(json['dependencies'] as List),
      json['chain_name'] as String,
    );

Map<String, dynamic> _$DeployHeaderToJson(DeployHeader instance) =>
    <String, dynamic>{
      'account': DeployHeader.toHex(instance.account),
      'timestamp': DeployHeader.timestampToJson(instance.timestamp),
      'ttl': humanizerTTL(instance.ttl),
      'gas_price': instance.gasPrice,
      'body_hash': byteArrayJsonSerializer(instance.bodyHash),
      'dependencies': DeployHeader.dependenciesToJson(instance.dependencies),
      'chain_name': instance.chainName,
    };

Approval _$ApprovalFromJson(Map<String, dynamic> json) => Approval(
      json['signer'] as String,
      json['signature'] as String,
    );

Map<String, dynamic> _$ApprovalToJson(Approval instance) => <String, dynamic>{
      'signer': instance.signer,
      'signature': instance.signature,
    };

ModuleBytes _$ModuleBytesFromJson(Map<String, dynamic> json) => ModuleBytes(
      byteArrayJsonDeserializer(json['module_bytes'] as String),
      desRA(json['args'] as List),
    )..tag = json['tag'] as int;

Map<String, dynamic> _$ModuleBytesToJson(ModuleBytes instance) =>
    <String, dynamic>{
      'tag': instance.tag,
      'module_bytes': byteArrayJsonSerializer(instance.moduleBytes),
      'args': serRA(instance.args),
    };

StoredContractByHash _$StoredContractByHashFromJson(
        Map<String, dynamic> json) =>
    StoredContractByHash(
      byteArrayJsonDeserializer(json['hash'] as String),
      json['entry_point'] as String,
      desRA(json['args'] as List),
    )..tag = json['tag'] as int;

Map<String, dynamic> _$StoredContractByHashToJson(
        StoredContractByHash instance) =>
    <String, dynamic>{
      'tag': instance.tag,
      'args': serRA(instance.args),
      'hash': byteArrayJsonSerializer(instance.hash),
      'entry_point': instance.entryPoint,
    };

StoredContractByName _$StoredContractByNameFromJson(
        Map<String, dynamic> json) =>
    StoredContractByName(
      json['name'] as String,
      json['entry_point'] as String,
      desRA(json['args'] as List),
    )..tag = json['tag'] as int;

Map<String, dynamic> _$StoredContractByNameToJson(
        StoredContractByName instance) =>
    <String, dynamic>{
      'tag': instance.tag,
      'name': instance.name,
      'entry_point': instance.entryPoint,
      'args': serRA(instance.args),
    };

StoredVersionedContractByName _$StoredVersionedContractByNameFromJson(
        Map<String, dynamic> json) =>
    StoredVersionedContractByName(
      json['name'] as String,
      json['version'] as num?,
      json['entry_point'] as String,
      desRA(json['args'] as List),
    )..tag = json['tag'] as int;

Map<String, dynamic> _$StoredVersionedContractByNameToJson(
        StoredVersionedContractByName instance) =>
    <String, dynamic>{
      'tag': instance.tag,
      'name': instance.name,
      'version': instance.version,
      'entry_point': instance.entryPoint,
      'args': serRA(instance.args),
    };

StoredVersionedContractByHash _$StoredVersionedContractByHashFromJson(
        Map<String, dynamic> json) =>
    StoredVersionedContractByHash(
      byteArrayJsonDeserializer(json['hash'] as String),
      json['version'] as num?,
      json['entry_point'] as String,
      desRA(json['args'] as List),
    )..tag = json['tag'] as int;

Map<String, dynamic> _$StoredVersionedContractByHashToJson(
        StoredVersionedContractByHash instance) =>
    <String, dynamic>{
      'tag': instance.tag,
      'hash': byteArrayJsonSerializer(instance.hash),
      'version': instance.version,
      'entry_point': instance.entryPoint,
      'args': serRA(instance.args),
    };

Transfer _$TransferFromJson(Map<String, dynamic> json) => Transfer(
      desRA(json['args'] as List),
    )..tag = json['tag'] as int;

Map<String, dynamic> _$TransferToJson(Transfer instance) => <String, dynamic>{
      'tag': instance.tag,
      'args': serRA(instance.args),
    };

ExecutableDeployItem _$ExecutableDeployItemFromJson(Map<String, dynamic> json) {
  print(json['ModuleBytes']);
  return ExecutableDeployItem()
    ..moduleBytes = json['ModuleBytes'] == null
        ? null
        : ModuleBytes.fromJson(json['ModuleBytes'] as Map<String, dynamic>)
    ..storedContractByHash = json['StoredContractByHash'] == null
        ? null
        : StoredContractByHash.fromJson(
            json['StoredContractByHash'] as Map<String, dynamic>)
    ..storedContractByName = json['StoredContractByName'] == null
        ? null
        : StoredContractByName.fromJson(
            json['StoredContractByName'] as Map<String, dynamic>)
    ..storedVersionedContractByHash =
        json['StoredVersionedContractByHash'] == null
            ? null
            : StoredVersionedContractByHash.fromJson(
                json['StoredVersionedContractByHash'] as Map<String, dynamic>)
    ..storedVersionedContractByName =
        json['StoredVersionedContractByName'] == null
            ? null
            : StoredVersionedContractByName.fromJson(
                json['StoredVersionedContractByName'] as Map<String, dynamic>)
    ..transfer = json['Transfer'] == null
        ? null
        : Transfer.fromJson(json['Transfer'] as Map<String, dynamic>);

Map<String, dynamic> _$ExecutableDeployItemToJson(
        ExecutableDeployItem instance) =>
    <String, dynamic>{
      'ModuleBytes': instance.moduleBytes?.toJson(),
      'StoredContractByHash': instance.storedContractByHash?.toJson(),
      'StoredContractByName': instance.storedContractByName?.toJson(),
      'StoredVersionedContractByHash':
          instance.storedVersionedContractByHash?.toJson(),
      'StoredVersionedContractByName':
          instance.storedVersionedContractByName?.toJson(),
      'Transfer': instance.transfer?.toJson(),
    };

Deploy _$DeployFromJson(Map<String, dynamic> json) => Deploy(
      byteArrayJsonDeserializer(json['hash'] as String),
      DeployHeader.fromJson(json['header'] as Map<String, dynamic>),
      ExecutableDeployItem.fromJson(json['payment'] as Map<String, dynamic>),
      ExecutableDeployItem.fromJson(json['session'] as Map<String, dynamic>),
      (json['approvals'] as List<dynamic>)
          .map((e) => Approval.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DeployToJson(Deploy instance) => <String, dynamic>{
      'hash': byteArrayJsonSerializer(instance.hash),
      'header': instance.header.toJson(),
      'payment': instance.payment.toJson(),
      'session': instance.session.toJson(),
      'approvals': instance.approvals.map((e) => e.toJson()).toList(),
    };
