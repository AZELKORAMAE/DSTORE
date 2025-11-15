import 'package:flutter/material.dart';
import 'safe_text.dart';
import 'responsive_container.dart';

/// ListTile sécurisé qui gère automatiquement l'overflow
class SafeListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final bool isThreeLine;
  final bool? dense;
  final VisualDensity? visualDensity;
  final ShapeBorder? shape;
  final ListTileStyle? style;
  final Color? selectedColor;
  final Color? iconColor;
  final Color? textColor;
  final EdgeInsetsGeometry? contentPadding;
  final bool enabled;
  final GestureTapCallback? onTap;
  final GestureLongPressCallback? onLongPress;
  final MouseCursor? mouseCursor;
  final bool selected;
  final Color? focusColor;
  final Color? hoverColor;
  final FocusNode? focusNode;
  final bool autofocus;
  final Color? tileColor;
  final Color? selectedTileColor;
  final bool? enableFeedback;
  final double? horizontalTitleGap;
  final double? minVerticalPadding;
  final double? minLeadingWidth;
  
  // Propriétés spécifiques pour le texte sécurisé
  final String? titleText;
  final String? subtitleText;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final int? titleMaxLines;
  final int? subtitleMaxLines;

  const SafeListTile({
    Key? key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.isThreeLine = false,
    this.dense,
    this.visualDensity,
    this.shape,
    this.style,
    this.selectedColor,
    this.iconColor,
    this.textColor,
    this.contentPadding,
    this.enabled = true,
    this.onTap,
    this.onLongPress,
    this.mouseCursor,
    this.selected = false,
    this.focusColor,
    this.hoverColor,
    this.focusNode,
    this.autofocus = false,
    this.tileColor,
    this.selectedTileColor,
    this.enableFeedback,
    this.horizontalTitleGap,
    this.minVerticalPadding,
    this.minLeadingWidth,
    this.titleText,
    this.subtitleText,
    this.titleStyle,
    this.subtitleStyle,
    this.titleMaxLines,
    this.subtitleMaxLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = ScreenUtils.getScreenSize(context);
    final isSmallScreen = screenSize == ScreenSize.small;
    
    // Adapter le padding selon la taille d'écran
    EdgeInsetsGeometry? adaptiveContentPadding = contentPadding;
    if (isSmallScreen && contentPadding == null) {
      adaptiveContentPadding = const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4.0,
      );
    }
    
    // Créer le titre sécurisé
    Widget? safeTitle = title;
    if (titleText != null) {
      safeTitle = SafeText(
        titleText!,
        style: titleStyle,
        maxLines: titleMaxLines ?? (isSmallScreen ? 1 : 2),
      );
    }
    
    // Créer le sous-titre sécurisé
    Widget? safeSubtitle = subtitle;
    if (subtitleText != null) {
      safeSubtitle = SafeText(
        subtitleText!,
        style: subtitleStyle,
        maxLines: subtitleMaxLines ?? (isSmallScreen ? 1 : 2),
      );
    }
    
    // Adapter la densité selon la taille d'écran
    VisualDensity? adaptiveDensity = visualDensity;
    if (isSmallScreen && visualDensity == null) {
      adaptiveDensity = VisualDensity.compact;
    }
    
    return ListTile(
      leading: leading,
      title: safeTitle,
      subtitle: safeSubtitle,
      trailing: trailing,
      isThreeLine: isThreeLine,
      dense: dense,
      visualDensity: adaptiveDensity,
      shape: shape,
      style: style,
      selectedColor: selectedColor,
      iconColor: iconColor,
      textColor: textColor,
      contentPadding: adaptiveContentPadding,
      enabled: enabled,
      onTap: onTap,
      onLongPress: onLongPress,
      mouseCursor: mouseCursor,
      selected: selected,
      focusColor: focusColor,
      hoverColor: hoverColor,
      focusNode: focusNode,
      autofocus: autofocus,
      tileColor: tileColor,
      selectedTileColor: selectedTileColor,
      enableFeedback: enableFeedback,
      horizontalTitleGap: horizontalTitleGap,
      minVerticalPadding: minVerticalPadding,
      minLeadingWidth: minLeadingWidth,
    );
  }
}

/// Factory pour créer facilement des SafeListTile avec du texte
class SafeListTileFactory {
  static Widget create({
    Key? key,
    Widget? leading,
    required String title,
    String? subtitle,
    Widget? trailing,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
    GestureTapCallback? onTap,
    GestureLongPressCallback? onLongPress,
    bool selected = false,
    EdgeInsetsGeometry? contentPadding,
    int? titleMaxLines,
    int? subtitleMaxLines,
  }) {
    return SafeListTile(
      key: key,
      leading: leading,
      titleText: title,
      subtitleText: subtitle,
      trailing: trailing,
      titleStyle: titleStyle,
      subtitleStyle: subtitleStyle,
      onTap: onTap,
      onLongPress: onLongPress,
      selected: selected,
      contentPadding: contentPadding,
      titleMaxLines: titleMaxLines,
      subtitleMaxLines: subtitleMaxLines,
    );
  }
  
  static Widget withIcon({
    Key? key,
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? iconColor,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
    GestureTapCallback? onTap,
    GestureLongPressCallback? onLongPress,
    bool selected = false,
    EdgeInsetsGeometry? contentPadding,
    int? titleMaxLines,
    int? subtitleMaxLines,
  }) {
    return SafeListTile(
      key: key,
      leading: Icon(icon, color: iconColor),
      titleText: title,
      subtitleText: subtitle,
      trailing: trailing,
      titleStyle: titleStyle,
      subtitleStyle: subtitleStyle,
      onTap: onTap,
      onLongPress: onLongPress,
      selected: selected,
      contentPadding: contentPadding,
      titleMaxLines: titleMaxLines,
      subtitleMaxLines: subtitleMaxLines,
    );
  }
  
  static Widget withAvatar({
    Key? key,
    required String avatarText,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? avatarBackgroundColor,
    Color? avatarForegroundColor,
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
    GestureTapCallback? onTap,
    GestureLongPressCallback? onLongPress,
    bool selected = false,
    EdgeInsetsGeometry? contentPadding,
    int? titleMaxLines,
    int? subtitleMaxLines,
  }) {
    return SafeListTile(
      key: key,
      leading: CircleAvatar(
        backgroundColor: avatarBackgroundColor,
        foregroundColor: avatarForegroundColor,
        child: SafeText(
          avatarText,
          maxLines: 1,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      titleText: title,
      subtitleText: subtitle,
      trailing: trailing,
      titleStyle: titleStyle,
      subtitleStyle: subtitleStyle,
      onTap: onTap,
      onLongPress: onLongPress,
      selected: selected,
      contentPadding: contentPadding,
      titleMaxLines: titleMaxLines,
      subtitleMaxLines: subtitleMaxLines,
    );
  }
}