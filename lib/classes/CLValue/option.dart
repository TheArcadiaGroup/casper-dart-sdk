// ignore_for_file: constant_identifier_names

import 'dart:typed_data';

import 'package:oxidized/oxidized.dart';

import 'abstract.dart';
import 'bool.dart';
import 'constants.dart';
import 'numeric.dart';
import 'utils.dart';

const OPTION_TAG_NONE = 0;

const OPTION_TAG_SOME = 1;

class CLOptionType<T extends CLType> extends CLType {
  @override
  get linksTo => CLOption;

  @override
  CLTypeTag get tag => CLTypeTag.Option;

  T? inner;

  CLOptionType(this.inner);

  @override
  String toString() {
    if (inner == null) {
      return '$OPTION_ID (NONE)';
    }

    return '$OPTION_ID (${inner.toString()})';
  }

  @override
  Uint8List toBytes() {
    return Uint8List.fromList([
      ...Uint8List.fromList([tag.value]),
      ...inner!.toBytes()
    ]);
  }

  @override
  Map<String, dynamic> toJson() => {OPTION_ID: inner!.toJson()};
}

class CLOptionBytesParser extends CLValueBytesParsers {
  @override
  ResultAndRemainder<CLOption<CLValue>, CLErrorCodes> fromBytesWithRemainder(
      Uint8List bytes,
      [CLType? innerType]) {
    var u8Res = CLU8BytesParser().fromBytesWithRemainder(bytes);
    var number = u8Res.result.unwrap().value();
    var optionTag = number.toNumber();

    innerType as CLOptionType<CLType>;
    if (optionTag == OPTION_TAG_NONE) {
      return resultHelper(Ok(CLOption(const None<CLValue>(), innerType.inner)),
          u8Res.remainder);
    }

    if (optionTag == OPTION_TAG_SOME) {
      if (u8Res.remainder == null) {
        return resultHelper(Err(CLErrorCodes.EarlyEndOfStream));
      }

      var parser =
          matchByteParserByCLType(innerType.inner ?? CLBoolType()).unwrap();
      var valRes = parser.fromBytesWithRemainder(
          u8Res.remainder ?? Uint8List.fromList([]), innerType.inner);
      var clValue = valRes.result.unwrap();

      return resultHelper(Ok(CLOption(Some(clValue))), valRes.remainder);
    }

    return resultHelper(Err(CLErrorCodes.Formatting));
  }

  @override
  Result<Uint8List, CLErrorCodes> toBytes(CLValue val) {
    val as CLOption<CLValue>;

    if (val.data.isNone()) {
      return Ok(Uint8List.fromList([OPTION_TAG_NONE]));
    }
    if (val.data.isSome()) {
      return Ok(Uint8List.fromList([
        ...Uint8List.fromList([OPTION_TAG_SOME]),
        ...CLValueParsers.toBytes(val.data.unwrap()).unwrap()
      ]));
    }

    return Err(CLErrorCodes.UnknownValue);
  }
}

class CLOption<T extends CLValue> extends CLValue {
  @override
  late Option<T> data;
  late CLType innerType;

  CLOption(Option<T> _data, [CLType? _innerType]) {
    data = _data;
    if (_data.isNone()) {
      if (_innerType == null) {
        throw Exception('You had to assign innerType for None');
      }
      innerType = _innerType;
    } else {
      innerType = _data.unwrap().clType();
    }
  }

  @override
  CLType clType() {
    return CLOptionType(innerType);
  }

  @override
  Option<T> value() {
    return data;
  }

  ///
  /// Checks whether the `Option` contains no value.
  ///
  /// @returns True if the `Option` has no value.
  ///
  bool isNone() {
    return data.isNone();
  }

  /// Checks whether the `Option` contains a value.
  ///
  /// @returns True if the `Option` has some value.
  bool isSome() {
    return data.isSome();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    other as CLOption<CLValue>;

    if (data.isNone() && other.data.isNone()) {
      return true;
    }

    var v1 = other.data.unwrap();
    var v2 = data.unwrap();

    return v1 == v2;
  }

  @override
  int get hashCode => data.hashCode;
}
