import 'dart:typed_data';
import 'package:oxidized/oxidized.dart';
import 'package:json_annotation/json_annotation.dart';
import '../byte_converters.dart';
import '../conversions.dart';

import 'constants.dart';
import 'numeric.dart';
import 'utils.dart';

part 'abstract.g.dart';

class ResultAndRemainder<T extends Object, E extends Object> {
  late Result<T, E> result;
  late Uint8List? remainder;

  ResultAndRemainder(Result<T, E> _result, Uint8List? _remainder) {
    result = _result;
    remainder = _remainder;
  }
}

@JsonSerializable(explicitToJson: true)
class CLJSONFormat {
  late String bytes;

  @JsonKey(name: 'cl_type')
  late dynamic clType;

  CLJSONFormat(this.bytes, this.clType);

  @override
  String toString() {
    return '{"bytes":"$bytes","cl_type":$clType}';
  }

  factory CLJSONFormat.fromJson(Map<String, dynamic> json) =>
      _$CLJSONFormatFromJson(json);
  Map<String, dynamic> toJson() => _$CLJSONFormatToJson(this);
}

ResultAndRemainder<T, E> resultHelper<T extends Object, E extends Object>(
    Result<T, E> arg1,
    [Uint8List? arg2]) {
  return ResultAndRemainder(arg1, arg2);
}

abstract class CLType {
  @override
  String toString();
  dynamic toJson();
  dynamic get linksTo;
  CLTypeTag get tag;

  Uint8List toBytes() {
    return Uint8List.fromList(List.from([tag.value]));
  }
}

abstract class ToBytes {
  Result<Uint8List, CLErrorCodes> toBytes();
}

abstract class CLValue {
  dynamic get data;
  bool isCLValue = true;
  CLType clType();
  dynamic value();
}

class CLValueParsers {
  static Result<CLValue, String> fromJSON(dynamic json) {
    CLType clType = matchTypeToCLType(json['cl_type']);
    Uint8List uint8Bytes = base16Decode(json['bytes']);
    CLValue clEntity = CLValueParsers.fromBytes(uint8Bytes, clType).unwrap();
    return Ok(clEntity);
  }

  static Result<CLValue, CLErrorCodes> fromBytes(Uint8List bytes, CLType type) {
    CLValueBytesParsers parser = matchByteParserByCLType(type).unwrap();
    return parser.fromBytes(bytes, type);
  }

  static Result<CLJSONFormat, CLErrorCodes> toJSON(CLValue val) {
    var rawBytes = CLValueParsers.toBytes(val).unwrap();
    var bytes = base16Encode(rawBytes);
    var clType = val.clType().toJson();

    return Ok(CLJSONFormat(bytes, clType));
  }

  static Result<Uint8List, CLErrorCodes> toBytes(CLValue val) {
    CLValueBytesParsers bytes = matchByteParserByCLType(val.clType()).unwrap();
    return bytes.toBytes(val);
  }

  static Result<Uint8List, CLErrorCodes> toBytesWithType(CLValue value) {
    var clTypeBytes = value.clType().toBytes();
    var parser = matchByteParserByCLType(value.clType()).unwrap();
    var bytes = parser.toBytes(value).unwrap();
    var result = Uint8List.fromList([...toBytesArrayU8(bytes), ...clTypeBytes]);
    return Ok(result);
  }

  static Result<CLValue, CLErrorCodes> fromBytesWithType(Uint8List rawBytes) {
    var clu32Res = CLU32BytesParser().fromBytesWithRemainder(rawBytes);

    var val = clu32Res.result.unwrap();
    int length = val.value().toNumber() as int;

    if (clu32Res.remainder == null) {
      return Err(CLErrorCodes.EarlyEndOfStream);
    } else {
      var valueBytes = clu32Res.remainder!.sublist(0, length);
      var typeBytes = clu32Res.remainder!.sublist(length);
      var res = matchBytesToCLType(typeBytes);
      var clType = res.result.unwrap();
      var parser = matchByteParserByCLType(clType).unwrap();

      var clValue = parser.fromBytes(valueBytes, clType).unwrap();

      return Ok(clValue);
    }
  }
}

abstract class CLValueBytesParsers {
  Result<CLValue, CLErrorCodes> fromBytes(Uint8List bytes, CLType innerType) {
    ResultAndRemainder<CLValue, CLErrorCodes> result =
        fromBytesWithRemainder(bytes, innerType);

    if (result.remainder != null && result.remainder!.isNotEmpty) {
      return Err(CLErrorCodes.LeftOverBytes);
    }

    return result.result;
  }

  Result<Uint8List, CLErrorCodes> toBytes(CLValue val);

  ResultAndRemainder<CLValue, CLErrorCodes> fromBytesWithRemainder(
      Uint8List bytes,
      [CLType? innerType]);
}
