// ignore_for_file: constant_identifier_names

import 'dart:typed_data';

import 'package:oxidized/oxidized.dart';
import 'package:pinenacl/digests.dart';

import 'abstract.dart';
import 'bool.dart';
import 'byte_array.dart';
import 'constants.dart';
import 'key.dart';
import 'list.dart';
import 'map.dart';
import 'numeric.dart';
import 'option.dart';
import 'public_key.dart';
import 'result.dart';
import 'tuple.dart';
import 'unit.dart';
import 'uref.dart';
import 'string.dart';

const TUPLE_MATCH_LEN_TO_ID = [TUPLE1_ID, TUPLE2_ID, TUPLE3_ID];

CLType matchTypeToCLType(dynamic type) {
  if (type is String) {
    switch (type) {
      case BOOL_ID:
        return CLBoolType();
      case KEY_ID:
        return CLKeyType();
      case PUBLIC_KEY_ID:
        return CLPublicKeyType();
      case STRING_ID:
        return CLStringType();
      case UREF_ID:
        return CLURefType();
      case UNIT_ID:
        return CLUnitType();
      case I32_ID:
        return CLI32Type();
      case I64_ID:
        return CLI64Type();
      case U8_ID:
        return CLU8Type();
      case U32_ID:
        return CLU32Type();
      case U64_ID:
        return CLU64Type();
      case U128_ID:
        return CLU128Type();
      case U256_ID:
        return CLU256Type();
      case U512_ID:
        return CLU512Type();
      default:
        throw Exception(
            'The simple type ' + type.toString() + ' is not supported');
    }
  }

  if (type is Map) {
    if (type.containsKey(LIST_ID)) {
      return CLListType(matchTypeToCLType(type[LIST_ID]));
    }

    if (type.containsKey(BYTE_ARRAY_ID)) {
      return CLByteArrayType(type[BYTE_ARRAY_ID]);
    }

    if (type.containsKey(MAP_ID)) {
      var _map = type.values.first as Map;
      var keyType = matchTypeToCLType(_map['key']);
      var valType = matchTypeToCLType(_map['value']);

      return CLMapType({keyType: valType});
    }
    if (type.containsKey(TUPLE1_ID)) {
      var list = type[TUPLE1_ID] as List;
      var vals = list.map((t) => matchTypeToCLType(t)).toList();
      return CLTuple1Type(vals);
    }

    if (type.containsKey(TUPLE2_ID)) {
      var list = type[TUPLE2_ID] as List;
      var vals = list.map((t) => matchTypeToCLType(t)).toList();
      return CLTuple2Type(vals);
    }

    if (type.containsKey(TUPLE3_ID)) {
      var list = type[TUPLE3_ID] as List;
      var vals = list.map((t) => matchTypeToCLType(t)).toList();
      return CLTuple3Type(vals);
    }

    if (type.containsKey(OPTION_ID)) {
      var inner = matchTypeToCLType(type[OPTION_ID]);
      return CLOptionType(inner);
    }

    if (type.containsKey(RESULT_ID)) {
      var innerOk = matchTypeToCLType(type[RESULT_ID]['ok']);
      var innerErr = matchTypeToCLType(type[RESULT_ID]['err']);
      return CLResultType(CLResultTypeMap(innerOk, innerErr));
    }
    throw Exception('The complex type $type is not supported');
  }

  throw Exception('Unknown data provided.');
}

Result<CLValueBytesParsers, String> matchByteParserByCLType(CLType val) {
  if (val.tag == CLTypeTag.Bool) {
    return Ok(CLBoolBytesParser());
  }

  if (val.tag == CLTypeTag.I32) {
    return Ok(CLI32BytesParser());
  }
  if (val.tag == CLTypeTag.I64) {
    return Ok(CLI64BytesParser());
  }
  if (val.tag == CLTypeTag.U8) {
    return Ok(CLU8BytesParser());
  }
  if (val.tag == CLTypeTag.U32) {
    return Ok(CLU32BytesParser());
  }
  if (val.tag == CLTypeTag.U64) {
    return Ok(CLU64BytesParser());
  }
  if (val.tag == CLTypeTag.U128) {
    return Ok(CLU128BytesParser());
  }
  if (val.tag == CLTypeTag.U256) {
    return Ok(CLU256BytesParser());
  }
  if (val.tag == CLTypeTag.U512) {
    return Ok(CLU512BytesParser());
  }

  if (val.tag == CLTypeTag.ByteArray) {
    return Ok(CLByteArrayBytesParser());
  }

  if (val.tag == CLTypeTag.URef) {
    return Ok(CLURefBytesParser());
  }

  if (val.tag == CLTypeTag.Key) {
    return Ok(CLKeyBytesParser());
  }

  if (val.tag == CLTypeTag.PublicKey) {
    return Ok(CLPublicKeyBytesParser());
  }

  if (val.tag == CLTypeTag.List) {
    return Ok(CLListBytesParser());
  }

  if (val.tag == CLTypeTag.Map) {
    return Ok(CLMapBytesParser());
  }

  if (val.tag == CLTypeTag.Tuple1 ||
      val.tag == CLTypeTag.Tuple2 ||
      val.tag == CLTypeTag.Tuple3) {
    return Ok(CLTupleBytesParser());
  }

  if (val.tag == CLTypeTag.Option) {
    return Ok(CLOptionBytesParser());
  }

  if (val.tag == CLTypeTag.Result) {
    return Ok(CLResultBytesParser());
  }

  if (val.tag == CLTypeTag.String) {
    return Ok(CLStringBytesParser());
  }

  if (val.tag == CLTypeTag.Unit) {
    return Ok(CLUnitBytesParser());
  }

  return Err('Unknown type');
}

ResultAndRemainder<CLType, String> matchBytesToCLType(Uint8List bytes) {
  var tag = bytes[0];
  var remainder = bytes.sublist(1);

  if (tag == CLTypeTag.Bool.value) {
    return resultHelper(Ok(CLBoolType()), remainder);
  }

  if (tag == CLTypeTag.I32.value) {
    return resultHelper(Ok(CLI32Type()), remainder);
  }

  if (tag == CLTypeTag.I64.value) {
    return resultHelper(Ok(CLI64Type()), remainder);
  }

  if (tag == CLTypeTag.U8.value) {
    return resultHelper(Ok(CLU8Type()), remainder);
  }

  if (tag == CLTypeTag.U32.value) {
    return resultHelper(Ok(CLU32Type()), remainder);
  }

  if (tag == CLTypeTag.U64.value) {
    return resultHelper(Ok(CLU64Type()), remainder);
  }

  if (tag == CLTypeTag.U64.value) {
    return resultHelper(Ok(CLU64Type()), remainder);
  }

  if (tag == CLTypeTag.U128.value) {
    return resultHelper(Ok(CLU128Type()), remainder);
  }

  if (tag == CLTypeTag.U256.value) {
    return resultHelper(Ok(CLU256Type()), remainder);
  }

  if (tag == CLTypeTag.U512.value) {
    return resultHelper(Ok(CLU512Type()), remainder);
  }

  if (tag == CLTypeTag.Unit.value) {
    return resultHelper(Ok(CLUnitType()), remainder);
  }

  if (tag == CLTypeTag.String.value) {
    return resultHelper(Ok(CLStringType()), remainder);
  }

  if (tag == CLTypeTag.Key.value) {
    return resultHelper(Ok(CLKeyType()), remainder);
  }

  if (tag == CLTypeTag.URef.value) {
    return resultHelper(Ok(CLURefType()), remainder);
  }

  if (tag == CLTypeTag.Option.value) {
    var res = matchBytesToCLType(remainder);
    var innerType = res.result.unwrap();

    return resultHelper(Ok(CLOptionType(innerType)), res.remainder);
  }

  if (tag == CLTypeTag.List.value) {
    var res = matchBytesToCLType(remainder);
    var innerType = res.result.unwrap();
    return resultHelper(Ok(CLListType(innerType)), res.remainder);
  }

  if (tag == CLTypeTag.ByteArray.value) {
    var res = matchBytesToCLType(remainder);
    var innerType = res.result.unwrap();
    return resultHelper(Ok(CLListType(innerType)), res.remainder);
  }

  if (tag == CLTypeTag.Result.value) {
    var okTypeRes = matchBytesToCLType(remainder);
    var okType = okTypeRes.result.unwrap();

    if (okTypeRes.remainder == null) {
      return resultHelper(Err('Missing Error type bytes in Result'));
    }

    var errTypeRes =
        matchBytesToCLType(okTypeRes.remainder ?? Uint8List.fromList([]));
    var errType = errTypeRes.result.unwrap();

    var map = CLResultTypeMap(okType, errType);
    return resultHelper(Ok(CLResultType(map)), errTypeRes.remainder);
  }

  if (tag == CLTypeTag.Map.value) {
    var keyTypeRes = matchBytesToCLType(remainder);
    var keyType = keyTypeRes.result.unwrap();

    if (keyTypeRes.remainder == null) {
      return resultHelper(Err('Missing Key type bytes in Map'));
    }

    var valTypeRes =
        matchBytesToCLType(keyTypeRes.remainder ?? Uint8List.fromList([]));
    var valType = valTypeRes.result.unwrap();

    return resultHelper(
        Ok(CLMapType({keyType: valType})), valTypeRes.remainder);
  }

  if (tag == CLTypeTag.Tuple1.value) {
    var innerTypeRes = matchBytesToCLType(remainder);
    var innerType = innerTypeRes.result.unwrap();

    return resultHelper(Ok(CLTuple1Type([innerType])), innerTypeRes.remainder);
  }

  if (tag == CLTypeTag.Tuple2.value) {
    var innerType1Res = matchBytesToCLType(remainder);
    var innerType1 = innerType1Res.result.unwrap();

    if (innerType1Res.remainder == null) {
      return resultHelper(
          Err('Missing second tuple type bytes in CLTuple2Type'));
    }

    var innerType2Res =
        matchBytesToCLType(innerType1Res.remainder ?? Uint8List.fromList([]));
    var innerType2 = innerType2Res.result.unwrap();

    return resultHelper(
        Ok(CLTuple1Type([innerType1, innerType2])), innerType2Res.remainder);
  }

  if (tag == CLTypeTag.Tuple3.value) {
    var innerType1Res = matchBytesToCLType(remainder);
    var innerType1 = innerType1Res.result.unwrap();

    if (innerType1Res.remainder == null) {
      return resultHelper(
          Err('Missing second tuple type bytes in CLTuple2Type'));
    }

    var innerType2Res =
        matchBytesToCLType(innerType1Res.remainder ?? Uint8List.fromList([]));
    var innerType2 = innerType2Res.result.unwrap();

    if (innerType2Res.remainder == null) {
      return resultHelper(
          Err('Missing third tuple type bytes in CLTuple2Type'));
    }

    var innerType3Res =
        matchBytesToCLType(innerType2Res.remainder ?? Uint8List.fromList([]));
    var innerType3 = innerType3Res.result.unwrap();

    return resultHelper(Ok(CLTuple1Type([innerType1, innerType2, innerType3])),
        innerType3Res.remainder ?? Uint8List.fromList([]));
  }

  if (tag == CLTypeTag.Any.value) {
    return resultHelper(Err('Any unsupported'));
  }

  if (tag == CLTypeTag.PublicKey.value) {
    return resultHelper(Ok(CLPublicKeyType()));
  }

  return resultHelper(Err('Unsupported type'), remainder);
}

String padNum(String v, [int n = 1]) {
  var arr = List<String>.filled(n, '');
  var arr2 = arr.join('0');
  var index = (n | 2);
  var str = arr2;

  if (index >= 0 && index <= arr2.length) {
    str = arr2.substring(arr2.length - (n | 2));
  }
  return str + v;
}

Uint8List byteHash(Uint8List x) {
  var hasher = Hash.blake2b;
  return hasher(x, digestSize: 32);
}
