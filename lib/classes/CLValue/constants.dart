/// The length in bytes of a [`AccountHash`].
// ignore_for_file: constant_identifier_names
const ACCOUNT_HASH_LENGTH = 32;

enum CLErrorCodes {
  EarlyEndOfStream,
  Formatting,
  LeftOverBytes,
  OutOfMemory,
  UnknownValue,
}

enum KeyVariant {
  Account,
  Hash,
  URef,
}

/// Casper types, i.e. types which can be stored and manipulated by smart contracts.
///
/// Provides a description of the underlying data type of a [[CLValue]].
enum CLTypeTag {
  /// Account Hash
  AccountHash,

  /// A boolean value
  Bool,

  /// A 32-bit signed integer
  I32,

  /// A 64-bit signed integer
  I64,

  /// An 8-bit unsigned integer (a byte)
  U8,

  /// A 32-bit unsigned integer
  U32,

  /// A 64-bit unsigned integer
  U64,

  /// A 128-bit unsigned integer
  U128,

  /// A 256-bit unsigned integer
  U256,

  /// A 512-bit unsigned integer
  U512,

  /// A unit type, i.e. type with no values (analogous to `void` in C and `()` in Rust)
  Unit,

  /// A string of characters
  String,

  /// A key in the global state - URef/hash/etc.
  Key,

  /// An Unforgeable Reference (URef)
  URef,

  /// An [[Option]], i.e. a type that can contain a value or nothing at all
  Option,

  /// A list of values
  List,

  /// A fixed-length array of bytes
  ByteArray,

  /// A [[Result]], i.e. a type that can contain either a value representing success or one representing failure.
  Result,

  /// A key-value map.
  Map,

  /// A 1-value tuple.
  Tuple1,

  /// A 2-value tuple, i.e. a pair of values.
  Tuple2,

  /// A 3-value tuple.
  Tuple3,

  /// A value of any type.
  Any,

  /// A value of public key type.
  PublicKey,
}

extension CLTypeTagExention on CLTypeTag {
  int get value {
    switch (this) {
      case CLTypeTag.AccountHash:
        return -1;
      case CLTypeTag.Bool:
        return 0;
      case CLTypeTag.I32:
        return 1;
      case CLTypeTag.I64:
        return 2;
      case CLTypeTag.U8:
        return 3;
      case CLTypeTag.U32:
        return 4;
      case CLTypeTag.U64:
        return 5;
      case CLTypeTag.U128:
        return 6;
      case CLTypeTag.U256:
        return 7;
      case CLTypeTag.U512:
        return 8;
      case CLTypeTag.Unit:
        return 9;
      case CLTypeTag.String:
        return 10;
      case CLTypeTag.Key:
        return 11;
      case CLTypeTag.URef:
        return 12;
      case CLTypeTag.Option:
        return 13;
      case CLTypeTag.List:
        return 14;
      case CLTypeTag.ByteArray:
        return 15;
      case CLTypeTag.Result:
        return 16;
      case CLTypeTag.Map:
        return 17;
      case CLTypeTag.Tuple1:
        return 18;
      case CLTypeTag.Tuple2:
        return 19;
      case CLTypeTag.Tuple3:
        return 20;
      case CLTypeTag.Any:
        return 21;
      case CLTypeTag.PublicKey:
        return 22;
      default:
        return 0;
    }
  }
}

const BOOL_ID = 'Bool';
const KEY_ID = 'Key';
const PUBLIC_KEY_ID = 'PublicKey';
const STRING_ID = 'String';
const UREF_ID = 'URef';
const UNIT_ID = 'Unit';
const I32_ID = 'I32';
const I64_ID = 'I64';
const U8_ID = 'U8';
const U32_ID = 'U32';
const U64_ID = 'U64';
const U128_ID = 'U128';
const U256_ID = 'U256';
const U512_ID = 'U512';

const BYTE_ARRAY_ID = 'ByteArray';
const LIST_ID = 'List';
const MAP_ID = 'Map';
const OPTION_ID = 'Option';
const RESULT_ID = 'Result';
const TUPLE1_ID = 'Tuple1';
const TUPLE2_ID = 'Tuple2';
const TUPLE3_ID = 'Tuple3';

const ACCOUNT_HASH_ID = 'AccountHash';
