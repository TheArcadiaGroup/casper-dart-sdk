// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:asn1lib/asn1lib.dart';
import 'package:pinenacl/ed25519.dart';
import 'package:ecdsa/ecdsa.dart' as ecdsa;
import 'package:elliptic/elliptic.dart' as elliptic;
import 'package:pinenacl/tweetnacl.dart';

import 'CLValue/public_key.dart';
import 'casper_hdkey.dart';
import 'contracts.dart';
import 'conversions.dart';

const PEM_SECRET_KEY_TAG = 'PRIVATE KEY';
const PEM_EC_SECRET_KEY_TAG = 'EC PRIVATE KEY';
const PEM_PUBLIC_KEY_TAG = 'PUBLIC KEY';

/// Supported types of Asymmetric Key algorithm
enum SignatureAlgorithm { Ed25519, Secp256K1 }

extension SignatureAlgorithmExtension on SignatureAlgorithm {
  String get value {
    switch (this) {
      case SignatureAlgorithm.Ed25519:
        return 'ed25519';
      case SignatureAlgorithm.Secp256K1:
        return 'secp256k1';
    }
  }
}

Uint8List accountHashHelper(
    SignatureAlgorithm signatureAlgorithm, Uint8List publicKey) {
  var separator = decodeBase16('00');
  var prefix =
      Uint8List.fromList([...signatureAlgorithm.value.codeUnits, ...separator]);

  if (publicKey.isEmpty) {
    return Uint8List.fromList([]);
  } else {
    return byteHash(Uint8List.fromList([...prefix, ...publicKey]));
  }
}

/// Get rid of PEM frames, skips header `-----BEGIN PUBLIC KEY-----`
/// and footer `-----END PUBLIC KEY-----`
///
/// Example PEM:
///
/// ```
/// -----BEGIN PUBLIC KEY-----\r\n
/// MFYwEAYHKoZIzj0CAQYFK4EEAAoDQgAEj1fgdbpNbt06EY/8C+wbBXq6VvG+vCVD\r\n
/// Nl74LvVAmXfpdzCWFKbdrnIlX3EFDxkd9qpk35F/kLcqV3rDn/u3dg==\r\n
/// -----END PUBLIC KEY-----\r\n
/// ```
///
Uint8List readBase64Content(String content) {
  var base64Str = content
      .split(RegExp(r'\r?\n'))
      .where((x) => !x.startsWith('---'))
      .join('')
      .trim();

  return base64Decode(base64Str);
}

abstract class AsymmetricKey {
  late CLPublicKey publicKey;
  late Uint8List privateKey;
  late SignatureAlgorithm signatureAlgorithm;

  AsymmetricKey(Uint8List _publicKey, Uint8List _privateKey,
      SignatureAlgorithm _signatureAlgorithm) {
    publicKey = CLPublicKey(_publicKey, _signatureAlgorithm);
    privateKey = _privateKey;
    signatureAlgorithm = _signatureAlgorithm;
  }

  /// Compute a unique hash from the algorithm name(Ed25519 here) and a key, used for accounts.
  Uint8List accountHash() {
    return publicKey.toAccountHash();
  }

  ///Get the account hex
  String accountHex() {
    return publicKey.toHex();
  }

  String toPem(String tag, String content) {
    return '-----BEGIN $tag-----\n$content\n-----END $tag-----\n';
  }

  ///Export the key encoded in pem
  String exportPublicKeyInPem();

  ///Expect the key encoded in pem
  String exportPrivateKeyInPem();

  /// Sign the message by using the keyPair
  /// @param msg
  Uint8List sign(Uint8List msg);

  /// Verify the signature along with the raw message
  /// @param signature
  /// @param msg
  bool verify(Uint8List signature, Uint8List msg);
}

class Ed25519 extends AsymmetricKey {
  Ed25519(SigningKey signingKey)
      : super(signingKey.publicKey.toUint8List(), signingKey.seed.toUint8List(),
            SignatureAlgorithm.Ed25519);

  ///
  /// Generating a new Ed25519 key pair
  ///
  static Ed25519 newKey() {
    return Ed25519(SigningKey.generate());
  }

  /// Generate the accountHex for the Ed25519 key
  ///
  /// @param publicKey
  static String accountHexStr(Uint8List publicKey) {
    return '01' + encodeBase16(publicKey);
  }

  /// Parse the key pair from publicKey file and privateKey file
  ///
  /// @param publicKeyPath path of key file
  /// @param privateKeyPath path of key file
  static AsymmetricKey parseKeyFiles(
      String publicKeyPath, String privateKeyPath) {
    var publicKey = Ed25519.parsePublicKeyFile(publicKeyPath);
    var privateKey = Ed25519.parsePrivateKeyFile(privateKeyPath);
    var secret = Uint8List.fromList([...privateKey, ...publicKey]);

    return Ed25519(SigningKey.fromValidBytes(secret));
  }

  /// Generate the accountHash for the Ed25519 key
  /// @param publicKey
  static Uint8List accountHashEd25519(Uint8List publicKey) {
    return accountHashHelper(SignatureAlgorithm.Ed25519, publicKey);
  }

  /// Construct keyPair from a key and key
  /// @param publicKey
  /// @param privateKey
  static AsymmetricKey parseKeyPair(Uint8List publicKey, Uint8List privateKey) {
    var publ = Ed25519.parsePublicKey(publicKey);
    var priv = Ed25519.parsePrivateKey(privateKey);

    var secr = Uint8List.fromList([...priv, ...publ]);
    var key = SigningKey.fromValidBytes(secr);
    return Ed25519(key);
  }

  static Uint8List parsePrivateKeyFile(String path) {
    return Ed25519.parsePrivateKey(Ed25519.readBase64File(path));
  }

  static Uint8List parsePublicKeyFile(String path) {
    return Ed25519.parsePublicKey(Ed25519.readBase64File(path));
  }

  static Uint8List parsePrivateKey(Uint8List bytes) {
    return Ed25519.parseKey(bytes, 0, 32);
  }

  static Uint8List parsePublicKey(Uint8List bytes) {
    return Ed25519.parseKey(bytes, 32, 64);
  }

  static Uint8List readBase64WithPEM(String content) {
    return readBase64Content(content);
  }

  /// Read the Base64 content of a file, get rid of PEM frames.
  ///
  /// @param path the path of file to read from
  static Uint8List readBase64File(String path) {
    File file = File(path);
    String content = file.readAsStringSync();
    return Ed25519.readBase64WithPEM(content);
  }

  static Uint8List parseKey(Uint8List bytes, int from, int to) {
    var len = bytes.length;
    // prettier-ignore
    var key = (len == 32)
        ? bytes
        : (len == 64)
            ? bytes.sublist(from, to)
            : (len > 32 && len < 64)
                ? bytes.sublist(len % 32)
                : null;

    if (key == null || key.length != 32) {
      throw Exception("Unexpected key length: $len");
    }
    return key;
  }

  @override
  String exportPrivateKeyInPem() {
    var derPrefix = Uint8List.fromList(
        [48, 46, 2, 1, 0, 48, 5, 6, 3, 43, 101, 112, 4, 34, 4, 32]);
    var encoded = base64Encode(Uint8List.fromList([
      ...derPrefix,
      ...Uint8List.fromList(Ed25519.parsePrivateKey(privateKey))
    ]));
    return toPem(PEM_SECRET_KEY_TAG, encoded);
  }

  @override
  String exportPublicKeyInPem() {
    var derPrefix =
        Uint8List.fromList([48, 42, 48, 5, 6, 3, 43, 101, 112, 3, 33, 0]);
    var encoded = base64Encode(Uint8List.fromList(
        [...derPrefix, ...Uint8List.fromList(publicKey.value())]));
    return toPem(PEM_PUBLIC_KEY_TAG, encoded);
  }

  @override
  Uint8List sign(Uint8List msg) {
    var sig = SigningKey.fromSeed(privateKey).sign(msg);
    return sig.signature.toUint8List();
  }

  @override
  bool verify(Uint8List signature, Uint8List msg) {
    try {
      var vKey = VerifyKey(publicKey.value());
      return vKey.verify(signature: Signature(signature), message: msg);
    } catch (e) {
      print(e);
      return false;
    }
  }

  /// Derive public key from private key
  /// @param privateKey
  static Uint8List privateToPublicKey(Uint8List privateKey) {
    return SigningKey.fromSeed(privateKey).publicKey.toUint8List();
  }

  /// Restore Ed25519 keyPair from private key file
  /// @param privateKeyPath
  static loadKeyPairFromPrivateFile(String privateKeyPath) {
    var privateKey = Ed25519.parsePrivateKeyFile(privateKeyPath);
    var publicKey = SigningKey.fromSeed(privateKey).publicKey;
    return Ed25519.parseKeyPair(publicKey.toUint8List(), privateKey);
  }
}

class Secp256K1 extends AsymmetricKey {
  Secp256K1(Uint8List publicKey, Uint8List privateKey)
      : super(publicKey, privateKey, SignatureAlgorithm.Secp256K1);

  /// Generating a new Secp256K1 key pair
  static Secp256K1 newKey() {
    var ec = elliptic.getSecp256k1();
    var privateKey = ec.generatePrivateKey();
    var publicKey = privateKey.publicKey;
    var privateKeyHex = privateKey.toHex();
    var publicKeyHex = publicKey.toCompressedHex();
    return Secp256K1(decodeBase16(publicKeyHex), decodeBase16(privateKeyHex));
  }

  /// Parse the key pair from publicKey file and privateKey file
  /// @param publicKeyPath path of public key file
  /// @param privateKeyPath path of private key file
  static AsymmetricKey parseKeyFiles(
      String publicKeyPath, String privateKeyPath) {
    var publicKey = Secp256K1.parsePublicKeyFile(publicKeyPath);
    var privateKey = Secp256K1.parsePrivateKeyFile(privateKeyPath);
    return Secp256K1(publicKey, privateKey);
  }

  /// Generate the accountHash for the Ed25519 key
  /// @param publicKey
  static Uint8List accountHashSecp256K1(Uint8List publicKey) {
    return accountHashHelper(SignatureAlgorithm.Secp256K1, publicKey);
  }

  static String accountHexStr(Uint8List publickKey) {
    return '02' + encodeBase16(publickKey);
  }

  static AsymmetricKey parseKeyPair(Uint8List publicKey, Uint8List privateKey,
      [String? originalFormat = 'der']) {
    var publ = Secp256K1.parsePublicKey(publicKey, originalFormat);
    var priv = Secp256K1.parsePrivateKey(privateKey, originalFormat);
    return Secp256K1(publ, priv);
  }

  static Uint8List parsePrivateKeyFile(String path) {
    return Secp256K1.parsePrivateKey(Secp256K1.readBase64File(path));
  }

  static Uint8List parsePublicKeyFile(String path) {
    return Secp256K1.parsePublicKey(Secp256K1.readBase64File(path));
  }

  static Uint8List parsePrivateKey(Uint8List bytes,
      [String? originalFormat = 'der']) {
    Uint8List result = Uint8List.fromList(bytes);
    if (originalFormat == 'der') {
      var subBytes = bytes.sublist(7, 39);
      result = subBytes;
    }
    return result;
  }

  static Uint8List parsePublicKey(Uint8List bytes,
      [String? originalFormat = 'der']) {
    Uint8List result = Uint8List.fromList(bytes);
    if (originalFormat == 'der') {
      var subBytes = bytes.sublist(23, bytes.length);
      result = subBytes;
    }
    return result;
  }

  static Uint8List readBase64WithPEM(String content) {
    return readBase64Content(content);
  }

  static Uint8List readBase64File(String path) {
    File file = File(path);
    String content = file.readAsStringSync();
    return Secp256K1.readBase64WithPEM(content);
  }

  @override
  String exportPrivateKeyInPem() {
    var outer = ASN1Sequence();

    var version = ASN1Integer(BigInt.one);
    var privKey = ASN1OctetString(privateKey);
    var choice = ASN1Sequence(tag: 0xA0);
    choice.add(ASN1ObjectIdentifier.fromComponentString('1.3.132.0.10'));

    var pubKey = ASN1Sequence(tag: 0xA1);
    var subjectPublicKey = ASN1BitString(publicKey.toHex().codeUnits);
    pubKey.add(subjectPublicKey);

    outer.add(version);
    outer.add(privKey);
    outer.add(choice);
    outer.add(pubKey);

    return toPem(PEM_EC_SECRET_KEY_TAG, base64Encode(outer.encodedBytes));
  }

  @override
  String exportPublicKeyInPem() {
    var outer = ASN1Sequence();
    var algorithm = ASN1Sequence();
    algorithm.add(ASN1ObjectIdentifier.fromComponentString(
        '1.2.840.10045.2.1')); // ecPublicKey
    algorithm.add(
        ASN1ObjectIdentifier.fromComponentString('1.3.132.0.10')); // secp256k1

    outer.add(algorithm);
    outer.add(ASN1BitString(publicKey.data));

    return toPem(PEM_PUBLIC_KEY_TAG, base64Encode(outer.encodedBytes));
  }

  @override
  Uint8List sign(Uint8List msg) {
    var ec = elliptic.getSecp256k1();
    var priv = elliptic.PrivateKey.fromBytes(ec, privateKey);
    var out = Uint8List.fromList(List.filled(32, 0, growable: true));
    TweetNaClExt.crypto_hash_sha256(out, msg);
    var sig = ecdsa.signature(priv, out);
    return Uint8List.fromList(sig.toCompact());
  }

  @override
  bool verify(Uint8List signature, Uint8List msg) {
    var ec = elliptic.getSecp256k1();
    var pk = elliptic.PublicKey.fromHex(ec, encodeBase16(publicKey.value()));
    var out = Uint8List.fromList(List.filled(32, 0, growable: true));
    TweetNaClExt.crypto_hash_sha256(out, msg);
    var result = ecdsa.verify(pk, out, ecdsa.Signature.fromCompact(signature));
    return result;
  }

  /// Derive public key from private key
  /// @param privateKey
  static Uint8List privateToPublicKey(Uint8List privateKey) {
    var ec = elliptic.getSecp256k1();
    var pubKey =
        elliptic.PrivateKey.fromHex(ec, encodeBase16(privateKey)).publicKey;
    return decodeBase16(pubKey.toCompressedHex());
  }

  /// Restore Secp256K1 keyPair from private key file
  /// @param privateKeyPath a path to file of the private key
  static AsymmetricKey loadKeyPairFromPrivateFile(String privateKeyPath) {
    var ec = elliptic.getSecp256k1();
    var privateKey = Secp256K1.parsePrivateKeyFile(privateKeyPath);
    var publicKey =
        elliptic.PrivateKey.fromHex(ec, encodeBase16(privateKey)).publicKey;
    return Secp256K1.parseKeyPair(
        Uint8List.fromList(decodeBase16(publicKey.toCompressedHex())),
        privateKey,
        'raw');
  }

  /// From hdKey derive a child Secp256K1 key
  /// @param hdKey
  /// @param index
  static Secp256K1 deriveIndex(CasperHDKey hdKey, int index) {
    return hdKey.deriveIndex(index);
  }
}
