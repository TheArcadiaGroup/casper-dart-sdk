import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';
import 'package:oxidized/oxidized.dart';

import 'byte_converters.dart';
import 'CLValue/abstract.dart';
import 'CLValue/constants.dart';
import 'CLValue/numeric.dart';
import 'CLValue/string.dart';

part 'runtime_args.g.dart';

class NamedArgs implements ToBytes {
  late String name;
  late CLValue value;

  NamedArgs(this.name, this.value);

  @override
  Result<Uint8List, CLErrorCodes> toBytes() {
    var name = toBytesString(this.name);
    var value = CLValueParsers.toBytesWithType(this.value);
    return Ok(Uint8List.fromList([
      ...name,
      ...value.unwrap(),
    ]));
  }

  static ResultAndRemainder<NamedArgs, String> fromBytes(Uint8List bytes) {
    var nameRes = CLStringBytesParser().fromBytesWithRemainder(bytes);
    var name = nameRes.result.unwrap();

    if (nameRes.remainder == null) {
      return resultHelper(Err('Missing data for value of named arg'));
    }

    var value = CLValueParsers.fromBytesWithType(
            nameRes.remainder ?? Uint8List.fromList([]))
        .unwrap();
    return resultHelper(Ok(NamedArgs(name.value(), value)));
  }
}

Map<String, CLValue> desRA(List<List<dynamic>> data) {
  Map<String, CLValue> result = {};

  for (var item in data) {
    var val = CLValueParsers.fromJSON(
        item[1] is CLJSONFormat ? item[1].toJson() : item[1]);
    result[item[0]] = val.unwrap();
  }
  return result;
}

List<List<dynamic>> serRA(Map<String, CLValue> map) {
  List<List<dynamic>> result = List.empty(growable: true);
  for (var arg in map.entries) {
    var subList = List.empty(growable: true);

    subList.addAll([arg.key, CLValueParsers.toJSON(arg.value).unwrap()]);
    result.add(subList);
  }
  return result;
}

@JsonSerializable(explicitToJson: true)
class RuntimeArgs implements ToBytes {
  @JsonKey(fromJson: desRA, toJson: serRA)
  late Map<String, CLValue> args;

  RuntimeArgs(this.args);

  factory RuntimeArgs.fromJson(Map<String, dynamic> json) =>
      _$RuntimeArgsFromJson(json);
  Map<String, dynamic> toJson() => _$RuntimeArgsToJson(this);

  @override
  Result<Uint8List, CLErrorCodes> toBytes() {
    List<NamedArgs> list = List.empty(growable: true);
    for (var arg in args.entries) {
      list.add(NamedArgs(arg.key, arg.value));
    }

    return Ok(toBytesVector(list));
  }

  ResultAndRemainder<RuntimeArgs, String> fromBytes(Uint8List bytes) {
    var sizeRes = CLU32BytesParser().fromBytesWithRemainder(bytes);
    var size = sizeRes.result.unwrap().value().toNumber();

    var remainBytes = sizeRes.remainder;
    List<NamedArgs> res = List.empty(growable: true);

    for (var i = 0; i < size; i++) {
      if (remainBytes == null) {
        return resultHelper(Err('Error while parsing bytes'));
      }

      var namedArgRes = NamedArgs.fromBytes(remainBytes);

      res.add(namedArgRes.result.unwrap());
      remainBytes = namedArgRes.remainder;
    }

    return resultHelper(Ok(RuntimeArgs.fromNamedArgs(res)), remainBytes);
  }

  static RuntimeArgs fromMap(Map<String, CLValue> args) {
    return RuntimeArgs(args);
  }

  static RuntimeArgs fromNamedArgs(List<NamedArgs> namedArgs) {
    Map<String, CLValue> args = {};
    for (var arg in namedArgs) {
      args[arg.name] = arg.value;
    }
    return RuntimeArgs.fromMap(args);
  }

  void insert(String key, CLValue value) {
    args[key] = value;
  }
}
