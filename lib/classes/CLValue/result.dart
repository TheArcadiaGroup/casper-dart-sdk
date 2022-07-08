// ignore_for_file: constant_identifier_names
import 'package:oxidized/oxidized.dart';
import 'package:pinenacl/ed25519.dart';

import 'abstract.dart';
import 'constants.dart';
import 'numeric.dart';
import 'utils.dart';

const RESULT_TAG_ERROR = 0;
const RESULT_TAG_OK = 1;

class CLResultTypeMap<T extends CLType, E extends CLType> {
  late T ok;
  late E err;

  CLResultTypeMap(this.ok, this.err);
}

class CLResultType<T extends CLType, E extends CLType> extends CLType {
  @override
  get linksTo => CLResult;

  @override
  CLTypeTag get tag => CLTypeTag.Result;

  late T innerOk;
  late E innerErr;

  CLResultType(CLResultTypeMap<T, E> map) {
    innerOk = map.ok;
    innerErr = map.err;
  }

  @override
  String toString() {
    return '$RESULT_ID (OK: ${innerOk.toString()}, ERR: ${innerOk.toString()})';
  }

  @override
  Map<String, dynamic> toJson() => {
        RESULT_ID: {"ok": innerOk.toJson(), "err": innerErr.toJson()}
      };

  @override
  Uint8List toBytes() {
    return Uint8List.fromList([
      ...Uint8List.fromList([tag.value]),
      ...innerOk.toBytes(),
      ...innerErr.toBytes()
    ]);
  }
}

class CLResultBytesParser extends CLValueBytesParsers {
  @override
  ResultAndRemainder<CLValue, CLErrorCodes> fromBytesWithRemainder(
      Uint8List bytes,
      [CLType? innerType]) {
    var u8Res = CLU8BytesParser().fromBytesWithRemainder(bytes);

    if (u8Res.remainder == null) {
      return resultHelper(Err(CLErrorCodes.EarlyEndOfStream));
    }

    var resultTag = u8Res.result.unwrap().value().toNumber();
    innerType as CLResultType<CLType, CLType>;
    var referenceErr = innerType.innerErr;
    var referenceOk = innerType.innerOk;

    if (resultTag == RESULT_TAG_ERROR) {
      var parser = matchByteParserByCLType(referenceErr).unwrap();
      var valRes = parser.fromBytesWithRemainder(
          u8Res.remainder ?? Uint8List.fromList([]), innerType.innerErr);

      var val = CLResult(Err(valRes.result.unwrap()),
          CLResultTypeMap(referenceOk, referenceErr));

      return resultHelper(Ok(val), valRes.remainder);
    }

    if (resultTag == RESULT_TAG_OK) {
      var parser = matchByteParserByCLType(referenceOk).unwrap();
      var valRes = parser.fromBytesWithRemainder(
          u8Res.remainder ?? Uint8List.fromList([]), innerType.innerOk);

      var val = CLResult(Ok(valRes.result.unwrap()),
          CLResultTypeMap(referenceOk, referenceErr));

      return resultHelper(Ok(val), valRes.remainder);
    }

    return resultHelper(Err(CLErrorCodes.Formatting));
  }

  @override
  Result<Uint8List, CLErrorCodes> toBytes(CLValue val) {
    val as CLResult<CLType, CLType>;

    var v = val.isOk() ? val.data.unwrap() : val.data.unwrapErr();

    if (val.isOk() && v.isCLValue) {
      return Ok(Uint8List.fromList([
        ...Uint8List.fromList([RESULT_TAG_OK]),
        ...CLValueParsers.toBytes(v).unwrap()
      ]));
    } else if (val.isError()) {
      return Ok(Uint8List.fromList([
        ...Uint8List.fromList([RESULT_TAG_ERROR]),
        ...CLValueParsers.toBytes(v).unwrap()
      ]));
    } else {
      throw Exception('Unproper data stored in CLResult');
    }
  }
}

class CLResult<T extends CLType, E extends CLType> extends CLValue {
  @override
  late Result<CLValue, CLValue> data;
  late T innerOk;
  late E innerErr;

  CLResult(this.data, CLResultTypeMap<T, E> map) {
    innerOk = map.ok;
    innerErr = map.err;
  }

  @override
  CLType clType() {
    return CLResultType(CLResultTypeMap(innerOk, innerErr));
  }

  @override
  Result<CLValue, CLValue> value() {
    return data;
  }

  bool isError() {
    return data.isErr();
  }

  bool isOk() {
    return data.isOk();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    other as CLResult<CLType, CLType>;

    if (isError() && other.isError()) {
      return data.unwrapErr() == other.data.unwrapErr();
    }

    return data.unwrap() == other.data.unwrap();
  }

  @override
  int get hashCode => data.hashCode;
}
