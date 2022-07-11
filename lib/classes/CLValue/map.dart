import 'dart:typed_data';

import 'package:oxidized/oxidized.dart';

import 'abstract.dart';
import 'constants.dart';
import 'numeric.dart';
import 'utils.dart';
import '../byte_converters.dart';

class MapEntryType {
  late CLType key;
  late CLType value;

  MapEntryType(this.key, this.value);
}

class CLMapType<K extends CLType, V extends CLType> extends CLType {
  @override
  get linksTo => CLMap;

  @override
  CLTypeTag get tag => CLTypeTag.Map;

  late K innerKey;
  late V innerValue;

  CLMapType(Map<K, V> map) {
    innerKey = map.keys.first;
    innerValue = map.values.first;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      MAP_ID: {"key": innerKey.toString(), "value": innerValue.toString()}
    };
  }

  @override
  String toString() {
    return "$MAP_ID (${innerKey.toString()}: ${innerValue.toString()})";
  }

  @override
  Uint8List toBytes() {
    return Uint8List.fromList([
      ...Uint8List.fromList([tag.value]),
      ...innerKey.toBytes(),
      ...innerValue.toBytes()
    ]);
  }
}

class CLMapBytesParser extends CLValueBytesParsers {
  @override
  ResultAndRemainder<CLMap, CLErrorCodes> fromBytesWithRemainder(
      Uint8List bytes,
      [CLType? innerType]) {
    innerType as CLMapType<CLType, CLType>;
    var u32Res = CLU32BytesParser().fromBytesWithRemainder(bytes);

    CLU32 val = u32Res.result.unwrap();
    var size = val.value().toNumber();
    List<Map<CLValue, CLValue>> vec = [];

    var remainder = u32Res.remainder;

    if (size == 0) {
      return resultHelper(
          Ok(CLMap.fromMap({innerType.innerKey: innerType.innerValue})));
    }

    for (var i = 0; i < size; i++) {
      if (remainder == null) {
        return resultHelper(Err(CLErrorCodes.EarlyEndOfStream));
      }

      CLValueBytesParsers keyParser =
          matchByteParserByCLType(innerType.innerKey).unwrap();
      var kRes =
          keyParser.fromBytesWithRemainder(remainder, innerType.innerKey);

      CLValue finalKey = kRes.result.unwrap();
      remainder = kRes.remainder;

      if (remainder == null) {
        return resultHelper(Err(CLErrorCodes.EarlyEndOfStream));
      }

      CLValueBytesParsers valParser =
          matchByteParserByCLType(innerType.innerValue).unwrap();
      var vRes =
          valParser.fromBytesWithRemainder(remainder, innerType.innerValue);

      CLValue finalValue = vRes.result.unwrap();
      remainder = vRes.remainder;

      vec.add({finalKey: finalValue});
    }

    return resultHelper(Ok(CLMap.fromList(vec)), remainder);
  }

  @override
  Result<Uint8List, CLErrorCodes> toBytes(CLValue val) {
    val as CLMap<CLValue, CLValue>;
    var list = val.data;
    var kvBytes = list.map((e) {
      Uint8List byteKey = CLValueParsers.toBytes(e.keys.first).unwrap();
      Uint8List byteVal = CLValueParsers.toBytes(e.values.first).unwrap();

      return [byteKey, byteVal].expand((element) => element).toList();
    }).toList();

    return Ok(Uint8List.fromList([
      ...toBytesU32(val.data.length),
      ...kvBytes.expand((element) => element).toList()
    ]));
  }
}

class CLMap<K extends CLValue, V extends CLValue> extends CLValue {
  @override
  late List<Map<K, V>> data;
  Map<CLType, CLType> refType = {};

  CLMap.fromList(List<Map<K, V>> v) {
    var key = v[0].keys.first;
    var value = v[0].values.first;
    refType[key.clType()] = value.clType();

    if (v.every((element) {
      return (element.keys.first.clType().toString() ==
              refType.keys.first.toString() &&
          element.values.first.clType().toString() ==
              refType.values.first.toString());
    })) {
      data = v;
    } else {
      throw Exception('Invalid data provided.');
    }
  }

  CLMap.fromMap(Map<CLType, CLType> v) {
    refType = v;
    data = [];
  }

  @override
  CLType clType() {
    return CLMapType(refType);
  }

  @override
  List<Map<K, V>> value() {
    return data;
  }

  V? get(K k) {
    var result = data.firstWhere(
      (d) => d.keys.first.value() == k.value(),
      orElse: () => {},
    );
    return result.values.isNotEmpty ? result.values.first : null;
  }

  void set(K k, V v) {
    if (get(k) != null) {
      data = data.map((e) {
        return e.keys.first.value() == k.value() ? {e.keys.first: v} : e;
      }).toList();
      return;
    }

    data.add({
      k: v,
    });
  }

  void delete(K k) {
    data.removeWhere((e) => e.keys.first.value() == k.value());
  }

  int size() {
    return data.length;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    other as CLMap<CLValue, CLValue>;

    if (data.length != other.data.length) return false;

    for (var i = 0; i < data.length; i++) {
      if (data[i].keys.first != other.data[i].keys.first) {
        return false;
      }

      if (data[i].values.first != other.data[i].values.first) {
        return false;
      }
    }

    return true;
  }

  @override
  int get hashCode => data.hashCode;
}
