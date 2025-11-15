import 'package:flutter/material.dart';

/// Widget Row responsive qui gère automatiquement l'overflow
/// en passant en mode Column sur les petits écrans
class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;
  final double? breakpoint;
  final EdgeInsetsGeometry? padding;
  final double spacing;

  const ResponsiveRow({
    Key? key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
    this.breakpoint = 360.0,
    this.padding,
    this.spacing = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final shouldUseColumn = screenWidth < (breakpoint ?? 360.0);

    Widget content;
    
    if (shouldUseColumn) {
      // Sur petits écrans, utiliser une Column
      content = Column(
        mainAxisAlignment: _convertMainAxisAlignment(mainAxisAlignment),
        crossAxisAlignment: _convertCrossAxisAlignment(crossAxisAlignment),
        mainAxisSize: mainAxisSize,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        textBaseline: textBaseline,
        children: _addSpacing(children, true),
      );
    } else {
      // Sur grands écrans, utiliser une Row normale
      content = Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        textDirection: textDirection,
        verticalDirection: verticalDirection,
        textBaseline: textBaseline,
        children: _addSpacing(children, false),
      );
    }

    if (padding != null) {
      return Padding(
        padding: padding!,
        child: content,
      );
    }

    return content;
  }

  /// Convertit MainAxisAlignment de Row vers Column
  MainAxisAlignment _convertMainAxisAlignment(MainAxisAlignment alignment) {
    switch (alignment) {
      case MainAxisAlignment.start:
        return MainAxisAlignment.start;
      case MainAxisAlignment.end:
        return MainAxisAlignment.end;
      case MainAxisAlignment.center:
        return MainAxisAlignment.center;
      case MainAxisAlignment.spaceBetween:
        return MainAxisAlignment.spaceBetween;
      case MainAxisAlignment.spaceAround:
        return MainAxisAlignment.spaceAround;
      case MainAxisAlignment.spaceEvenly:
        return MainAxisAlignment.spaceEvenly;
    }
  }

  /// Convertit CrossAxisAlignment de Row vers Column
  CrossAxisAlignment _convertCrossAxisAlignment(CrossAxisAlignment alignment) {
    switch (alignment) {
      case CrossAxisAlignment.start:
        return CrossAxisAlignment.start;
      case CrossAxisAlignment.end:
        return CrossAxisAlignment.end;
      case CrossAxisAlignment.center:
        return CrossAxisAlignment.center;
      case CrossAxisAlignment.stretch:
        return CrossAxisAlignment.stretch;
      case CrossAxisAlignment.baseline:
        return CrossAxisAlignment.baseline;
    }
  }

  /// Ajoute l'espacement entre les widgets
  List<Widget> _addSpacing(List<Widget> widgets, bool isColumn) {
    if (widgets.isEmpty || spacing == 0) return widgets;

    final List<Widget> spacedWidgets = [];
    for (int i = 0; i < widgets.length; i++) {
      spacedWidgets.add(widgets[i]);
      if (i < widgets.length - 1) {
        spacedWidgets.add(
          isColumn 
            ? SizedBox(height: spacing)
            : SizedBox(width: spacing),
        );
      }
    }
    return spacedWidgets;
  }
}

/// Widget Row flexible qui utilise Flexible/Expanded automatiquement
class FlexibleRow extends StatelessWidget {
  final List<Widget> children;
  final List<int>? flexValues;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;
  final EdgeInsetsGeometry? padding;

  const FlexibleRow({
    Key? key,
    required this.children,
    this.flexValues,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final wrappedChildren = <Widget>[];
    
    for (int i = 0; i < children.length; i++) {
      final child = children[i];
      final flex = flexValues != null && i < flexValues!.length 
        ? flexValues![i] 
        : 1;
      
      if (flex > 0) {
        wrappedChildren.add(Expanded(flex: flex, child: child));
      } else {
        wrappedChildren.add(child);
      }
    }

    Widget content = Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      children: wrappedChildren,
    );

    if (padding != null) {
      return Padding(
        padding: padding!,
        child: content,
      );
    }

    return content;
  }
}