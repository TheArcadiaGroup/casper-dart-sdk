import 'dart:typed_data';

import 'package:casper_dart_sdk/classes/CLValue/abstract.dart';
import 'package:casper_dart_sdk/classes/CLValue/builders.dart';
import 'package:casper_dart_sdk/classes/CLValue/byte_array.dart';
import 'package:casper_dart_sdk/classes/CLValue/list.dart';
import 'package:casper_dart_sdk/classes/CLValue/numeric.dart';
import 'package:casper_dart_sdk/classes/CLValue/option.dart';
import 'package:casper_dart_sdk/classes/conversions.dart';
import 'package:casper_dart_sdk/classes/keys.dart';
import 'package:casper_dart_sdk/classes/runtime_args.dart';
import 'package:oxidized/oxidized.dart';
import 'package:test/test.dart';

void main() {
  group('RunTimeArgs', () {
    test('should serialize RuntimeArgs correctly', () {
      var args = RuntimeArgs.fromMap({'foo': CLValueBuilder.i32(1)});

      var bytes = args.toBytes().unwrap();

      expect(
          bytes,
          Uint8List.fromList([
            1,
            0,
            0,
            0,
            3,
            0,
            0,
            0,
            102,
            111,
            111,
            4,
            0,
            0,
            0,
            1,
            0,
            0,
            0,
            1
          ]));
    });

    test('should serialize empty NamedArgs correctly', () {
      var truth = decodeBase16('00000000');
      var runtimeArgs = RuntimeArgs.fromMap({});
      var bytes = runtimeArgs.toBytes().unwrap();
      expect(bytes, truth);
    });

    test('should deserialize RuntimeArgs', () {
      var a = CLValueBuilder.u512(123);
      var runtimeArgs = RuntimeArgs.fromMap({
        'a': CLValueBuilder.option(None(), a.clType()),
        'b': CLValueBuilder.option(None(), a.clType()),
      });

      var serializer = runtimeArgs.toJson();
      var value = RuntimeArgs.fromJson(serializer);

      expect((value.args['a'] as CLOption<CLValue>).isNone(), true);
    });

    test('should allow to extract lists of account hashes.', () {
      var account0 = Ed25519.newKey().accountHash();
      var account1 = Ed25519.newKey().accountHash();
      var account0byteArray = CLValueBuilder.byteArray(account0);
      var account1byteArray = CLValueBuilder.byteArray(account1);
      var runtimeArgs = RuntimeArgs.fromMap({
        'accounts': CLValueBuilder.list([account0byteArray, account1byteArray])
      });
      var accounts = runtimeArgs.args['accounts'] as CLList<CLByteArray>;

      expect(accounts.get(0), account0byteArray);
      expect(accounts.get(1), account1byteArray);
    });
  });
}
