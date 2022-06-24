import 'package:casper_dart_sdk/services/casper_service_by_json_rpc.dart';
import 'package:test/test.dart';

void main() {
  group('CasperServiceByJSONRPC', () {
    test('getDeployInfo', () async {
      var casperService = CasperServiceByJsonRPC('https://casper-node.tor.us');

      var re = await casperService.getDeployInfo(
          '0a9ec2dc69f3d7a6ade91d2bffa35829ef8111e217b22b1d79eacce0515763df');
      print(re);
    });
  });
}
