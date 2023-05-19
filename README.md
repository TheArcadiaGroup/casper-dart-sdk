# Casper Dart SDK
Casper Dart SDK is a powerful software development kit (SDK) for the Casper blockchain, written in Dart. With this SDK, you can interact with the Casper network, write smart contracts, and build DApps using Dart, a language known for its scalability and efficiency.


# Features
Chain Interaction: The SDK allows direct interaction with the Casper blockchain.

Smart Contract Management: Allows deploying, calling and managing smart contracts on the Casper network.

Event Handling: Built-in event handling to respond to various events within the Casper network.

Flexible Payments: You can set the amount of payment for each contract call.

Time-To-Live (TTL): You can specify the TTL for a deploy, allowing for flexibility in transaction lifetime.
Installation

Add the following to your pubspec.yaml file:
```
dependencies:
  casper_dart_sdk:
    git: https://github.com/TheArcadiaGroup/casper-dart-sdk.git
```

Then run:
```
pub get
```



# API

One of the main classes provided by this SDK is ContractClient. The client exposes several methods to interact with the Casper network, including:

contractCall(ContractClientCallParams params): Executes a call to a contract deployed on the network, returning the deploy hash.

createUnsignedContractCall(ContractClientCallParamsUnsigned params): Creates an unsigned contract call.

putSignatureAndSend(AppendSignature sig): Puts a signature on the contract call and sends it to the network.

addPendingDeploy(deployType, String deployHash): Adds a deploy hash to the list of pending deploys.

handleEvents(eventNames, callback): Handles various Casper events. Only one event listener can be created at a time.

# Contributing

Contributions to the Casper Dart SDK are welcome! Please see the CONTRIBUTING.md file for more details.

# License
Casper Dart SDK is licensed under the MIT License.
