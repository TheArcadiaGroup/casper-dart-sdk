// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:oxidized/oxidized.dart';

import 'abstract.dart';
import 'constants.dart';
import 'key.dart';
import 'utils.dart';
import '../conversions.dart';

enum AccessRights {
  None,
  READ,
  WRITE,
  ADD,
  READ_WRITE,
  READ_ADD,
  ADD_WRITE,
  READ_ADD_WRITE
}

extension AccessRightsExtension on AccessRights {
  int get accessValue {
    switch (this) {
      case AccessRights.None:
        return 0;
      case AccessRights.READ:
        return 1;
      case AccessRights.WRITE:
        return 2;
      case AccessRights.ADD:
        return 4;
      case AccessRights.READ_WRITE:
        return 1 | 2;
      case AccessRights.READ_ADD:
        return 1 | 4;
      case AccessRights.ADD_WRITE:
        return 4 | 2;
      case AccessRights.READ_ADD_WRITE:
        return 1 | 4 | 2;
      default:
        return 0;
    }
  }
}

class CLURefType extends CLType {
  @override
  Type get linksTo => CLURef;

  @override
  CLTypeTag get tag => CLTypeTag.URef;

  @override
  String toString() => UREF_ID;

  @override
  String toJson() => UREF_ID;
}

String FORMATTED_STRING_PREFIX = 'uref';

/// Length of [[URef]] address field.
/// @internal
int UREF_ADDR_LENGTH = 32;

/// Length of [[ACCESS_RIGHT]] field.
/// @internal
int ACCESS_RIGHT_LENGTH = 1;

int UREF_BYTES_LENGTH = UREF_ADDR_LENGTH + ACCESS_RIGHT_LENGTH;

class CLURefBytesParser extends CLValueBytesParsers {
  @override
  Result<Uint8List, CLErrorCodes> toBytes(CLValue val) {
    if (val is CLKey) {
      if (val.isURef()) {
        var uref = val.data as CLURef;
        return Ok(Uint8List.fromList([
          ...uref.data,
          ...Uint8List.fromList([uref.accessRights.accessValue])
        ]));
      }
    } else {
      val as CLURef;
      return Ok(Uint8List.fromList([
        ...val.data,
        ...Uint8List.fromList([val.accessRights.accessValue])
      ]));
    }

    return Err(CLErrorCodes.EarlyEndOfStream);
  }

  @override
  ResultAndRemainder<CLURef, CLErrorCodes> fromBytesWithRemainder(
      Uint8List bytes,
      [CLType? innerType]) {
    if (bytes.length < UREF_BYTES_LENGTH) {
      return resultHelper(Err(CLErrorCodes.EarlyEndOfStream));
    }

    var urefBytes = bytes.sublist(0, UREF_ADDR_LENGTH);
    var accessRights = bytes[UREF_BYTES_LENGTH - 1];
    var uref = CLURef(urefBytes,
        AccessRights.values.firstWhere((e) => e.index == accessRights));
    return resultHelper(Ok(uref), bytes.sublist(UREF_BYTES_LENGTH));
  }
}

class CLURef extends CLValue {
  @override
  late Uint8List data;
  late AccessRights accessRights;

  //
  /// Constructs new instance of URef.
  /// @param uRefAddr Bytes representing address of the URef.
  /// @param accessRights Access rights flag. Use [[AccessRights.NONE]] to indicate no permissions.
  ///
  CLURef(Uint8List v, AccessRights _accessRights) {
    if (v.length != 32) {
      throw Exception('The length of URefAddr should be 32');
    }

    if (!AccessRights.values.contains(_accessRights)) {
      throw Exception('Unsuported AccessRights');
    }

    data = v;
    accessRights = _accessRights;
  }

  @override
  CLType clType() {
    return CLURefType();
  }

  @override
  dynamic value() {
    return {'data': data, 'accessRights': accessRights};
  }

  ///
  /// Parses a casper-client supported string formatted argument into a `URef`.
  ///
  static CLURef fromFormattedStr(String input) {
    if (!input.startsWith("$FORMATTED_STRING_PREFIX-")) {
      throw Exception("Prefix is not 'uref-'");
    }

    List<String> parts =
        input.substring("$FORMATTED_STRING_PREFIX-".length).split('-');

    if (parts.length != 2) {
      throw Exception('No access rights as suffix');
    } else {
      parts = parts.sublist(0, 2);
    }

    var addr = base16Decode(parts[0]);
    var accessRights = AccessRights.values
        .firstWhere((e) => e.accessValue == int.parse(parts[1]));

    return CLURef(addr, accessRights);
  }

  String toFormattedStr() {
    return [
      FORMATTED_STRING_PREFIX,
      base16Encode(data),
      padNum(accessRights.accessValue.toString(), 3)
    ].join('-');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other.runtimeType != runtimeType) return false;

    other as CLURef;
    Function eq = const ListEquality().equals;
    return eq(data, other.data);
  }

  @override
  int get hashCode => data.hashCode;
}
