import 'package:casper_dart_sdk/classes/CLValue/clvalue.dart';
import 'package:casper_dart_sdk/classes/classes.dart';
import 'package:casper_dart_sdk/erc20-client/erc20_client.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('ERC20 Client', () {
    var nodeAddress = 'https://casper-node.tor.us';
    var chainName = 'casper';
    var eventStreamAddress = 'http://16.162.124.124:9999/events/main';
    var erc20Client = ERC20Client(nodeAddress, chainName, eventStreamAddress);

    var contractHash =
        'hash-012f8f3689ddf5c7a92ddeb54a311afb660051bb5fab3568dbb3d796809be8c6';

    var senderPublicKey = CLPublicKey.fromHex(
        '02025d0f7d345c9863814ff3ccd934664bbd28fb911d8320b7cab9828f021341705d');

    var senderPrivateKey =
        Secp256K1.readBase64WithPEM('-----BEGIN EC PRIVATE KEY-----\n'
            'MHQCAQEEIPCR7Cs+AzPFATVPvp/K1zOBQX5ifxfGuCX1kzwy24uXoAcGBSuBBAAK\n'
            'oUQDQgAEXQ99NFyYY4FP88zZNGZLvSj7kR2DILfKuYKPAhNBcF3ZZgQHUXxT0lb8\n'
            'teHP8hv36fe9171dQuZZbo7V1Wej8A==\n'
            '-----END EC PRIVATE KEY-----');
    var senderKey =
        Secp256K1.parseKeyPair(senderPublicKey.value(), senderPrivateKey);

    var recipient = CLPublicKey.fromHex(
        '0202f92c9b79232db38584ad558cf5becf5bfd23987e4e1d36d49166289ed8208f5f');

    test('setContractHash', () async {
      await erc20Client.setContractHash(contractHash);

      expect(erc20Client.contractPackageHash,
          'contract-package-wasmafc752ad814c4e05cafb25fb676fd74b65f1a340c5b5f0055814d3dd5115280a');
      expect(erc20Client.namedKeys['Allowances'],
          'uref-f698c997cd7fc412f2399b62110c72c12c78177104d1f97b88a0ed52e2f70440-007');
      expect(erc20Client.namedKeys['Balances'],
          'uref-a45eaf62d70b972b29f4125b7aea04a737055ad1980458cb0d0c1c6f95d56c25-007');
    });

    test('name', () async {
      expect(await erc20Client.name(), 'ETH Wrapped (Casper)');
    });

    test('symbol', () async {
      expect(await erc20Client.symbol(), 'dETH');
    });

    test('decimals', () async {
      expect((await erc20Client.decimals()).toString(), '18');
    });

    test('totalSupply', () async {
      expect(
          (await erc20Client.totalSupply()).toString(), '54644170275049631250');
    });

    test('balanceOf', () async {
      var balance = await erc20Client.balanceOf(senderPublicKey);
      var balanceMotes = CasperClient.fromMotes(balance.toString(), 18);
      expect(balanceMotes, '0.000118397173589323');
    });

    test('transfer', () async {
      var transferAmount = CasperClient.toMotes('0.000118397173589323', 18);
      var paymentAmount = '400000000';
      var hash = await erc20Client.transfer(
        senderKey,
        recipient,
        transferAmount,
        paymentAmount,
      );
      print(hash);
    });
  });
}
