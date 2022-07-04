import 'dart:typed_data';

import 'abstract.dart';
import 'byte_array.dart';
import 'key.dart';
import 'list.dart';
import 'map.dart';
import 'numeric.dart';
import 'string.dart';
import 'uref.dart';
import 'package:oxidized/oxidized.dart';

import 'bool.dart';
import 'option.dart';
import 'public_key.dart';
import 'tuple.dart';
import 'unit.dart';

class CLTypeBuilder {
  static CLBoolType boolean() {
    return CLBoolType();
  }

  static CLU8Type u8() {
    return CLU8Type();
  }

  static CLU32Type u32() {
    return CLU32Type();
  }

  static CLI32Type i32() {
    return CLI32Type();
  }

  static CLU64Type u64() {
    return CLU64Type();
  }

  static CLI64Type i64() {
    return CLI64Type();
  }

  static CLU128Type u128() {
    return CLU128Type();
  }

  static CLU256Type u256() {
    return CLU256Type();
  }

  static CLU512Type u512() {
    return CLU512Type();
  }

  static CLUnitType unit() {
    return CLUnitType();
  }

  static CLStringType string() {
    return CLStringType();
  }

  static CLKeyType key() {
    return CLKeyType();
  }

  static CLURefType uref() {
    return CLURefType();
  }

  static CLListType<T> list<T extends CLType>(T val) {
    return CLListType(val);
  }

  static CLTuple1Type tuple1(List<CLType> t) {
    return CLTuple1Type(t);
  }

  static CLTuple2Type tuple2(List<CLType> t) {
    return CLTuple2Type(t);
  }

  static CLTuple3Type tuple3(List<CLType> t) {
    return CLTuple3Type(t);
  }

  static CLOptionType<T> option<T extends CLType>(T type) {
    return CLOptionType(type);
  }

  static CLMapType<K, V> map<K extends CLType, V extends CLType>(
      Map<K, V> val) {
    return CLMapType(val);
  }

  static CLPublicKeyType publicKey() {
    return CLPublicKeyType();
  }

  static CLByteArrayType byteArray(int size) {
    return CLByteArrayType(size);
  }
}

class CLValueBuilder {
  static CLBool boolean(bool val) {
    return CLBool(val);
  }

  static CLU8 u8(dynamic val) {
    return CLU8(val);
  }

  static CLU32 u32(dynamic val) {
    return CLU32(val);
  }

  static CLI32 i32(dynamic val) {
    return CLI32(val);
  }

  static CLU64 u64(dynamic val) {
    return CLU64(val);
  }

  static CLI64 i64(dynamic val) {
    return CLI64(val);
  }

  static CLU128 u128(dynamic val) {
    return CLU128(val);
  }

  static CLU256 u256(dynamic val) {
    return CLU256(val);
  }

  static CLU512 u512(dynamic val) {
    return CLU512(val);
  }

  static CLUnit unit() {
    return CLUnit();
  }

  static CLString string(String val) {
    return CLString(val);
  }

  static CLKey key(CLValue val) {
    return CLKey(val);
  }

  static CLURef uref(Uint8List val, AccessRights accessRights) {
    return CLURef(val, accessRights);
  }

  static CLList<T> list<T extends CLValue>(List<T> val) {
    return CLList.fromList(val);
  }

  static CLTuple1 tuple1(List<CLValue> t) {
    return CLTuple1(t);
  }

  static CLTuple2 tuple2(List<CLValue> t) {
    return CLTuple2(t);
  }

  static CLTuple3 tuple3(List<CLValue> t) {
    return CLTuple3(t);
  }

  static CLOption<CLValue> option(Option<CLValue> data, [CLType? innerType]) {
    return CLOption(data, innerType);
  }

  static CLMap<K, V> mapFromList<K extends CLValue, V extends CLValue>(
      List<Map<K, V>> val) {
    return CLMap.fromList(val);
  }

  static CLMap<K, V> mapfromMap<K extends CLValue, V extends CLValue>(
      Map<CLType, CLType> val) {
    return CLMap.fromMap(val);
  }

  static CLPublicKey publicKey(Uint8List rawPublicKey, CLPublicKeyTag tag) {
    return CLPublicKey(rawPublicKey, tag);
  }

  static CLByteArray byteArray(Uint8List bytes) {
    return CLByteArray(bytes);
  }
}
