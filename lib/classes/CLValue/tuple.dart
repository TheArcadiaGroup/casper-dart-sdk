import 'dart:typed_data';

import 'package:oxidized/oxidized.dart';
import 'package:collection/collection.dart';

import 'abstract.dart';
import 'constants.dart';
import 'utils.dart';

class CLTupleType extends CLType {
  @override
  late CLTypeTag tag;

  @override
  late Type linksTo;

  late List<CLType> inner;

  @override
  Map<String, dynamic> toJson() {
    var id = TUPLE_MATCH_LEN_TO_ID[inner.length - 1];
    return {id: inner.map((t) => t.toJson()).toList()};
  }

  CLTupleType(this.inner, this.linksTo, this.tag);

  @override
  String toString() {
    var innerTypes = inner.map((e) => e.toString()).join(', ');
    return 'Tuple${inner.length} ($innerTypes)';
  }

  @override
  Uint8List toBytes() {
    var _inner = inner.map((t) => t.toBytes()).toList();
    return Uint8List.fromList([
      ...Uint8List.fromList([tag.value]),
      ..._inner.expand((element) => element)
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other.runtimeType != runtimeType) return false;

    other as CLTupleType;
    return toString() == other.toString();
  }

  @override
  int get hashCode => tag.hashCode;
}

class CLTupleBytesParser extends CLValueBytesParsers {
  @override
  ResultAndRemainder<CLValue, CLErrorCodes> fromBytesWithRemainder(
      Uint8List bytes,
      [CLType? innerType]) {
    var rem = bytes;
    innerType as CLTupleType;
    var val = innerType.inner.map((CLType t) {
      var parser = matchByteParserByCLType(t).unwrap();
      var vRes = parser.fromBytesWithRemainder(rem, t);

      rem = vRes.remainder!;
      return vRes.result.unwrap();
    }).toList();

    if (val.length == 1) {
      return resultHelper(Ok(CLTuple1(val)), rem);
    }
    if (val.length == 2) {
      return resultHelper(Ok(CLTuple2(val)), rem);
    }
    if (val.length == 3) {
      return resultHelper(Ok(CLTuple3(val)), rem);
    }
    return resultHelper(Err(CLErrorCodes.Formatting));
  }

  @override
  Result<Uint8List, CLErrorCodes> toBytes(CLValue val) {
    val as CLTuple;
    var bytes =
        val.data.map((d) => CLValueParsers.toBytes(d).unwrap().toList());
    return Ok(Uint8List.fromList([...bytes.expand((element) => element)]));
  }
}

class CLTuple extends CLValue {
  @override
  late List<CLValue> data;
  late int tupleSize;

  CLTuple(int size, List<CLValue> v) {
    if (v.length > size) {
      throw Exception('Too many elements!');
    }

    tupleSize = size;
    data = v;
  }

  @override
  CLType clType() {
    throw UnimplementedError();
  }

  @override
  List<CLValue> value() {
    return data;
  }

  CLValue get(int index) {
    return data.elementAt(index);
  }

  void set(int index, CLValue item) {
    if (index >= tupleSize) {
      throw Exception('Tuple index out of bounds.');
    }

    data[index] = item;
  }

  void push(CLValue item) {
    if (data.length < tupleSize) {
      data.add(item);
    } else {
      throw Exception('No more space in this tuple!');
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    other as CLTuple;
    Function eq = const ListEquality().equals;
    return eq(data, other.data) && tupleSize == other.tupleSize;
  }

  @override
  int get hashCode => data.hashCode;
}

class CLTuple1Type extends CLTupleType {
  CLTuple1Type(List<CLType> inner) : super(inner, CLTuple1, CLTypeTag.Tuple1);
}

class CLTuple1 extends CLTuple {
  CLTuple1(List<CLValue> value) : super(1, value);

  @override
  CLType clType() {
    return CLTuple1Type(data.map((e) => e.clType()).toList());
  }
}

class CLTuple2Type extends CLTupleType {
  CLTuple2Type(List<CLType> inner) : super(inner, CLTuple2, CLTypeTag.Tuple2);
}

class CLTuple2 extends CLTuple {
  CLTuple2(List<CLValue> value) : super(2, value);

  @override
  CLType clType() {
    return CLTuple2Type(data.map((e) => e.clType()).toList());
  }
}

class CLTuple3Type extends CLTupleType {
  CLTuple3Type(List<CLType> inner) : super(inner, CLTuple3, CLTypeTag.Tuple3);
}

class CLTuple3 extends CLTuple {
  CLTuple3(List<CLValue> value) : super(3, value);

  @override
  CLType clType() {
    return CLTuple3Type(data.map((e) => e.clType()).toList());
  }
}
