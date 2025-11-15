import 'package:flutter/material.dart';

/// Énumération des tailles d'écran
enum ScreenSize {
  small,   // < 360px
  medium,  // 360px - 600px
  large,   // 600px - 900px
  xlarge,  // > 900px
}

/// Utilitaire pour obtenir la taille d'écran actuelle
class ScreenUtils {
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < 360) return ScreenSize.small;
    if (width < 600) return ScreenSize.medium;
    if (width < 900) return ScreenSize.large;
    return ScreenSize.xlarge;
  }
  
  static bool isSmallScreen(BuildContext context) {
    return getScreenSize(context) == ScreenSize.small;
  }
  
  static bool isMediumScreen(BuildContext context) {
    return getScreenSize(context) == ScreenSize.medium;
  }
  
  static bool isLargeScreen(BuildContext context) {
    final size = getScreenSize(context);
    return size == ScreenSize.large || size == ScreenSize.xlarge;
  }
}

/// Container responsive qui adapte ses propriétés selon la taille d'écran
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BoxDecoration? decoration;
  final AlignmentGeometry? alignment;
  final BoxConstraints? constraints;
  
  // Propriétés adaptatives
  final EdgeInsetsGeometry? smallPadding;
  final EdgeInsetsGeometry? mediumPadding;
  final EdgeInsetsGeometry? largePadding;
  
  final EdgeInsetsGeometry? smallMargin;
  final EdgeInsetsGeometry? mediumMargin;
  final EdgeInsetsGeometry? largeMargin;
  
  final double? smallWidth;
  final double? mediumWidth;
  final double? largeWidth;
  
  final double? smallHeight;
  final double? mediumHeight;
  final double? largeHeight;

  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.decoration,
    this.alignment,
    this.constraints,
    this.smallPadding,
    this.mediumPadding,
    this.largePadding,
    this.smallMargin,
    this.mediumMargin,
    this.largeMargin,
    this.smallWidth,
    this.mediumWidth,
    this.largeWidth,
    this.smallHeight,
    this.mediumHeight,
    this.largeHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = ScreenUtils.getScreenSize(context);
    
    EdgeInsetsGeometry? adaptivePadding = padding;
    EdgeInsetsGeometry? adaptiveMargin = margin;
    double? adaptiveWidth = width;
    double? adaptiveHeight = height;
    
    switch (screenSize) {
      case ScreenSize.small:
        adaptivePadding = smallPadding ?? padding;
        adaptiveMargin = smallMargin ?? margin;
        adaptiveWidth = smallWidth ?? width;
        adaptiveHeight = smallHeight ?? height;
        break;
      case ScreenSize.medium:
        adaptivePadding = mediumPadding ?? padding;
        adaptiveMargin = mediumMargin ?? margin;
        adaptiveWidth = mediumWidth ?? width;
        adaptiveHeight = mediumHeight ?? height;
        break;
      case ScreenSize.large:
      case ScreenSize.xlarge:
        adaptivePadding = largePadding ?? padding;
        adaptiveMargin = largeMargin ?? margin;
        adaptiveWidth = largeWidth ?? width;
        adaptiveHeight = largeHeight ?? height;
        break;
    }
    
    return Container(
      padding: adaptivePadding,
      margin: adaptiveMargin,
      width: adaptiveWidth,
      height: adaptiveHeight,
      decoration: decoration,
      alignment: alignment,
      constraints: constraints,
      child: child,
    );
  }
}

/// Card responsive qui adapte ses propriétés selon la taille d'écran
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final ShapeBorder? shape;
  final Color? color;
  final Color? shadowColor;
  final Clip? clipBehavior;
  
  // Propriétés adaptatives
  final EdgeInsetsGeometry? smallPadding;
  final EdgeInsetsGeometry? mediumPadding;
  final EdgeInsetsGeometry? largePadding;
  
  final double? smallElevation;
  final double? mediumElevation;
  final double? largeElevation;

  const ResponsiveCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.shape,
    this.color,
    this.shadowColor,
    this.clipBehavior,
    this.smallPadding,
    this.mediumPadding,
    this.largePadding,
    this.smallElevation,
    this.mediumElevation,
    this.largeElevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = ScreenUtils.getScreenSize(context);
    
    EdgeInsetsGeometry? adaptivePadding = padding;
    double? adaptiveElevation = elevation;
    
    switch (screenSize) {
      case ScreenSize.small:
        adaptivePadding = smallPadding ?? padding ?? const EdgeInsets.all(8.0);
        adaptiveElevation = smallElevation ?? elevation ?? 2.0;
        break;
      case ScreenSize.medium:
        adaptivePadding = mediumPadding ?? padding ?? const EdgeInsets.all(12.0);
        adaptiveElevation = mediumElevation ?? elevation ?? 4.0;
        break;
      case ScreenSize.large:
      case ScreenSize.xlarge:
        adaptivePadding = largePadding ?? padding ?? const EdgeInsets.all(16.0);
        adaptiveElevation = largeElevation ?? elevation ?? 6.0;
        break;
    }
    
    Widget content = Padding(
      padding: adaptivePadding!,
      child: child,
    );
    
    return Card(
      margin: margin,
      elevation: adaptiveElevation,
      shape: shape,
      color: color,
      shadowColor: shadowColor,
      clipBehavior: clipBehavior,
      child: content,
    );
  }
}