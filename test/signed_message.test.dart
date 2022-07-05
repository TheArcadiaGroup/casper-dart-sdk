import 'package:casper_dart_sdk/classes/keys.dart';
import 'package:casper_dart_sdk/classes/signed_message.dart';
import 'package:test/test.dart';

void main() {
  group('SignedMessage', () {
    test('Should generate proper signed message and validate it (Ed25519)', () {
      var signKeyPair = Ed25519.newKey();
      const exampleMessage = "Hello World!";
      const wrongMessage = "!Hello World";

      var signature = signRawMessage(signKeyPair, exampleMessage);
      var valid = verifyMessageSignature(
          signKeyPair.publicKey, exampleMessage, signature);
      var invalid = verifyMessageSignature(
          signKeyPair.publicKey, wrongMessage, signature);

      expect(valid, true);
      expect(invalid, false);
    });
  });

  test('Should generate proper signed message and validate it (Secp256K1)', () {
    var publicKeyBase64 =
        '-----BEGIN PUBLIC KEY-----\nMDYwEAYHKoZIzj0CAQYFK4EEAAoDIgAD7iWeZr7TBbmnR+VMExP9/g0FxpLfBpj4eL9awxnvAJw=\n-----END PUBLIC KEY-----';
    var privateKeyBase64 =
        '-----BEGIN EC PRIVATE KEY-----\nMHcCAQEEICvJUWkBs+3s6snQHntQwGIzOIpFjBdANYyBPCIQEjAhoAcGBSuBBAAKoUcDRQAwMjAzZWUyNTllNjZiZWQzMDViOWE3NDdlNTRjMTMxM2ZkZmUwZDA1YzY5MmRmMDY5OGY4NzhiZjVhYzMxOWVmMDA5Yw==\n-----END EC PRIVATE KEY-----';
    var publicKey = Secp256K1.readBase64WithPEM(publicKeyBase64);
    var privateKey = Secp256K1.readBase64WithPEM(privateKeyBase64);
    var signKeyPair = Secp256K1.parseKeyPair(publicKey, privateKey);

    var exampleMessage = "Hello World!";
    var wrongMessage = "!Hello World";

    var signature = signRawMessage(signKeyPair, exampleMessage);
    var valid = verifyMessageSignature(
        signKeyPair.publicKey, exampleMessage, signature);
    var invalid =
        verifyMessageSignature(signKeyPair.publicKey, wrongMessage, signature);

    expect(valid, true);
    expect(invalid, false);
  });
}
