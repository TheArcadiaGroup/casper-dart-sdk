// ignore_for_file: constant_identifier_names

import 'dart:typed_data';

import 'package:oxidized/oxidized.dart';
import 'package:collection/collection.dart';

import 'constants.dart';
import '../contracts.dart';
import '../conversions.dart';

import '../keys.dart';
import 'abstract.dart';

const ED25519_LENGTH = 32;
const SECP256K1_LENGTH = 33;

enum CLPublicKeyTag { ED25519, SECP256K1 }

extension CLPublicKeyTagExtension on CLPublicKeyTag {
  int get value {
    switch (this) {
      case CLPublicKeyTag.ED25519:
        return 1;
      case CLPublicKeyTag.SECP256K1:
        return 2;
    }
  }
}

class CLPublicKeyType extends CLType {
  @override
  get linksTo => CLPublicKey;

  @override
  CLTypeTag get tag => CLTypeTag.PublicKey;

  @override
  String toJSON() {
    return '"$PUBLIC_KEY_ID"';
  }

  @override
  String toString() {
    return PUBLIC_KEY_ID;
  }
}

class CLPublicKeyBytesParser extends CLValueBytesParsers {
  @override
  ResultAndRemainder<CLValue, CLErrorCodes> fromBytesWithRemainder(
      Uint8List bytes,
      [CLType? innerType]) {
    if (bytes.isEmpty) {
      return resultHelper(Err(CLErrorCodes.EarlyEndOfStream));
    }

    var tag = bytes[0];

    var keySize = 0;

    if (tag == CLPublicKeyTag.ED25519.value) {
      keySize = ED25519_LENGTH;
    } else if (tag == CLPublicKeyTag.SECP256K1.value) {
      keySize = SECP256K1_LENGTH;
    } else {
      return resultHelper(Err(CLErrorCodes.Formatting));
    }

    var keyBytes = bytes.sublist(1, keySize + 1);
    var publicKey = CLPublicKey(keyBytes, tag);

    return resultHelper(Ok(publicKey), bytes.sublist(keySize + 1));
  }

  @override
  Result<Uint8List, CLErrorCodes> toBytes(CLValue val) {
    val as CLPublicKey;
    return Ok(Uint8List.fromList([
      ...Uint8List.fromList([val.tag.value]),
      ...val.data
    ]));
  }
}

class CLPublicKey extends CLValue {
  @override
  late Uint8List data;
  late CLPublicKeyTag tag;

  CLPublicKey(Uint8List rawPublicKey, dynamic _tag) {
    if (_tag == CLPublicKeyTag.ED25519 ||
        _tag == CLPublicKeyTag.ED25519.value ||
        _tag == SignatureAlgorithm.Ed25519 ||
        _tag == SignatureAlgorithm.Ed25519.value) {
      if (rawPublicKey.length != ED25519_LENGTH) {
        throw Exception(
            'Wrong length of ED25519 key. Expected $ED25519_LENGTH, but got ${rawPublicKey.length}.');
      }

      data = rawPublicKey;
      tag = CLPublicKeyTag.ED25519;
      return;
    }

    if (_tag == CLPublicKeyTag.SECP256K1 ||
        _tag == CLPublicKeyTag.SECP256K1.value ||
        _tag == SignatureAlgorithm.Secp256K1 ||
        _tag == SignatureAlgorithm.Secp256K1.value) {
      if (rawPublicKey.length != SECP256K1_LENGTH) {
        throw Exception(
            'Wrong length of SECP256K1 key. Expected $SECP256K1_LENGTH, but got ${rawPublicKey.length}.');
      }
      data = rawPublicKey;
      tag = CLPublicKeyTag.SECP256K1;
      return;
    }

    throw Exception('Unsupported type of public key');
  }

  @override
  CLType clType() {
    return CLPublicKeyType();
  }

  @override
  Uint8List value() {
    return data;
  }

  bool isEd25519() {
    return tag == CLPublicKeyTag.ED25519;
  }

  bool isSecp256K1() {
    return tag == CLPublicKeyTag.SECP256K1;
  }

  String toHex() {
    return '0${tag.value}${encodeBase16(data)}';
  }

  Uint8List toAccountHash() {
    var algorithmIdentifier =
        CLPublicKeyTag.values.firstWhere((element) => element == tag);
    var separator = Uint8List.fromList([0]);
    var algorithm = algorithmIdentifier.toString().split('.')[1].toLowerCase();
    var prefix = Uint8List.fromList([
      ...algorithm.codeUnits,
      ...separator,
    ]);

    if (data.isEmpty) {
      return Uint8List.fromList([]);
    } else {
      return byteHash(Uint8List.fromList([...prefix, ...data]));
    }
  }

  String toAccountHashStr() {
    var bytes = toAccountHash();
    var hashHex = encodeBase16(bytes);
    return 'account-hash-$hashHex';
  }

  static CLPublicKey fromEd25519(Uint8List publicKey) {
    return CLPublicKey(publicKey, CLPublicKeyTag.ED25519);
  }

  static CLPublicKey fromSecp256K1(Uint8List publicKey) {
    return CLPublicKey(publicKey, CLPublicKeyTag.SECP256K1);
  }

  /// Tries to decode PublicKey from its hex-representation.
  /// The hex format should be as produced by PublicKey.toAccountHex
  /// @param publicKeyHex
  static CLPublicKey fromHex(String publicKeyHex) {
    if (publicKeyHex.length < 2) {
      throw Exception('Asymmetric key error: too short');
    }

    if (!RegExp(r"^0(1[0-9a-fA-F]{64}|2[0-9a-fA-F]{66})$")
        .hasMatch(publicKeyHex)) {
      throw Exception('Invalid public key');
    }

    var publicKeyHexBytes = decodeBase16(publicKeyHex);

    return CLPublicKey(publicKeyHexBytes.sublist(1), publicKeyHexBytes[0]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other.runtimeType != runtimeType) return false;

    other as CLPublicKey;
    Function eq = const ListEquality().equals;
    return eq(data, other.data) && tag == other.tag;
  }

  @override
  int get hashCode => data.hashCode;
}
