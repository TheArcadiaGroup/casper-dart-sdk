import 'dart:ffi';
import 'dart:math' as math;
import 'dart:typed_data';

enum ArrayType { list, buffer }

class DivMod {
  late BN? div;
  late BN? mod;

  DivMod(BN? _div, BN? _mod) {
    div = _div;
    mod = _mod;
  }
}

class BN {
  int negative = 0;
  List<int> words = [];
  int length = 0;

  BN(dynamic number, [dynamic base, String? endian]) {
    if (number != null) {
      if (base == 'le' || base == 'be') {
        endian = base;
        base = 10;
      }

      _init(number, base: base ?? 10, endian: endian ?? 'be');
    }
  }

  static bool isBN(dynamic number) {
    return number != null && number is BN && number.words.isNotEmpty;
  }

  static BN max(BN left, BN right) {
    if (left.cmp(right) > 0) return left;
    return right;
  }

  static BN min(BN left, BN right) {
    if (left.cmp(right) < 0) return left;
    return right;
  }

  void _init(dynamic number, {dynamic base, String? endian}) {
    if (number is num) {
      _initNumber(number, base, endian);
    }

    if (number is List || number is Array) {
      return _initArray(number, base, endian);
    }

    if (base == 'hex') {
      base = 16;
    }

    assert(base == (base | 0) && base >= 2 && base <= 36);
    number = number.toString().replaceAll(RegExp(r'/\s+/g'), '');
    var start = 0;
    if (number[0] == '-') {
      start++;
      negative = 1;
    }

    if (start < number.length) {
      if (base == 16) {
        _parseHex(number, start, endian);
      } else {
        _parseBase(number, base, start);
        if (endian == 'le') {
          _initArray(toArray(), base, endian);
        }
      }
    }
  }

  void _initNumber(dynamic number, [int? base, String? endian]) {
    if (number < 0) {
      negative = 1;
      number = -number;
    }

    if (number < 0x4000000) {
      words = [number & 0x3ffffff];
      length = 1;
    } else if (number < 0x10000000000000) {
      words = [number & 0x3ffffff, (number / 0x4000000) & 0x3ffffff];
      length = 2;
    } else if (number < 0x20000000000000) {
      words = [number & 0x3ffffff, (number / 0x4000000) & 0x3ffffff, 1];
      length = 3;
    } else {
      throw Exception('number out-of-bounds, number: ' + number.toString());
    }

    if (endian != 'le') return;

    // Reverse the bytes
    _initArray(toArray(), base, endian);
  }

  void _initArray(List<int> number, [int? base, String? endian]) {
    // Perhaps a Uint8List
    if (number.isEmpty) {
      words = [0];
      length = 1;
    }

    length = (number.length / 3).ceil();
    words = Uint8List.fromList(List.filled(length, 0));

    int w;
    var off = 0;
    if (endian == 'be') {
      for (var i = number.length - 1, j = 0; i >= 0; i -= 3) {
        w = number[i] | (number[i - 1] << 8) | (number[i - 2] << 16);
        words[j] |= (w << off) & 0x3ffffff;
        words[j + 1] = (w >>> (26 - off)) & 0x3ffffff;
        off += 24;
        if (off >= 26) {
          off -= 26;
          j++;
        }
      }
    } else if (endian == 'le') {
      for (var i = 0, j = 0; i < number.length; i += 3) {
        w = number[i] | (number[i + 1] << 8) | (number[i + 2] << 16);
        words[j] |= (w << off) & 0x3ffffff;
        words[j + 1] = (w >>> (26 - off)) & 0x3ffffff;
        off += 24;
        if (off >= 26) {
          off -= 26;
          j++;
        }
      }
    }

    strip();
  }

  int parseHex4Bits(String str, int index) {
    var c = str.codeUnitAt(index);
    // 'A' - 'F'
    if (c >= 65 && c <= 70) {
      return c - 55;
      // 'a' - 'f'
    } else if (c >= 97 && c <= 102) {
      return c - 87;
      // '0' - '9'
    } else {
      return (c - 48) & 0xf;
    }
  }

  int parseHexByte(String str, int lowerBound, int index) {
    var r = parseHex4Bits(str, index);
    if (index - 1 >= lowerBound) {
      r |= parseHex4Bits(str, index - 1) << 4;
    }
    return r;
  }

  void _parseHex(String number, int start, [String? endian]) {
    // Create possibly bigger array to ensure that it fits the number
    length = ((number.length - start) / 6).ceil();
    words = List.filled(length, 0);

    // 24-bits chunks
    var off = 0;
    var j = 0;

    int w;

    if (endian == 'be') {
      for (var i = number.length - 1; i >= start; i -= 2) {
        w = parseHexByte(number, start, i) << off;
        words[j] |= w & 0x3ffffff;
        if (off >= 18) {
          off -= 18;
          j += 1;
          words[j] |= w >>> 26;
        } else {
          off += 8;
        }
      }
    } else {
      var parseLength = number.length - start;
      for (var i = parseLength % 2 == 0 ? start + 1 : start;
          i < number.length;
          i += 2) {
        w = parseHexByte(number, start, i) << off;
        words[j] |= w & 0x3ffffff;
        if (off >= 18) {
          off -= 18;
          j += 1;
          words[j] |= w >>> 26;
        } else {
          off += 8;
        }
      }
    }

    strip();
  }

  int parseBase(String str, int start, int end, int mul) {
    var r = 0;
    var len = math.min(str.length, end);
    for (var i = start; i < len; i++) {
      var c = str.codeUnitAt(i) - 48;

      r *= mul;

      // 'a'
      if (c >= 49) {
        r += c - 49 + 0xa;

        // 'A'
      } else if (c >= 17) {
        r += c - 17 + 0xa;

        // '0' - '9'
      } else {
        r += c;
      }
    }
    return r;
  }

  void _parseBase(String number, int base, int start) {
    // Initialize as zero
    words = [0];
    length = 1;
    var limbLen = 0;
    var limbPow = 1;

    // Find length of limb in base
    while (limbPow <= 0x3ffffff) {
      limbPow *= base;
      limbLen++;
    }
    limbLen--;
    limbPow = limbPow ~/ base;
    limbPow = limbPow | 0;

    var total = number.length - start;
    var mod = total % limbLen;
    var end = math.min(total, total - mod) + start;

    var word = 0;
    var i = start;
    for (i = start; i < end; i += limbLen) {
      word = parseBase(number, i, i + limbLen, base);
      imuln(limbPow);
      if (words[0] + word < 0x4000000) {
        words[0] += word;
      } else {
        _iaddn(word);
      }
    }

    if (mod != 0) {
      var pow = 1;
      word = parseBase(number, i, number.length, base);

      for (var i = 0; i < mod; i++) {
        pow *= base;
      }

      imuln(pow);
      if (words[0] + word < 0x4000000) {
        words[0] += word;
      } else {
        _iaddn(word);
      }
    }

    strip();
  }

  void copy(BN dest) {
    dest.words = List.empty(growable: true);
    for (var i = 0; i < length; i++) {
      dest.words.add(words[i]);
    }
    dest.length = length;
    dest.negative = negative;
    // dest.red = red;
  }

  BN clone() {
    var r = BN(null);
    copy(r);
    return r;
  }

  BN _expand(size) {
    while (length < size) {
      words.add(0);
      length++;
    }
    return this;
  }

  BN strip() {
    while (length > 1 && words[length - 1] == 0) {
      length--;
    }

    return _normSign();
  }

  BN _normSign() {
    if (length == 1 && words[0] == 0) {
      negative = 0;
    }

    return this;
  }

  //inspect

  var zeros = [
    '',
    '0',
    '00',
    '000',
    '0000',
    '00000',
    '000000',
    '0000000',
    '00000000',
    '000000000',
    '0000000000',
    '00000000000',
    '000000000000',
    '0000000000000',
    '00000000000000',
    '000000000000000',
    '0000000000000000',
    '00000000000000000',
    '000000000000000000',
    '0000000000000000000',
    '00000000000000000000',
    '000000000000000000000',
    '0000000000000000000000',
    '00000000000000000000000',
    '000000000000000000000000',
    '0000000000000000000000000'
  ];

  var groupSizes = [
    0,
    0,
    25,
    16,
    12,
    11,
    10,
    9,
    8,
    8,
    7,
    7,
    7,
    7,
    6,
    6,
    6,
    6,
    6,
    6,
    6,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5,
    5
  ];

  var groupBases = [
    0,
    0,
    33554432,
    43046721,
    16777216,
    48828125,
    60466176,
    40353607,
    16777216,
    43046721,
    10000000,
    19487171,
    35831808,
    62748517,
    7529536,
    11390625,
    16777216,
    24137569,
    34012224,
    47045881,
    64000000,
    4084101,
    5153632,
    6436343,
    7962624,
    9765625,
    11881376,
    14348907,
    17210368,
    20511149,
    24300000,
    28629151,
    33554432,
    39135393,
    45435424,
    52521875,
    60466176
  ];

  @override
  String toString([dynamic base, int? padding]) {
    base = base ?? 10;
    if (padding != null) {
      padding = padding | 0;
    } else {
      padding = 1;
    }

    String out;
    if (base == 16 || base == 'hex') {
      out = '';
      var off = 0;
      var carry = 0;
      for (var i = 0; i < length; i++) {
        var w = words[i];
        var word = (((w << off) | carry) & 0xffffff).toRadixString(16);
        carry = (w >>> (24 - off)) & 0xffffff;
        if (carry != 0 || i != length - 1) {
          out = zeros[6 - word.length] + word + out;
        } else {
          out = word + out;
        }
        off += 2;
        if (off >= 26) {
          off -= 26;
          i--;
        }
      }
      if (carry != 0) {
        out = carry.toRadixString(16) + out;
      }
      while (out.length % padding != 0) {
        out = '0' + out;
      }
      if (negative != 0) {
        out = '-' + out;
      }
      return out.toString();
    }

    if (base == (base | 0) && base >= 2 && base <= 36) {
      // var groupSize = Math.floor(BN.wordSize * Math.LN2 / Math.log(base));
      var groupSize = groupSizes[base];
      // var groupBase = Math.pow(base, groupSize);
      var groupBase = groupBases[base];
      out = '';
      var c = clone();
      c.negative = 0;
      while (!c.isZero()) {
        var r = c.modn(groupBase).toRadixString(base);
        c = c.idivn(groupBase);

        if (!c.isZero()) {
          out = zeros[groupSize - r.length] + r + out;
        } else {
          out = r + out;
        }
      }
      if (isZero()) {
        out = '0' + out;
      }
      while (out.length % padding != 0) {
        out = '0' + out;
      }
      if (negative != 0) {
        out = '-' + out;
      }
      return out.toString();
    }

    throw Exception('Base should be between 2 and 36');
  }

  num toNumber() {
    var ret = words[0];
    if (length == 2) {
      ret += words[1] * 0x4000000;
    } else if (length == 3 && words[2] == 0x01) {
      // NOTE: at this stage it is known that the top bit is set
      ret += 0x10000000000000 + (words[1] * 0x4000000);
    } else if (length > 2) {
      assert(false, 'Number can only safely store up to 53 bits');
    }
    return (negative != 0) ? -ret : ret;
  }

  //toJSON

  //toBuffer

  List<int> toArray([String? endian, int? length]) {
    var _list = List<int>.from(toArrayLike(ArrayType.list, endian, length));
    return _list;
  }

  dynamic toArrayLike(ArrayType arrayType, [String? endian, int? length]) {
    var _byteLength = byteLength();
    var reqLength = length ?? math.max(1, _byteLength);

    if (_byteLength > reqLength) {
      throw Exception("Byte array longer than desired length");
    }
    if (reqLength <= 0) throw Exception("Requested array length <= 0");

    strip();

    var littleEdian = endian == 'le';
    dynamic res;
    if (arrayType == ArrayType.list) {
      res = List.filled(reqLength, 0);
    } else if (arrayType == ArrayType.buffer) {
      res = Uint8List(reqLength).buffer;
    }

    int b, i;
    var q = clone();
    if (!littleEdian) {
      // Assume big-endian
      for (i = 0; i < reqLength - _byteLength; i++) {
        res[i] = 0;
      }

      for (i = 0; !q.isZero(); i++) {
        b = q.andln(0xff);
        q.iushrn(8);

        res[reqLength - i - 1] = b;
      }
    } else {
      for (i = 0; !q.isZero(); i++) {
        b = q.andln(0xff);
        q.iushrn(8);

        res[i] = b;
      }

      for (; i < reqLength; i++) {
        res[i] = 0;
      }
    }

    return res;
  }

  int _countBits(int w) {
    var t = w;
    var r = 0;
    if (t >= 0x1000) {
      r += 13;
      t >>>= 13;
    }
    if (t >= 0x40) {
      r += 7;
      t >>>= 7;
    }
    if (t >= 0x8) {
      r += 4;
      t >>>= 4;
    }
    if (t >= 0x02) {
      r += 2;
      t >>>= 2;
    }
    return r + t;
  }

  //_zeroBits

  int bitLength() {
    var w = words[length - 1];
    var hi = _countBits(w);
    return (length - 1) * 26 + hi;
  }

  Uint8List toBitArray(BN num) {
    var w = Uint8List.fromList(List.filled(num.bitLength(), 0));

    for (var bit = 0; bit < w.length; bit++) {
      var off = (bit ~/ 26) | 0;
      var wbit = bit % 26;

      w[bit] = (num.words[off] & (1 << wbit)) >>> wbit;
    }

    return w;
  }

  //zeroBits

  int byteLength() {
    return (bitLength() / 8).ceil();
  }

  BN toTwos(width) {
    if (negative != 0) {
      return abs().inotn(width).iaddn(1);
    }
    return clone();
  }

  BN fromTwos(int width) {
    if (testn(width - 1)) {
      return notn(width).iaddn(1).ineg();
    }
    return clone();
  }

  bool isNeg() {
    return negative != 0;
  }

  BN neg() {
    return clone().ineg();
  }

  BN ineg() {
    if (!isZero()) {
      negative ^= 1;
    }

    return this;
  }

  BN iuor(BN other) {
    while (length < other.length) {
      words[length++] = 0;
    }

    for (var i = 0; i < other.length; i++) {
      words[i] = words[i] | other.words[i];
    }

    return strip();
  }

  BN ior(BN other) {
    assert((negative | other.negative) == 0);
    return iuor(other);
  }

  BN or(BN other) {
    if (length > other.length) return clone().ior(other);
    return other.clone().ior(this);
  }

  BN uor(BN other) {
    if (length > other.length) return clone().iuor(other);
    return other.clone().iuor(this);
  }

  BN iuand(BN other) {
    // b = min-length(num, this)
    BN b;
    if (length > other.length) {
      b = other;
    } else {
      b = this;
    }

    for (var i = 0; i < b.length; i++) {
      words[i] = words[i] & other.words[i];
    }

    length = b.length;

    return strip();
  }

  BN iand(BN other) {
    assert((negative | other.negative) == 0);
    return iuand(other);
  }

  BN and(BN other) {
    if (length > other.length) return clone().iand(other);
    return other.clone().iand(this);
  }

  BN uand(BN other) {
    if (length > other.length) return clone().iuand(other);
    return other.clone().iuand(this);
  }

  // Xor `num` with `this` in-place
  BN iuxor(BN other) {
    // a.length > b.length
    BN a;
    BN b;
    if (length > other.length) {
      a = this;
      b = other;
    } else {
      a = other;
      b = this;
    }

    int i;

    for (i = 0; i < b.length; i++) {
      words[i] = a.words[i] ^ b.words[i];
    }

    if (this != a) {
      for (; i < a.length; i++) {
        words[i] = a.words[i];
      }
    }

    length = a.length;

    return strip();
  }

  BN ixor(BN other) {
    assert((negative | other.negative) == 0);
    return iuxor(other);
  }

  // Xor `num` with `this`
  BN xor(BN other) {
    if (length > other.length) return clone().ixor(other);
    return other.clone().ixor(this);
  }

  BN uxor(BN other) {
    if (length > other.length) return clone().iuxor(other);
    return other.clone().iuxor(this);
  }

  /// Not ``this`` with ``width`` bitwidth
  BN inotn(int width) {
    assert(width >= 0);

    var bytesNeeded = (width / 26).ceil() | 0;
    var bitsLeft = width % 26;

    // Extend the buffer with leading zeroes
    _expand(bytesNeeded);

    if (bitsLeft > 0) {
      bytesNeeded--;
    }

    var i = 0;

    // Handle complete words
    for (i = 0; i < bytesNeeded; i++) {
      words[i] = ~words[i] & 0x3ffffff;
    }

    // Handle the residue
    if (bitsLeft > 0) {
      words[i] = ~words[i] & (0x3ffffff >> (26 - bitsLeft));
    }

    // And remove leading zeroes
    return strip();
  }

  BN notn(int width) {
    return clone().inotn(width);
  }

  //setn
  BN iadd(BN other) {
    dynamic r;

    // negative + positive
    if (negative != 0 && other.negative == 0) {
      negative = 0;
      r = isub(other);
      negative ^= 1;
      return _normSign();

      // positive + negative
    } else if (negative == 0 && other.negative != 0) {
      other.negative = 0;
      r = isub(other);
      other.negative = 1;
      return r._normSign();
    }

    // a.length > b.length
    BN a, b;
    if (length > other.length) {
      a = this;
      b = other;
    } else {
      a = other;
      b = this;
    }

    var i = 0;
    var carry = 0;
    for (i = 0; i < b.length; i++) {
      r = (a.words[i] | 0) + (b.words[i] | 0) + carry;
      words[i] = r & 0x3ffffff;
      carry = r >>> 26;
    }
    for (; carry != 0 && i < a.length; i++) {
      r = (a.words[i] | 0) + carry;
      words[i] = r & 0x3ffffff;
      carry = r >>> 26;
    }

    length = a.length;
    if (carry != 0) {
      words[length] = carry;
      length++;
      // Copy the rest of the words
    } else if (a != this) {
      for (; i < a.length; i++) {
        words[i] = a.words[i];
      }
    }

    return this;
  }

  BN add(BN other) {
    BN res;
    if (other.negative != 0 && negative == 0) {
      other.negative = 0;
      res = sub(other);
      other.negative ^= 1;
      return res;
    } else if (other.negative == 0 && negative != 0) {
      negative = 0;
      res = other.sub(this);
      negative = 1;
      return res;
    }

    if (length > other.length) return clone().iadd(other);

    return other.clone().iadd(this);
  }

  BN isub(BN other) {
    // this - (-num) = this + num
    dynamic r;
    if (other.negative != 0) {
      other.negative = 0;
      r = iadd(other);
      other.negative = 1;
      return r._normSign();

      // -this - num = -(this + num)
    } else if (negative != 0) {
      negative = 0;
      iadd(other);
      negative = 1;
      return _normSign();
    }

    // At this point both numbers are positive
    var _cmp = cmp(other);

    // Optimization - zeroify
    if (_cmp == 0) {
      negative = 0;
      length = 1;
      words[0] = 0;
      return this;
    }

    // a > b
    BN a, b;
    if (_cmp > 0) {
      a = this;
      b = other;
    } else {
      a = other;
      b = this;
    }

    var i = 0;
    var carry = 0;
    for (i = 0; i < b.length; i++) {
      r = (a.words[i] | 0) - (b.words[i] | 0) + carry;
      carry = r >> 26;
      words[i] = r & 0x3ffffff;
    }
    for (; carry != 0 && i < a.length; i++) {
      r = (a.words[i] | 0) + carry;
      carry = r >> 26;
      words[i] = r & 0x3ffffff;
    }

    // Copy rest of the words
    if (carry == 0 && i < a.length && a != this) {
      for (; i < a.length; i++) {
        words[i] = a.words[i];
      }
    }

    length = math.max(length, i);

    if (a != this) {
      negative = 1;
    }

    return strip();
  }

  BN sub(BN other) {
    return clone().isub(other);
  }

  BN smallMulTo(BN self, BN number, BN out) {
    out.negative = number.negative ^ self.negative;
    var len = (self.length + number.length) | 0;
    out.length = len;
    len = (len - 1) | 0;

    // Peel one iteration (compiler can't do it, because of code complexity)
    var a = self.words[0] | 0;
    var b = number.words[0] | 0;
    var r = a * b;

    var lo = r & 0x3ffffff;
    var carry = (r ~/ 0x4000000) | 0;
    out.words[0] = lo;
    var k = 1;

    for (k = 1; k < len; k++) {
      // Sum all words with the same `i + j = k` and accumulate `ncarry`,
      // note that ncarry could be >= 0x3ffffff
      var ncarry = carry >>> 26;
      var rword = (carry & 0x3ffffff);
      var maxJ = math.min(k, number.length - 1);
      for (var j = math.max(0, k - self.length + 1); j <= maxJ; j++) {
        var i = (k - j) | 0;
        a = self.words[i] | 0;
        b = number.words[j] | 0;
        r = a * b + rword;
        ncarry += (r ~/ 0x4000000) | 0;
        rword = r & 0x3ffffff;
      }
      out.words[k] = rword | 0;
      carry = ncarry | 0;
    }
    if (carry != 0) {
      out.words[k] = carry | 0;
    } else {
      out.length--;
    }

    return out.strip();
  }

  int mimul(int a, int b) {
    final aHi = (a >>> 16) & 0xffff;
    final aLo = a & 0xffff;
    final bHi = (b >>> 16) & 0xffff;
    final bLo = b & 0xffff;
    // the shift by 0 fixes the sign on the high part
    // the final |0 converts the unsigned value into a signed value
    return ((aLo * bLo) + (((aHi * bLo + aLo * bHi) << 16) >>> 0)).toSigned(32);
  }

  BN comb10MulTo(BN self, BN number, BN out) {
    var a = self.words;
    var b = number.words;
    var o = out.words;
    var c = 0;
    dynamic lo;
    dynamic mid;
    dynamic hi;
    var a0 = a[0] | 0;
    var al0 = a0 & 0x1fff;
    var ah0 = a0 >>> 13;
    var a1 = a[1] | 0;
    var al1 = a1 & 0x1fff;
    var ah1 = a1 >>> 13;
    var a2 = a[2] | 0;
    var al2 = a2 & 0x1fff;
    var ah2 = a2 >>> 13;
    var a3 = a[3] | 0;
    var al3 = a3 & 0x1fff;
    var ah3 = a3 >>> 13;
    var a4 = a[4] | 0;
    var al4 = a4 & 0x1fff;
    var ah4 = a4 >>> 13;
    var a5 = a[5] | 0;
    var al5 = a5 & 0x1fff;
    var ah5 = a5 >>> 13;
    var a6 = a[6] | 0;
    var al6 = a6 & 0x1fff;
    var ah6 = a6 >>> 13;
    var a7 = a[7] | 0;
    var al7 = a7 & 0x1fff;
    var ah7 = a7 >>> 13;
    var a8 = a[8] | 0;
    var al8 = a8 & 0x1fff;
    var ah8 = a8 >>> 13;
    var a9 = a[9] | 0;
    var al9 = a9 & 0x1fff;
    var ah9 = a9 >>> 13;
    var b0 = b[0] | 0;
    var bl0 = b0 & 0x1fff;
    var bh0 = b0 >>> 13;
    var b1 = b[1] | 0;
    var bl1 = b1 & 0x1fff;
    var bh1 = b1 >>> 13;
    var b2 = b[2] | 0;
    var bl2 = b2 & 0x1fff;
    var bh2 = b2 >>> 13;
    var b3 = b[3] | 0;
    var bl3 = b3 & 0x1fff;
    var bh3 = b3 >>> 13;
    var b4 = b[4] | 0;
    var bl4 = b4 & 0x1fff;
    var bh4 = b4 >>> 13;
    var b5 = b[5] | 0;
    var bl5 = b5 & 0x1fff;
    var bh5 = b5 >>> 13;
    var b6 = b[6] | 0;
    var bl6 = b6 & 0x1fff;
    var bh6 = b6 >>> 13;
    var b7 = b[7] | 0;
    var bl7 = b7 & 0x1fff;
    var bh7 = b7 >>> 13;
    var b8 = b[8] | 0;
    var bl8 = b8 & 0x1fff;
    var bh8 = b8 >>> 13;
    var b9 = b[9] | 0;
    var bl9 = b9 & 0x1fff;
    var bh9 = b9 >>> 13;

    out.negative = self.negative ^ number.negative;
    out.length = 19;
    /* k = 0 */
    lo = mimul(al0, bl0);
    mid = mimul(al0, bh0);
    mid = (mid + mimul(ah0, bl0)) | 0;
    hi = mimul(ah0, bh0);
    dynamic w0 = (((c + lo) > 0 ? (c + lo) : 0) + ((mid & 0x1fff) << 13));
    w0 = w0 > 0 ? w0 : 0;
    c = (((hi + (mid >>> 13)) | 0) + (w0 >>> 26)) | 0;
    w0 &= 0x3ffffff;
    /* k = 1 */
    lo = mimul(al1, bl0);
    mid = mimul(al1, bh0);
    mid = (mid + mimul(ah1, bl0)) | 0;
    hi = mimul(ah1, bh0);
    lo = (lo + mimul(al0, bl1)) | 0;
    mid = (mid + mimul(al0, bh1)) | 0;
    mid = (mid + mimul(ah0, bl1)) | 0;
    hi = (hi + mimul(ah0, bh1)) | 0;
    dynamic w1 = (((c + lo) > 0 ? (c + lo) : 0) + ((mid & 0x1fff) << 13));
    w1 = w1 > 0 ? w1 : 0;
    c = (((hi + (mid >>> 13)) | 0) + (w1 >>> 26)) | 0;
    w1 &= 0x3ffffff;
    /* k = 2 */
    lo = mimul(al2, bl0);
    mid = mimul(al2, bh0);
    mid = (mid + mimul(ah2, bl0)) | 0;
    hi = mimul(ah2, bh0);
    lo = (lo + mimul(al1, bl1)) | 0;
    mid = (mid + mimul(al1, bh1)) | 0;
    mid = (mid + mimul(ah1, bl1)) | 0;
    hi = (hi + mimul(ah1, bh1)) | 0;
    lo = (lo + mimul(al0, bl2)) | 0;
    mid = (mid + mimul(al0, bh2)) | 0;
    mid = (mid + mimul(ah0, bl2)) | 0;
    hi = (hi + mimul(ah0, bh2)) | 0;
    dynamic w2 = (((c + lo) > 0 ? (c + lo) : 0) + ((mid & 0x1fff) << 13));
    w2 = w2 > 0 ? w2 : 0;
    c = (((hi + (mid >>> 13)) | 0) + (w2 >>> 26)) | 0;
    w2 &= 0x3ffffff;
    /* k = 3 */
    lo = mimul(al3, bl0);
    mid = mimul(al3, bh0);
    mid = (mid + mimul(ah3, bl0)) | 0;
    hi = mimul(ah3, bh0);
    lo = (lo + mimul(al2, bl1)) | 0;
    mid = (mid + mimul(al2, bh1)) | 0;
    mid = (mid + mimul(ah2, bl1)) | 0;
    hi = (hi + mimul(ah2, bh1)) | 0;
    lo = (lo + mimul(al1, bl2)) | 0;
    mid = (mid + mimul(al1, bh2)) | 0;
    mid = (mid + mimul(ah1, bl2)) | 0;
    hi = (hi + mimul(ah1, bh2)) | 0;
    lo = (lo + mimul(al0, bl3)) | 0;
    mid = (mid + mimul(al0, bh3)) | 0;
    mid = (mid + mimul(ah0, bl3)) | 0;
    hi = (hi + mimul(ah0, bh3)) | 0;
    dynamic w3 = (((c + lo) > 0 ? (c + lo) : 0) + ((mid & 0x1fff) << 13));
    w3 = w3 > 0 ? w3 : 0;
    c = (((hi + (mid >>> 13)) | 0) + (w3 >>> 26)) | 0;
    w3 &= 0x3ffffff;
    /* k = 4 */
    lo = mimul(al4, bl0);
    mid = mimul(al4, bh0);
    mid = (mid + mimul(ah4, bl0)) | 0;
    hi = mimul(ah4, bh0);
    lo = (lo + mimul(al3, bl1)) | 0;
    mid = (mid + mimul(al3, bh1)) | 0;
    mid = (mid + mimul(ah3, bl1)) | 0;
    hi = (hi + mimul(ah3, bh1)) | 0;
    lo = (lo + mimul(al2, bl2)) | 0;
    mid = (mid + mimul(al2, bh2)) | 0;
    mid = (mid + mimul(ah2, bl2)) | 0;
    hi = (hi + mimul(ah2, bh2)) | 0;
    lo = (lo + mimul(al1, bl3)) | 0;
    mid = (mid + mimul(al1, bh3)) | 0;
    mid = (mid + mimul(ah1, bl3)) | 0;
    hi = (hi + mimul(ah1, bh3)) | 0;
    lo = (lo + mimul(al0, bl4)) | 0;
    mid = (mid + mimul(al0, bh4)) | 0;
    mid = (mid + mimul(ah0, bl4)) | 0;
    hi = (hi + mimul(ah0, bh4)) | 0;
    dynamic w4 = (((c + lo) > 0 ? (c + lo) : 0) + ((mid & 0x1fff) << 13));
    w4 = w4 > 0 ? w4 : 0;
    c = (((hi + (mid >>> 13)) | 0) + (w4 >>> 26)) | 0;
    w4 &= 0x3ffffff;
    /* k = 5 */
    lo = mimul(al5, bl0);
    mid = mimul(al5, bh0);
    mid = (mid + mimul(ah5, bl0)) | 0;
    hi = mimul(ah5, bh0);
    lo = (lo + mimul(al4, bl1)) | 0;
    mid = (mid + mimul(al4, bh1)) | 0;
    mid = (mid + mimul(ah4, bl1)) | 0;
    hi = (hi + mimul(ah4, bh1)) | 0;
    lo = (lo + mimul(al3, bl2)) | 0;
    mid = (mid + mimul(al3, bh2)) | 0;
    mid = (mid + mimul(ah3, bl2)) | 0;
    hi = (hi + mimul(ah3, bh2)) | 0;
    lo = (lo + mimul(al2, bl3)) | 0;
    mid = (mid + mimul(al2, bh3)) | 0;
    mid = (mid + mimul(ah2, bl3)) | 0;
    hi = (hi + mimul(ah2, bh3)) | 0;
    lo = (lo + mimul(al1, bl4)) | 0;
    mid = (mid + mimul(al1, bh4)) | 0;
    mid = (mid + mimul(ah1, bl4)) | 0;
    hi = (hi + mimul(ah1, bh4)) | 0;
    lo = (lo + mimul(al0, bl5)) | 0;
    mid = (mid + mimul(al0, bh5)) | 0;
    mid = (mid + mimul(ah0, bl5)) | 0;
    hi = (hi + mimul(ah0, bh5)) | 0;
    dynamic w5 = (((c + lo) > 0 ? (c + lo) : 0) + ((mid & 0x1fff) << 13));
    w5 = w5 > 0 ? w5 : 0;
    c = (((hi + (mid >>> 13)) | 0) + (w5 >>> 26)) | 0;
    w5 &= 0x3ffffff;
    /* k = 6 */
    lo = mimul(al6, bl0);
    mid = mimul(al6, bh0);
    mid = (mid + mimul(ah6, bl0)) | 0;
    hi = mimul(ah6, bh0);
    lo = (lo + mimul(al5, bl1)) | 0;
    mid = (mid + mimul(al5, bh1)) | 0;
    mid = (mid + mimul(ah5, bl1)) | 0;
    hi = (hi + mimul(ah5, bh1)) | 0;
    lo = (lo + mimul(al4, bl2)) | 0;
    mid = (mid + mimul(al4, bh2)) | 0;
    mid = (mid + mimul(ah4, bl2)) | 0;
    hi = (hi + mimul(ah4, bh2)) | 0;
    lo = (lo + mimul(al3, bl3)) | 0;
    mid = (mid + mimul(al3, bh3)) | 0;
    mid = (mid + mimul(ah3, bl3)) | 0;
    hi = (hi + mimul(ah3, bh3)) | 0;
    lo = (lo + mimul(al2, bl4)) | 0;
    mid = (mid + mimul(al2, bh4)) | 0;
    mid = (mid + mimul(ah2, bl4)) | 0;
    hi = (hi + mimul(ah2, bh4)) | 0;
    lo = (lo + mimul(al1, bl5)) | 0;
    mid = (mid + mimul(al1, bh5)) | 0;
    mid = (mid + mimul(ah1, bl5)) | 0;
    hi = (hi + mimul(ah1, bh5)) | 0;
    lo = (lo + mimul(al0, bl6)) | 0;
    mid = (mid + mimul(al0, bh6)) | 0;
    mid = (mid + mimul(ah0, bl6)) | 0;
    hi = (hi + mimul(ah0, bh6)) | 0;
    dynamic w6 = (((c + lo) > 0 ? (c + lo) : 0) + ((mid & 0x1fff) << 13));
    w6 = w6 > 0 ? w6 : 0;
    c = (((hi + (mid >>> 13)) | 0) + (w6 >>> 26)) | 0;
    w6 &= 0x3ffffff;
    /* k = 7 */
    lo = mimul(al7, bl0);
    mid = mimul(al7, bh0);
    mid = (mid + mimul(ah7, bl0)) | 0;
    hi = mimul(ah7, bh0);
    lo = (lo + mimul(al6, bl1)) | 0;
    mid = (mid + mimul(al6, bh1)) | 0;
    mid = (mid + mimul(ah6, bl1)) | 0;
    hi = (hi + mimul(ah6, bh1)) | 0;
    lo = (lo + mimul(al5, bl2)) | 0;
    mid = (mid + mimul(al5, bh2)) | 0;
    mid = (mid + mimul(ah5, bl2)) | 0;
    hi = (hi + mimul(ah5, bh2)) | 0;
    lo = (lo + mimul(al4, bl3)) | 0;
    mid = (mid + mimul(al4, bh3)) | 0;
    mid = (mid + mimul(ah4, bl3)) | 0;
    hi = (hi + mimul(ah4, bh3)) | 0;
    lo = (lo + mimul(al3, bl4)) | 0;
    mid = (mid + mimul(al3, bh4)) | 0;
    mid = (mid + mimul(ah3, bl4)) | 0;
    hi = (hi + mimul(ah3, bh4)) | 0;
    lo = (lo + mimul(al2, bl5)) | 0;
    mid = (mid + mimul(al2, bh5)) | 0;
    mid = (mid + mimul(ah2, bl5)) | 0;
    hi = (hi + mimul(ah2, bh5)) | 0;
    lo = (lo + mimul(al1, bl6)) | 0;
    mid = (mid + mimul(al1, bh6)) | 0;
    mid = (mid + mimul(ah1, bl6)) | 0;
    hi = (hi + mimul(ah1, bh6)) | 0;
    lo = (lo + mimul(al0, bl7)) | 0;
    mid = (mid + mimul(al0, bh7)) | 0;
    mid = (mid + mimul(ah0, bl7)) | 0;
    hi = (hi + mimul(ah0, bh7)) | 0;
    dynamic w7 = (((c + lo) > 0 ? (c + lo) : 0) + ((mid & 0x1fff) << 13));
    w7 = w7 > 0 ? w7 : 0;
    c = (((hi + (mid >>> 13)) | 0) + (w7 >>> 26)) | 0;
    w7 &= 0x3ffffff;
    /* k = 8 */
    lo = mimul(al8, bl0);
    mid = mimul(al8, bh0);
    mid = (mid + mimul(ah8, bl0)) | 0;
    hi = mimul(ah8, bh0);
    lo = (lo + mimul(al7, bl1)) | 0;
    mid = (mid + mimul(al7, bh1)) | 0;
    mid = (mid + mimul(ah7, bl1)) | 0;
    hi = (hi + mimul(ah7, bh1)) | 0;
    lo = (lo + mimul(al6, bl2)) | 0;
    mid = (mid + mimul(al6, bh2)) | 0;
    mid = (mid + mimul(ah6, bl2)) | 0;
    hi = (hi + mimul(ah6, bh2)) | 0;
    lo = (lo + mimul(al5, bl3)) | 0;
    mid = (mid + mimul(al5, bh3)) | 0;
    mid = (mid + mimul(ah5, bl3)) | 0;
    hi = (hi + mimul(ah5, bh3)) | 0;
    lo = (lo + mimul(al4, bl4)) | 0;
    mid = (mid + mimul(al4, bh4)) | 0;
    mid = (mid + mimul(ah4, bl4)) | 0;
    hi = (hi + mimul(ah4, bh4)) | 0;
    lo = (lo + mimul(al3, bl5)) | 0;
    mid = (mid + mimul(al3, bh5)) | 0;
    mid = (mid + mimul(ah3, bl5)) | 0;
    hi = (hi + mimul(ah3, bh5)) | 0;
    lo = (lo + mimul(al2, bl6)) | 0;
    mid = (mid + mimul(al2, bh6)) | 0;
    mid = (mid + mimul(ah2, bl6)) | 0;
    hi = (hi + mimul(ah2, bh6)) | 0;
    lo = (lo + mimul(al1, bl7)) | 0;
    mid = (mid + mimul(al1, bh7)) | 0;
    mid = (mid + mimul(ah1, bl7)) | 0;
    hi = (hi + mimul(ah1, bh7)) | 0;
    lo = (lo + mimul(al0, bl8)) | 0;
    mid = (mid + mimul(al0, bh8)) | 0;
    mid = (mid + mimul(ah0, bl8)) | 0;
    hi = (hi + mimul(ah0, bh8)) | 0;
    dynamic w8 = (((c + lo) > 0 ? (c + lo) : 0) + ((mid & 0x1fff) << 13));
    w8 = w8 > 0 ? w8 : 0;
    c = (((hi + (mid >>> 13)) | 0) + (w8 >>> 26)) | 0;
    w8 &= 0x3ffffff;
    /* k = 9 */
    lo = mimul(al9, bl0);
    mid = mimul(al9, bh0);
    mid = (mid + mimul(ah9, bl0)) | 0;
    hi = mimul(ah9, bh0);
    lo = (lo + mimul(al8, bl1)) | 0;
    mid = (mid + mimul(al8, bh1)) | 0;
    mid = (mid + mimul(ah8, bl1)) | 0;
    hi = (hi + mimul(ah8, bh1)) | 0;
    lo = (lo + mimul(al7, bl2)) | 0;
    mid = (mid + mimul(al7, bh2)) | 0;
    mid = (mid + mimul(ah7, bl2)) | 0;
    hi = (hi + mimul(ah7, bh2)) | 0;
    lo = (lo + mimul(al6, bl3)) | 0;
    mid = (mid + mimul(al6, bh3)) | 0;
    mid = (mid + mimul(ah6, bl3)) | 0;
    hi = (hi + mimul(ah6, bh3)) | 0;
    lo = (lo + mimul(al5, bl4)) | 0;
    mid = (mid + mimul(al5, bh4)) | 0;
    mid = (mid + mimul(ah5, bl4)) | 0;
    hi = (hi + mimul(ah5, bh4)) | 0;
    lo = (lo + mimul(al4, bl5)) | 0;
    mid = (mid + mimul(al4, bh5)) | 0;
    mid = (mid + mimul(ah4, bl5)) | 0;
    hi = (hi + mimul(ah4, bh5)) | 0;
    lo = (lo + mimul(al3, bl6)) | 0;
    mid = (mid + mimul(al3, bh6)) | 0;
    mid = (mid + mimul(ah3, bl6)) | 0;
    hi = (hi + mimul(ah3, bh6)) | 0;
    lo = (lo + mimul(al2, bl7)) | 0;
    mid = (mid + mimul(al2, bh7)) | 0;
    mid = (mid + mimul(ah2, bl7)) | 0;
    hi = (hi + mimul(ah2, bh7)) | 0;
    lo = (lo + mimul(al1, bl8)) | 0;
    mid = (mid + mimul(al1, bh8)) | 0;
    mid = (mid + mimul(ah1, bl8)) | 0;
    hi = (hi + mimul(ah1, bh8)) | 0;
    lo = (lo + mimul(al0, bl9)) | 0;
    mid = (mid + mimul(al0, bh9)) | 0;
    mid = (mid + mimul(ah0, bl9)) | 0;
    hi = (hi + mimul(ah0, bh9)) | 0;
    dynamic w9 = (((c + lo) > 0 ? (c + lo) : 0) + ((mid & 0x1fff) << 13));
    w9 = w9 > 0 ? w9 : 0;
    c = (((hi + (mid >>> 13)) | 0) + (w9 >>> 26)) | 0;
    w9 &= 0x3ffffff;
    /* k = 10 */
    lo = mimul(al9, bl1);
    mid = mimul(al9, bh1);
    mid = (mid + mimul(ah9, bl1)) | 0;
    hi = mimul(ah9, bh1);
    lo = (lo + mimul(al8, bl2)) | 0;
    mid = (mid + mimul(al8, bh2)) | 0;
    mid = (mid + mimul(ah8, bl2)) | 0;
    hi = (hi + mimul(ah8, bh2)) | 0;
    lo = (lo + mimul(al7, bl3)) | 0;
    mid = (mid + mimul(al7, bh3)) | 0;
    mid = (mid + mimul(ah7, bl3)) | 0;
    hi = (hi + mimul(ah7, bh3)) | 0;
    lo = (lo + mimul(al6, bl4)) | 0;
    mid = (mid + mimul(al6, bh4)) | 0;
    mid = (mid + mimul(ah6, bl4)) | 0;
    hi = (hi + mimul(ah6, bh4)) | 0;
    lo = (lo + mimul(al5, bl5)) | 0;
    mid = (mid + mimul(al5, bh5)) | 0;
    mid = (mid + mimul(ah5, bl5)) | 0;
    hi = (hi + mimul(ah5, bh5)) | 0;
    lo = (lo + mimul(al4, bl6)) | 0;
    mid = (mid + mimul(al4, bh6)) | 0;
    mid = (mid + mimul(ah4, bl6)) | 0;
    hi = (hi + mimul(ah4, bh6)) | 0;
    lo = (lo + mimul(al3, bl7)) | 0;
    mid = (mid + mimul(al3, bh7)) | 0;
    mid = (mid + mimul(ah3, bl7)) | 0;
    hi = (hi + mimul(ah3, bh7)) | 0;
    lo = (lo + mimul(al2, bl8)) | 0;
    mid = (mid + mimul(al2, bh8)) | 0;
    mid = (mid + mimul(ah2, bl8)) | 0;
    hi = (hi + mimul(ah2, bh8)) | 0;
    lo = (lo + mimul(al1, bl9)) | 0;
    mid = (mid + mimul(al1, bh9)) | 0;
    mid = (mid + mimul(ah1, bl9)) | 0;
    hi = (hi + mimul(ah1, bh9)) | 0;
    dynamic w10 = (((c + lo) > 0 ? (c + lo) : 0) + ((mid & 0x1fff) << 13));
    w10 = w10 > 0 ? w10 : 0;
    c = (((hi + (mid >>> 13)) | 0) + (w10 >>> 26)) | 0;
    w10 &= 0x3ffffff;
    /* k = 11 */
    lo = mimul(al9, bl2);
    mid = mimul(al9, bh2);
    mid = (mid + mimul(ah9, bl2)) | 0;
    hi = mimul(ah9, bh2);
    lo = (lo + mimul(al8, bl3)) | 0;
    mid = (mid + mimul(al8, bh3)) | 0;
    mid = (mid + mimul(ah8, bl3)) | 0;
    hi = (hi + mimul(ah8, bh3)) | 0;
    lo = (lo + mimul(al7, bl4)) | 0;
    mid = (mid + mimul(al7, bh4)) | 0;
    mid = (mid + mimul(ah7, bl4)) | 0;
    hi = (hi + mimul(ah7, bh4)) | 0;
    lo = (lo + mimul(al6, bl5)) | 0;
    mid = (mid + mimul(al6, bh5)) | 0;
    mid = (mid + mimul(ah6, bl5)) | 0;
    hi = (hi + mimul(ah6, bh5)) | 0;
    lo = (lo + mimul(al5, bl6)) | 0;
    mid = (mid + mimul(al5, bh6)) | 0;
    mid = (mid + mimul(ah5, bl6)) | 0;
    hi = (hi + mimul(ah5, bh6)) | 0;
    lo = (lo + mimul(al4, bl7)) | 0;
    mid = (mid + mimul(al4, bh7)) | 0;
    mid = (mid + mimul(ah4, bl7)) | 0;
    hi = (hi + mimul(ah4, bh7)) | 0;
    lo = (lo + mimul(al3, bl8)) | 0;
    mid = (mid + mimul(al3, bh8)) | 0;
    mid = (mid + mimul(ah3, bl8)) | 0;
    hi = (hi + mimul(ah3, bh8)) | 0;
    lo = (lo + mimul(al2, bl9)) | 0;
    mid = (mid + mimul(al2, bh9)) | 0;
    mid = (mid + mimul(ah2, bl9)) | 0;
    hi = (hi + mimul(ah2, bh9)) | 0;
    dynamic w11 = (((c + lo) > 0 ? (c + lo) : 0) + ((mid & 0x1fff) << 13));
    w11 = w11 > 0 ? w11 : 0;
    c = (((hi + (mid >>> 13)) | 0) + (w11 >>> 26)) | 0;
    w11 &= 0x3ffffff;
    /* k = 12 */
    lo = mimul(al9, bl3);
    mid = mimul(al9, bh3);
    mid = (mid + mimul(ah9, bl3)) | 0;
    hi = mimul(ah9, bh3);
    lo = (lo + mimul(al8, bl4)) | 0;
    mid = (mid + mimul(al8, bh4)) | 0;
    mid = (mid + mimul(ah8, bl4)) | 0;
    hi = (hi + mimul(ah8, bh4)) | 0;
    lo = (lo + mimul(al7, bl5)) | 0;
    mid = (mid + mimul(al7, bh5)) | 0;
    mid = (mid + mimul(ah7, bl5)) | 0;
    hi = (hi + mimul(ah7, bh5)) | 0;
    lo = (lo + mimul(al6, bl6)) | 0;
    mid = (mid + mimul(al6, bh6)) | 0;
    mid = (mid + mimul(ah6, bl6)) | 0;
    hi = (hi + mimul(ah6, bh6)) | 0;
    lo = (lo + mimul(al5, bl7)) | 0;
    mid = (mid + mimul(al5, bh7)) | 0;
    mid = (mid + mimul(ah5, bl7)) | 0;
    hi = (hi + mimul(ah5, bh7)) | 0;
    lo = (lo + mimul(al4, bl8)) | 0;
    mid = (mid + mimul(al4, bh8)) | 0;
    mid = (mid + mimul(ah4, bl8)) | 0;
    hi = (hi + mimul(ah4, bh8)) | 0;
    lo = (lo + mimul(al3, bl9)) | 0;
    mid = (mid + mimul(al3, bh9)) | 0;
    mid = (mid + mimul(ah3, bl9)) | 0;
    hi = (hi + mimul(ah3, bh9)) | 0;
    dynamic w12 = (((c + lo) > 0 ? (c + lo) : 0) + ((mid & 0x1fff) << 13));
    w12 = w12 > 0 ? w12 : 0;
    c = (((hi + (mid >>> 13)) | 0) + (w12 >>> 26)) | 0;
    w12 &= 0x3ffffff;
    /* k = 13 */
    lo = mimul(al9, bl4);
    mid = mimul(al9, bh4);
    mid = (mid + mimul(ah9, bl4)) | 0;
    hi = mimul(ah9, bh4);
    lo = (lo + mimul(al8, bl5)) | 0;
    mid = (mid + mimul(al8, bh5)) | 0;
    mid = (mid + mimul(ah8, bl5)) | 0;
    hi = (hi + mimul(ah8, bh5)) | 0;
    lo = (lo + mimul(al7, bl6)) | 0;
    mid = (mid + mimul(al7, bh6)) | 0;
    mid = (mid + mimul(ah7, bl6)) | 0;
    hi = (hi + mimul(ah7, bh6)) | 0;
    lo = (lo + mimul(al6, bl7)) | 0;
    mid = (mid + mimul(al6, bh7)) | 0;
    mid = (mid + mimul(ah6, bl7)) | 0;
    hi = (hi + mimul(ah6, bh7)) | 0;
    lo = (lo + mimul(al5, bl8)) | 0;
    mid = (mid + mimul(al5, bh8)) | 0;
    mid = (mid + mimul(ah5, bl8)) | 0;
    hi = (hi + mimul(ah5, bh8)) | 0;
    lo = (lo + mimul(al4, bl9)) | 0;
    mid = (mid + mimul(al4, bh9)) | 0;
    mid = (mid + mimul(ah4, bl9)) | 0;
    hi = (hi + mimul(ah4, bh9)) | 0;
    dynamic w13 = (((c + lo) > 0 ? (c + lo) : 0) + ((mid & 0x1fff) << 13));
    w13 = w13 > 0 ? w13 : 0;
    c = (((hi + (mid >>> 13)) | 0) + (w13 >>> 26)) | 0;
    w13 &= 0x3ffffff;
    /* k = 14 */
    lo = mimul(al9, bl5);
    mid = mimul(al9, bh5);
    mid = (mid + mimul(ah9, bl5)) | 0;
    hi = mimul(ah9, bh5);
    lo = (lo + mimul(al8, bl6)) | 0;
    mid = (mid + mimul(al8, bh6)) | 0;
    mid = (mid + mimul(ah8, bl6)) | 0;
    hi = (hi + mimul(ah8, bh6)) | 0;
    lo = (lo + mimul(al7, bl7)) | 0;
    mid = (mid + mimul(al7, bh7)) | 0;
    mid = (mid + mimul(ah7, bl7)) | 0;
    hi = (hi + mimul(ah7, bh7)) | 0;
    lo = (lo + mimul(al6, bl8)) | 0;
    mid = (mid + mimul(al6, bh8)) | 0;
    mid = (mid + mimul(ah6, bl8)) | 0;
    hi = (hi + mimul(ah6, bh8)) | 0;
    lo = (lo + mimul(al5, bl9)) | 0;
    mid = (mid + mimul(al5, bh9)) | 0;
    mid = (mid + mimul(ah5, bl9)) | 0;
    hi = (hi + mimul(ah5, bh9)) | 0;
    dynamic w14 = (((c + lo) > 0 ? (c + lo) : 0) + ((mid & 0x1fff) << 13));
    w14 = w14 > 0 ? w14 : 0;
    c = (((hi + (mid >>> 13)) | 0) + (w14 >>> 26)) | 0;
    w14 &= 0x3ffffff;
    /* k = 15 */
    lo = mimul(al9, bl6);
    mid = mimul(al9, bh6);
    mid = (mid + mimul(ah9, bl6)) | 0;
    hi = mimul(ah9, bh6);
    lo = (lo + mimul(al8, bl7)) | 0;
    mid = (mid + mimul(al8, bh7)) | 0;
    mid = (mid + mimul(ah8, bl7)) | 0;
    hi = (hi + mimul(ah8, bh7)) | 0;
    lo = (lo + mimul(al7, bl8)) | 0;
    mid = (mid + mimul(al7, bh8)) | 0;
    mid = (mid + mimul(ah7, bl8)) | 0;
    hi = (hi + mimul(ah7, bh8)) | 0;
    lo = (lo + mimul(al6, bl9)) | 0;
    mid = (mid + mimul(al6, bh9)) | 0;
    mid = (mid + mimul(ah6, bl9)) | 0;
    hi = (hi + mimul(ah6, bh9)) | 0;
    dynamic w15 = (((c + lo) > 0 ? (c + lo) : 0) + ((mid & 0x1fff) << 13));
    w15 = w15 > 0 ? w15 : 0;
    c = (((hi + (mid >>> 13)) | 0) + (w15 >>> 26)) | 0;
    w15 &= 0x3ffffff;
    /* k = 16 */
    lo = mimul(al9, bl7);
    mid = mimul(al9, bh7);
    mid = (mid + mimul(ah9, bl7)) | 0;
    hi = mimul(ah9, bh7);
    lo = (lo + mimul(al8, bl8)) | 0;
    mid = (mid + mimul(al8, bh8)) | 0;
    mid = (mid + mimul(ah8, bl8)) | 0;
    hi = (hi + mimul(ah8, bh8)) | 0;
    lo = (lo + mimul(al7, bl9)) | 0;
    mid = (mid + mimul(al7, bh9)) | 0;
    mid = (mid + mimul(ah7, bl9)) | 0;
    hi = (hi + mimul(ah7, bh9)) | 0;
    dynamic w16 = (((c + lo) > 0 ? (c + lo) : 0) + ((mid & 0x1fff) << 13));
    w16 = w16 > 0 ? w16 : 0;
    c = (((hi + (mid >>> 13)) | 0) + (w16 >>> 26)) | 0;
    w16 &= 0x3ffffff;
    /* k = 17 */
    lo = mimul(al9, bl8);
    mid = mimul(al9, bh8);
    mid = (mid + mimul(ah9, bl8)) | 0;
    hi = mimul(ah9, bh8);
    lo = (lo + mimul(al8, bl9)) | 0;
    mid = (mid + mimul(al8, bh9)) | 0;
    mid = (mid + mimul(ah8, bl9)) | 0;
    hi = (hi + mimul(ah8, bh9)) | 0;
    dynamic w17 = (((c + lo) > 0 ? (c + lo) : 0) + ((mid & 0x1fff) << 13));
    w17 = w17 > 0 ? w17 : 0;
    c = (((hi + (mid >>> 13)) | 0) + (w17 >>> 26)) | 0;
    w17 &= 0x3ffffff;
    /* k = 18 */
    lo = mimul(al9, bl9);
    mid = mimul(al9, bh9);
    mid = (mid + mimul(ah9, bl9)) | 0;
    hi = mimul(ah9, bh9);
    dynamic w18 = (((c + lo) > 0 ? (c + lo) : 0) + ((mid & 0x1fff) << 13));
    w18 = w18 > 0 ? w18 : 0;
    c = (((hi + (mid >>> 13)) | 0) + (w18 >>> 26)) | 0;
    w18 &= 0x3ffffff;
    o[0] = w0;
    o[1] = w1;
    o[2] = w2;
    o[3] = w3;
    o[4] = w4;
    o[5] = w5;
    o[6] = w6;
    o[7] = w7;
    o[8] = w8;
    o[9] = w9;
    o[10] = w10;
    o[11] = w11;
    o[12] = w12;
    o[13] = w13;
    o[14] = w14;
    o[15] = w15;
    o[16] = w16;
    o[17] = w17;
    o[18] = w18;
    if (c != 0) {
      o[19] = c;
      out.length++;
    }
    return out;
  }

  BN bigMulTo(BN self, BN number, BN out) {
    out.negative = number.negative ^ self.negative;
    out.length = self.length + number.length;

    var carry = 0;
    var hncarry = 0;
    var k = 0;
    for (k = 0; k < out.length - 1; k++) {
      // Sum all words with the same `i + j = k` and accumulate `ncarry`,
      // note that ncarry could be >= 0x3ffffff
      var ncarry = hncarry;
      hncarry = 0;
      var rword = carry & 0x3ffffff;
      var maxJ = math.min(k, number.length - 1);
      for (var j = math.max(0, k - self.length + 1); j <= maxJ; j++) {
        var i = k - j;
        var a = self.words[i] | 0;
        var b = number.words[j] | 0;
        var r = a * b;

        var lo = r & 0x3ffffff;
        ncarry = (ncarry + (((r / 0x4000000) as int) | 0)) | 0;
        lo = (lo + rword) | 0;
        rword = lo & 0x3ffffff;
        ncarry = (ncarry + (lo >>> 26)) | 0;

        hncarry += ncarry >>> 26;
        ncarry &= 0x3ffffff;
      }
      out.words[k] = rword;
      carry = ncarry;
      ncarry = hncarry;
    }
    if (carry == 0) {
      out.words[k] = carry;
    } else {
      out.length--;
    }

    return out.strip();
  }

  BN jumboMulTo(BN self, BN number, BN out) {
    return fftmMulp(self, number, out);
  }

  int guessLen13b(int n, int m) {
    var N = math.max(m, n) | 1;
    N = ((N / 2) as int) | 0;
    var odd = N & 1;
    var i = 0;
    for (N; N > 0; N = N >>> 1) {
      i++;
    }

    return 1 << i + 1 + odd;
  }

  List<int> makeRBT(int N) {
    var t = List.filled(N, 0);
    var l = _countBits(N) - 1;
    for (var i = 0; i < N; i++) {
      t[i] = revBin(i, l, N);
    }

    return t;
  }

  int revBin(x, l, N) {
    if (x == 0 || x == N - 1) return x;

    var rb = 0;
    for (var i = 0; i < l; i++) {
      rb |= (x & 1) << (l - i - 1);
      x >>= 1;
    }

    return rb;
  }

  List<int> stub(int N) {
    var ph = List.filled(N, 0);
    for (var i = 0; i < N; i++) {
      ph[i] = 0;
    }

    return ph;
  }

  void convert13b(List<int> ws, int len, List<int> rws, int N) {
    var carry = 0;
    var i = 0;
    for (i = 0; i < len; i++) {
      carry = carry + (ws[i] | 0);

      rws[2 * i] = carry & 0x1fff;
      carry = carry >>> 13;
      rws[2 * i + 1] = carry & 0x1fff;
      carry = carry >>> 13;
    }

    // Pad with zeroes
    for (i = 2 * len; i < N; ++i) {
      rws[i] = 0;
    }

    assert(carry == 0);
    assert((carry & ~0x1fff) == 0);
  }

  void permute(List<int> rbt, List<int> rws, List<int> iws, List<int> rtws,
      List<int> itws, int N) {
    for (var i = 0; i < N; i++) {
      rtws[i] = rws[rbt[i]];
      itws[i] = iws[rbt[i]];
    }
  }

  void transform(List<int> rws, List<int> iws, List<int> rtws, List<int> itws,
      int N, List<int> rbt) {
    permute(rbt, rws, iws, rtws, itws, N);

    for (var s = 1; s < N; s <<= 1) {
      var l = s << 1;

      var rtwdf = math.cos(2 * math.pi / l);
      var itwdf = math.sin(2 * math.pi / l);

      for (var p = 0; p < N; p += l) {
        var rtwdf_ = rtwdf;
        var itwdf_ = itwdf;

        for (var j = 0; j < s; j++) {
          var re = rtws[p + j];
          var ie = itws[p + j];

          var ro = rtws[p + j + s];
          var io = itws[p + j + s];

          var rx = rtwdf_ * ro - itwdf_ * io;

          io = (rtwdf_ * io + itwdf_ * ro) as int;
          ro = rx as int;

          rtws[p + j] = re + ro;
          itws[p + j] = ie + io;

          rtws[p + j + s] = re - ro;
          itws[p + j + s] = ie - io;

          /* jshint maxdepth : false */
          if (j != l) {
            rx = rtwdf * rtwdf_ - itwdf * itwdf_;

            itwdf_ = rtwdf * itwdf_ + itwdf * rtwdf_;
            rtwdf_ = rx;
          }
        }
      }
    }
  }

  void conjugate(List<int> rws, List<int> iws, N) {
    if (N <= 1) return;

    for (var i = 0; i < N / 2; i++) {
      var t = rws[i];

      rws[i] = rws[N - i - 1];
      rws[N - i - 1] = t;

      t = iws[i];

      iws[i] = -iws[N - i - 1];
      iws[N - i - 1] = -t;
    }
  }

  List<int> normalize13b(List<int> ws, N) {
    var carry = 0;
    for (var i = 0; i < N / 2; i++) {
      var w = (ws[2 * i + 1] / N).round() * 0x2000 +
          (ws[2 * i] / N).round() +
          carry;

      ws[i] = w & 0x3ffffff;

      if (w < 0x4000000) {
        carry = 0;
      } else {
        carry = ((w / 0x4000000) as int) | 0;
      }
    }

    return ws;
  }

  BN fftmMulp(BN x, BN y, BN out) {
    var N = 2 * guessLen13b(x.length, y.length);

    var rbt = makeRBT(N);

    var _ = stub(N);

    var rws = List.filled(N, 0);
    var rwst = List.filled(N, 0);
    var iwst = List.filled(N, 0);

    var nrws = List.filled(N, 0);
    var nrwst = List.filled(N, 0);
    var niwst = List.filled(N, 0);

    var rmws = out.words;
    rmws.length = N;

    convert13b(x.words, x.length, rws, N);
    convert13b(y.words, y.length, nrws, N);

    transform(rws, _, rwst, iwst, N, rbt);
    transform(nrws, _, nrwst, niwst, N, rbt);

    for (var i = 0; i < N; i++) {
      var rx = rwst[i] * nrwst[i] - iwst[i] * niwst[i];
      iwst[i] = rwst[i] * niwst[i] + iwst[i] * nrwst[i];
      rwst[i] = rx;
    }

    conjugate(rwst, iwst, N);
    transform(rwst, iwst, rmws, _, N, rbt);
    conjugate(rmws, _, N);
    normalize13b(rmws, N);

    out.negative = x.negative ^ y.negative;
    out.length = x.length + y.length;
    return out.strip();
  }

  BN mulTo(BN number, BN out) {
    BN res;
    var len = length + number.length;
    if (length == 10 && number.length == 10) {
      res = comb10MulTo(this, number, out);
    } else if (len < 63) {
      res = smallMulTo(this, number, out);
    } else if (len < 1024) {
      res = bigMulTo(this, number, out);
    } else {
      res = jumboMulTo(this, number, out);
    }

    return res;
  }

  /// Cooley-Tukey algorithm for FFT
  /// slightly revisited to rely on looping instead of recursion
  //FFTM

  // ......

  /// Multiply `this` by `num`
  BN mul(BN num) {
    var out = BN(null);
    out.words = List.filled(length + num.length, 0);
    return mulTo(num, out);
  }

  //mulf

  // In-place Multiplication
  BN imul(BN other) {
    return clone().mulTo(other, this);
  }

  BN imuln(int other) {
    assert(other < 0x4000000);

    // Carry
    var carry = 0;
    var i = 0;
    for (i = 0; i < length; i++) {
      var w = (words[i] | 0) * other;
      var lo = (w & 0x3ffffff) + (carry & 0x3ffffff);
      carry >>= 26;
      carry += (w ~/ 0x4000000) | 0;
      // NOTE: lo is 27bit maximum
      carry += lo >>> 26;
      words[i] = lo & 0x3ffffff;
    }

    if (carry != 0) {
      words.add(carry);
      length++;
    }

    return this;
  }

  //muln

  /// `this` * `this`
  BN sqr() {
    return mul(this);
  }

  /// `this` * `this` in-place
  BN isqr() {
    return imul(clone());
  }

  BN pow(BN pow) {
    var w = toBitArray(pow);
    if (w.isEmpty) return BN(1);

    // Skip leading zeroes
    var res = this;
    var i = 0;
    for (i = 0; i < w.length; i++, res = res.sqr()) {
      if (w[i] != 0) break;
    }

    if (++i < w.length) {
      for (var q = res.sqr(); i < w.length; i++, q = q.sqr()) {
        if (w[i] == 0) continue;

        res = res.mul(q);
      }
    }

    return res;
  }

  BN iushln(int bits) {
    assert(bits >= 0);
    var r = bits % 26;
    var s = (bits - r) ~/ 26;
    var carryMask = (0x3ffffff >>> (26 - r)) << (26 - r);
    var i = 0;

    if (r != 0) {
      var carry = 0;

      for (i = 0; i < length; i++) {
        var newCarry = words[i] & carryMask;
        var c = ((words[i] | 0) - newCarry) << r;
        words[i] = c | carry;
        carry = newCarry >>> (26 - r);
      }

      if (carry > 0) {
        words.add(carry);
        length++;
      }
    }

    if (s != 0) {
      for (i = length - 1; i >= 0; i--) {
        words[i + s] = words[i];
      }

      for (i = 0; i < s; i++) {
        words[i] = 0;
      }

      length += s;
    }

    return strip();
  }

  BN ishln(int bits) {
    assert(negative == 0);
    return iushln(bits);
  }

  /// Shift-right in-place
  /// NOTE: `hint` is a lowest bit before trailing zeroes
  /// NOTE: if `extended` is present - it will be filled with destroyed bits
  iushrn(int bits, [int? hint, BN? extended]) {
    if (bits < 0) throw Exception("iushrn bits must be >= 0");
    int h;
    if (hint != null) {
      h = ((hint - (hint % 26)) / 26) as int;
    } else {
      h = 0;
    }

    int r = bits % 26;
    int s = math.min(((bits - r) ~/ 26), length);
    int mask = 0x3ffffff ^ ((0x3ffffff >>> r) << r);
    var maskedWords = extended;

    h -= s;
    h = math.max(0, h);

    // Extended mode, copy masked part
    if (maskedWords != null) {
      for (var i = 0; i < s; i++) {
        maskedWords.words[i] = words[i];
      }
      maskedWords.length = s;
    }

    if (s == 0) {
      // No-op, we should not move anything at all
    } else if (length > s) {
      length -= s;
      for (var i = 0; i < length; i++) {
        words[i] = words[i + s];
      }
    } else {
      words[0] = 0;
      length = 1;
    }

    var carry = 0;
    for (var i = length - 1; i >= 0 && (carry != 0 || i >= h); i--) {
      var word = words[i] | 0;
      words[i] = (carry << (26 - r)) | (word >>> r);
      carry = word & mask;
    }

    // Push carried bits as a mask
    if (maskedWords != null && carry == 0) {
      maskedWords.words[maskedWords.length++] = carry;
    }

    if (length == 0) {
      words[0] = 0;
      length = 1;
    }

    return strip();
  }

  BN ishrn(int bits, [int? hint, BN? extended]) {
    assert(negative == 0);
    return iushrn(bits, hint, extended);
  }

  BN shln(int bits) {
    return clone().ishln(bits);
  }

  /// Shift-right
  BN shrn(int bits) {
    return clone().ishrn(bits);
  }

  BN ushln(int bits) {
    return clone().iushln(bits);
  }

  bool testn(int bit) {
    assert(bit >= 0);
    var r = bit % 26;
    var s = (bit - r) ~/ 26;
    var q = 1 << r;

    // Fast case: bit is much higher than all existing words
    if (length <= s) return false;

    // Check bit and return
    var w = words[s];

    return !!((w & q) > 0);
  }

  BN imaskn(int bits) {
    assert(bits >= 0);
    var r = bits % 26;
    var s = (bits - r) ~/ 26;

    assert(negative == 0, 'imaskn works only with positive numbers');

    if (length <= s) {
      return this;
    }

    if (r != 0) {
      s++;
    }
    length = math.min(s, length);
    if (r != 0) {
      var mask = 0x3ffffff ^ ((0x3ffffff >>> r) << r);
      words[length - 1] &= mask;
    }

    return strip();
  }

  BN maskn(int bits) {
    return clone().imaskn(bits);
  }

  /// Add plain number `number` to `this`
  BN iaddn(int number) {
    assert(number < 0x4000000);
    if (number < 0) return isubn(-number);

    // Possible sign change
    if (negative != 0) {
      if (length == 1 && (words[0] | 0) < number) {
        words[0] = number - (words[0] | 0);
        negative = 0;
        return this;
      }

      negative = 0;
      isubn(number);
      negative = 1;
      return this;
    }

    // Add without checks
    return _iaddn(number);
  }

  BN _iaddn(int number) {
    words[0] += number;
    var i = 0;

    // Carry
    for (i = 0; i < length && words[i] >= 0x4000000; i++) {
      words[i] -= 0x4000000;
      if (i == length - 1) {
        words[i + 1] = 1;
      } else {
        words[i + 1]++;
      }
    }
    length = math.max(length, i + 1);

    return this;
  }

  /// Subtract plain number `num` from `this`
  BN isubn(int number) {
    assert(number < 0x4000000);
    if (number < 0) return iaddn(-number);

    if (negative != 0) {
      negative = 0;
      iaddn(number);
      negative = 1;
      return this;
    }

    words[0] -= number;

    if (length == 1 && words[0] < 0) {
      words[0] = -words[0];
      negative = 1;
    } else {
      // Carry
      for (var i = 0; i < length && words[i] < 0; i++) {
        words[i] += 0x4000000;
        words[i + 1] -= 1;
      }
    }

    return strip();
  }

  //addn

  //subn

  BN iabs() {
    negative = 0;
    return this;
  }

  BN abs() {
    return clone().iabs();
  }

  BN _ishlnsubmul(BN other, int mul, int shift) {
    var len = other.length + shift;
    int i;

    _expand(len);

    int w;
    var carry = 0;
    for (i = 0; i < other.length; i++) {
      w = (words[i + shift] | 0) + carry;
      var right = (other.words[i] | 0) * mul;
      w -= right & 0x3ffffff;
      carry = (w >> 26) - ((right ~/ 0x4000000) | 0);
      words[i + shift] = w & 0x3ffffff;
    }
    for (; i < length - shift; i++) {
      w = (words[i + shift] | 0) + carry;
      carry = w >> 26;
      words[i + shift] = w & 0x3ffffff;
    }

    if (carry == 0) return strip();

    // Subtraction overflow
    assert(carry == -1);
    carry = 0;
    for (i = 0; i < length; i++) {
      w = -(words[i] | 0) + carry;
      carry = w >> 26;
      words[i] = w & 0x3ffffff;
    }
    negative = 1;

    return strip();
  }

  DivMod _wordDiv(BN other, String mode) {
    var shift = length - other.length;

    var a = clone();
    var b = other;

    // Normalize
    var bhi = b.words[b.length - 1] | 0;
    var bhiBits = _countBits(bhi);
    shift = 26 - bhiBits;
    if (shift != 0) {
      b = b.ushln(shift);
      a.iushln(shift);
      bhi = b.words[b.length - 1] | 0;
    }

    // Initialize quotient
    var m = a.length - b.length;
    BN? q;

    if (mode != 'mod') {
      q = BN(null);
      q.length = m + 1;
      q.words = List.filled(q.length, 0);
      for (var i = 0; i < q.length; i++) {
        q.words[i] = 0;
      }
    }

    var diff = a.clone()._ishlnsubmul(b, 1, m);
    if (diff.negative == 0) {
      a = diff;
      if (q != null) {
        q.words[m] = 1;
      }
    }

    for (var j = m - 1; j >= 0; j--) {
      var qj = (a.words[b.length + j] | 0) * 0x4000000 +
          (a.words[b.length + j - 1] | 0);

      // NOTE: (qj / bhi) is (0x3ffffff * 0x4000000 + 0x3ffffff) / 0x2000000 max
      // (0x7ffffff)
      qj = math.min((qj ~/ bhi) | 0, 0x3ffffff);

      a._ishlnsubmul(b, qj, j);
      while (a.negative != 0) {
        qj--;
        a.negative = 0;
        a._ishlnsubmul(b, 1, j);
        if (!a.isZero()) {
          a.negative ^= 1;
        }
      }
      if (q != null) {
        q.words[j] = qj;
      }
    }
    if (q != null) {
      q = q.strip();
    }
    a.strip();

    // Denormalize
    if (mode != 'div' && shift != 0) {
      a.iushrn(shift);
    }

    return DivMod(q, a);
  }

  /// NOTE: 1) `mode` can be set to `mod` to request mod only,
  ///       to `div` to request div only, or be absent to
  ///       request both div & mod
  ///       2) `positive` is true if unsigned mod is requested
  DivMod divmod(BN num, [String? mode, bool? positive]) {
    assert(!num.isZero());

    if (isZero()) {
      return DivMod(BN(0), BN(0));
    }

    dynamic div, mod, res;
    if (negative != 0 && num.negative == 0) {
      res = neg().divmod(num, mode);

      if (mode != 'mod') {
        div = res.div.neg();
      }

      if (mode != 'div') {
        mod = res.mod.neg();
        if (positive! && (mod.negative != 0)) {
          mod.iadd(num);
        }
      }

      return DivMod(div, mod);
    }

    if (negative == 0 && num.negative != 0) {
      res = divmod(num.neg(), mode);

      if (mode != 'mod') {
        div = res.div.neg();
      }

      return DivMod(div, res.mod);
    }

    if ((negative & num.negative) != 0) {
      res = neg().divmod(num.neg(), mode);

      if (mode != 'div') {
        mod = res.mod.neg();
        if (positive! && mod.negative != 0) {
          mod.isub(num);
        }
      }

      return DivMod(res.div, mod);
    }

    // Both numbers are positive at this point

    // Strip both numbers to approximate shift value
    if (num.length > length || cmp(num) < 0) {
      return DivMod(BN(0), this);
    }

    // Very short reduction
    if (num.length == 1) {
      if (mode == 'div') {
        return DivMod(divn(num.words[0]), null);
      }

      if (mode == 'mod') {
        return DivMod(null, BN(modn(num.words[0])));
      }

      return DivMod(divn(num.words[0]), BN(modn(num.words[0])));
    }

    return _wordDiv(num, mode!);
  }

  BN div(BN other) {
    return divmod(other, 'div', false).div!;
  }

  // Find `this` % `num`
  BN mod(BN other) {
    return divmod(other, 'mod', false).mod!;
  }

  //umod

  //divRound

  int modn(int number) {
    assert(number <= 0x3ffffff);
    var p = (1 << 26) % number;

    var acc = 0;
    for (var i = length - 1; i >= 0; i--) {
      acc = (p * acc + (words[i] | 0)) % number;
    }

    return acc;
  }

  /// In-place division by number
  BN idivn(int number) {
    assert(number <= 0x3ffffff);

    var carry = 0;
    for (var i = length - 1; i >= 0; i--) {
      var w = (words[i] | 0) + carry * 0x4000000;
      words[i] = w ~/ number | 0;
      carry = w % number;
    }

    return strip();
  }

  BN divn(int number) {
    return clone().idivn(number);
  }

  //egcd

  //_invmp

  //gcd

  //invm

  //isEven

  //isOdd

  // And first word and num
  int andln(int number) {
    return words[0] & number;
  }

  //bincn

  bool isZero() {
    return length == 1 && words[0] == 0;
  }

  int cmpn(int number) {
    var _negative = number < 0;

    if (negative != 0 && !_negative) return -1;
    if (negative == 0 && _negative) return 1;

    strip();

    int res;
    if (length > 1) {
      res = 1;
    } else {
      if (_negative) {
        number = -number;
      }

      assert(number <= 0x3ffffff, 'Number is too big');

      var w = words[0] | 0;
      res = w == number
          ? 0
          : w < number
              ? -1
              : 1;
    }
    if (negative != 0) return -res | 0;
    return res;
  }

  /// Compare two numbers and return:
  /// 1 - if `this` > `num`
  /// 0 - if `this` == `num`
  /// -1 - if `this` < `num`
  int cmp(BN other) {
    if (negative != 0 && other.negative == 0) return -1;
    if (negative == 0 && other.negative != 0) return 1;

    int res = ucmp(other);
    if (negative != 0) return -res | 0;
    return res;
  }

  /// Unsigned comparison
  int ucmp(BN other) {
    // At this point both numbers have the same sign
    if (length > other.length) return 1;
    if (length < other.length) return -1;

    int res = 0;
    for (var i = length - 1; i >= 0; i--) {
      var a = words[i] | 0;
      var b = other.words[i] | 0;

      if (a == b) continue;
      if (a < b) {
        res = -1;
      } else if (a > b) {
        res = 1;
      }
      break;
    }
    return res;
  }

  bool gtn(int other) {
    return cmpn(other) == 1;
  }

  bool gt(BN other) {
    return cmp(other) == 1;
  }

  bool gten(int other) {
    return cmpn(other) >= 0;
  }

  bool gte(BN other) {
    return cmp(other) >= 0;
  }

  bool ltn(int other) {
    return cmpn(other) == -1;
  }

  bool lt(BN other) {
    return cmp(other) == -1;
  }

  bool lten(int other) {
    return cmpn(other) <= 0;
  }

  bool lte(BN other) {
    return cmp(other) <= 0;
  }

  bool eqn(int other) {
    return cmpn(other) == 0;
  }

  bool eq(BN other) {
    return cmp(other) == 0;
  }

  //red

  //toRed
}
