import 'package:casper_dart_sdk/classes/CLValue/public_key.dart';
import 'package:casper_dart_sdk/services/casper_service_by_json_rpc.dart';
import 'package:dart_bignumber/dart_bignumber.dart';

class BalanceServiceByJsonRPC {
  late Map<String, String> balanceUrefs;
  late CasperServiceByJsonRPC casperService;

  BalanceServiceByJsonRPC(this.casperService);

  /// Query balance for the specified account
  ///
  /// It will cache balance URef values for accounts so that on subsequent queries,
  /// it only takes 1 state query not 4 to get the value.
  /// @param blockHashBase16
  /// @param publicKey
  Future<BigNumber?> getAccountBalance(
      String blockHashBase16, CLPublicKey publicKey) async {
    try {
      var stateRootHash = await casperService.getStateRootHash(blockHashBase16);
      var balanceUref = balanceUrefs[publicKey.toHex()];

      // Find the balance Uref and cache it if we don't have it.
      if (balanceUref == null) {
        balanceUref = await casperService.getAccountBalanceUrefByPublicKey(
            stateRootHash, publicKey);
        if (balanceUref != null) {
          balanceUrefs[publicKey.toHex()] = balanceUref;
        }
      }

      if (balanceUref == null) {
        return null;
      }

      return await casperService.getAccountBalance(stateRootHash, balanceUref);
    } catch (e) {
      return null;
    }
  }
}
