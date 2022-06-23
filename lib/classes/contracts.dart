import 'dart:typed_data';

import 'package:pinenacl/digests.dart';

Uint8List byteHash(Uint8List x) {
  var hasher = Hash.blake2b;
  return hasher(x, digestSize: 32);
}
