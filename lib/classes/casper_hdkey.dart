import 'dart:typed_data';

import 'conversions.dart';
import 'keys.dart';
import 'package:hdkey/hdkey.dart';
import 'package:pinenacl/tweetnacl.dart';

class CasperHDKey {
  // Registered at https://github.com/satoshilabs/slips/blob/master/slip-0044.md
  final int _bip44Index = 506;

  String _bip44Path(int index) {
    return [
      "m",
      "44'", // bip 44
      "$_bip44Index'", // coin index
      "0'", // wallet
      "0", // external
      "$index" // child account index
    ].join('/');
  }

  final HDKey _hdKey;

  CasperHDKey(this._hdKey);

  static CasperHDKey fromMasterSeed(Uint8List seed) {
    return CasperHDKey(HDKey.fromMasterSeed(seed));
  }

  Uint8List publicKey() {
    return _hdKey.publicKey ?? Uint8List.fromList([]);
  }

  Uint8List privateKey() {
    return _hdKey.privateKey ?? Uint8List.fromList([]);
  }

  String privateExtendedKey() {
    return _hdKey.privateExtendedKey ?? '';
  }

  String publicExtendedKey() {
    return _hdKey.publicExtendedKey;
  }

  /// Derive the child key basing the path
  /// @param path
  Secp256K1 derive(String path) {
    var secpKeyPair = _hdKey.derive(path);
    return Secp256K1(secpKeyPair.publicKey ?? Uint8List.fromList([]),
        secpKeyPair.privateKey ?? Uint8List.fromList([]));
  }

  /// Derive child key basing the bip44 protocol
  /// @param index the index of child key
  Secp256K1 deriveIndex(int index) {
    return derive(_bip44Path(index));
  }

  /// Generate the signature for the message by using the key
  /// @param msg The message to sign
  Uint8List sign(Uint8List msg) {
    var out = Uint8List.fromList(List.filled(32, 0, growable: true));
    return _hdKey.sign(TweetNaClExt.crypto_hash_sha256(out, msg));
  }

  /// Verify the signature
  /// @param signature the signature generated for the msg
  /// @param msg the raw message
  bool verify(Uint8List signature, Uint8List msg) {
    return _hdKey.verify(msg, signature);
  }

  String toJSON() {
    var xpriv = base16Encode(_hdKey.privateKey ?? Uint8List.fromList([]));
    var xpub = base16Encode(_hdKey.publicKey ?? Uint8List.fromList([]));
    return '{"xpriv": $xpriv, "xpub": $xpub}';
  }
}
