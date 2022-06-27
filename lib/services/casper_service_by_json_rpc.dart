import 'dart:convert';

import 'package:casper_dart_sdk/classes/CLValue/public_key.dart';
import 'package:casper_dart_sdk/classes/bignumber.dart';
import 'package:casper_dart_sdk/classes/conversions.dart';
import 'package:casper_dart_sdk/classes/stored_value.dart';
import 'package:http/http.dart' as http;

class CasperServiceByJsonRPC {
  final String rpcUrl;
  int _currentRequestId = 0;

  CasperServiceByJsonRPC(this.rpcUrl);

  Future<Map<String, dynamic>> call(String function,
      [Map<String, dynamic>? params]) async {
    params ??= {};

    final requestPayload = {
      'jsonrpc': '2.0',
      'method': function,
      'params': params,
      'id': _currentRequestId++,
    };

    var request = http.Request('POST', Uri.parse(rpcUrl));
    request.body = jsonEncode(requestPayload);
    // we have add the
    request.headers.addAll({'Content-Type': 'application/json'});

    final stream = await request.send();
    final response = await http.Response.fromStream(stream);
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data.containsKey('error')) {
      final error = data['error'];

      final code = error['code'] as int;
      final message = error['message'] as String;
      final errorData = error['data'];

      throw RPCError(code, message, errorData);
    }

    final result = data['result'];
    return result;
  }

  Future<Map<String, dynamic>> _makeRPCCall(String function,
      [Map<String, dynamic>? params]) async {
    try {
      final data = await call(function, params);
      // ignore: only_throw_errors
      if (data is Error || data is Exception) throw data;

      return data;
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  /// Get information about a single deploy by hash.
  ///
  /// @param deployHashBase16
  Future<Map<String, dynamic>> getDeployInfo(String deployHashBase16) async {
    return await _makeRPCCall(
        'info_get_deploy', {'deploy_hash': deployHashBase16});
  }

  /// Get information about a block by hash.
  ///
  /// @param blockHashBase16
  Future<Map<String, dynamic>> getBlockInfo(String blockHashBase16) async {
    try {
      var response = await _makeRPCCall('chain_get_block', {
        'block_identifier': {'Hash': blockHashBase16}
      });

      if (response.containsKey('block')) {
        var block = response['block'] as Map<String, dynamic>;
        if (block.containsKey('hash') &&
            response['block']['hash'].toString().toLowerCase() !=
                blockHashBase16.toLowerCase()) {
          throw Exception('Returned block does not have a matching hash.');
        }
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getBlockInfoByHeight(num height) async {
    var response = await _makeRPCCall('chain_get_block', {
      'block_identifier': {'Height': height}
    });

    if (response.containsKey('block')) {
      var block = response['block'] as Map<String, dynamic>;
      if (block.containsKey('header') &&
          response['block']['header']['height'] != height) {
        throw Exception('Returned block does not have a matching height.');
      }
    }

    return response;
  }

  Future<Map<String, dynamic>> getLatestBlockInfo() async {
    return await _makeRPCCall('chain_get_block');
  }

  Future<Map<String, dynamic>> getPeers() async {
    return await _makeRPCCall('info_get_peers');
  }

  Future<Map<String, dynamic>> getStatus() async {
    return await _makeRPCCall('info_get_status');
  }

  Future<Map<String, dynamic>> getValidatorsInfo() async {
    return await _makeRPCCall('state_get_auction_info');
  }

  Future<Map<String, dynamic>> getValidatorsInfoByBlockHeight() async {
    return await _makeRPCCall('state_get_auction_info');
  }

  /// Get the reference to the balance so we can cache it.
  Future<String?> getAccountBalanceUrefByPublicKeyHash(
      String stateRootHash, String accountHash) async {
    var res =
        await getBlockState(stateRootHash, 'account-hash$accountHash', []);
    var account = res.account;
    return account?.mainPurse;
  }

  Future<String?> getAccountBalanceUrefByPublicKey(
      String stateRootHash, CLPublicKey publicKey) async {
    return getAccountBalanceUrefByPublicKeyHash(
        stateRootHash, encodeBase16(publicKey.toAccountHash()));
  }

  Future<BigNumber> getAccountBalance(
      String stateRootHash, String balanceUref) async {
    try {
      var res = await _makeRPCCall('state_get_balance',
          {'state_root_hash': stateRootHash, 'purse_uref': balanceUref});
      return BigNumber.from(res['balance_value']);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getStateRootHash(String? blockHashBase16) async {
    return await _makeRPCCall(
        'chain_get_state_root_hash', {'block_hash': blockHashBase16});
  }

  Future<StoredValue> getBlockState(
      String stateRootHash, String key, List<String> path) async {
    var res = await _makeRPCCall('state_get_item',
        {'state_root_hash': stateRootHash, 'key': key, 'path': path});

    try {
      var storedValueJson = res['stored_value'];
      var storedValue = StoredValue.fromJson(storedValueJson);
      return storedValue;
    } catch (e) {
      rethrow;
    }
  }

  // deploy(De)
}

/// Exception thrown when an the server returns an error code to an rpc request.
class RPCError implements Exception {
  const RPCError(this.errorCode, this.message, this.data);

  final int errorCode;
  final String message;
  final dynamic data;

  @override
  String toString() {
    return 'RPCError: got code $errorCode with msg "$message".';
  }
}
