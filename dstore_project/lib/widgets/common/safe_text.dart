import 'package:flutter/material.dart';

/// Widget de texte sécurisé qui gère automatiquement l'overflow
/// et s'adapte à différentes tailles d'écran
class SafeText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow overflow;
  final bool softWrap;
  final double? textScaleFactor;
  final Locale? locale;
  final StrutStyle? strutStyle;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;

  const SafeText(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.softWrap = true,
    this.textScaleFactor,
    this.locale,
    this.strutStyle,
    this.textWidthBasis,
    this.textHeightBehavior,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obtenir la taille de l'écran pour adapter le comportement
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 600;
    
    // Adapter le nombre de lignes selon la taille de l'écran
    int adaptiveMaxLines = maxLines ?? (isSmallScreen ? 1 : isMediumScreen ? 2 : 3);
    
    // Adapter la taille du texte si nécessaire
    TextStyle? adaptiveStyle = style;
    if (isSmallScreen && style != null && style!.fontSize != null) {
      adaptiveStyle = style!.copyWith(
        fontSize: (style!.fontSize! * 0.9).clamp(10.0, style!.fontSize!),
      );
    }

    return Text(
      text,
      style: adaptiveStyle,
      textAlign: textAlign,
      maxLines: adaptiveMaxLines,
      overflow: overflow,
      softWrap: softWrap,
      textScaleFactor: textScaleFactor,
      locale: locale,
      strutStyle: strutStyle,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }
}

/// Widget de texte pour les titres avec gestion automatique de l'overflow
class SafeTitle extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;

  const SafeTitle(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return SafeText(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines ?? (isSmallScreen ? 1 : 2),
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Widget de texte pour les sous-titres avec gestion automatique de l'overflow
class SafeSubtitle extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;

  const SafeSubtitle(
    this.text, {
    Key? key,
    this.style,
    this.textAlign,
    this.maxLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return SafeText(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines ?? (isSmallScreen ? 2 : 3),
      overflow: TextOverflow.ellipsis,
    );
  }
}