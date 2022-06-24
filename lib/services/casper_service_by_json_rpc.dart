import 'dart:convert';

import 'package:http/http.dart' as http;

class CasperServiceByJsonRPC {
  final String rpcUrl;
  int _currentRequestId = 0;

  CasperServiceByJsonRPC(this.rpcUrl);

  Future<Map<String, dynamic>> call(
      String function, Map<String, dynamic>? params) async {
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

  Future<Map<String, dynamic>> _makeRPCCall(
      String function, Map<String, dynamic>? params) async {
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
