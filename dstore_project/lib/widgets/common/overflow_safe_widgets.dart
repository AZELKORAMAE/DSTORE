/// Bibliothèque de widgets anti-overflow pour une interface utilisateur robuste
/// 
/// Cette bibliothèque fournit des widgets qui gèrent automatiquement les problèmes
/// d'overflow et s'adaptent aux différentes tailles d'écran.
/// 
/// Utilisation :
/// ```dart
/// import 'package:your_app/widgets/common/overflow_safe_widgets.dart';
/// 
/// // Utiliser SafeText au lieu de Text
/// SafeText('Mon texte qui peut être long')
/// 
/// // Utiliser ResponsiveRow au lieu de Row
/// ResponsiveRow(
///   children: [widget1, widget2, widget3],
/// )
/// 
/// // Utiliser SafeListTile au lieu de ListTile
/// SafeListTileFactory.create(
///   title: 'Mon titre',
///   subtitle: 'Mon sous-titre',
/// )
/// ```

library overflow_safe_widgets;

// Export des widgets de texte sécurisé
export 'safe_text.dart';

// Export des widgets de layout responsive
export 'responsive_row.dart';

// Export des containers responsives
export 'responsive_container.dart';

// Export des ListTile sécurisés
export 'safe_list_tile.dart';

// Utilitaires et constantes
class OverflowSafeConstants {
  // Breakpoints pour les différentes tailles d'écran
  static const double smallScreenBreakpoint = 360.0;
  static const double mediumScreenBreakpoint = 600.0;
  static const double largeScreenBreakpoint = 900.0;
  
  // Espacements adaptatifs
  static const double smallSpacing = 4.0;
  static const double mediumSpacing = 8.0;
  static const double largeSpacing = 16.0;
  
  // Padding adaptatifs
  static const EdgeInsets smallPadding = EdgeInsets.all(8.0);
  static const EdgeInsets mediumPadding = EdgeInsets.all(12.0);
  static const EdgeInsets largePadding = EdgeInsets.all(16.0);
  
  // Tailles de police adaptatives
  static const double smallFontSize = 12.0;
  static const double mediumFontSize = 14.0;
  static const double largeFontSize = 16.0;
  
  // Nombre de lignes par défaut selon la taille d'écran
  static const int smallScreenMaxLines = 1;
  static const int mediumScreenMaxLines = 2;
  static const int largeScreenMaxLines = 3;
}

/// Mixin pour ajouter des fonctionnalités anti-overflow à n'importe quel widget
mixin OverflowSafeMixin {
  /// Obtient le nombre de lignes adaptatif selon la taille d'écran
  int getAdaptiveMaxLines(BuildContext context, {int? override}) {
    if (override != null) return override;
    
    final width = MediaQuery.of(context).size.width;
    if (width < OverflowSafeConstants.smallScreenBreakpoint) {
      return OverflowSafeConstants.smallScreenMaxLines;
    } else if (width < OverflowSafeConstants.mediumScreenBreakpoint) {
      return OverflowSafeConstants.mediumScreenMaxLines;
    } else {
      return OverflowSafeConstants.largeScreenMaxLines;
    }
  }
  
  /// Obtient le padding adaptatif selon la taille d'écran
  EdgeInsets getAdaptivePadding(BuildContext context, {EdgeInsets? override}) {
    if (override != null) return override;
    
    final width = MediaQuery.of(context).size.width;
    if (width < OverflowSafeConstants.smallScreenBreakpoint) {
      return OverflowSafeConstants.smallPadding;
    } else if (width < OverflowSafeConstants.mediumScreenBreakpoint) {
      return OverflowSafeConstants.mediumPadding;
    } else {
      return OverflowSafeConstants.largePadding;
    }
  }
  
  /// Obtient l'espacement adaptatif selon la taille d'écran
  double getAdaptiveSpacing(BuildContext context, {double? override}) {
    if (override != null) return override;
    
    final width = MediaQuery.of(context).size.width;
    if (width < OverflowSafeConstants.smallScreenBreakpoint) {
      return OverflowSafeConstants.smallSpacing;
    } else if (width < OverflowSafeConstants.mediumScreenBreakpoint) {
      return OverflowSafeConstants.mediumSpacing;
    } else {
      return OverflowSafeConstants.largeSpacing;
    }
  }
  
  /// Obtient la taille de police adaptative selon la taille d'écran
  double getAdaptiveFontSize(BuildContext context, {double? override}) {
    if (override != null) return override;
    
    final width = MediaQuery.of(context).size.width;
    if (width < OverflowSafeConstants.smallScreenBreakpoint) {
      return OverflowSafeConstants.smallFontSize;
    } else if (width < OverflowSafeConstants.mediumScreenBreakpoint) {
      return OverflowSafeConstants.mediumFontSize;
    } else {
      return OverflowSafeConstants.largeFontSize;
    }
  }
}