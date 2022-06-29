import 'dart:typed_data';

import 'package:casper_dart_sdk/services/casper_service_by_json_rpc.dart';
import 'package:oxidized/oxidized.dart';

import 'CLValue/public_key.dart';
import 'bignumber.dart';
import 'casper_hdkey.dart';
import 'conversions.dart';
import 'deploy_util.dart';
import 'deploy_util.dart' as deploy_util;
import 'keys.dart';

class CasperClient {
  late CasperServiceByJsonRPC nodeClient;

  CasperClient(String nodeUrl) {
    nodeClient = CasperServiceByJsonRPC(nodeUrl);
  }

  /// Generate new key pair.
  /// @param algo Currently we support Ed25519 and Secp256K1.
  AsymmetricKey newKeyPair(SignatureAlgorithm algo) {
    switch (algo) {
      case SignatureAlgorithm.Ed25519:
        return Ed25519.newKey();
      case SignatureAlgorithm.Secp256K1:
        return Secp256K1.newKey();
      default:
        throw Exception('Invalid signature algorithm');
    }
  }

  /// Load private key from file
  ///
  /// @param path the path to the publicKey file
  /// @param algo the signature algorithm of the file
  Uint8List loadPublicKeyFromFile(String path, SignatureAlgorithm algo) {
    switch (algo) {
      case SignatureAlgorithm.Ed25519:
        return Ed25519.parsePublicKeyFile(path);
      case SignatureAlgorithm.Secp256K1:
        return Secp256K1.parsePublicKeyFile(path);
      default:
        throw Exception('Invalid signature algorithm');
    }
  }

  /// Load private key
  /// @param path the path to the private key file
  Uint8List loadPrivateKeyFromFile(String path, SignatureAlgorithm algo) {
    switch (algo) {
      case SignatureAlgorithm.Ed25519:
        return Ed25519.parsePrivateKeyFile(path);
      case SignatureAlgorithm.Secp256K1:
        return Secp256K1.parsePrivateKeyFile(path);
      default:
        throw Exception('Invalid signature algorithm');
    }
  }

  /// Load private key file to restore keyPair
  ///
  /// @param path The path to the private key
  /// @param algo
  AsymmetricKey loadKeyPairFromPrivateFile(
      String path, SignatureAlgorithm algo) {
    switch (algo) {
      case SignatureAlgorithm.Ed25519:
        return Ed25519.loadKeyPairFromPrivateFile(path);
      case SignatureAlgorithm.Secp256K1:
        return Secp256K1.loadKeyPairFromPrivateFile(path);
      default:
        throw Exception('Invalid signature algorithm');
    }
  }

  /// Create a new hierarchical deterministic wallet, supporting bip32 protocol
  ///
  /// @param seed The seed buffer for parent key
  CasperHDKey newHdWallet(Uint8List seed) {
    return CasperHDKey.fromMasterSeed(seed);
  }

  /// Compute public key from private Key.
  /// @param privateKey
  Uint8List privateToPublicKey(Uint8List privateKey, SignatureAlgorithm algo) {
    switch (algo) {
      case SignatureAlgorithm.Ed25519:
        return Ed25519.privateToPublicKey(privateKey);
      case SignatureAlgorithm.Secp256K1:
        return Secp256K1.privateToPublicKey(privateKey);
      default:
        throw Exception('Invalid signature algorithm');
    }
  }

  /// Construct a unsigned Deploy object
  ///
  /// @param deployParams Parameters for deploy
  /// @param session
  /// @param payment
  Deploy makeDeploy(DeployParams deployParams, ExecutableDeployItem session,
      ExecutableDeployItem payment) {
    return deploy_util.makeDeploy(deployParams, session, payment);
  }

  /// Sign the deploy with the specified signKeyPair
  /// @param deploy unsigned Deploy object
  /// @param signKeyPair the keypair to sign the Deploy object
  Deploy signDeploy(Deploy deploy, AsymmetricKey signKeyPair) {
    return deploy_util.signDeploy(deploy, signKeyPair);
  }

  /// Send deploy to network
  /// @param signedDeploy Signed deploy object
  Future<String> putDeploy(Deploy signedDeploy) async {
    var res = await nodeClient.deploy(signedDeploy);
    return res['deploy_hash'];
  }

  /// convert the deploy object to json
  /// @param deploy
  String deployToJson(Deploy deploy) {
    return deploy_util.deployToJson(deploy).toString();
  }

  /// Convert the json to deploy object
  ///
  /// @param json
  Result<Deploy, Exception> deployFromJson(dynamic json) {
    return deploy_util.deployFromJson(json);
  }

  /// Construct the deploy for transfer purpose
  ///
  /// @param deployParams
  /// @param session
  /// @param payment
  Deploy makeTransferDeploy(DeployParams deployParams,
      ExecutableDeployItem session, ExecutableDeployItem payment) {
    if (!session.isTransfer()) {
      throw Exception('The session is not a Transfer ExecutableDeployItem');
    }
    return makeDeploy(deployParams, session, payment);
  }

  /// Get the balance of public key
  Future<BigNumber> balanceOfByPublicKey(CLPublicKey publicKey) async {
    return balanceOfByAccountHash(encodeBase16(publicKey.toAccountHash()));
  }

  // /// Get the balance by account hash
  Future<BigNumber> balanceOfByAccountHash(String accountHashStr) async {
    try {
      var res = await nodeClient.getLatestBlockInfo();
      var stateRootHash = res.block?.header.stateRootHash;
      // Find the balance Uref and cache it if we don't have it.
      if (stateRootHash == null) {
        return BigNumber.from(0);
      }
      var balanceUref = await nodeClient.getAccountBalanceUrefByPublicKeyHash(
          stateRootHash, accountHashStr);

      if (balanceUref == null) {
        return BigNumber.from(0);
      }

      return await nodeClient.getAccountBalance(stateRootHash, balanceUref);
    } catch (e) {
      return BigNumber.from(0);
    }
  }

  /// Get deploy by hash from RPC.
  /// @param deployHash
  /// @returns Tuple of Deploy and raw RPC response.
  Future<Map<Deploy, GetDeployResult>> getDeploy(String deployHash) async {
    GetDeployResult deployResult = await nodeClient.getDeployInfo(deployHash);
    var deploy = deploy_util.deployFromJson(deployResult).unwrap();
    return {deploy: deployResult};
  }

  /// Get the main purse uref for the specified publicKey
  /// @param publicKey
  Future<String?> getAccountMainPurseUref(CLPublicKey publicKey) async {
    try {
      GetBlockResult blockResult = await nodeClient.getLatestBlockInfo();
      var stateRootHash = blockResult.block?.header.stateRootHash;

      if (stateRootHash == null) {
        return null;
      }

      var balanceUref = await nodeClient.getAccountBalanceUrefByPublicKeyHash(
          stateRootHash, encodeBase16(publicKey.toAccountHash()));
      return balanceUref;
    } catch (e) {
      rethrow;
    }
  }
}
