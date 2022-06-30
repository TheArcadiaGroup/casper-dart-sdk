// ignore_for_file: non_constant_identifier_names

import 'dart:typed_data';

import 'conversions.dart';

/// Functions to convert data to the FFI
typedef Serializer<T> = Uint8List Function(T arg);

/// Help function to serialize size
///
/// @param size
/// @constructor
Uint8List serializeSize(num size) {
  var list = List.filled(4, 0, growable: true);
  list.setRange(0, 1, [size as int]);
  return Uint8List.fromList(list);
}

Serializer<num> Size = serializeSize;

/// `Array[Byte]` serializes as follows:
///  1) your array of bytes
///
/// So for `[1,2,3,4,5,6]` it serializes to`[1, 2, 3, 4, 5, 6]`
///
/// @param bytes
Uint8List serializeByteArray(List<int> bytes) {
  return Uint8List.fromList(bytes);
}

Serializer<Uint8List> ByteArrayArg = serializeByteArray;

/// Serialize ByteArray
///
/// `Seq[Byte]` serializes as follows:
///  1) length of the array as 4 bytes
///  2) your array of bytes
///
/// So for `[1,2,3,4,5,6]` it serializes to`[6, 0, 0, 0, 1, 2, 3, 4, 5, 6]`
Uint8List serializeByteSequence(List<int> bytes) {
  return Uint8List.fromList([...Size(bytes.length), ...bytes]);
}

Serializer<Uint8List> ByteSequenceArg = serializeByteSequence;

/// Serialize public key
///
/// A public key is the same as array but it's expected to be 32 bytes long exactly.
/// It's `[u8; 32]` (32 element byte array) but serializes to `(32.toBytes() ++ array.toBytes())`
/// We serialize 32(literally, number 32) to 4 bytes instead of 1 byte, little endianness.
/// This is how`111..11` public key looks like when serialized:
/// [32, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
var PublicKeyArg = ByteArrayArg;

/// Serialize UINT64
///
/// @param value
Uint8List serializeUInt64(BigInt value) {
  var list = Uint8List.fromList(List<int>.filled(8, 0));
  var bytes = bigIntToBytes(value);
  list.setRange(0, bytes.length, bytes);
  return Uint8List.fromList(list);
}

Serializer<BigInt> UInt64Arg = serializeUInt64;

/// Combine multiple arguments.
///
/// so, what you want to send is`Vec(PublicKey, u64)`:
/// • `PublicKey` serializes to`byte array of the key`,
/// • `u64` serializes to`8 byte array`,
///
/// so, what we have is(for example):
///  `Vec([32, 0, 0, 0, {public key bytes}], [1, 2, 3, 4, 0, 0, 0, 0])`
///
/// Which gives us:
/// `[2, 0, 0, 0`  - for the number of elements in the external vector
/// `32, 0, 0, 0, 1, 1, …` - public key
/// `8, 0, 0, 0, ` - for the number of bytes in the second element of the vector.
/// That was serialized `u64` (`[1, 2, 3, 4, 0, 0, 0, 0]`)
/// `1, 2, 3, 4, 0, 0, 0, 0]`
Uint8List serializeArgs(List<Uint8List> args) {
  var bytes = List<Uint8List>.empty(growable: true);
  for (var arg in args) {
    bytes.add(ByteSequenceArg(arg));
  }
  var list = Uint8List.fromList([...Size(args.length)]);
  bytes.insert(0, list);
  return Uint8List.fromList(bytes.expand((element) => element).toList());
}

Serializer<List<Uint8List>> Args = serializeArgs;
