import '../classes/stored_value.dart';

abstract class RpcResult {
  String get apiVersion;
}

abstract class Peer {
  late String nodeId;
  late String address;
}

abstract class GetPeersResult extends RpcResult {
  late List<Peer> peers;
}

class LastAddedBlockInfo {
  late String hash;
  late String timestamp;
  late num eraId;
  late num height;
  late String stateRootHash;
  late String creator;

  LastAddedBlockInfo(this.hash, this.timestamp, this.eraId, this.height,
      this.stateRootHash, this.creator);
}

abstract class GetStatusResult extends GetPeersResult {
  late LastAddedBlockInfo lastAddedBlockInfo;
  late String buildVersion;
}

abstract class GetStateRootHashResult extends RpcResult {
  late String stateRootHash;
}

class ExecutionResultBody {
  late num cost;
  late String? errorMessage;
  late List<String> transfers;

  ExecutionResultBody(this.cost, this.errorMessage, this.transfers);
}

abstract class ExecutionResult {
  late ExecutionResultBody success;
  late ExecutionResultBody failure;
}

abstract class JsonExecutionResult {
  late String blockHash;
  late ExecutionResult result;
}

abstract class GetDeployResult extends RpcResult {
  late JsonDeploy deploy;
  late List<JsonExecutionResult> executionResults;
}

abstract class GetBlockResult extends RpcResult {
  late JsonBlock block;
}

abstract class JsonSystemTransaction {
  String? slash;
  late Map<String, num>? reward;
}

class JsonDeployHeader {
  late String account;
  late num timestamp;
  late num ttl;
  late num gasPrice;
  late String bodyHash;
  late List<String> dependencies;
  late String chainName;
}

abstract class JsonExecutableDeployItem {}

class JsonApproval {
  late String signer;
  late String signature;

  JsonApproval(this.signer, this.signature);
}

class JsonDeploy {
  late String hash;
  late JsonDeployHeader header;
  late JsonExecutableDeployItem payment;
  late JsonExecutableDeployItem session;
  late List<JsonApproval> approvals;

  JsonDeploy(
      this.hash, this.header, this.payment, this.session, this.approvals);
}

class JsonHeader {
  late String parentHash;
  late String stateRootHash;
  late String bodyHash;
  late List<String> deployHashes;
  late bool randomBit;
  late bool switchBlock;
  late num timestamp;
  late List<JsonSystemTransaction> systemTransactions;
  late num eraId;
  late num height;
  late String proposer;
  late String protocolVersion;
}

class JsonBlock {
  late String hash;
  late JsonHeader header;
  late List<String> proofs;
}

class BidInfo {
  late String bondingPurse;
  late String stakedAmount;
  late num delegationRate;
  late String fundsLocked;
}

class ValidatorWeight {
  late String publicKey;
  late String weight;
}

class EraSummary {
  late String blockHash;
  late num eraId;
  late StoredValue storedValue;
  late String stateRootHash;
}

class EraValidators {
  late num eraId;
  late List<ValidatorWeight> validatorWeights;
}

class Bid {
  late String bondingPurse;
  late String stakedAmount;
  late num delegationRate;
  late String reward;
  late List<Delegators> delegators;
}

class Delegators {
  late String bondingPurse;
  late String delegatee;
  late String stakedAmount;
  late String publicKey;
}

class DelegatorInfo {
  late String bondingPurse;
  late String delegatee;
  late String reward;
  late String stakedAmount;
}

class ValidatorBid {
  late String publicKey;
  late Bid bid;
}

class AuctionState {
  late String stateRootHash;
  late num blockHeight;
  late List<EraValidators> eraValidators;
  late List<ValidatorBid> bids;
}

class ValidatorsInfoResult extends RpcResult {
  @override
  late String apiVersion;
  late AuctionState auctionState;
}

class CasperServiceByJsonRPC {
  // late Client _client;
}
