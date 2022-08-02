import 'dart:convert';
import 'package:casper_dart_sdk/casper_dart_sdk.dart';
import 'package:test/test.dart';

void main() {
  group('Contract', () {
    test('byteHash', () {
      var inputBase64 =
          'CiD3h4YVBZm1ChNTR29eLxLNE8IU5RIJZ0HEjn7GNjmvVhABGOO9g5q8LSpA4X7mRaRWddGbdOmIM9Fm9p0QxFKvVBscD5dmu1YdPK29ufR/ZmI0oseKM6l5RVKIUO3hh5en5prtkrrCzl3sdw==';
      var input = base64Decode(inputBase64);
      var hash = byteHash(input);
      var hashHex = base16Encode(hash);
      const expectedHex =
          'e0c7d8fbcbfd7eb5231b779cb4d7dcbcc3d60846e5a198a2c66bb1d3aafbd9a7';
      expect(hashHex, expectedHex);
      expect(hash.length, 32);
    });

    test('sign', () {
      // Input is a deploy hash.
      var inputBase16 =
          '20bb4422795c2c61285b230a5b185339caa6c1d143092b5041cd0f96e8bf062c';
      var input = base16Decode(inputBase16);
      var publicKeyBase64 =
          'MCowBQYDK2VwAyEALnsOUzZT5+6UvOo2fEXyOr993f+Zjj1aFe2BBeR78Dc=';
      var privateKeyBase64 =
          'MC4CAQAwBQYDK2VwBCIEIEIcqHCVzuejJfD9wCoGVOLc3YFNUa9dcsy+mv5j2sar';
      var publicKey = base64Decode(publicKeyBase64);
      var privateKey = base64Decode(privateKeyBase64);
      var keyPair = Ed25519.parseKeyPair(publicKey, privateKey);

      var signature = keyPair.sign(input);

      var signatureHex = base16Encode(signature);
      var expectedHex =
          '1babb50ad05f179985295654e2f1b31ef0b15637efbca7cc8b6601158e67811bc1aa0e4ee30271a6e68ec658495f2f2360b67bea733baec97e63b960efe9b00c';
      expect(signature.length, 64);
      expect(signatureHex, expectedHex);
    });
    test('read entry point', () async {
      var casperClient = CasperClient('https://casper-node.tor.us');
      var contract = Contract(casperClient);
      contract.setContractHash(
          'hash-012f8f3689ddf5c7a92ddeb54a311afb660051bb5fab3568dbb3d796809be8c6');

      var name = await contract.queryContractData(['name'], casperClient);
      expect(name, 'ETH Wrapped (Casper)');
    });
  });
}
