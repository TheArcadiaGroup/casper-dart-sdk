import 'package:pinenacl/ed25519.dart';
import 'package:elliptic/elliptic.dart' as elliptic;
import 'package:ecdsa/ecdsa.dart' as ecdsa;
import 'package:pinenacl/tweetnacl.dart';

import 'CLValue/public_key.dart';
import 'conversions.dart';
import 'keys.dart' as keys;

/// Method for formatting messages with Casper header.
/// @param message The string to be formatted.
/// @returns The bytes of the formatted message
Uint8List formatMessageWithHeaders(String message) {
  var header = 'Casper Message:\n$message';
  return Uint8List.fromList(header.codeUnits);
}

/// Method for signing string message.
/// @param key AsymmetricKey used to sign the message
/// @param message Message that will be signed
/// @return Uint8Array Signature in byte format
Uint8List signRawMessage(keys.AsymmetricKey key, String message) {
  return key.sign(formatMessageWithHeaders(message));
}

/// Method for signing formatted message in bytes format.
/// @param key AsymmetricKey used to sign the message
/// @param formattedMessageBytes Bytes of the formatted message. (Strings can be formatted using the `formatMessageWithHeaders()` method)
/// @returns Uint8Array Signature in byte format
Uint8List signFormattedMessage(
    keys.AsymmetricKey key, Uint8List formattedMessageBytes) {
  return key.sign(formattedMessageBytes);
}

/// Method to verify signature
/// @param key Public key of private key used to signed.
/// @param message Message that was signed
/// @param signature Signature in byte format
/// @return boolean Verification result
bool verifyMessageSignature(
    CLPublicKey key, String message, Uint8List signature) {
  var messageWithHeader = formatMessageWithHeaders(message);
  if (key.isEd25519()) {
    try {
      var vKey = VerifyKey(key.value());
      return vKey.verify(
          signature: Signature(signature), message: messageWithHeader);
    } catch (e) {
      return false;
    }
  }
  if (key.isSecp256K1()) {
    var ec = elliptic.getSecp256k1();
    var pk = elliptic.PublicKey.fromHex(ec, base16Encode(key.value()));
    var out = Uint8List.fromList(List.filled(32, 0, growable: true));
    TweetNaClExt.crypto_hash_sha256(out, messageWithHeader);
    var result = ecdsa.verify(pk, out, ecdsa.Signature.fromCompact(signature));
    return result;
  }
  throw Exception('Unsupported algorithm.');
}
