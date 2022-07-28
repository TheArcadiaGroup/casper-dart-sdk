import 'package:casper_dart_sdk/classes/classes.dart';
import 'package:test/test.dart';

void main() {
  group('BigNumber', () {
    test('abs', () {
      var number = BigNumber.from(-1);

      expect(number.abs().toNumber(), equals(1));
    });

    test('add', () {
      var number1 = BigNumber.from(-1);
      var number2 = BigNumber.from(2);

      expect(number1.add(number2).toNumber(), equals(1));
    });

    test('div', () {
      var number1 = BigNumber.from(10);
      var number2 = BigNumber.from(2);

      expect(number1.div(number2).toNumber(), equals(5));
    });

    test('fromWei', () {
      var a = BigNumber.from(16984023806);
      var b = CasperClient.fromWei(a.toString());

      expect(b, '16.984023806');
    });

    test('toWei', () {
      // var a = BigNumber.from(1000000000000);
      var a = '16.984023806';
      var b = CasperClient.toWei(a);

      expect(b, '16984023806');
    });

    test('mul', () {
      var number1 = BigNumber.from(5);
      var number2 = BigNumber.from(2);

      expect(number1.mul(number2).toNumber(), equals(10));
    });

    test('mod', () {
      var number1 = BigNumber.from(5);
      var number2 = BigNumber.from(2);

      expect(number1.mod(number2).toNumber(), equals(1));
    });

    test('pow', () {
      var number1 = BigNumber.from(5);
      var number2 = BigNumber.from(2);

      expect(number1.pow(number2).toNumber(), equals(25));
    });

    test('and', () {
      var number1 = BigNumber.from(1);
      var number2 = BigNumber.from(5);

      expect(number1.and(number2).toNumber(), equals(1));
    });

    test('or', () {
      var number1 = BigNumber.from(1);
      var number2 = BigNumber.from(5);

      expect(number1.or(number2).toNumber(), equals(5));
    });

    test('xor', () {
      var number1 = BigNumber.from(10);
      var number2 = BigNumber.from(5);

      expect(number1.xor(number2).toNumber(), equals(15));
    });
  });
}
