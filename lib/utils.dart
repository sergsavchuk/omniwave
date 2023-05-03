import 'dart:io';

import 'package:flutter/foundation.dart';

class Utils {
  // TODO(sergsavchuk): use screen size and orientation to
  //  determine the parameter
  static final bool isSmallScreen =
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);
}

class Helpers {
  static String joinArtists(List<String>? artists) {
    if (artists == null) {
      return '';
    }

    return artists.join(', ');
  }
}
