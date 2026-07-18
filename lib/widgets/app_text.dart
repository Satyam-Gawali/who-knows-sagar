import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppText extends StatelessWidget {
  const AppText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String text;

  final TextStyle? style;

  final TextAlign? textAlign;

  final int? maxLines;

  final TextOverflow? overflow;

  bool _isDevanagari(String value) {
    return RegExp(r'[\u0900-\u097F]').hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDevanagari = _isDevanagari(text);

    return Text(
      text,

      textAlign: textAlign,

      maxLines: maxLines,

      overflow: overflow,

      style: (style ?? const TextStyle()).copyWith(
        fontFamily: isDevanagari
            ? GoogleFonts.notoSansDevanagari().fontFamily
            : GoogleFonts.outfit().fontFamily,
      ),
    );
  }
}
