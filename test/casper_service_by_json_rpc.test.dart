import 'package:casper_dart_sdk/services/casper_service_by_json_rpc.dart';
import 'package:test/test.dart';

void main() {
  group('CasperServiceByJSONRPC', () {
    var casperService = CasperServiceByJsonRPC('https://casper-node.tor.us');

    // test('getDeployInfo', () async {
    //   var re = await casperService.getDeployInfo(
    //       '0a9ec2dc69f3d7a6ade91d2bffa35829ef8111e217b22b1d79eacce0515763df');
    //   print(re);
    // });

    // test('getBlockInfo', () async {
    //   var re = await casperService.getBlockInfo(
    //       '5f5bd3f41e811ad4123133ccc72213ef81629860dd1d05daf3360c0a9519bf72');
    //   print(re);
    // });

    // test('getBlockInfo', () async {
    //   var re = await casperService.getBlockInfoByHeight(894624);
    //   print(re);
    // });

    // test('getLatestBlockInfo', () async {
    //   var re = await casperService.getLatestBlockInfo();
    //   print(re);
    // });

    // test('getPeers', () async {
    //   var re = await casperService.getPeers();
    //   print(re);
    // });

    // test('getStatus', () async {
    //   var re = await casperService.getStatus();
    //   print(re);
    // });

    // test('getValidatorsInfo', () async {
    //   var re = await casperService.getValidatorsInfo();
    //   print(re);
    // });

    test('getBlockState', () async {
      var re = await casperService.getBlockState(
          '0ceb047bf0508a328e552ce0fc7ab04d85bb839ac5c54156b885540e0040a62d',
          'account-hash-e3f6bf7f868a25f7b84597009158a1c2cea8df9bbcb949e0405c55c1a2b55c0b',
          []);
      expect(re.account?.accountHash,
          'account-hash-e3f6bf7f868a25f7b84597009158a1c2cea8df9bbcb949e0405c55c1a2b55c0b');
    });
  });
}
