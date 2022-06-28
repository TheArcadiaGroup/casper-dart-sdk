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
      DeployHeader.dependenciesFromJson(json['dependencies'] as List<String>),
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

ExecutableDeployItem _$ExecutableDeployItemFromJson(
        Map<String, dynamic> json) =>
    ExecutableDeployItem();

Map<String, dynamic> _$ExecutableDeployItemToJson(
        ExecutableDeployItem instance) =>
    <String, dynamic>{};

Deploy _$DeployFromJson(Map<String, dynamic> json) => Deploy()
  ..hash = byteArrayJsonDeserializer(json['hash'] as String)
  ..header = DeployHeader.fromJson(json['header'] as Map<String, dynamic>);

Map<String, dynamic> _$DeployToJson(Deploy instance) => <String, dynamic>{
      'hash': byteArrayJsonSerializer(instance.hash),
      'header': instance.header.toJson(),
    };
