import 'dart:convert';
import 'dart:typed_data';

import 'package:casper_dart_sdk/classes/classes.dart';
import 'package:casper_dart_sdk/contract-client/contract_client.dart';
import 'package:casper_dart_sdk/contract-client/types.dart';

import 'constants.dart';

class NameKeys {
  late String allowances;
  late String balances;

  NameKeys({
    required this.allowances,
    required this.balances,
  });
}

class ERC20Client extends ContractClient {
  ERC20Client(String nodeAddress, String chainName, String eventStreamAddress)
      : super(nodeAddress, chainName, eventStreamAddress);

  /// Installs the ERC20 contract.
  ///
  /// @param keys AsymmetricKey that will be used to install the contract.
  /// @param tokenName Name of the ERC20 token.
  /// @param tokenSymbol Symbol of the ERC20 token.
  /// @param tokenDecimals Specifies how many decimal places token will have.
  /// @param tokenTotalSupply Specifies the amount of tokens in existance.
  /// @param paymentAmount The payment amount that will be used to install the contract.
  /// @param wasmPath Path to the WASM file that will be installed.
  ///
  /// @returns Installation deploy hash.
  Future<String> install(
    AsymmetricKey keys,
    String tokenName,
    String tokenSymbol,
    String tokenDecimals,
    String tokenTotalSupply,
    String paymentAmount,
    String wasmPath,
  ) async {
    var runtimeArgs = RuntimeArgs.fromMap({
      'name': CLValueBuilder.string(tokenName),
      'symbol': CLValueBuilder.string(tokenSymbol),
      'decimals': CLValueBuilder.u8(tokenDecimals),
      'total_supply': CLValueBuilder.u256(tokenTotalSupply)
    });

    var params = InstallParams(
      chainName: chainName,
      nodeAddress: nodeAddress,
      keys: keys,
      runtimeArgs: runtimeArgs,
      paymentAmount: paymentAmount,
      pathToContract: wasmPath,
    );

    return await installContract(params);
  }

  /// Set ERC20 contract hash so its possible to communicate with it.
  ///
  /// @param hash Contract hash (raw hex string as well as `hash-` prefixed format is supported).
  Future<void> setContractHash(String hash) async {
    var properHash = hash.startsWith('hash-') ? hash.substring(5) : hash;
    var client =
        await setClient(nodeAddress, properHash, ['balances', 'allowances']);
    contractHash = properHash;
    contractPackageHash = client['contractPackageHash'];
    namedKeys = client['namedKeys'];
  }

  /// Returns the name of the ERC20 token.
  Future<String> name() async {
    return await contractSimpleGetter(nodeAddress, contractHash!, ['name']);
  }

  /// Returns the symbol of the ERC20 token.
  Future<String> symbol() async {
    return await contractSimpleGetter(nodeAddress, contractHash!, ['symbol']);
  }

  /// Returns the decimals of the ERC20 token.
  Future<BigNumber> decimals() async {
    return await contractSimpleGetter(nodeAddress, contractHash!, ['decimals']);
  }

  /// Returns the total supply of the ERC20 token.
  Future<BigNumber> totalSupply() async {
    return await contractSimpleGetter(
        nodeAddress, contractHash!, ['total_supply']);
  }

  /// Transfers an amount of tokens from the direct caller to a recipient.
  ///
  /// @param keys AsymmetricKey that will be used to sign the transaction.
  /// @param recipient Recipient address (it supports CLPublicKey, CLAccountHash and CLByteArray).
  /// @param transferAmount Amount of tokens that will be transfered.
  /// @param tokenDecimals Specifies how many decimal places token will have.
  /// @param paymentAmount Amount that will be used to pay the transaction.
  /// @param ttl Time to live in miliseconds after which transaction will be expired (defaults to 30m).
  ///
  /// @returns Deploy hash.
  Future<String> transfer(AsymmetricKey keys, CLValue recipient,
      String transferAmount, String paymentAmount,
      [int ttl = 600000]) async {
    var runtimeArgs = RuntimeArgs.fromMap({
      'recipient': createRecipientAddress(recipient),
      'amount': CLValueBuilder.u256(transferAmount),
    });

    var params = ContractClientCallParams(
      keys: keys,
      entryPoint: 'transfer',
      runtimeArgs: runtimeArgs,
      paymentAmount: paymentAmount,
      callback: (deployHash) =>
          addPendingDeploy(ERC20Events.Transfer, deployHash),
      ttl: ttl,
    );

    return await contractCall(params);
  }

  /// Transfers an amount of tokens from the owner to a recipient, if the direct caller has been previously approved to spend the specied amount on behalf of the owner.
  ///
  /// @param keys AsymmetricKey that will be used to sign the transaction.
  /// @param owner Owner address (it supports CLPublicKey, CLAccountHash and CLByteArray).
  /// @param recipient Recipient address (it supports CLPublicKey, CLAccountHash and CLByteArray).
  /// @param transferAmount Amount of tokens that will be transfered.
  /// @param paymentAmount Amount that will be used to pay the transaction.
  /// @param ttl Time to live in miliseconds after which transaction will be expired (defaults to 30m).
  ///
  /// @returns Deploy hash.
  Future<String> transferFrom(AsymmetricKey keys, CLValue owner,
      CLValue recipient, String transferAmount, String paymentAmount,
      [int ttl = 60000]) async {
    var runtimeArgs = RuntimeArgs.fromMap({
      'recipient': createRecipientAddress(recipient),
      'owner': createRecipientAddress(owner),
      'amount': CLValueBuilder.u256(transferAmount),
    });

    var params = ContractClientCallParams(
      keys: keys,
      entryPoint: 'transfer_from',
      runtimeArgs: runtimeArgs,
      paymentAmount: paymentAmount,
      callback: (deployHash) =>
          addPendingDeploy(ERC20Events.Transfer, deployHash),
      ttl: ttl,
    );

    return await contractCall(params);
  }

  /// Allows a spender to transfer up to an amount of the direct caller’s tokens.
  ///
  /// @param keys AsymmetricKey that will be used to sign the transaction.
  /// @param spender Spender address (it supports CLPublicKey, CLAccountHash and CLByteArray).
  /// @param approveAmount The amount of tokens that will be allowed to transfer.
  /// @param paymentAmount Amount that will be used to pay the transaction.
  /// @param ttl Time to live in miliseconds after which transaction will be expired (defaults to 30m).
  ///
  /// @returns Deploy hash.
  Future<String> approve(AsymmetricKey keys, CLValue spender,
      String approveAmount, String paymentAmount,
      [int ttl = 60000]) async {
    var runtimeArgs = RuntimeArgs.fromMap({
      'spender': createRecipientAddress(spender),
      'amount': CLValueBuilder.u256(approveAmount),
    });

    var params = ContractClientCallParams(
      keys: keys,
      entryPoint: 'approve',
      runtimeArgs: runtimeArgs,
      paymentAmount: paymentAmount,
      callback: (deployHash) =>
          addPendingDeploy(ERC20Events.Approve, deployHash),
      ttl: ttl,
    );

    return await contractCall(params);
  }

  /// Returns the balance of the account address.
  ///
  /// @param account Account address (it supports CLPublicKey, CLAccountHash and CLByteArray).
  ///
  /// @returns Balance of an account.
  Future<BigNumber> balanceOf(CLValue account) async {
    var key = createRecipientAddress(account);
    var keyBytes = CLValueParsers.toBytes(key).unwrap();
    var itemKey = base64Encode(keyBytes);
    var result = await contractDictionaryGetter(
        nodeAddress, itemKey, namedKeys['Balances']);
    if (result is BigNumber) {
      return result;
    }
    return BigNumber.ZERO;
  }

  /// Returns the amount of owner’s tokens allowed to be spent by spender.
  ///
  /// @param owner Owner address (it supports CLPublicKey, CLAccountHash and CLByteArray).
  /// @param spender Spender address (it supports CLPublicKey, CLAccountHash and CLByteArray).
  ///
  /// @returns Amount in tokens.
  Future<String> allowances(CLValue owner, CLValue spender) async {
    var keyOwner = createRecipientAddress(owner);
    var keySpender = createRecipientAddress(spender);
    var finalBytes = Uint8List.fromList([
      ...CLValueParsers.toBytes(keyOwner).unwrap(),
      ...CLValueParsers.toBytes(keySpender).unwrap()
    ]);
    var blaked = byteHash(finalBytes);
    var encodedBytes = base64Encode(blaked);

    var result = await contractDictionaryGetter(
        nodeAddress, encodedBytes, namedKeys['allowances']);

    return result.toString();
  }
}
