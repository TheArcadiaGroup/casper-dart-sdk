import 'dart:typed_data';

import 'package:casper_dart_sdk/classes/CLValue/abstract.dart';
import 'package:casper_dart_sdk/classes/CLValue/account_hash.dart';
import 'package:casper_dart_sdk/classes/CLValue/builders.dart';
import 'package:casper_dart_sdk/classes/CLValue/public_key.dart';
import 'package:casper_dart_sdk/classes/CLValue/uref.dart';
import 'package:casper_dart_sdk/classes/byte_converters.dart';
import 'package:casper_dart_sdk/classes/conversions.dart';
import 'package:casper_dart_sdk/classes/keys.dart';
import 'package:oxidized/oxidized.dart';
import 'package:test/test.dart';

void main() {
  group('Byte Converters', () {
    test('CLU256 of zero after serialization should be equal to [0]', () {
      var toBytesNum128 = toBytesNumber(128, false);
      var toBytesNum256 = toBytesNumber(256, false);
      var toBytesNum512 = toBytesNumber(512, false);

      var expectedRes = Uint8List.fromList([0]);

      expect(toBytesNum128(0), expectedRes);
      expect(toBytesNum256(0), expectedRes);
      expect(toBytesNum512(0), expectedRes);
    });

    test('should be able to serialize/deserialize u8', () {
      var validBytes = Uint8List.fromList([0x0a]);
      var clVal = CLValueBuilder.u8(10);

      var clValFromBytes =
          CLValueParsers.fromBytes(validBytes, CLTypeBuilder.u8()).unwrap();
      var clValBytes = CLValueParsers.toBytes(clVal).unwrap();

      expect(clValFromBytes, clVal);
      expect(clValBytes, validBytes);
    });

    test('should be able to serialize/deserialize u32', () {
      var validBytes = Uint8List.fromList([0xc0, 0xd0, 0xe0, 0xf0]);
      var clVal = CLValueBuilder.u32(0xf0e0d0c0);

      var clValFromBytes =
          CLValueParsers.fromBytes(validBytes, CLTypeBuilder.u32()).unwrap();
      var clValBytes = CLValueParsers.toBytes(clVal).unwrap();

      expect(clValFromBytes, clVal);
      expect(clValBytes, validBytes);
    });

    test('should be able to serialize/deserialize i32', () {
      var validBytes = Uint8List.fromList([96, 121, 254, 255]);
      var clVal = CLValueBuilder.i32(-100000);

      var clValFromBytes =
          CLValueParsers.fromBytes(validBytes, CLTypeBuilder.i32()).unwrap();
      var clValBytes = CLValueParsers.toBytes(clVal).unwrap();

      expect(clValFromBytes, clVal);
      expect(clValBytes, validBytes);
    });

    test('should be able to serialize/deserialize i64', () {
      var validBytes = Uint8List.fromList([57, 20, 94, 139, 1, 121, 193, 2]);
      var clVal = CLValueBuilder.i64('198572906121139257');

      var clValFromBytes =
          CLValueParsers.fromBytes(validBytes, CLTypeBuilder.i64()).unwrap();
      var clValBytes = CLValueParsers.toBytes(clVal).unwrap();

      expect(clValFromBytes, clVal);
      expect(clValBytes, validBytes);

      var validBytes2 =
          Uint8List.fromList([40, 88, 148, 186, 102, 193, 241, 255]);
      var clVal2 = CLValueBuilder.i64('-4009477689550808');

      var clValFromBytes2 =
          CLValueParsers.fromBytes(validBytes2, CLTypeBuilder.i64()).unwrap();
      var clValBytes2 = CLValueParsers.toBytes(clVal2).unwrap();

      expect(clValFromBytes2, clVal2);
      expect(clValBytes2, validBytes2);
    });

    test('should be able to serialize/deserialize u64', () {
      var validBytes =
          Uint8List.fromList([57, 20, 214, 178, 212, 118, 11, 197]);
      var clVal = CLValueBuilder.u64('14198572906121139257');

      var clValFromBytes =
          CLValueParsers.fromBytes(validBytes, CLTypeBuilder.u64()).unwrap();
      var clValBytes = CLValueParsers.toBytes(clVal).unwrap();

      expect(clValFromBytes, clVal);
      expect(clValBytes, validBytes);
    });

    test('should be able to serialize/deserialize u128', () {
      var clVal = CLValueBuilder.u128(264848365584384);
      var validBytes = Uint8List.fromList([6, 0, 0, 192, 208, 224, 240]);

      var clValFromBytes =
          CLValueParsers.fromBytes(validBytes, CLTypeBuilder.u128()).unwrap();
      var clValBytes = CLValueParsers.toBytes(clVal).unwrap();

      expect(clValFromBytes.value(), clVal.value());
      expect(clValBytes, validBytes);
    });

    test('should be able to serialize/deserialize utf8 string', () {
      var clVal = CLValueBuilder.string('test_测试');
      var validBytes = Uint8List.fromList(
          [11, 0, 0, 0, 116, 101, 115, 116, 95, 230, 181, 139, 232, 175, 149]);

      var clValFromBytes =
          CLValueParsers.fromBytes(validBytes, CLTypeBuilder.string()).unwrap();
      var clValBytes = CLValueParsers.toBytes(clVal).unwrap();

      expect(clValFromBytes.data, clVal.data);
      expect(clValBytes, validBytes);
    });

    test('should be able to serialize/deserialize unit', () {
      var clVal = CLValueBuilder.unit();
      var validBytes = Uint8List.fromList([]);

      var clValFromBytes =
          CLValueParsers.fromBytes(validBytes, CLTypeBuilder.unit()).unwrap();
      var clValBytes = CLValueParsers.toBytes(clVal).unwrap();

      expect(clValFromBytes, clVal);
      expect(clValBytes, validBytes);
    });

    test('should serialize/deserialize URef variant of Key correctly', () {
      var urefAddr =
          '2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a';
      var clVal = CLValueBuilder.uref(
          decodeBase16(urefAddr), AccessRights.READ_ADD_WRITE);
      var validBytes = decodeBase16(
          '022a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a07');
      var bytes = CLValueParsers.toBytes(CLValueBuilder.key(clVal)).unwrap();

      expect(bytes, validBytes);

      var uref = CLURef.fromFormattedStr(
          'uref-d93dfedfc13180a0ea188841e64e0a1af718a733216e7fae4909dface372d2b0-007');
      var clVal2 = CLValueBuilder.key(uref);
      var validBytes2 = CLValueParsers.toBytes(clVal2).unwrap();

      expect(
          validBytes2,
          Uint8List.fromList([
            2,
            217,
            61,
            254,
            223,
            193,
            49,
            128,
            160,
            234,
            24,
            136,
            65,
            230,
            78,
            10,
            26,
            247,
            24,
            167,
            51,
            33,
            110,
            127,
            174,
            73,
            9,
            223,
            172,
            227,
            114,
            210,
            176,
            7
          ]));

      expect(
          CLValueParsers.fromBytes(bytes, CLTypeBuilder.key())
              .unwrap()
              .value()
              .data,
          decodeBase16(urefAddr));
      expect(
          CLValueParsers.fromBytes(bytes, CLTypeBuilder.key())
              .unwrap()
              .value()
              .accessRights,
          AccessRights.READ_ADD_WRITE);
    });

    test('should serialize/deserialize Hash variant of Key correctly', () {
      var keyHash = CLValueBuilder.key(
          CLValueBuilder.byteArray(Uint8List.fromList(List.filled(32, 42))));

      var expectedBytes = Uint8List.fromList([
        1,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42
      ]);
      expect(CLValueParsers.toBytes(keyHash).unwrap(), expectedBytes);
      expect(
          CLValueParsers.fromBytes(expectedBytes, CLTypeBuilder.key()).unwrap(),
          keyHash);
    });

    test('should serialize/deserialize Account variant of Key correctly', () {
      var keyAccount = CLValueBuilder.key(
          CLAccountHash(Uint8List.fromList(List.filled(32, 42))));

      var expectedBytes = Uint8List.fromList([
        0,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42,
        42
      ]);

      expect(CLValueParsers.toBytes(keyAccount).unwrap(), expectedBytes);
      expect(
          CLValueParsers.fromBytes(expectedBytes, CLTypeBuilder.key()).unwrap(),
          keyAccount);
    });

    test('should serialize DeployHash correctly', () {
      var deployHash = decodeBase16(
          '7e83be8eb783d4631c3239eee08e95f33396210e23893155b6fb734e9b7f0df7');
      var bytes = deployHash;
      expect(
          bytes,
          Uint8List.fromList([
            126,
            131,
            190,
            142,
            183,
            131,
            212,
            99,
            28,
            50,
            57,
            238,
            224,
            142,
            149,
            243,
            51,
            150,
            33,
            14,
            35,
            137,
            49,
            85,
            182,
            251,
            115,
            78,
            155,
            127,
            13,
            247
          ]));
    });

    test('should serialize/deserialize URef correctly', () {
      var uref = CLURef.fromFormattedStr(
          'uref-ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff-007');

      var expectedBytes = Uint8List.fromList([
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        255,
        7
      ]);
      expect(CLValueParsers.toBytes(uref).unwrap(), expectedBytes);
      expect(
          CLValueParsers.fromBytes(expectedBytes, CLTypeBuilder.uref())
              .unwrap(),
          uref);
    });

    test('should serialize/deserialize Tuple1 correctly', () {
      var value1 = CLValueBuilder.string('hello');
      var tuple = CLValueBuilder.tuple1([value1]);

      var expectedBytes =
          Uint8List.fromList([5, 0, 0, 0, 104, 101, 108, 108, 111]);
      expect(CLValueParsers.toBytes(tuple).unwrap(), expectedBytes);

      expect(
          CLValueParsers.fromBytes(
                  expectedBytes, CLTypeBuilder.tuple1([CLTypeBuilder.string()]))
              .unwrap()
              .clType(),
          tuple.clType());

      expect(
          CLValueParsers.toBytes(CLValueParsers.fromBytes(expectedBytes,
                  CLTypeBuilder.tuple1([CLTypeBuilder.string()])).unwrap())
              .unwrap(),
          expectedBytes);
    });

    test('should serialize/deserialize Tuple2 correctly', () {
      var value1 = CLValueBuilder.string('hello');
      var value2 = CLValueBuilder.u64(123456);
      var tuple2 = CLValueBuilder.tuple2([value1, value2]);

      var expectedBytes = Uint8List.fromList(
          [5, 0, 0, 0, 104, 101, 108, 108, 111, 64, 226, 1, 0, 0, 0, 0, 0]);
      expect(CLValueParsers.toBytes(tuple2).unwrap(), expectedBytes);

      expect(
          CLValueParsers.fromBytes(
                  expectedBytes,
                  CLTypeBuilder.tuple2(
                      [CLTypeBuilder.string(), CLTypeBuilder.u64()]))
              .unwrap()
              .clType(),
          tuple2.clType());

      expect(
          CLValueParsers.toBytes(CLValueParsers.fromBytes(
                  expectedBytes,
                  CLTypeBuilder.tuple2(
                      [CLTypeBuilder.string(), CLTypeBuilder.u64()])).unwrap())
              .unwrap(),
          expectedBytes);
    });

    test('should serialize/deserialize Tuple3 correctly', () {
      var value1 = CLValueBuilder.string('hello');
      var value2 = CLValueBuilder.u64(123456);
      var value3 = CLValueBuilder.boolean(true);
      var tuple3 = CLValueBuilder.tuple3([value1, value2, value3]);

      var expectedBytes = Uint8List.fromList(
          [5, 0, 0, 0, 104, 101, 108, 108, 111, 64, 226, 1, 0, 0, 0, 0, 0, 1]);
      expect(CLValueParsers.toBytes(tuple3).unwrap(), expectedBytes);

      expect(
          CLValueParsers.fromBytes(
              expectedBytes,
              CLTypeBuilder.tuple3([
                CLTypeBuilder.string(),
                CLTypeBuilder.u64(),
                CLTypeBuilder.boolean()
              ])).unwrap().clType(),
          tuple3.clType());

      expect(
          CLValueParsers.toBytes(CLValueParsers.fromBytes(
                  expectedBytes,
                  CLTypeBuilder.tuple3([
                    CLTypeBuilder.string(),
                    CLTypeBuilder.u64(),
                    CLTypeBuilder.boolean()
                  ])).unwrap())
              .unwrap(),
          expectedBytes);
    });

    test('should serialize/deserialize List correctly', () {
      var list = CLValueBuilder.list([
        CLValueBuilder.u32(1),
        CLValueBuilder.u32(2),
        CLValueBuilder.u32(3)
      ]);

      var expectedBytes =
          Uint8List.fromList([3, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 3, 0, 0, 0]);

      expect(CLValueParsers.toBytes(list).unwrap(), expectedBytes);

      expect(
          CLValueParsers.fromBytes(
                  expectedBytes, CLTypeBuilder.list(CLTypeBuilder.u32()))
              .unwrap(),
          list);
    });

    test('should serialze/deserialize Map correctly', () {
      var map = CLValueBuilder.mapFromList([
        {
          CLValueBuilder.string('test1'): CLValueBuilder.list(
              [CLValueBuilder.u64(1), CLValueBuilder.u64(2)])
        },
        {
          CLValueBuilder.string('test2'): CLValueBuilder.list(
              [CLValueBuilder.u64(3), CLValueBuilder.u64(4)])
        }
      ]);

      var expectBytes = Uint8List.fromList([
        2,
        0,
        0,
        0,
        5,
        0,
        0,
        0,
        116,
        101,
        115,
        116,
        49,
        2,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        2,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        5,
        0,
        0,
        0,
        116,
        101,
        115,
        116,
        50,
        2,
        0,
        0,
        0,
        3,
        0,
        0,
        0,
        0,
        0,
        0,
        0,
        4,
        0,
        0,
        0,
        0,
        0,
        0,
        0
      ]);

      expect(CLValueParsers.toBytes(map).unwrap(), expectBytes);
      expect(
          CLValueParsers.fromBytes(
              expectBytes,
              CLTypeBuilder.map({
                CLTypeBuilder.string(): CLTypeBuilder.list(CLTypeBuilder.u64())
              })).unwrap().data,
          map.data);
    });

    test('should serialize/deserialize Option correctly', () {
      var opt = CLValueBuilder.option(Some(CLValueBuilder.string('test')));
      var expectedBytes =
          Uint8List.fromList([1, 4, 0, 0, 0, 116, 101, 115, 116]);
      expect(CLValueParsers.toBytes(opt).unwrap(), expectedBytes);

      expect(
          CLValueParsers.fromBytes(
                  expectedBytes, CLTypeBuilder.option(CLTypeBuilder.string()))
              .unwrap(),
          opt);
    });

    test('should serialize ByteArray correctly', () {
      var byteArray = Uint8List.fromList(List.filled(32, 42));
      var bytes =
          CLValueParsers.toBytesWithType(CLValueBuilder.byteArray(byteArray))
              .unwrap();
      expect(
          bytes,
          Uint8List.fromList([
            32,
            0,
            0,
            0,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            15,
            32,
            0,
            0,
            0
          ]));
    });

    test('should serialize PublicKey correctly', () {
      var publicKey = Uint8List.fromList(List.filled(32, 42));
      var bytes = CLValueParsers.toBytes(
              CLValueBuilder.publicKey(publicKey, CLPublicKeyTag.ED25519))
          .unwrap();
      expect(
          bytes,
          Uint8List.fromList([
            1,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42,
            42
          ]));
    });

    test('should compute hex from PublicKey correctly', () {
      var ed25519Account = Ed25519.newKey();
      var ed25519AccountHex = ed25519Account.accountHex();
      expect(CLPublicKey.fromHex(ed25519AccountHex), ed25519Account.publicKey);

      var secp256K1Account = Secp256K1.newKey();
      var secp256K1AccountHex = secp256K1Account.accountHex();
      expect(
          CLPublicKey.fromHex(secp256K1AccountHex), secp256K1Account.publicKey);
    });
  });
}
