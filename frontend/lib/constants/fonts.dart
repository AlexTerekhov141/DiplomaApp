import 'package:flutter/material.dart';

import 'colors.dart';

abstract class Font {}

class Headers {
  static const TextStyle H5 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle H4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle H4Bold = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

}

class L extends Font{
  static final TextStyle Normal = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: Base.c500
  );
  static final TextStyle Bold = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Base.c400
  );
  static final TextStyle Strong = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Base.c400
  );

  static final TextStyle Italic = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.italic,
      color: Base.c400
  );
}

class M extends Font{
  static const TextStyle Normal = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal
  );
  static const TextStyle Bold = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold
  );
  static const TextStyle Strong = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600
  );

  static const TextStyle Italic = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.italic
  );
}

class S extends Font{
  static const TextStyle Normal = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal
  );
  static const TextStyle Bold = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold
  );
  static const TextStyle Strong = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600
  );

  static const TextStyle Italic = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.italic
  );
}
