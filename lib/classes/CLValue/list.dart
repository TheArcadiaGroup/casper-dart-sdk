import 'dart:typed_data';

import 'package:oxidized/oxidized.dart';
import 'package:collection/collection.dart';

import 'abstract.dart';
import 'constants.dart';
import 'numeric.dart';
import 'utils.dart';

import '../byte_converters.dart';

class CLListType<T extends CLType> extends CLType {
  @override
  Type get linksTo => CLList;

  @override
  CLTypeTag get tag => CLTypeTag.List;

  late T inner;

  CLListType(this.inner);

  @override
  Map<String, dynamic> toJson() {
    var json = inner.toJson();
    return {LIST_ID: json};
  }

  @override
  String toString() {
    return "$LIST_ID (" + inner.toString() + ")";
  }

  @override
  Uint8List toBytes() {
    return Uint8List.fromList([
      ...Uint8List.fromList([tag.value]),
      ...inner.toBytes()
    ]);
  }
}

class CLListBytesParser extends CLValueBytesParsers {
  @override
  ResultAndRemainder<CLList, CLErrorCodes> fromBytesWithRemainder(
      Uint8List bytes,
      [CLType? innerType]) {
    var u32Res = CLU32BytesParser().fromBytesWithRemainder(bytes, innerType);

    if (u32Res.result.isErr()) {
      return resultHelper(Err(u32Res.result.unwrapErr()));
    }

    CLU32 val = u32Res.result.unwrap();
    var size = val.value().toNumber();
    List<CLValue> vec = List.empty(growable: true);
    var remainder = u32Res.remainder;

    innerType as CLListType<CLType>;
    CLValueBytesParsers parser =
        matchByteParserByCLType(innerType.inner).unwrap();

    for (var i = 0; i < size; i++) {
      if (remainder == null) {
        return resultHelper(Err(CLErrorCodes.EarlyEndOfStream));
      }

      ResultAndRemainder<CLValue, CLErrorCodes> vRes =
          parser.fromBytesWithRemainder(remainder, innerType.inner);

      if (vRes.result.isErr()) {
        return resultHelper(Err(vRes.result.unwrapErr()));
      }

      vec.add(vRes.result.unwrap());
      remainder = vRes.remainder;
    }

    if (vec.isEmpty) {
      return resultHelper(Ok(CLList.fromCType(innerType.inner)), remainder);
    }

    return resultHelper(Ok(CLList.fromList(vec)), remainder);
  }

  @override
  Result<Uint8List, CLErrorCodes> toBytes(CLValue val) {
    return Ok(toBytesVectorNew(val.data));
  }
}

class CLList<T extends CLValue> extends CLValue {
  @override
  late List<T> data;
  late CLType vectorType;

  CLList.fromList(List<T> v) {
    var refType = v[0].clType();

    if (v.every((i) => i.clType().toString() == refType.toString())) {
      data = v;
      vectorType = refType;
    } else {
      throw Exception('Invalid data provided.');
    }
  }

  CLList.fromCType(CLType v) {
    vectorType = v;
    data = [];
  }

  @override
  CLType clType() {
    return CLListType(vectorType);
  }

  @override
  List<T> value() {
    return data;
  }

  T get(int index) {
    if (index >= data.length) {
      throw Exception('List index out of bounds.');
    }

    return data[index];
  }

  void set(int index, T item) {
    if (index >= data.length) {
      throw Exception('List index out of bounds.');
    }

    data[index] = item;
  }

  void push(T item) {
    if (item.clType().toString() == vectorType.toString()) {
      data.add(item);
    } else {
      throw Exception(
          'Incosnsistent data type, use ' + vectorType.toString() + '.');
    }
  }

  void remove(int index) {
    data.removeAt(index);
  }

  dynamic pop() {
    return data.removeLast();
  }

  int size() {
    return data.length;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    other as CLList<CLValue>;

    Function eq = const ListEquality().equals;
    return eq(data, other.data) &&
        vectorType.toString() == other.vectorType.toString();
  }

  @override
  int get hashCode => data.hashCode;
}
