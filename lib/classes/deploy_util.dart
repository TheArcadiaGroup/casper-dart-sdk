import 'package:duration/duration.dart';
import 'package:duration/locale.dart';

import 'CLValue/constants.dart';
import 'CLValue/public_key.dart';
import 'byte_converters.dart';
import 'conversions.dart';

import 'package:json_annotation/json_annotation.dart';
import 'package:oxidized/oxidized.dart';
import 'package:pinenacl/ed25519.dart';

import 'CLValue/abstract.dart';

part 'deploy_util.g.dart';

String byteArrayJsonSerializer(Uint8List bytes) {
  return encodeBase16(bytes);
}

Uint8List byteArrayJsonDeserializer(String str) {
  return decodeBase16(str);
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
  return printDuration(duration, locale: ShortEnDurationLocale());
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
    units.add(dehumanizeUnit(strArray[i]));
  }

  return units.reduce((value, element) => (value + element));
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
    return DateTime.fromMillisecondsSinceEpoch(timestamp).toIso8601String();
  }

  static List<Uint8List> dependenciesFromJson(List<String> json) {
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

//DeployJson

//Approval

abstract class ExecutableDeployItemInternal implements ToBytes {
  abstract int tag;

  // abstract RuntimeArgs args;
}

// desRA

// serRA

// class ModuleBytes extends ExecutableDeployItemInternal

// class StoredContractByHash extends ExecutableDeployItemInternal

// class StoredContractByName extends ExecutableDeployItemInternal

// class StoredVersionedContractByName extends ExecutableDeployItemInternal

// class StoredVersionedContractByHash extends ExecutableDeployItemInternal

// class Transfer extends ExecutableDeployItemInternal

@JsonSerializable(explicitToJson: true)
class ExecutableDeployItem implements ToBytes {
  @override
  Result<Uint8List, CLErrorCodes> toBytes() {
    // TODO: implement toBytes
    throw UnimplementedError();
  }
}

@JsonSerializable(explicitToJson: true)
class Deploy {
  @JsonKey(fromJson: byteArrayJsonDeserializer, toJson: byteArrayJsonSerializer)
  late Uint8List hash;

  late DeployHeader header;
}
