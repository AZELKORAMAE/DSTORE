import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('fr', ''),
    Locale('en', ''),
    Locale('ar', ''),
  ];

  // Navigation
  String get dashboard {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['dashboard'] ?? 'dashboard';
}
  String get products {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['products'] ?? 'products';
}
  String get invoices {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['invoices'] ?? 'invoices';
}
  String get clients {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['clients'] ?? 'clients';
}
  String get suppliers {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['suppliers'] ?? 'suppliers';
}
  String get settings {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['settings'] ?? 'settings';
}
  String get more {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['more'] ?? 'more';
}

  // Dashboard
  String get todayRevenue =>
      _localizedValues[locale.languageCode]!['todayRevenue']!;
  String get totalProducts =>
      _localizedValues[locale.languageCode]!['totalProducts']!;
  String get totalClients =>
      _localizedValues[locale.languageCode]!['totalClients']!;
  String get lowStock {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['lowStock'] ?? 'lowStock';
}
  String get recentActivities =>
      _localizedValues[locale.languageCode]!['recentActivities']!;
  String get viewAll {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['viewAll'] ?? 'viewAll';
}
  String get noRecentActivity =>
      _localizedValues[locale.languageCode]!['noRecentActivity']!;
  String get weeklyRevenue =>
      _localizedValues[locale.languageCode]!['weeklyRevenue']!;
  String get salesByProduct =>
      _localizedValues[locale.languageCode]!['salesByProduct']!;
  String get stockByCategory =>
      _localizedValues[locale.languageCode]!['stockByCategory']!;

  // Common
  String get add {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['add'] ?? 'add';
}
  String get edit {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['edit'] ?? 'edit';
}
  String get delete {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['delete'] ?? 'delete';
}
  String get save {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['save'] ?? 'save';
}
  String get cancel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['cancel'] ?? 'cancel';
}
  String get confirm {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['confirm'] ?? 'confirm';
}
  String get search {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['search'] ?? 'search';
}
  String get filter {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['filter'] ?? 'filter';
}
  String get name {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['name'] ?? 'name';
}
  String get description =>
      _localizedValues[locale.languageCode]!['description']!;
  String get price {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['price'] ?? 'price';
}
  String get quantity {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['quantity'] ?? 'quantity';
}
  String get total {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['total'] ?? 'total';
}
  String get date {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['date'] ?? 'date';
}
  String get status {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['status'] ?? 'status';
}

  // Products
  String get addProduct =>
      _localizedValues[locale.languageCode]!['addProduct']!;
  String get editProduct =>
      _localizedValues[locale.languageCode]!['editProduct']!;
  String get productName =>
      _localizedValues[locale.languageCode]!['productName']!;
  String get productDescription =>
      _localizedValues[locale.languageCode]!['productDescription']!;
  String get salePrice {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['salePrice'] ?? 'salePrice';
}
  String get purchasePrice =>
      _localizedValues[locale.languageCode]!['purchasePrice']!;
  String get stock {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['stock'] ?? 'stock';
}
  String get category {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['category'] ?? 'category';
}
  String get barcode {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['barcode'] ?? 'barcode';
}
  String get unit {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['unit'] ?? 'unit';
}
  String get threshold {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['threshold'] ?? 'threshold';
}

  // Product Form Fields
  String get basicInfo {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['basicInfo'] ?? 'basicInfo';
}
  String get priceStock {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['priceStock'] ?? 'priceStock';
}
  String get advancedOptions {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['advancedOptions'] ?? 'advancedOptions';
}
  String get productNameRequired {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['productNameRequired'] ?? 'productNameRequired';
}
  String get productNameHint {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['productNameHint'] ?? 'productNameHint';
}
  String get descriptionHint {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['descriptionHint'] ?? 'descriptionHint';
}
  String get noCategory {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['noCategory'] ?? 'noCategory';
}
  String get barcodeHint {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['barcodeHint'] ?? 'barcodeHint';
}
  String get sku {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['sku'] ?? 'sku';
}
  String get skuHint {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['skuHint'] ?? 'skuHint';
}
  String get scanBarcodeTooltip {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['scanBarcodeTooltip'] ?? 'scanBarcodeTooltip';
}
  String get generateBarcodeTooltip {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['generateBarcodeTooltip'] ?? 'generateBarcodeTooltip';
}
  String get printBarcodeTooltip {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['printBarcodeTooltip'] ?? 'printBarcodeTooltip';
}
  String get purchasePriceRequired {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['purchasePriceRequired'] ?? 'purchasePriceRequired';
}
  String get purchasePriceHint {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['purchasePriceHint'] ?? 'purchasePriceHint';
}
  String get salePriceRequired {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['salePriceRequired'] ?? 'salePriceRequired';
}
  String get salePriceHint {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['salePriceHint'] ?? 'salePriceHint';
}
  String get invalidPrice {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['invalidPrice'] ?? 'invalidPrice';
}
  String get stockQuantityRequired {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['stockQuantityRequired'] ?? 'stockQuantityRequired';
}
  String get stockQuantityHint {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['stockQuantityHint'] ?? 'stockQuantityHint';
}
  String get invalidQuantity {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['invalidQuantity'] ?? 'invalidQuantity';
}
  String get stockAlertThreshold {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['stockAlertThreshold'] ?? 'stockAlertThreshold';
}
  String get stockAlertThresholdHint {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['stockAlertThresholdHint'] ?? 'stockAlertThresholdHint';
}
  String get stockAlertThresholdHelper {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['stockAlertThresholdHelper'] ?? 'stockAlertThresholdHelper';
}
  String get thresholdRequired {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['thresholdRequired'] ?? 'thresholdRequired';
}
  String get invalidThreshold {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['invalidThreshold'] ?? 'invalidThreshold';
}
  String get activeProduct {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['activeProduct'] ?? 'activeProduct';
}
  String get activeProductDescription {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['activeProductDescription'] ?? 'activeProductDescription';
}
  String get productImage {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['productImage'] ?? 'productImage';
}
  String get chooseImage {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['chooseImage'] ?? 'chooseImage';
}
  String get takePhoto {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['takePhoto'] ?? 'takePhoto';
}
  String get removeImage {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['removeImage'] ?? 'removeImage';
}
  String get noImageSelected {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['noImageSelected'] ?? 'noImageSelected';
}
  String get profitPerUnit {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['profitPerUnit'] ?? 'profitPerUnit';
}
  String get productDetails {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['productDetails'] ?? 'productDetails';
}
  String get productStatus {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['productStatus'] ?? 'productStatus';
}
  String get active {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['active'] ?? 'active';
}
  String get inactive {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['inactive'] ?? 'inactive';
}
  String get modifiedOn {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['modifiedOn'] ?? 'modifiedOn';
}
  String get noDescription {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['noDescription'] ?? 'noDescription';
}
  String get notDefined {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['notDefined'] ?? 'notDefined';
}

  // Messages de succès et d'erreur
  String get productCreatedSuccess {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['productCreatedSuccess'] ?? 'productCreatedSuccess';
}
  String get productUpdatedSuccess {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['productUpdatedSuccess'] ?? 'productUpdatedSuccess';
}
  String get saveError {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['saveError'] ?? 'saveError';
}
  String get saveErrorMessage {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['saveErrorMessage'] ?? 'saveErrorMessage';
}

  // Actions rapides et autres
  String get quickActions {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['quickActions'] ?? 'quickActions';
}
  /// Subtitle under Quick Actions heading on dashboard
  String get quickActionsSubtitle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['quickActionsSubtitle'] ?? 'quickActionsSubtitle';
}
  String get adjustStock {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['adjustStock'] ?? 'adjustStock';
}
  String get stockAdjustment {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['stockAdjustment'] ?? 'stockAdjustment';
}
  String get addStock {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['addStock'] ?? 'addStock';
}
  String get removeStock {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['removeStock'] ?? 'removeStock';
}
  String get setStock {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['setStock'] ?? 'setStock';
}
  String get newQuantity {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['newQuantity'] ?? 'newQuantity';
}
  String get reason {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['reason'] ?? 'reason';
}
  String get reasonHint {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['reasonHint'] ?? 'reasonHint';
}
  String get userNotConnected {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['userNotConnected'] ?? 'userNotConnected';
}
  String get existingProductDialog {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['existingProductDialog'] ?? 'existingProductDialog';
}
  String get existingProductMessage {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['existingProductMessage'] ?? 'existingProductMessage';
}

  // Import et messages
  String get productsFoundInExcel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['productsFoundInExcel'] ?? 'productsFoundInExcel';
}
  String get noProductsFoundInExcel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['noProductsFoundInExcel'] ?? 'noProductsFoundInExcel';
}
  String get errorReadingFile {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['errorReadingFile'] ?? 'errorReadingFile';
}
  String get selectCategory {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['selectCategory'] ?? 'selectCategory';
}
  String get supportedFileFormats {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['supportedFileFormats'] ?? 'supportedFileFormats';
}
  String get acceptedFormats {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['acceptedFormats'] ?? 'acceptedFormats';
}
  String get requiredColumns {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['requiredColumns'] ?? 'requiredColumns';
}
  String get optionalColumns {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['optionalColumns'] ?? 'optionalColumns';
}
  String get productNameRequiredForImport {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['productNameRequiredForImport'] ?? 'productNameRequiredForImport';
}
  String get barcodeColumn {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['barcodeColumn'] ?? 'barcodeColumn';
}
  String get imageColumn {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['imageColumn'] ?? 'imageColumn';
}
  String get descriptionColumn {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['descriptionColumn'] ?? 'descriptionColumn';
}
  String get purchasePriceColumn {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['purchasePriceColumn'] ?? 'purchasePriceColumn';
}
  String get salePriceColumn {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['salePriceColumn'] ?? 'salePriceColumn';
}
  String get stockColumn {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['stockColumn'] ?? 'stockColumn';
}
  String get unitColumn {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['unitColumn'] ?? 'unitColumn';
}

  // Settings
  String get theme {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['theme'] ?? 'theme';
}
  String get language {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['language'] ?? 'language';
}
  String get scanSound {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['scanSound'] ?? 'scanSound';
}
  String get companySettings =>
      _localizedValues[locale.languageCode]!['companySettings']!;
  String get companyName =>
      _localizedValues[locale.languageCode]!['companyName']!;
  String get companyLogo =>
      _localizedValues[locale.languageCode]!['companyLogo']!;
  String get administration =>
      _localizedValues[locale.languageCode]!['administration']!;
  String get globalProducts =>
      _localizedValues[locale.languageCode]!['globalProducts']!;
  String get userManagement =>
      _localizedValues[locale.languageCode]!['userManagement']!;

  // Themes
  String get lightTheme =>
      _localizedValues[locale.languageCode]!['lightTheme']!;
  String get darkTheme {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['darkTheme'] ?? 'darkTheme';
}
  String get systemTheme =>
      _localizedValues[locale.languageCode]!['systemTheme']!;

  // Sounds
  String get classicBeep =>
      _localizedValues[locale.languageCode]!['classicBeep']!;
  String get success {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['success'] ?? 'success';
}
  String get notification =>
      _localizedValues[locale.languageCode]!['notification']!;
  String get cashRegister =>
      _localizedValues[locale.languageCode]!['cashRegister']!;
  String get noSound {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['noSound'] ?? 'noSound';
}

  // Messages
  String get chooseLanguage =>
      _localizedValues[locale.languageCode]!['chooseLanguage']!;
  String get chooseTheme =>
      _localizedValues[locale.languageCode]!['chooseTheme']!;
  String get chooseScanSound =>
      _localizedValues[locale.languageCode]!['chooseScanSound']!;
  String get testSound {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['testSound'] ?? 'testSound';
}

  // Navigation supplémentaire
  String get categories =>
      _localizedValues[locale.languageCode]!['categories']!;
  String get home {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['home'] ?? 'home';
}
  String get reports {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['reports'] ?? 'reports';
}
  String get pos {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['pos'] ?? 'pos';
}

  // Dépenses
  String get expenses {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['expenses'] ?? 'expenses';
}
  String get addExpense =>
      _localizedValues[locale.languageCode]!['addExpense']!;
  String get expenseType =>
      _localizedValues[locale.languageCode]!['expenseType']!;
  String get amount {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['amount'] ?? 'amount';
}
  String get rent {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['rent'] ?? 'rent';
}
  String get electricity =>
      _localizedValues[locale.languageCode]!['electricity']!;
  String get wifi {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['wifi'] ?? 'wifi';
}
  String get other {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['other'] ?? 'other';
}
  String get monthlyExpenses =>
      _localizedValues[locale.languageCode]!['monthlyExpenses']!;

  // Import/Export
  String get importProducts =>
      _localizedValues[locale.languageCode]!['importProducts']!;
  String get exportData =>
      _localizedValues[locale.languageCode]!['exportData']!;
  String get selectFile =>
      _localizedValues[locale.languageCode]!['selectFile']!;
  String get importFromExcel =>
      _localizedValues[locale.languageCode]!['importFromExcel']!;

  // Recherche avancée
  String get searchByName =>
      _localizedValues[locale.languageCode]!['searchByName']!;
  String get searchByBarcode =>
      _localizedValues[locale.languageCode]!['searchByBarcode']!;
  String get searchByCategory =>
      _localizedValues[locale.languageCode]!['searchByCategory']!;
  String get advancedSearch =>
      _localizedValues[locale.languageCode]!['advancedSearch']!;
  String get noResults {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['noResults'] ?? 'noResults';
}
  String get scanBarcode =>
      _localizedValues[locale.languageCode]!['scanBarcode']!;
  String get searchProducts =>
      _localizedValues[locale.languageCode]!['searchProducts']!;

  // Messages d'interface
  String get welcome {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['welcome'] ?? 'welcome';
}
  String get loading {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['loading'] ?? 'loading';
}
  String get error {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['error'] ?? 'error';
}
  String get successMessage =>
      _localizedValues[locale.languageCode]!['successMessage']!;
  String get retry {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['retry'] ?? 'retry';
}
  String get close {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['close'] ?? 'close';
}
  String get back {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['back'] ?? 'back';
}
  String get next {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['next'] ?? 'next';
}
  String get previous {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['previous'] ?? 'previous';
}
  String get finish {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['finish'] ?? 'finish';
}

  // Formulaires
  String get required {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['required'] ?? 'required';
}
  String get optional {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['optional'] ?? 'optional';
}
  String get pleaseEnter =>
      _localizedValues[locale.languageCode]!['pleaseEnter']!;
  String get invalidFormat =>
      _localizedValues[locale.languageCode]!['invalidFormat']!;

  // Actions
  String get create {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['create'] ?? 'create';
}
  String get update {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['update'] ?? 'update';
}
  String get remove {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['remove'] ?? 'remove';
}
  String get duplicate {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['duplicate'] ?? 'duplicate';
}
  String get share {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['share'] ?? 'share';
}
String get print {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['print'] ?? 'print';
}
String get customizePdf {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['customizePdf'] ?? 'customizePdf';
}
String get thermalPrint {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['thermalPrint'] ?? 'thermalPrint';
}
String get shareInvoice {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['shareInvoice'] ?? 'shareInvoice';
}
String get shareFormatQuestion {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['shareFormatQuestion'] ?? 'shareFormatQuestion';
}
String get standardPdf {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['standardPdf'] ?? 'standardPdf';
}
String get thermalPdf {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['thermalPdf'] ?? 'thermalPdf';
}
String get sendByEmail {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['sendByEmail'] ?? 'sendByEmail';
}
String get invoiceImage {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['invoiceImage'] ?? 'invoiceImage';
}
String get viewFullscreen {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['viewFullscreen'] ?? 'viewFullscreen';
}
String get imageNotAvailable {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['imageNotAvailable'] ?? 'imageNotAvailable';
}
String get thankYouVisit {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['thankYouVisit'] ?? 'thankYouVisit';
}
String get billedToHeader {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['billedToHeader'] ?? 'billedToHeader';
}
String get clientHeader {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['clientHeader'] ?? 'clientHeader';
}
String get supplierHeader {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['supplierHeader'] ?? 'supplierHeader';
}
String get itemsHeader {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['itemsHeader'] ?? 'itemsHeader';
}
String get itemLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['itemLabel'] ?? 'itemLabel';
}
String get unitPriceShort {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['unitPriceShort'] ?? 'unitPriceShort';
}
String get discountLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['discountLabel'] ?? 'discountLabel';
}
String get noItemsInInvoice {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['noItemsInInvoice'] ?? 'noItemsInInvoice';
}
String get featureNotImplemented {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['featureNotImplemented'] ?? 'featureNotImplemented';
}

  // Factures
  String get invoice {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['invoice'] ?? 'invoice';
}
  String get invoiceNumber {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['invoiceNumber'] ?? 'invoiceNumber';
}
  String get invoiceDate {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['invoiceDate'] ?? 'invoiceDate';
}
  String get dueDate {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['dueDate'] ?? 'dueDate';
}
  String get subtotal {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['subtotal'] ?? 'subtotal';
}
  String get taxAmount {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['taxAmount'] ?? 'taxAmount';
}
  String get discountAmount {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['discountAmount'] ?? 'discountAmount';
}
  String get totalAmount {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['totalAmount'] ?? 'totalAmount';
}
  String get paidAmount {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['paidAmount'] ?? 'paidAmount';
}
  String get remainingAmount {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['remainingAmount'] ?? 'remainingAmount';
}
  String get unitPrice {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['unitPrice'] ?? 'unitPrice';
}
  String get itemTotal {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['itemTotal'] ?? 'itemTotal';
}
  String get tvaRate {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['tvaRate'] ?? 'tvaRate';
}
  String get currency {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['currency'] ?? 'currency';
}

  // Support
  String get support {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['support'] ?? 'support';
}
  String get contactUs {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['contactUs'] ?? 'contactUs';
}
  String get sendMessage {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['sendMessage'] ?? 'sendMessage';
}
  String get yourEmail {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['yourEmail'] ?? 'yourEmail';
}
  String get subject {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['subject'] ?? 'subject';
}
  String get message {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['message'] ?? 'message';
}
  String get contactInfo {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['contactInfo'] ?? 'contactInfo';
}
  String get phone {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['phone'] ?? 'phone';
}
  String get whatsapp {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['whatsapp'] ?? 'whatsapp';
}
  String get availability {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['availability'] ?? 'availability';
}
  String get responseTime {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['responseTime'] ?? 'responseTime';
}
  String get supportedLanguages {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['supportedLanguages'] ?? 'supportedLanguages';
}
  String get email {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['email'] ?? 'email';
}

  // Paramètres
  String get appSettings {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['appSettings'] ?? 'appSettings';
}
  String get businessSettings {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['businessSettings'] ?? 'businessSettings';
}
  String get notifications {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['notifications'] ?? 'notifications';
}
  String get pushNotifications {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['pushNotifications'] ?? 'pushNotifications';
}
  String get dataBackup {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['dataBackup'] ?? 'dataBackup';
}
  String get aboutSupport {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['aboutSupport'] ?? 'aboutSupport';
}
  String get logout {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['logout'] ?? 'logout';
}
  String get version {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['version'] ?? 'version';
}
  String get termsOfService {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['termsOfService'] ?? 'termsOfService';
}
  String get advancedSettings {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['advancedSettings'] ?? 'advancedSettings';
}
  String get dataManagement {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['dataManagement'] ?? 'dataManagement';
}

  // Actions rapides et navigation
  String get sale {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['sale'] ?? 'sale';
}
  String get purchase {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['purchase'] ?? 'purchase';
}
  String get createInvoice {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['createInvoice'] ?? 'createInvoice';
}
  String get manageStock {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['manageStock'] ?? 'manageStock';
}
  String get viewAllClients {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['viewAllClients'] ?? 'viewAllClients';
}
  String get viewAllSuppliers {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['viewAllSuppliers'] ?? 'viewAllSuppliers';
}
  /// Label to add a supplier (used in quick actions and supplier screens)
  String get addSupplier {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['addSupplier'] ?? 'addSupplier';
}
  String get addClient {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['addClient'] ?? 'addClient';
}
  String get addCategory {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['addCategory'] ?? 'addCategory';
}

  // Formulaires et champs
  String get profile {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['profile'] ?? 'profile';
}
  String get fullName {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['fullName'] ?? 'fullName';
}
  String get businessName {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['businessName'] ?? 'businessName';
}
  String get phoneNumber {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['phoneNumber'] ?? 'phoneNumber';
}
  String get address {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['address'] ?? 'address';
}
  String get subscriptionStatus {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['subscriptionStatus'] ?? 'subscriptionStatus';
}
  String get subscriptionType {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['subscriptionType'] ?? 'subscriptionType';
}
  String get subscriptionStartDate {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['subscriptionStartDate'] ?? 'subscriptionStartDate';
}
  String get subscriptionEndDate {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['subscriptionEndDate'] ?? 'subscriptionEndDate';
}
  String get lastPaymentDate {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['lastPaymentDate'] ?? 'lastPaymentDate';
}
  String get lastLoginDate {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['lastLoginDate'] ?? 'lastLoginDate';
}
  String get activeSubscription {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['activeSubscription'] ?? 'activeSubscription';
}
  String get expiredSubscription {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['expiredSubscription'] ?? 'expiredSubscription';
}
  String get noActiveSubscription {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['noActiveSubscription'] ?? 'noActiveSubscription';
}
  String get subscriptionRemainingDays {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['subscriptionRemainingDays'] ?? 'subscriptionRemainingDays';
}
  String get subscriptionRemainingHours {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['subscriptionRemainingHours'] ?? 'subscriptionRemainingHours';
}
  String get subscriptionRemainingTime {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['subscriptionRemainingTime'] ?? 'subscriptionRemainingTime';
}
  String get subscriptionExpired {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['subscriptionExpired'] ?? 'subscriptionExpired';
}
  String get refreshSubscription {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['refreshSubscription'] ?? 'refreshSubscription';
}
  String get subscriptionUpdated {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['subscriptionUpdated'] ?? 'subscriptionUpdated';
}

  // Messages et notifications
  String get noSalesDataAvailable {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['noSalesDataAvailable'] ?? 'noSalesDataAvailable';
}
  String get noNotifications {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['noNotifications'] ?? 'noNotifications';
}
  String get ok {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['ok'] ?? 'ok';
}
  String get warning {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['warning'] ?? 'warning';
}
  String get info {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['info'] ?? 'info';
}

  // Scanner et codes-barres
  String get manualBarcodeEntry {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['manualBarcodeEntry'] ?? 'manualBarcodeEntry';
}
  String get manualBarcodeEntryDescription {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['manualBarcodeEntryDescription'] ?? 'manualBarcodeEntryDescription';
}
  String get scanError {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['scanError'] ?? 'scanError';
}
  String get barcodeScanner {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['barcodeScanner'] ?? 'barcodeScanner';
}
  String get multipleLabelsPerPage {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['multipleLabelsPerPage'] ?? 'multipleLabelsPerPage';
}
  String get numberOfLabels {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['numberOfLabels'] ?? 'numberOfLabels';
}

  // Images et sélection
  String get chooseFromGallery {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['chooseFromGallery'] ?? 'chooseFromGallery';
}
  String get permissionRequired {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['permissionRequired'] ?? 'permissionRequired';
}
  String get imageSelectionError {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['imageSelectionError'] ?? 'imageSelectionError';
}
  String get imageSelectionNotImplemented {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['imageSelectionNotImplemented'] ?? 'imageSelectionNotImplemented';
}

  // Clients et fournisseurs
  String get anonymousClient {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['anonymousClient'] ?? 'anonymousClient';
}
  String get anonymousSupplier {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['anonymousSupplier'] ?? 'anonymousSupplier';
}
  String get activeSupplier {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['activeSupplier'] ?? 'activeSupplier';
}
  String get activeSupplierDescription {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['activeSupplierDescription'] ?? 'activeSupplierDescription';
}
  String get supplierDetails {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['supplierDetails'] ?? 'supplierDetails';
}
  String get clientDetails {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['clientDetails'] ?? 'clientDetails';
}

  // Factures et POS
  String get tax {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['tax'] ?? 'tax';
}
  String get paid {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['paid'] ?? 'paid';
}
  String get modifyQuantity {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['modifyQuantity'] ?? 'modifyQuantity';
}
  String get modifyPrice {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['modifyPrice'] ?? 'modifyPrice';
}
  String get product {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['product'] ?? 'product';
}
  String get currentPrice {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['currentPrice'] ?? 'currentPrice';
}
  String get newUnitPrice {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['newUnitPrice'] ?? 'newUnitPrice';
}
  String get modify {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['modify'] ?? 'modify';
}
  String get clearCart {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['clearCart'] ?? 'clearCart';
}
  String get clearCartConfirmation {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['clearCartConfirmation'] ?? 'clearCartConfirmation';
}
  String get clear {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['clear'] ?? 'clear';
}
  String get newTransaction {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['newTransaction'] ?? 'newTransaction';
}
  String get finalizePurchase {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['finalizePurchase'] ?? 'finalizePurchase';
}

  // POS / Point de vente
  String get posSaleTitle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['posSaleTitle'] ?? 'posSaleTitle';
}
  String get posPurchaseTitle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['posPurchaseTitle'] ?? 'posPurchaseTitle';
}
  String get barcodeEntryHint {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['barcodeEntryHint'] ?? 'barcodeEntryHint';
}
  String get quantityShort {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['quantityShort'] ?? 'quantityShort';
}
  String get closeScannerTooltip {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['closeScannerTooltip'] ?? 'closeScannerTooltip';
}
  String get scannerTooltip {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['scannerTooltip'] ?? 'scannerTooltip';
}
  String get clientOptionalLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['clientOptionalLabel'] ?? 'clientOptionalLabel';
}
  String get supplierLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['supplierLabel'] ?? 'supplierLabel';
}
  String get selectSupplierError {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['selectSupplierError'] ?? 'selectSupplierError';
}
  String get emptyCartTitle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['emptyCartTitle'] ?? 'emptyCartTitle';
}
  String get emptyCartSubtitle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['emptyCartSubtitle'] ?? 'emptyCartSubtitle';
}
  String get unitPriceLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['unitPriceLabel'] ?? 'unitPriceLabel';
}
  String get quantityLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['quantityLabel'] ?? 'quantityLabel';
}
  String get amountPaid {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['amountPaid'] ?? 'amountPaid';
}
  String get changeLabelPositive {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['changeLabelPositive'] ?? 'changeLabelPositive';
}
  String get changeLabelNegative {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['changeLabelNegative'] ?? 'changeLabelNegative';
}
  String get finalizeSale {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['finalizeSale'] ?? 'finalizeSale';
}
  String get saleSuccess {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['saleSuccess'] ?? 'saleSuccess';
}
  String get purchaseSuccess {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['purchaseSuccess'] ?? 'purchaseSuccess';
}
  String get invoiceTotalLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['invoiceTotalLabel'] ?? 'invoiceTotalLabel';
}
  String get invoicePaidLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['invoicePaidLabel'] ?? 'invoicePaidLabel';
}
  String get invoiceChangeToReturnLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['invoiceChangeToReturnLabel'] ?? 'invoiceChangeToReturnLabel';
}
  String get creditAddedLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['creditAddedLabel'] ?? 'creditAddedLabel';
}
  String get invoiceCreationError {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['invoiceCreationError'] ?? 'invoiceCreationError';
}
  String get partialPaymentError {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['partialPaymentError'] ?? 'partialPaymentError';
}
  String get creditLimitExceeded {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['creditLimitExceeded'] ?? 'creditLimitExceeded';
}
  String get genericErrorPrefix {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['genericErrorPrefix'] ?? 'genericErrorPrefix';
}
  String get errorLoadingSuppliers {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['errorLoadingSuppliers'] ?? 'errorLoadingSuppliers';
}
  String get productNotFound {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['productNotFound'] ?? 'productNotFound';
}
  String get addProductWithBarcodeQuestion => _localizedValues[locale.languageCode]!['addProductWithBarcodeQuestion'] ?? 'Produit non trouvé. Voulez-vous ajouter un nouveau produit avec ce code-barres?';
  // Removed duplicate getter totalAmountLabel (defined earlier)
  // String get totalAmountLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['totalAmountLabel'] ?? 'totalAmountLabel';
}
  String get invoiceImageOptional {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['invoiceImageOptional'] ?? 'invoiceImageOptional';
}

  // Catégories
  // Removed duplicate getter editCategory (defined earlier)
  String get deleteCategory {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['deleteCategory'] ?? 'deleteCategory';
}
  String get confirmDeleteCategory {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['confirmDeleteCategory'] ?? 'confirmDeleteCategory';
}
  String get deleteCategoryConfirmation {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['deleteCategoryConfirmation'] ?? 'deleteCategoryConfirmation';
}
  String get categoryDeletedSuccess {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['categoryDeletedSuccess'] ?? 'categoryDeletedSuccess';
}
  String get categoryDeleteError {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['categoryDeleteError'] ?? 'categoryDeleteError';
}

  // Crédits
  String get makePayment {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['makePayment'] ?? 'makePayment';
}
  String get pleaseEnterAmount {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['pleaseEnterAmount'] ?? 'pleaseEnterAmount';
}
  String get invalidAmount {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['invalidAmount'] ?? 'invalidAmount';
}
  String get amountExceedsRemaining {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['amountExceedsRemaining'] ?? 'amountExceedsRemaining';
}
  String get paymentError {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['paymentError'] ?? 'paymentError';
}
  String get loadHistoryError {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['loadHistoryError'] ?? 'loadHistoryError';
}

  // Recherche
  String get noResultsFound {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['noResultsFound'] ?? 'noResultsFound';
}

  // Paramètres avancés
  String get advancedSettingsTitle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['advancedSettingsTitle'] ?? 'advancedSettingsTitle';
}
  String get completeReset {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['completeReset'] ?? 'completeReset';
}
  String get businessDataReset {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['businessDataReset'] ?? 'businessDataReset';
}
  String get completeResetDescription {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['completeResetDescription'] ?? 'completeResetDescription';
}
  String get businessDataResetDescription {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['businessDataResetDescription'] ?? 'businessDataResetDescription';
}
  String get typeToConfirm {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['typeToConfirm'] ?? 'typeToConfirm';
}
  String get typeHere {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['typeHere'] ?? 'typeHere';
}

  // Gestion des appareils
  String get authorize {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['authorize'] ?? 'authorize';
}
  String get revoke {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['revoke'] ?? 'revoke';
}
  String get removeDevice {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['removeDevice'] ?? 'removeDevice';
}

  // Sauvegarde Google Drive
  String get googleDriveBackup {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['googleDriveBackup'] ?? 'googleDriveBackup';
}
  String get connectToGoogleDrive {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['connectToGoogleDrive'] ?? 'connectToGoogleDrive';
}
  String get disconnect {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['disconnect'] ?? 'disconnect';
}
  String get backup {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['backup'] ?? 'backup';
}
  String get refresh {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['refresh'] ?? 'refresh';
}
  String get createdOn {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['createdOn'] ?? 'createdOn';
}
  String get size {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['size'] ?? 'size';
}
  String get restore {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['restore'] ?? 'restore';
}
  String get confirmRestore {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['confirmRestore'] ?? 'confirmRestore';
}
  String get confirmDelete {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['confirmDelete'] ?? 'confirmDelete';
}

  // Paramètres de l'entreprise
  String get chooseCurrency {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['chooseCurrency'] ?? 'chooseCurrency';
}
  String get moroccanDirham {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['moroccanDirham'] ?? 'moroccanDirham';
}
  String get euro {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['euro'] ?? 'euro';
}
  String get usDollar {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['usDollar'] ?? 'usDollar';
}
  String get clearAllData {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['clearAllData'] ?? 'clearAllData';
}
  String get logoutConfirmation {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['logoutConfirmation'] ?? 'logoutConfirmation';
}
  String get logoutConfirmationMessage {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['logoutConfirmationMessage'] ?? 'logoutConfirmationMessage';
}
  String get exitConfirmationMessage {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['exitConfirmationMessage'] ?? 'exitConfirmationMessage';
}
  String get chooseSound {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['chooseSound'] ?? 'chooseSound';
}

  // Support
  String get needHelp {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['needHelp'] ?? 'needHelp';
}
  String get ourTeamIsHere {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['ourTeamIsHere'] ?? 'ourTeamIsHere';
}
  String get otherContactMethods {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['otherContactMethods'] ?? 'otherContactMethods';
}
  String get availabilityHours {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['availabilityHours'] ?? 'availabilityHours';
}
  String get supportedLanguagesList {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['supportedLanguagesList'] ?? 'supportedLanguagesList';
}
  String get responseTimeHours {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['responseTimeHours'] ?? 'responseTimeHours';
}
  String get emailAppOpened {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['emailAppOpened'] ?? 'emailAppOpened';
}
  String get cannotOpenEmailApp {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['cannotOpenEmailApp'] ?? 'cannotOpenEmailApp';
}
  String get cannotOpenPhoneApp {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['cannotOpenPhoneApp'] ?? 'cannotOpenPhoneApp';
}
  String get cannotOpenWhatsApp {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['cannotOpenWhatsApp'] ?? 'cannotOpenWhatsApp';
}
  String get messageMinLength {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['messageMinLength'] ?? 'messageMinLength';
}
  String get describeYourProblem {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['describeYourProblem'] ?? 'describeYourProblem';
}
  String get subjectOfMessage {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['subjectOfMessage'] ?? 'subjectOfMessage';
}
  String get sending {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['sending'] ?? 'sending';
}
  String get sendMessageButton {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['sendMessageButton'] ?? 'sendMessageButton';
}

  // Autorisation d'appareil
  String get deviceAuthorization {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['deviceAuthorization'] ?? 'deviceAuthorization';
}
  String get deviceInfo {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['deviceInfo'] ?? 'deviceInfo';
}
  String get deviceRegisteredAutomatically {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['deviceRegisteredAutomatically'] ?? 'deviceRegisteredAutomatically';
}
  String get adminMustAuthorize {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['adminMustAuthorize'] ?? 'adminMustAuthorize';
}
  String get youWillReceiveNotification {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['youWillReceiveNotification'] ?? 'youWillReceiveNotification';
}
  String get cannotAccessApp {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['cannotAccessApp'] ?? 'cannotAccessApp';
}

  // Écrans et contenus
  String get refreshData {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['refreshData'] ?? 'refreshData';
}
  String get editItem {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['editItem'] ?? 'editItem';
}
  String get deleteItem {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['deleteItem'] ?? 'deleteItem';
}
  String get deleteConfirmation {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['deleteConfirmation'] ?? 'deleteConfirmation';
}
  String get yes {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['yes'] ?? 'yes';
}
  String get no {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['no'] ?? 'no';
}

  // Champs manquants pour les produits
  String get rupture {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['rupture'] ?? 'rupture';
}
  String get stockFaible {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['stockFaible'] ?? 'stockFaible';
}
  String get tous {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['tous'] ?? 'tous';
}
  String get marge {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['marge'] ?? 'marge';
}
  String get valeur {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['valeur'] ?? 'valeur';
}
  String get piece {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['piece'] ?? 'piece';
}
  String get modifier {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['modifier'] ?? 'modifier';
}
  String get ruptureDeStock {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['ruptureDeStock'] ?? 'ruptureDeStock';
}
  String get stockSuffisant {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['stockSuffisant'] ?? 'stockSuffisant';
}
  String get stockActuel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['stockActuel'] ?? 'stockActuel';
}
  String get valeurStock {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['valeurStock'] ?? 'valeurStock';
}
  String get produitsNecessitantAttention {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['produitsNecessitantAttention'] ?? 'produitsNecessitantAttention';
}
  String get gererLesStocks {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['gererLesStocks'] ?? 'gererLesStocks';
}
  String get voirAutresProduits {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['voirAutresProduits'] ?? 'voirAutresProduits';
}
  String get stockOptimalPourTousLesProduits {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['stockOptimalPourTousLesProduits'] ?? 'stockOptimalPourTousLesProduits';
}
  String get produitsEnStockFaible {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['produitsEnStockFaible'] ?? 'produitsEnStockFaible';
}
  String get faible {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['faible'] ?? 'faible';
}
  String get okStatus {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['okStatus'] ?? 'okStatus';
}
  String get min {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['min'] ?? 'min';
}
  String get ruptureLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['ruptureLabel'] ?? 'ruptureLabel';
}
  String get faibleLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['faibleLabel'] ?? 'faibleLabel';
}
  String get chargement {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['chargement'] ?? 'chargement';
}
  String get erreurDeChargement {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['erreurDeChargement'] ?? 'erreurDeChargement';
}
  String get gestionDesStocks {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['gestionDesStocks'] ?? 'gestionDesStocks';
}
  String get alertesDeStock {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['alertesDeStock'] ?? 'alertesDeStock';
}
  String get produitsNecessitentAttention {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['produitsNecessitentAttention'] ?? 'produitsNecessitentAttention';
}
  String get stockFaibleLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['stockFaibleLabel'] ?? 'stockFaibleLabel';
}
  String get produitsEnStockFaibleLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['produitsEnStockFaibleLabel'] ?? 'produitsEnStockFaibleLabel';
}

  // Champs manquants pour le dashboard
  String get bonjour {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['bonjour'] ?? 'bonjour';
}
  String get bonApresMidi {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['bonApresMidi'] ?? 'bonApresMidi';
}
  String get bonsoir {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['bonsoir'] ?? 'bonsoir';
}
  String get utilisateur {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['utilisateur'] ?? 'utilisateur';
}
  String get apercuActivite {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['apercuActivite'] ?? 'apercuActivite';
}
  String get actionsRapides {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['actionsRapides'] ?? 'actionsRapides';
}
  String get facture {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['facture'] ?? 'facture';
}
  String get scanner {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['scanner'] ?? 'scanner';
}
  String get nouvelleFacture {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['nouvelleFacture'] ?? 'nouvelleFacture';
}
  String get ajouterProduit {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['ajouterProduit'] ?? 'ajouterProduit';
}
  String get nouveauClient {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['nouveauClient'] ?? 'nouveauClient';
}
  String get ajouterCategorie {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['ajouterCategorie'] ?? 'ajouterCategorie';
}
  String get nouveauFournisseur {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['nouveauFournisseur'] ?? 'nouveauFournisseur';
}
  String get scannerProduit {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['scannerProduit'] ?? 'scannerProduit';
}
  String get pointDeVente {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['pointDeVente'] ?? 'pointDeVente';
}
  String get accesRapideVente {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['accesRapideVente'] ?? 'accesRapideVente';
}
  String get vente {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['vente'] ?? 'vente';
}
  String get achat {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['achat'] ?? 'achat';
}
  String get aucuneNotification {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['aucuneNotification'] ?? 'aucuneNotification';
}
  String get fermer {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['fermer'] ?? 'fermer';
}
  String get revenusDuJour {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['revenusDuJour'] ?? 'revenusDuJour';
}
  String get produits {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['produits'] ?? 'produits';
}

  // Stock alerts
  /// Singular form: "needs your attention" / "nécessite votre attention" / "يحتاج إلى اهتمامك"
  String get needAttentionSingular {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['needAttentionSingular'] ?? 'needAttentionSingular';
}
  /// Plural form: "need your attention" / "nécessitent votre attention" / "يحتاجون إلى اهتمامك"
  String get needAttentionPlural {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['needAttentionPlural'] ?? 'needAttentionPlural';
}
  /// Message when all products have sufficient stock
  String get allProductsSufficientStock {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['allProductsSufficientStock'] ?? 'allProductsSufficientStock';
}
  /// Label for link to see more products
  String get seeOtherProducts {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['seeOtherProducts'] ?? 'seeOtherProducts';
}

  // ====================================================================
  // Ajout de getters pour les écrans Catégories, Clients, Crédits et
  // Factures. Ces getters permettent d'accéder aux nouvelles clés de
  // traduction ajoutées dans la carte _localizedValues. Sans ces
  // getters, les chaînes ne seraient pas disponibles via AppLocalizations.

  // Catégories
  String get categoriesSearchHint {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['categoriesSearchHint'] ?? 'categoriesSearchHint';
}
  String get categoriesTotal {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['categoriesTotal'] ?? 'categoriesTotal';
}
  String get categoriesActive {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['categoriesActive'] ?? 'categoriesActive';
}
  String get categoriesProducts {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['categoriesProducts'] ?? 'categoriesProducts';
}
  String get categoriesEmptyTitle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['categoriesEmptyTitle'] ?? 'categoriesEmptyTitle';
}
  String get categoriesEmptySubtitle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['categoriesEmptySubtitle'] ?? 'categoriesEmptySubtitle';
}
  String get createCategory {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['createCategory'] ?? 'createCategory';
}
  String get editCategory {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['editCategory'] ?? 'editCategory';
}
  String get addCategoryTitle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['addCategoryTitle'] ?? 'addCategoryTitle';
}
  String get categoryPreview {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['categoryPreview'] ?? 'categoryPreview';
}
  String get categoryNameLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['categoryNameLabel'] ?? 'categoryNameLabel';
}
  String get categoryNameHint {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['categoryNameHint'] ?? 'categoryNameHint';
}
  String get categoryNameRequired {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['categoryNameRequired'] ?? 'categoryNameRequired';
}
  String get categoryDescriptionHint {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['categoryDescriptionHint'] ?? 'categoryDescriptionHint';
}
  String get categoryImagePlaceholder {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['categoryImagePlaceholder'] ?? 'categoryImagePlaceholder';
}
  String get categoryColor {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['categoryColor'] ?? 'categoryColor';
}
  String get options {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['options'] ?? 'options';
}
  String get categoryActive {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['categoryActive'] ?? 'categoryActive';
}
  String get categoryActiveHelper {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['categoryActiveHelper'] ?? 'categoryActiveHelper';
}
  String get categoryCreatedSuccess {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['categoryCreatedSuccess'] ?? 'categoryCreatedSuccess';
}
  String get categoryUpdatedSuccess {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['categoryUpdatedSuccess'] ?? 'categoryUpdatedSuccess';
}
  String get categoryImageUploadError {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['categoryImageUploadError'] ?? 'categoryImageUploadError';
}

  // Clients
  String get clientsSearchHint {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['clientsSearchHint'] ?? 'clientsSearchHint';
}
  String get filterAllClients {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['filterAllClients'] ?? 'filterAllClients';
}
  String get filterPositiveCredit {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['filterPositiveCredit'] ?? 'filterPositiveCredit';
}
  String get filterNegativeCredit {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['filterNegativeCredit'] ?? 'filterNegativeCredit';
}
  String get filterActiveClients {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['filterActiveClients'] ?? 'filterActiveClients';
}
  String get sortByName {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['sortByName'] ?? 'sortByName';
}
  String get sortByCredit {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['sortByCredit'] ?? 'sortByCredit';
}
  String get sortByLastPurchase {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['sortByLastPurchase'] ?? 'sortByLastPurchase';
}
  String get clientsTotalLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['clientsTotalLabel'] ?? 'clientsTotalLabel';
}
  String get clientsPositiveCreditShort {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['clientsPositiveCreditShort'] ?? 'clientsPositiveCreditShort';
}
  String get clientsNegativeCreditShort {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['clientsNegativeCreditShort'] ?? 'clientsNegativeCreditShort';
}
  String get totalCreditLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['totalCreditLabel'] ?? 'totalCreditLabel';
}
  String get clientsEmptyTitle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['clientsEmptyTitle'] ?? 'clientsEmptyTitle';
}
  String get clientsEmptySubtitle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['clientsEmptySubtitle'] ?? 'clientsEmptySubtitle';
}
  
  // Suppliers
  String get supplierNameLabel => _localizedValues[locale.languageCode]!['supplierNameLabel'] ?? 'Nom du fournisseur';
  String get supplierNameRequired => _localizedValues[locale.languageCode]!['supplierNameRequired'] ?? 'Le nom du fournisseur est requis';
  String get supplierExistsMessage => _localizedValues[locale.languageCode]!['supplierExistsMessage'] ?? 'Un fournisseur avec ce nom ou ce numéro de téléphone existe déjà.';
  // Removed duplicate getter addClient (defined earlier)
  String get editClient {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['editClient'] ?? 'editClient';
}
  String get addClientTitle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['addClientTitle'] ?? 'addClientTitle';
}
  String get clientPreview {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['clientPreview'] ?? 'clientPreview';
}
  String get creditLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['creditLabel'] ?? 'creditLabel';
}
  String get totalPurchasesLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['totalPurchasesLabel'] ?? 'totalPurchasesLabel';
}
  String get personalInfo {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['personalInfo'] ?? 'personalInfo';
}
  String get clientNameLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['clientNameLabel'] ?? 'clientNameLabel';
}
  String get clientNameHint {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['clientNameHint'] ?? 'clientNameHint';
}
  String get clientNameRequired {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['clientNameRequired'] ?? 'clientNameRequired';
}
  // Removed duplicate getter contactInfo (defined earlier)
  String get phoneLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['phoneLabel'] ?? 'phoneLabel';
}
  String get phoneHint {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['phoneHint'] ?? 'phoneHint';
}
  String get emailLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['emailLabel'] ?? 'emailLabel';
}
  String get emailHint {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['emailHint'] ?? 'emailHint';
}
  String get invalidEmail {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['invalidEmail'] ?? 'invalidEmail';
}
  String get addressLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['addressLabel'] ?? 'addressLabel';
}
  String get addressHint {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['addressHint'] ?? 'addressHint';
}
  String get cityLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['cityLabel'] ?? 'cityLabel';
}
  String get cityHint {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['cityHint'] ?? 'cityHint';
}
  String get creditAndLimits {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['creditAndLimits'] ?? 'creditAndLimits';
}
  String get creditLimitLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['creditLimitLabel'] ?? 'creditLimitLabel';
}
  String get creditLimitHint {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['creditLimitHint'] ?? 'creditLimitHint';
}
  String get creditLimitHelper {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['creditLimitHelper'] ?? 'creditLimitHelper';
}
  String get creditLimitRequired {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['creditLimitRequired'] ?? 'creditLimitRequired';
}
  // Removed duplicate getter invalidAmount (defined earlier)
  String get currentCreditLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['currentCreditLabel'] ?? 'currentCreditLabel';
}
  String get notesOptions {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['notesOptions'] ?? 'notesOptions';
}
  String get notesLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['notesLabel'] ?? 'notesLabel';
}
  String get notesHint {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['notesHint'] ?? 'notesHint';
}
  String get clientActive {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['clientActive'] ?? 'clientActive';
}
  String get clientActiveHelper {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['clientActiveHelper'] ?? 'clientActiveHelper';
}
  String get clientCreatedSuccess {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['clientCreatedSuccess'] ?? 'clientCreatedSuccess';
}
  String get clientUpdatedSuccess {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['clientUpdatedSuccess'] ?? 'clientUpdatedSuccess';
}
  String get clientExistsMessage => _localizedValues[locale.languageCode]!['clientExistsMessage'] ?? 'Un client avec ce nom ou ce numéro de téléphone existe déjà.';

  // Crédits
  String get clientsWithCreditsTitle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['clientsWithCreditsTitle'] ?? 'clientsWithCreditsTitle';
}
  String get loadingCredits {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['loadingCredits'] ?? 'loadingCredits';
}
  String get creditsSummary {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['creditsSummary'] ?? 'creditsSummary';
}
  String get clientsLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['clientsLabel'] ?? 'clientsLabel';
}
  String get creditsLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['creditsLabel'] ?? 'creditsLabel';
}
  // Removed duplicate getter totalAmount (defined earlier)
  String get noCreditsTitle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['noCreditsTitle'] ?? 'noCreditsTitle';
}
  String get noCreditsSubtitle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['noCreditsSubtitle'] ?? 'noCreditsSubtitle';
}
  String get overdueLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['overdueLabel'] ?? 'overdueLabel';
}
  String get creditsCountLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['creditsCountLabel'] ?? 'creditsCountLabel';
}
  String get totalAmountLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['totalAmountLabel'] ?? 'totalAmountLabel';
}

  // Factures
  String get invoicesSearchHint {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['invoicesSearchHint'] ?? 'invoicesSearchHint';
}
  String get filterAllInvoices {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['filterAllInvoices'] ?? 'filterAllInvoices';
}
  String get filterDraft {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['filterDraft'] ?? 'filterDraft';
}
  String get filterSent {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['filterSent'] ?? 'filterSent';
}
  String get filterPaid {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['filterPaid'] ?? 'filterPaid';
}
  String get filterOverdue {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['filterOverdue'] ?? 'filterOverdue';
}
  String get sortByDate {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['sortByDate'] ?? 'sortByDate';
}
  String get sortByAmount {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['sortByAmount'] ?? 'sortByAmount';
}
  String get sortByClient {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['sortByClient'] ?? 'sortByClient';
}
  String get sortByStatus {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['sortByStatus'] ?? 'sortByStatus';
}
  String get pending {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['pending'] ?? 'pending';
}
  // Removed duplicate getter paid (defined earlier)
  String get newInvoice {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['newInvoice'] ?? 'newInvoice';
}
  String get invoicesEmptyTitle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['invoicesEmptyTitle'] ?? 'invoicesEmptyTitle';
}
  String get invoicesEmptySubtitle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['invoicesEmptySubtitle'] ?? 'invoicesEmptySubtitle';
}
  // Removed duplicate getter createInvoice (defined earlier)

  // ==== Product Transactions Report (sold and purchased products) ====
  /// Title of the transactions report screen
  String get productTransactionReport {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['productTransactionReport'] ?? 'productTransactionReport';
}

  /// Prompt shown when the user tries to generate a report without selecting dates
  String get selectDateRangeFirst {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['selectDateRangeFirst'] ?? 'selectDateRangeFirst';
}

  /// Error message shown when an error occurs while loading the report
  String get errorLoadingReport {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['errorLoadingReport'] ?? 'errorLoadingReport';
}

  /// Message displayed when there is no data to export
  String get noDataToExport {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['noDataToExport'] ?? 'noDataToExport';
}

  /// Label for the transaction type column in the report
  String get transactionType {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['transactionType'] ?? 'transactionType';
}

  /// Label for selecting all categories in filters
  String get allCategories {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['allCategories'] ?? 'allCategories';
}

  /// Label for the minimum quantity filter field
  String get minimumQuantity {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['minimumQuantity'] ?? 'minimumQuantity';
}

  /// Label for the button to view the report
  String get viewReport {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['viewReport'] ?? 'viewReport';
}

  /// Label for the button to export the report to Excel
  String get exportToExcel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['exportToExcel'] ?? 'exportToExcel';
}

  /// Message displayed when no data is found for the given filters
  String get noDataFound {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['noDataFound'] ?? 'noDataFound';
}

  /// Message shown when an export operation fails
  String get exportFailed {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['exportFailed'] ?? 'exportFailed';
}

  /// Label for the start date in date range pickers
  String get startDate {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['startDate'] ?? 'startDate';
}

  /// Label for the end date in date range pickers
  String get endDate {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['endDate'] ?? 'endDate';
}

  // Fournisseurs (Suppliers)
  /// Hint text for searching suppliers
  String get suppliersSearchHint {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['suppliersSearchHint'] ?? 'suppliersSearchHint';
}
  /// Label for total suppliers in quick stats
  String get suppliersTotalLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['suppliersTotalLabel'] ?? 'suppliersTotalLabel';
}
  /// Label for active suppliers in quick stats
  String get suppliersActiveLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['suppliersActiveLabel'] ?? 'suppliersActiveLabel';
}
  /// Label for total products supplied in quick stats
  String get suppliersProductsLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['suppliersProductsLabel'] ?? 'suppliersProductsLabel';
}
  /// Title shown when there are no suppliers
  String get suppliersEmptyTitle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['suppliersEmptyTitle'] ?? 'suppliersEmptyTitle';
}
  /// Subtitle shown when there are no suppliers
  String get suppliersEmptySubtitle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['suppliersEmptySubtitle'] ?? 'suppliersEmptySubtitle';
}
  /// Button label to add a new supplier
  // Removed duplicate getter addSupplier (defined earlier in actions/navigation section)
  // String get addSupplier {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['addSupplier'] ?? 'addSupplier';
}

  // ====== Daily Revenue and Stats ======
  /// Label for total sales in the daily revenue card
  String get totalSales {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['totalSales'] ?? 'totalSales';
}
  /// Label for collected revenue in the daily revenue card
  String get collected {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['collected'] ?? 'collected';
}
  /// Label for purchases in the daily revenue card
  String get purchases {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['purchases'] ?? 'purchases';
}
  /// Label for net profit in the daily revenue card
  String get netProfit {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['netProfit'] ?? 'netProfit';
}
  /// Label for singular invoice count (e.g. 1 invoice)
  String get invoiceCountSingle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['invoiceCountSingle'] ?? 'invoiceCountSingle';
}
  /// Label for plural invoice count (e.g. 2 invoices)
  String get invoiceCountPlural {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['invoiceCountPlural'] ?? 'invoiceCountPlural';
}
  /// Message shown when there is no data available
  String get noDataAvailable {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['noDataAvailable'] ?? 'noDataAvailable';
}

  // ====== Invoice Type Selection ======
  /// Title for choosing invoice type screen
  String get invoiceTypeChoiceTitle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['invoiceTypeChoiceTitle'] ?? 'invoiceTypeChoiceTitle';
}
  /// Subtitle describing selection of transaction type
  String get invoiceTypeChoiceSubtitle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['invoiceTypeChoiceSubtitle'] ?? 'invoiceTypeChoiceSubtitle';
}
  /// Title of sales invoice card
  String get salesInvoiceTitle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['salesInvoiceTitle'] ?? 'salesInvoiceTitle';
}
  /// Subtitle of sales invoice card
  String get salesInvoiceSubtitle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['salesInvoiceSubtitle'] ?? 'salesInvoiceSubtitle';
}
  /// Title of purchase voucher card
  String get purchaseVoucherTitle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['purchaseVoucherTitle'] ?? 'purchaseVoucherTitle';
}
  /// Subtitle of purchase voucher card
  String get purchaseVoucherSubtitle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['purchaseVoucherSubtitle'] ?? 'purchaseVoucherSubtitle';
}
  /// Label preceding the list of included features
  String get includedFeaturesLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['includedFeaturesLabel'] ?? 'includedFeaturesLabel';
}
  /// Feature: barcode scanner
  String get featureBarcodeScanner {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['featureBarcodeScanner'] ?? 'featureBarcodeScanner';
}
  /// Feature: client management
  String get featureClientManagement {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['featureClientManagement'] ?? 'featureClientManagement';
}
  /// Feature: change calculation
  String get featureCalculateChange {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['featureCalculateChange'] ?? 'featureCalculateChange';
}
  /// Feature: credit management
  String get featureCreditManagement {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['featureCreditManagement'] ?? 'featureCreditManagement';
}
  /// Feature: automatic stock update
  String get featureAutoStockUpdate {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['featureAutoStockUpdate'] ?? 'featureAutoStockUpdate';
}
  /// Feature: supplier management
  String get featureSupplierManagement {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['featureSupplierManagement'] ?? 'featureSupplierManagement';
}
  /// Feature: automatic addition to stock
  String get featureAutoAddToStock {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['featureAutoAddToStock'] ?? 'featureAutoAddToStock';
}
  /// Feature: cost tracking
  String get featureCostTracking {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['featureCostTracking'] ?? 'featureCostTracking';
}

  // ====== Add/Edit Supplier ======
  /// Page title when adding a supplier
  String get addSupplierTitle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['addSupplierTitle'] ?? 'addSupplierTitle';
}
  /// Page title when editing a supplier
  String get editSupplierTitle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['editSupplierTitle'] ?? 'editSupplierTitle';
}
  /// Label for supplier company name
  String get supplierCompanyNameLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['supplierCompanyNameLabel'] ?? 'supplierCompanyNameLabel';
}
  /// Hint for supplier company name
  String get supplierCompanyNameHint {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['supplierCompanyNameHint'] ?? 'supplierCompanyNameHint';
}
  /// Validation message when company name is required
  String get supplierCompanyNameRequired {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['supplierCompanyNameRequired'] ?? 'supplierCompanyNameRequired';
}
  /// Label for contact person
  String get supplierContactPersonLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['supplierContactPersonLabel'] ?? 'supplierContactPersonLabel';
}
  /// Hint for contact person
  String get supplierContactPersonHint {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['supplierContactPersonHint'] ?? 'supplierContactPersonHint';
}
  /// Section title for contact information
  String get supplierContactInfo {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['supplierContactInfo'] ?? 'supplierContactInfo';
}
  /// Label for supplier phone
  String get supplierPhoneLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['supplierPhoneLabel'] ?? 'supplierPhoneLabel';
}
  /// Hint for supplier phone
  String get supplierPhoneHint {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['supplierPhoneHint'] ?? 'supplierPhoneHint';
}
  /// Label for supplier email
  String get supplierEmailLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['supplierEmailLabel'] ?? 'supplierEmailLabel';
}
  /// Hint for supplier email
  String get supplierEmailHint {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['supplierEmailHint'] ?? 'supplierEmailHint';
}
  /// Label for supplier address
  String get supplierAddressLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['supplierAddressLabel'] ?? 'supplierAddressLabel';
}
  /// Hint for supplier address
  String get supplierAddressHint {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['supplierAddressHint'] ?? 'supplierAddressHint';
}
  /// Label for supplier city
  String get supplierCityLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['supplierCityLabel'] ?? 'supplierCityLabel';
}
  /// Hint for supplier city
  String get supplierCityHint {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['supplierCityHint'] ?? 'supplierCityHint';
}
  /// Section title for notes and options
  String get supplierNotesOptions {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['supplierNotesOptions'] ?? 'supplierNotesOptions';
}
  /// Label for notes
  String get supplierNotesLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['supplierNotesLabel'] ?? 'supplierNotesLabel';
}
  /// Hint for notes text
  String get supplierNotesHint {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['supplierNotesHint'] ?? 'supplierNotesHint';
}
  /// Label for supplier active toggle
  String get supplierActiveLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['supplierActiveLabel'] ?? 'supplierActiveLabel';
}
  /// Helper text explaining supplier active toggle
  String get supplierActiveHelper {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['supplierActiveHelper'] ?? 'supplierActiveHelper';
}
  /// Success message when supplier is created
  String get supplierCreatedSuccess {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['supplierCreatedSuccess'] ?? 'supplierCreatedSuccess';
}
  /// Success message when supplier is updated
  String get supplierUpdatedSuccess {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['supplierUpdatedSuccess'] ?? 'supplierUpdatedSuccess';
}
  /// Error message shown when saving supplier fails
  String get supplierSaveError {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['supplierSaveError'] ?? 'supplierSaveError';
}

    String get invoiceCustomizationTitle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['invoiceCustomizationTitle'] ?? 'invoiceCustomizationTitle';
}
  String get chooseLogo {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['chooseLogo'] ?? 'chooseLogo';
}
  String get companyNameLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['companyNameLabel'] ?? 'companyNameLabel';
}
  String get primaryColorLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['primaryColorLabel'] ?? 'primaryColorLabel';
}
  String get secondaryColorLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['secondaryColorLabel'] ?? 'secondaryColorLabel';
}
  String get fontSizeLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['fontSizeLabel'] ?? 'fontSizeLabel';
}
  String get showLogo {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['showLogo'] ?? 'showLogo';
}
  String get showCompanyInfo {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['showCompanyInfo'] ?? 'showCompanyInfo';
}
  String get showHeader {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['showHeader'] ?? 'showHeader';
}
  String get showFooter {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['showFooter'] ?? 'showFooter';
}
  String get headerTextLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['headerTextLabel'] ?? 'headerTextLabel';
}
  String get headerTextHint {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['headerTextHint'] ?? 'headerTextHint';
}
  String get footerTextLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['footerTextLabel'] ?? 'footerTextLabel';
}
  String get footerTextHint {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['footerTextHint'] ?? 'footerTextHint';
}
  String get reset {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['reset'] ?? 'reset';
}
  String get invoiceCustomizationSaved {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['invoiceCustomizationSaved'] ?? 'invoiceCustomizationSaved';
}
  String get invoiceCustomizationReset {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['invoiceCustomizationReset'] ?? 'invoiceCustomizationReset';
}
  String get pleaseCheckInput {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['pleaseCheckInput'] ?? 'pleaseCheckInput';
}
  String get logoPickError {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['logoPickError'] ?? 'logoPickError';
}
  String get companyInfoSectionTitle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['companyInfoSectionTitle'] ?? 'companyInfoSectionTitle';
}
  String get headerFooterSectionTitle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['headerFooterSectionTitle'] ?? 'headerFooterSectionTitle';
}
  String get chooseLogoShort {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['chooseLogoShort'] ?? 'chooseLogoShort';
}
  String get showCustomHeader {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['showCustomHeader'] ?? 'showCustomHeader';
}
  String get websiteLabel {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['websiteLabel'] ?? 'websiteLabel';
}
  String get showCustomFooter {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['showCustomFooter'] ?? 'showCustomFooter';
}
  String get appearanceSectionTitle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['appearanceSectionTitle'] ?? 'appearanceSectionTitle';
}
  String get pdfPreview {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['pdfPreview'] ?? 'pdfPreview';
}
  String get displayOptionsSectionTitle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['displayOptionsSectionTitle'] ?? 'displayOptionsSectionTitle';
}
  String get logoAndCompanyInfoTitle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['logoAndCompanyInfoTitle'] ?? 'logoAndCompanyInfoTitle';
}
  String get colorsAndStyleTitle {
  final map = _localizedValues[locale.languageCode] ?? _localizedValues['en'];
  return map?['colorsAndStyleTitle'] ?? 'colorsAndStyleTitle';
}
static const Map<String, Map<String, String>> _localizedValues = {
    'fr': {
      // Navigation
      'dashboard': 'Tableau de bord',
      'products': 'Produits',
      'invoices': 'Factures',
      'clients': 'Clients',
      'suppliers': 'Fournisseurs',
      'settings': 'Paramètres',
      'more': 'Plus',

      // Dashboard
      'todayRevenue': 'Revenus du jour',
      // Daily revenue and stats labels
      'totalSales': 'Ventes totales',
      'collected': 'Encaissé',
      'purchases': 'Achats',
      'invoiceCountSingle': 'facture',
      'invoiceCountPlural': 'factures',
      'totalProducts': 'Total produits',
      'totalClients': 'Total clients',
      'lowStock': 'Stock faible',
      'recentActivities': 'Activités récentes',
      'viewAll': 'Voir tout',
      'noRecentActivity': 'Aucune activité récente',
      'weeklyRevenue': 'Revenus hebdomadaires',
      'salesByProduct': 'Ventes par produit',
      'stockByCategory': 'Stock par catégorie',

      // Common
      'add': 'Ajouter',
      'edit': 'Modifier',
      'delete': 'Supprimer',
      'save': 'Enregistrer',
      'cancel': 'Annuler',
      'confirm': 'Confirmer',
      'search': 'Rechercher',
      'filter': 'Filtrer',
      'name': 'Nom',
      'description': 'Description',
      'price': 'Prix',
      'quantity': 'Quantité',
      'total': 'Total',
      'date': 'Date',
      'status': 'Statut',

      // Products
      'addProduct': 'Ajouter un produit',
      'editProduct': 'Modifier le produit',
      'productName': 'Nom du produit',
      'productDescription': 'Description du produit',
      'salePrice': 'Prix de vente',
      'purchasePrice': 'Prix d\'achat',
      'stock': 'Stock',
      'category': 'Catégorie',
      'barcode': 'Code-barres',
      'unit': 'Unité',
      'threshold': 'Seuil d\'alerte',

      // ===== Rapport des transactions produits =====
      'productTransactionReport': 'Rapport des transactions produits',
      'selectDateRangeFirst': 'Veuillez sélectionner une période',
      'errorLoadingReport': 'Erreur lors du chargement du rapport',
      'noDataToExport': 'Aucune donnée à exporter',
      'transactionType': 'Type',
      'allCategories': 'Toutes les catégories',
      'minimumQuantity': 'Quantité minimale',
      'viewReport': 'Afficher',
      'exportToExcel': 'Exporter en Excel',
      'noDataFound': 'Aucune donnée trouvée',
      'exportFailed': 'Échec de l\'exportation',

      // Étiquettes pour la plage de dates
      'startDate': 'Date de début',
      'endDate': 'Date de fin',

      // Product Form Fields
      'basicInfo': 'Informations de base',
      'priceStock': 'Prix et stock',
      'advancedOptions': 'Options avancées',
      'productNameRequired': 'Le nom est obligatoire',
      'productNameHint': 'Ex: iPhone 15 Pro',
      'descriptionHint': 'Description détaillée du produit',
      'noCategory': 'Aucune catégorie',
      'barcodeHint': '1234567890123',
      'sku': 'SKU',
      'skuHint': 'PROD-001',
      'scanBarcodeTooltip': 'Scanner code-barres',
      'generateBarcodeTooltip': 'Pas de code-barres ? Générer',
      'printBarcodeTooltip': 'Imprimer le code-barres',
      'purchasePriceRequired': 'Prix d\'achat obligatoire',
      'purchasePriceHint': '0.00',
      'salePriceRequired': 'Prix de vente obligatoire',
      'salePriceHint': '0.00',
      'invalidPrice': 'Prix invalide',
      'stockQuantityRequired': 'Quantité obligatoire',
      'stockQuantityHint': '0',
      'invalidQuantity': 'Quantité invalide',
      'stockAlertThreshold': 'Seuil d\'alerte stock *',
      'stockAlertThresholdHint': '10',
      'stockAlertThresholdHelper': 'Alerte quand le stock descend en dessous de cette valeur',
      'thresholdRequired': 'Seuil obligatoire',
      'invalidThreshold': 'Seuil invalide',
      'activeProduct': 'Produit actif',
      'activeProductDescription': 'Le produit est visible et disponible à la vente',
      'productImage': 'Image du produit',
      'chooseImage': 'Choisir une image',
      'takePhoto': 'Prendre une photo',
      'removeImage': 'Supprimer l\'image',
      'noImageSelected': 'Aucune image sélectionnée',
      'profitPerUnit': 'Profit par unité',
      'productDetails': 'Détails',
      'productStatus': 'Statut',
      'active': 'Actif',
      'inactive': 'Inactif',
      'createdOn': 'Créé le',
      'modifiedOn': 'Modifié le',
      'noDescription': 'Aucune description',
      'notDefined': 'Non défini',

      // Messages de succès et d'erreur
      'productCreatedSuccess': 'Produit créé avec succès',
      'productUpdatedSuccess': 'Produit modifié avec succès',
      'saveError': 'Erreur lors de la sauvegarde',
      'saveErrorMessage': 'Erreur lors de la sauvegarde: {error}',

      // Actions rapides et autres
      'quickActions': 'Actions rapides',
      'quickActionsSubtitle': 'Accès rapide aux fonctions principales',
      'adjustStock': 'Ajuster stock',
      'stockAdjustment': 'Ajuster le stock',
      'addStock': 'Ajouter',
      'removeStock': 'Retirer',
      'setStock': 'Définir',
      'newQuantity': 'Nouvelle quantité',
      'reason': 'Raison',
      'reasonHint': 'Raison de l\'ajustement (optionnel)',
      'userNotConnected': 'Erreur: Utilisateur non connecté',
      'existingProductDialog': 'Produit existant',
      'existingProductMessage': 'Un produit avec ce code-barres existe déjà. Voulez-vous le modifier ?',

      // Import et messages
      'productsFoundInExcel': '{count} produits trouvés dans le fichier Excel',
      'noProductsFoundInExcel': 'Aucun produit trouvé dans le fichier Excel',
      'errorReadingFile': 'Erreur lors de la lecture du fichier: {error}',
      'selectCategory': 'Sélectionner une catégorie',
      'supportedFileFormats': 'Formats de fichiers supportés',
      'acceptedFormats': '📁 Formats acceptés:',
      'requiredColumns': '📋 Colonnes requises:',
      'optionalColumns': '📋 Colonnes optionnelles:',
      'productNameRequiredForImport': '• nom - Nom du produit (obligatoire)',
      'barcodeColumn': '• code barre - Code-barres',
      'imageColumn': '• image - URL de l\'image',
      'descriptionColumn': '• description - Description',
      'purchasePriceColumn': '• prix_achat - Prix d\'achat',
      'salePriceColumn': '• prix_vente - Prix de vente',
      'stockColumn': '• stock - Quantité en stock',
      'unitColumn': '• unite - Unité de mesure',

      // Settings
      'theme': 'Thème',
      'language': 'Langue',
      'scanSound': 'Son de scan',
      'companySettings': 'Paramètres d\'entreprise',
      'companyName': 'Nom de l\'entreprise',
      'companyLogo': 'Logo de l\'entreprise',
      'administration': 'Administration',
      'globalProducts': 'Produits globaux',
      'userManagement': 'Gestion des utilisateurs',

      // Themes
      'lightTheme': 'Clair',
      'darkTheme': 'Sombre',
      'systemTheme': 'Système',

      // Sounds
      'classicBeep': 'Bip classique',
      'success': 'Succès',
      'notification': 'Notification',
      'cashRegister': 'Caisse enregistreuse',
      'noSound': 'Aucun son',

      // Messages
      'chooseLanguage': 'Choisir une langue',
      'chooseTheme': 'Choisir un thème',
      'chooseScanSound': 'Choisir un son de scan',
      'testSound': 'Tester le son',

      // Navigation supplémentaire
      'categories': 'Catégories',
      'home': 'Accueil',
      'reports': 'Rapports',
      'pos': 'Point de vente',

      // Dépenses
      'expenses': 'Dépenses',
      'addExpense': 'Ajouter une dépense',
      'expenseType': 'Type de dépense',
      'amount': 'Montant',
      'rent': 'Loyer',
      'electricity': 'Électricité',
      'wifi': 'Internet/WiFi',
      'other': 'Autre',
      'monthlyExpenses': 'Dépenses mensuelles',
      'netProfit': 'Bénéfice net',

      // Import/Export
      'importProducts': 'Importer des produits',
      'exportData': 'Exporter les données',
      'selectFile': 'Sélectionner un fichier',
      'importFromExcel': 'Importer depuis Excel',

      // Recherche avancée
      'searchByName': 'Rechercher par nom',
      'searchByBarcode': 'Rechercher par code-barres',
      'searchByCategory': 'Rechercher par catégorie',
      'advancedSearch': 'Recherche avancée',
      'noResults': 'Aucun résultat trouvé',
      'scanBarcode': 'Scanner le code-barres',
      'searchProducts': 'Rechercher des produits',

      // Messages d'interface
      'welcome': 'Bienvenue',
      'loading': 'Chargement...',
      'error': 'Erreur',
      'successMessage': 'Succès',
      'retry': 'Réessayer',
      'close': 'Fermer',
      'back': 'Retour',
      'next': 'Suivant',
      'previous': 'Précédent',
      'finish': 'Terminer',

      // Formulaires
      'required': 'Obligatoire',
      'optional': 'Optionnel',
      'pleaseEnter': 'Veuillez saisir',
      'invalidFormat': 'Format invalide',

      // Actions
      'create': 'Créer',
      'update': 'Mettre à jour',
      'remove': 'Supprimer',
      'duplicate': 'Dupliquer',
      'share': 'Partager',
      'print': 'Imprimer',

      // Factures
      // Doublons supprimés : voir bloc "Détails Facture" plus bas pour la version complète et cohérente des clés liées à la facture.

      // Support
      'support': 'Support',
      'contactUs': 'Contactez-nous',
      'sendMessage': 'Envoyer un message',
      'yourEmail': 'Votre email',
      'subject': 'Sujet',
      'message': 'Message',
      'contactInfo': 'Informations de contact',
      'phone': 'Téléphone',
      'whatsapp': 'WhatsApp',
      'availability': 'Disponibilité',
      'responseTime': 'Temps de réponse',
      'supportedLanguages': 'Langues supportées',
      'email': 'Email',

      // Paramètres
      'appSettings': 'Paramètres de l\'application',
      'businessSettings': 'Paramètres de l\'entreprise',
      'notifications': 'Notifications',
      'pushNotifications': 'Notifications push',
      'dataBackup': 'Sauvegarde des données',
      'aboutSupport': 'À propos du support',
      'logout': 'Déconnexion',
      'version': 'Version',
      'termsOfService': 'Conditions d\'utilisation',
      'advancedSettings': 'Paramètres avancés',
      'dataManagement': 'Gestion des données et réinitialisation',

      // Écrans et contenus
      'noDataAvailable': 'Aucune donnée disponible',
      'refreshData': 'Actualiser les données',
      'viewDetails': 'Voir les détails',
      'editItem': 'Modifier l\'élément',
      'deleteItem': 'Supprimer l\'élément',
      'confirmDelete': 'Confirmer la suppression',
      'deleteConfirmation': 'Êtes-vous sûr de vouloir supprimer cet élément ?',
      'yes': 'Oui',
      'no': 'Non',

      // Actions rapides et navigation
      'sale': 'Vente',
      'purchase': 'Achat',
      'createInvoice': 'Créer une facture',
      'manageStock': 'Gérer les stocks',
      'viewAllClients': 'Voir tous les clients',
      'viewAllSuppliers': 'Voir tous les fournisseurs',
      'addSupplier': 'Ajouter un fournisseur',
      'addCategory': 'Ajouter une catégorie',

      // Formulaires et champs
      'profile': 'Profil',
      'fullName': 'Nom complet',
      'businessName': 'Nom de l\'entreprise',
      'phoneNumber': 'Numéro de téléphone',
      'address': 'Adresse',
      'subscriptionStatus': 'Statut de l\'abonnement',
      'subscriptionType': 'Type d\'abonnement',
      'subscriptionStartDate': 'Date de début d\'abonnement',
      'subscriptionEndDate': 'Date de fin d\'abonnement',
      'lastPaymentDate': 'Date du dernier paiement',
      'lastLoginDate': 'Date de dernière connexion',
      'activeSubscription': 'Abonnement actif',
      'expiredSubscription': 'Abonnement expiré',
      'noActiveSubscription': 'Aucun abonnement actif',
      'subscriptionRemainingDays': 'Il vous reste {days} jours d\'abonnement',
      'subscriptionRemainingHours': 'Il vous reste {hours} heures d\'abonnement',
      'subscriptionRemainingTime': 'Il vous reste {days} jours et {hours} heures d\'abonnement',
      'subscriptionExpired': 'Abonnement expiré',
      'refreshSubscription': 'Actualiser l\'abonnement',
      'subscriptionUpdated': 'Statut d\'abonnement actualisé !',

      // Messages et notifications
      'noSalesDataAvailable': 'Aucune donnée de vente disponible',
      'noNotifications': 'Aucune notification',
      'ok': 'OK',
      'warning': 'Attention',
      'info': 'Information',

      // Scanner et codes-barres
      'manualBarcodeEntry': 'Saisie manuelle du code-barres',
      'manualBarcodeEntryDescription': 'Saisissez le code-barres manuellement ci-dessous',
      'scanError': 'Erreur lors du scan',
      'barcodeScanner': 'Scanner le code-barres',
      'multipleLabelsPerPage': 'Plusieurs étiquettes par page',
      'numberOfLabels': 'Nombre d\'étiquettes: ',

      // Images et sélection
      'chooseFromGallery': 'Choisir depuis la galerie',
      'permissionRequired': 'Permission requise',
      'imageSelectionError': 'Erreur lors de la sélection de l\'image',
      'imageSelectionNotImplemented': 'Sélection d\'image à implémenter',

      // Clients et fournisseurs
      'anonymousClient': 'Client anonyme',
      'anonymousSupplier': 'Fournisseur anonyme',
      'activeSupplier': 'Fournisseur actif',
      'activeSupplierDescription': 'Le fournisseur peut recevoir des commandes',
      'supplierDetails': 'Détails du fournisseur',
      'clientDetails': 'Détails du client',

      // Factures et POS
      'tax': 'TVA:',
      'modifyQuantity': 'Modifier la quantité',
      'modifyPrice': 'Modifier le prix',
      'product': 'Produit:',
      'currentPrice': 'Prix actuel:',
      'newUnitPrice': 'Nouveau prix unitaire (DH)',
      'modify': 'Modifier',
      'clearCart': 'Vider le panier',
      'clearCartConfirmation': 'Êtes-vous sûr de vouloir vider le panier ?',
      'clear': 'Vider',
      'newTransaction': 'Nouvelle transaction',
      'finalizePurchase': 'Finaliser l\'achat',

      // POS / Point de vente
      'posSaleTitle': 'Point de vente',
      'posPurchaseTitle': 'Bon d\'achat',
      'barcodeEntryHint': 'Scanner ou saisir le code-barres',
      'quantityShort': 'Qté',
      'closeScannerTooltip': 'Fermer scanner',
      'scannerTooltip': 'Scanner',
      'clientOptionalLabel': 'Client (optionnel)',
      'supplierLabel': 'Fournisseur',
      'selectSupplierError': 'Veuillez sélectionner un fournisseur ou choisir anonyme',
      'emptyCartTitle': 'Panier vide',
      'emptyCartSubtitle': 'Scannez ou saisissez un code-barres pour ajouter des produits',
      'unitPriceLabel': 'Prix unitaire',
      'quantityLabel': 'Quantité',
      'amountPaid': 'Montant payé',
      'changeLabelPositive': 'Monnaie',
      'changeLabelNegative': 'Manque',
      'finalizeSale': 'Finaliser vente',
      'saleSuccess': 'Vente réussie',
      'purchaseSuccess': 'Achat enregistré',
      'invoiceTotalLabel': 'Total',
      'invoicePaidLabel': 'Payé',
      'invoiceChangeToReturnLabel': 'Monnaie à rendre',
      'creditAddedLabel': 'Crédit ajouté',
      'invoiceCreationError': 'Erreur lors de la création de la facture',
      'partialPaymentError': 'Veuillez sélectionner un client pour un paiement partiel',
      'creditLimitExceeded': 'Limite de crédit dépassée pour ce client',
      'genericErrorPrefix': 'Erreur',
      'errorLoadingSuppliers': 'Erreur lors du chargement des fournisseurs',
      'productNotFound': 'Produit non trouvé',
      'totalAmountLabel': 'Montant total',
      'invoiceImageOptional': 'Image de la facture d\'achat (optionnel)',

      // Catégories
      'deleteCategory': 'Supprimer',
      'confirmDeleteCategory': 'Confirmer la suppression',
      'deleteCategoryConfirmation': 'Êtes-vous sûr de vouloir supprimer la catégorie "{name}" ?',
      'categoryDeletedSuccess': 'Catégorie "{name}" supprimée avec succès',
      'categoryDeleteError': 'Erreur lors de la suppression de la catégorie',

      // Crédits
      'makePayment': 'Effectuer le paiement',
      'pleaseEnterAmount': 'Veuillez saisir un montant',
      'invalidAmount': 'Montant invalide',
      'amountExceedsRemaining': 'Le montant ne peut pas dépasser le montant restant',
      'paymentError': 'Erreur lors du paiement',
      'loadHistoryError': 'Erreur chargement historique',

      // Recherche
      'noResultsFound': 'Aucun résultat trouvé',

      // Paramètres avancés
      'advancedSettingsTitle': 'Paramètres Avancés',
      'completeReset': 'Réinitialisation Complète',
      'businessDataReset': 'Suppression Données Business',
      'completeResetDescription': 'Cette action va supprimer TOUTES vos données :\n• Produits\n• Factures\n• Clients\n• Paramètres\n• Images\n\nVous redeviendrez comme un utilisateur nouveau.',
      'businessDataResetDescription': 'Cette action va supprimer vos données business :\n• Produits\n• Factures\n• Clients\n• Fournisseurs\n\nVos paramètres seront conservés.',
      'typeToConfirm': 'Pour confirmer, tapez exactement :',
      'typeHere': 'Tapez ici...',

      // Gestion des appareils
      'authorize': 'Autoriser',
      'revoke': 'Révoquer',
      'removeDevice': 'Supprimer',

      // Sauvegarde Google Drive
      'googleDriveBackup': 'Sauvegarde Google Drive',
      'connectToGoogleDrive': 'Se connecter à Google Drive',
      'disconnect': 'Déconnexion',
      'backup': 'Sauvegarder',
      'refresh': 'Actualiser',
      'size': 'Taille: {size}',
      'restore': 'Restaurer',
      'confirmRestore': 'Confirmer la restauration',

      // Paramètres de l'entreprise
      'chooseCurrency': 'Choisir la devise',
      'moroccanDirham': 'Dirham marocain (DH)',
      'euro': 'Euro (€)',
      'usDollar': 'Dollar américain (\$)',
      'clearAllData': 'Effacer toutes les données',
      'logoutConfirmation': 'Se déconnecter',
      'logoutConfirmationMessage': 'Êtes-vous sûr de vouloir vous déconnecter ?',
      'exitConfirmationMessage': 'Êtes-vous sûr de vouloir quitter l\'application ?',
      'chooseSound': 'Choisir un son',

      // Support
      'needHelp': 'Besoin d\'aide ?',
      'ourTeamIsHere': 'Notre équipe est là pour vous aider',
      'otherContactMethods': 'Autres moyens de contact',
      'availabilityHours': 'Heures de disponibilité',
      'supportedLanguagesList': 'Français, Anglais, Arabe',
      'responseTimeHours': '24-48 heures',
      'emailAppOpened': 'Application email ouverte avec succès',
      'cannotOpenEmailApp': 'Impossible d\'ouvrir l\'application email',
      'cannotOpenPhoneApp': 'Impossible d\'ouvrir l\'application téléphone',
      'cannotOpenWhatsApp': 'Impossible d\'ouvrir WhatsApp',
      'messageMinLength': 'Le message doit contenir au moins 10 caractères',
      'describeYourProblem': 'Décrivez votre problème ou question...',
      'subjectOfMessage': 'Sujet de votre message',
      'sending': 'Envoi...',
      'sendMessageButton': 'Envoyer le message',

      // Autorisation d'appareil
      'deviceAuthorization': 'Autorisation d\'appareil',
      'deviceInfo': 'Informations',
      'deviceRegisteredAutomatically': '• Votre appareil a été enregistré automatiquement',
      'adminMustAuthorize': '• Un administrateur doit l\'autoriser manuellement',
      'youWillReceiveNotification': '• Vous recevrez une notification une fois autorisé',
      'cannotAccessApp': '• En attendant, vous ne pouvez pas accéder à l\'application',

      // Champs manquants pour les produits
      'rupture': 'Rupture',
      'stockFaible': 'Stock faible',
      'tous': 'Tous',
      'marge': 'Marge',
      'valeur': 'Valeur',
      'piece': 'pièce',
      'modifier': 'Modifier',
      'ruptureDeStock': 'Rupture de stock',
      'stockSuffisant': 'Stock suffisant',
      'stockActuel': 'Stock actuel',
      'valeurStock': 'Valeur stock',
      'produitsNecessitantAttention': 'Produits nécessitant une attention',
      'gererLesStocks': 'Gérer les stocks',
      'voirAutresProduits': 'Voir {count} autres produits',
      'stockOptimalPourTousLesProduits': 'Stock optimal pour tous les produits',
      'produitsEnStockFaible': 'produits en stock faible',
      'faible': 'Faible',
      'okStatus': 'OK',
      'min': 'Min',
      'ruptureLabel': 'RUPTURE',
      'faibleLabel': 'FAIBLE',
      'chargement': 'Chargement...',
      'erreurDeChargement': 'Erreur de chargement',
      'gestionDesStocks': 'Gestion des stocks',
      'alertesDeStock': 'Alertes de stock',
      'produitsNecessitentAttention': 'produits nécessitent votre attention',
      'stockFaibleLabel': 'Stock faible',
      'produitsEnStockFaibleLabel': 'produits en stock faible',

      // Champs manquants pour le dashboard
      'bonjour': 'Bonjour',
      'bonApresMidi': 'Bon après-midi',
      'bonsoir': 'Bonsoir',
      'utilisateur': 'Utilisateur',
      'apercuActivite': 'Voici un aperçu de votre activité aujourd\'hui',
      'actionsRapides': 'Actions rapides',
      'facture': 'Facture',
      'scanner': 'Scanner',
      'nouvelleFacture': 'Nouvelle facture',
      'ajouterProduit': 'Ajouter produit',
      'nouveauClient': 'Nouveau client',
      'ajouterCategorie': 'Ajouter catégorie',
      'nouveauFournisseur': 'Nouveau fournisseur',
      'scannerProduit': 'Scanner produit',
      'pointDeVente': 'Point de Vente',
      'accesRapideVente': 'Accès rapide aux fonctions de vente et d\'achat',
      'vente': 'Vente',
      'achat': 'Achat',
      'aucuneNotification': 'Aucune notification',
      'fermer': 'Fermer',
      'revenusDuJour': 'Revenus du jour',
      'produits': 'Produits',
      // Stock alerts messages
      'needAttentionSingular': 'nécessite votre attention',
      'needAttentionPlural': 'nécessitent votre attention',
      'allProductsSufficientStock': 'Tous vos produits ont un stock suffisant',
      'seeOtherProducts': 'Voir {count} autres produits',

      // ====== Invoice type selection ======
      'invoiceTypeChoiceTitle': 'Choisissez le type de facture',
      'invoiceTypeChoiceSubtitle': 'Sélectionnez le type de transaction que vous souhaitez effectuer',
      'salesInvoiceTitle': 'Facture de Vente',
      'salesInvoiceSubtitle': 'Vendre des produits à un client',
      'purchaseVoucherTitle': 'Bon d\'Achat',
      'purchaseVoucherSubtitle': 'Enregistrer un achat de marchandises',
      'includedFeaturesLabel': 'Fonctionnalités incluses',
      'featureBarcodeScanner': 'Scanner de codes-barres',
      'featureClientManagement': 'Gestion des clients',
      'featureCalculateChange': 'Calcul de la monnaie',
      'featureCreditManagement': 'Gestion des crédits',
      'featureAutoStockUpdate': 'Mise à jour automatique du stock',
      'featureSupplierManagement': 'Gestion des fournisseurs',
      'featureAutoAddToStock': 'Ajout automatique au stock',
      'featureCostTracking': 'Suivi des coûts',

      // ====== Add/Edit Supplier ======
      'addSupplierTitle': 'Ajouter un fournisseur',
      'editSupplierTitle': 'Modifier le fournisseur',
      'supplierCompanyNameLabel': 'Nom de l\'entreprise',
      'supplierCompanyNameHint': 'ex: ABC SARL',
      'supplierCompanyNameRequired': 'Le nom de l\'entreprise est obligatoire',
      'supplierContactPersonLabel': 'Personne de contact',
      'supplierContactPersonHint': 'ex: John Doe',
      'supplierContactInfo': 'Informations de contact',
      'supplierPhoneLabel': 'Téléphone',
      'supplierPhoneHint': 'ex: 0612345678',
      'supplierEmailLabel': 'Email',
      'supplierEmailHint': 'ex: contact@exemple.com',
      'supplierAddressLabel': 'Adresse',
      'supplierAddressHint': 'ex: 123 rue Principale',
      'supplierCityLabel': 'Ville',
      'supplierCityHint': 'ex: Casablanca',
      'supplierNotesOptions': 'Notes et options',
      'supplierNotesLabel': 'Notes',
      'supplierNotesHint': 'Notes internes sur le fournisseur...',
      'supplierActiveLabel': 'Fournisseur actif',
      'supplierActiveHelper': 'Le fournisseur peut être sélectionné dans les commandes',
      'supplierCreatedSuccess': 'Fournisseur créé avec succès',
      'supplierUpdatedSuccess': 'Fournisseur mis à jour avec succès',
      'supplierSaveError': 'Erreur lors de la sauvegarde du fournisseur',
      // ======== Écrans Catégories ========
      'categoriesSearchHint': 'Rechercher une catégorie...',
      'categoriesTotal': 'Total',
      'categoriesActive': 'Actives',
      'categoriesProducts': 'Produits',
      'categoriesEmptyTitle': 'Aucune catégorie',
      'categoriesEmptySubtitle': 'Créez votre première catégorie pour organiser vos produits',
      'createCategory': 'Créer une catégorie',
      'editCategory': 'Modifier la catégorie',
      'addCategoryTitle': 'Ajouter une catégorie',
      'categoryPreview': 'Aperçu',
      'categoryNameLabel': 'Nom de la catégorie *',
      'categoryNameHint': 'Ex: Électronique, Vêtements...',
      'categoryNameRequired': 'Le nom est obligatoire',
      'categoryDescriptionHint': 'Description de la catégorie (optionnel)',
      'categoryImagePlaceholder': 'Image catégorie',
      'categoryColor': 'Couleur de la catégorie',
      'options': 'Options',
      'categoryActive': 'Catégorie active',
      'categoryActiveHelper': 'La catégorie est visible et utilisable',
      'categoryCreatedSuccess': 'Catégorie créée avec succès',
      'categoryUpdatedSuccess': 'Catégorie modifiée avec succès',
      'categoryImageUploadError': 'Catégorie créée mais erreur lors de l\'upload de l\'image: {error}',

      // ======== Écrans Clients ========
      'clientsSearchHint': 'Rechercher par nom, téléphone ou email...',
      'filterAllClients': 'Tous',
      'filterPositiveCredit': 'Crédit positif',
      'filterNegativeCredit': 'Crédit négatif',
      'filterActiveClients': 'Actifs',
      'sortByName': 'Nom',
      'sortByCredit': 'Crédit',
      'sortByLastPurchase': 'Dernier achat',
      'clientsTotalLabel': 'Total',
      'clientsPositiveCreditShort': 'Crédit +',
      'clientsNegativeCreditShort': 'Crédit -',
      'totalCreditLabel': 'Crédit total',
      'clientsEmptyTitle': 'Aucun client',
      'clientsEmptySubtitle': 'Commencez par ajouter votre premier client',
      'addClient': 'Ajouter un client',
      'editClient': 'Modifier le client',
      'addClientTitle': 'Ajouter un client',
      'clientPreview': 'Aperçu du client',
      'creditLabel': 'Crédit:',
      'totalPurchasesLabel': 'Total achats:',
      'personalInfo': 'Informations personnelles',
      'clientNameLabel': 'Nom complet *',
      'clientNameHint': 'Ex: Ahmed Ben Ali',
      'clientNameRequired': 'Le nom est obligatoire',
      'phoneLabel': 'Téléphone',
      'phoneHint': '+212 6 12 34 56 78',
      'emailLabel': 'Email',
      'emailHint': 'client@example.com',
      'invalidEmail': 'Email invalide',
      'addressLabel': 'Adresse',
      'addressHint': 'Rue, quartier...',
      'cityLabel': 'Ville',
      'cityHint': 'Casablanca, Rabat...',
      'creditAndLimits': 'Crédit et limites',
      'creditLimitLabel': 'Limite de crédit',
      'creditLimitHint': '0.00',
      'creditLimitHelper': 'Montant maximum que le client peut avoir en crédit',
      'creditLimitRequired': 'Limite de crédit obligatoire',
      'currentCreditLabel': 'Crédit actuel:',
      'notesOptions': 'Notes et options',
      'notesLabel': 'Notes',
      'notesHint': 'Notes internes sur le client...',
      'clientActive': 'Client actif',
      'clientActiveHelper': 'Le client peut effectuer des achats',
      'clientCreatedSuccess': 'Client créé avec succès',
      'clientUpdatedSuccess': 'Client modifié avec succès',

      // ======== Écrans Crédits ========
      'clientsWithCreditsTitle': 'Clients avec Crédits',
      'loadingCredits': 'Chargement des crédits...',
      'creditsSummary': 'Résumé des crédits',
      'clientsLabel': 'Clients',
      'creditsLabel': 'Crédits',
      'noCreditsTitle': 'Aucun crédit',
      'noCreditsSubtitle': 'Aucun client n\'a de crédit en cours',
      'overdueLabel': 'En retard',
      'creditsCountLabel': 'Crédits',
      // 'totalAmountLabel': 'Montant total', // duplicate removed, defined earlier

      // ======== Écrans Factures ========
      'invoicesSearchHint': 'Rechercher par numéro, client...',
      'filterAllInvoices': 'Toutes',
      'filterDraft': 'Brouillon',
      'filterSent': 'Envoyées',
      'filterPaid': 'Payées',
      'filterOverdue': 'En retard',
      'sortByDate': 'Date',
      'sortByAmount': 'Montant',
      'sortByClient': 'Client',
      'sortByStatus': 'Statut',
      'pending': 'En attente',
      'paid': 'Payées',
      'newInvoice': 'Nouvelle facture',
      'invoicesEmptyTitle': 'Aucune facture',
      'invoicesEmptySubtitle': 'Créez votre première facture pour commencer',
      // ======== Écrans Fournisseurs ========
      'suppliersSearchHint': 'Rechercher un fournisseur...',
      'suppliersTotalLabel': 'Total',
      'suppliersActiveLabel': 'Actifs',
      'suppliersProductsLabel': 'Produits',
      'suppliersEmptyTitle': 'Aucun fournisseur',
      'suppliersEmptySubtitle': 'Commencez par ajouter votre premier fournisseur',
      // 'addSupplier': 'Ajouter un fournisseur', // duplicate removed, defined earlier

      // ======== Détails Facture (ajout de clés manquantes) ========
      'invoice': 'Facture',
      'invoiceNumber': 'N° Facture',
      'invoiceDate': 'Date',
      'dueDate': 'Échéance',
      'subtotal': 'Sous-total',
      'taxAmount': 'TVA',
      'discountAmount': 'Remise',
      'paidAmount': 'Montant payé',
      'remainingAmount': 'Reste à payer',
      'unitPrice': 'Prix U.',
      'itemTotal': 'Total',
      'tvaRate': 'Taux de TVA',
      'currency': 'Devise',
      'summary': 'RÉSUMÉ',
      'paymentInfo': 'INFORMATIONS DE PAIEMENT',
      'notes': 'NOTES',
      'invoiceImage': 'IMAGE DE LA FACTURE',
      'shareInvoice': 'Partager la facture',
      'sendByEmail': 'Envoyer par email',
      'pdfStandard': 'PDF Standard',
      'pdfThermal': 'PDF Thermique',
      'thankYou': 'Merci de votre visite!',
      'purchaseVoucher': 'BON D\'ACHAT',
      'billedTo': 'FACTURÉ À:',
      'supplier': 'FOURNISSEUR:',
      'article': 'Article',
      'qtyShort': 'Qté',
      'unitPriceShort': '.Prix U',
      'totalShort': 'Total',
      'pdfSubtotal': 'Sous-total:',
      'pdfDiscount': 'Remise:',
      'pdfTax': 'TVA:',
      'pdfTotal': 'TOTAL:',
      'pdfPaid': 'Montant payé:',
      'pdfRemaining': 'Reste à payer:',
      'pdfDate': 'Date',
      'pdfDueDate': 'Échéance',
      'pdfInvoiceNumber': 'N°',
      'pdfItem': 'Article',
      'pdfQty': 'Qté',
      'pdfUnitPrice': 'Prix U.',
      'pdfTotalCol': 'Total',
      'pdfThankYou': 'Merci de votre visite!',
      'pdfInvoice': 'FACTURE DE VENTE',
      'pdfVoucher': 'BON D\'ACHAT',
      'pdfBilledTo': 'FACTURÉ À:',
      'pdfSupplier': 'FOURNISSEUR:',
      'pdfNotes': 'NOTES',
      'pdfPaymentInfo': 'INFORMATIONS DE PAIEMENT',
      'pdfImage': 'IMAGE DE LA FACTURE',
      'pdfShare': 'Partager',
      'pdfSendByEmail': 'Envoyer par email',
      'pdfCancel': 'Annuler',
          'standardPdf': 'PDF Standard',
          'thermalPdf': 'PDF Thermique',
          'invoiceCustomizationTitle': 'Personnalisation des factures',
          'chooseLogo': 'Choisir un logo',
          'companyNameLabel': 'Nom de l\'entreprise',
          'primaryColorLabel': 'Couleur primaire',
          'secondaryColorLabel': 'Couleur secondaire',
          'fontSizeLabel': 'Taille de police',
          'showLogo': 'Afficher le logo',
          'showCompanyInfo': 'Afficher les informations de l\'entreprise',
          'showHeader': 'Afficher l\'en-tête',
          'showFooter': 'Afficher le pied de page',
          'headerTextLabel': 'Texte d\'en-tête',
          'headerTextHint': 'Texte qui apparaîtra en haut de la facture',
          'footerTextLabel': 'Texte de pied de page',
          'footerTextHint': 'Texte qui apparaîtra en bas de la facture',
          'reset': 'Réinitialiser',
          'invoiceCustomizationSaved': 'Personnalisation sauvegardée avec succès',
          'invoiceCustomizationReset': 'Personnalisation réinitialisée',
          'pleaseCheckInput': 'Veuillez vérifier les informations saisies',
          'customizePdf': 'Personnaliser le PDF',
          'itemLabel': 'Article',
          'clientHeader': 'CLIENT',
          'pdfPreview': 'Aperçu PDF',
          'companyInfoSectionTitle': 'Informations de l\'entreprise',
          'chooseLogoShort': 'Choisir logo',
          'appearanceSectionTitle': 'Apparence',
          'headerFooterSectionTitle': 'En-tête et pied de page',
          'showCustomHeader': 'Afficher l\'en-tête personnalisé',
          'showCustomFooter': 'Afficher le pied de page personnalisé',
          'websiteLabel': 'Site web',
          'logoPickError': 'Erreur lors de la sélection du logo: {error}',
          'displayOptionsSectionTitle': 'Options d\'affichage',
          'logoAndCompanyInfoTitle': 'Logo de l\'entreprise et informations de l\'entreprise',
          'colorsAndStyleTitle': 'Couleurs et style',
    },
    'en': {
      // Navigation
      'dashboard': 'Dashboard',
      'products': 'Products',
      'invoices': 'Invoices',
      'clients': 'Clients',
      'suppliers': 'Suppliers',
      'settings': 'Settings',
      'more': 'More',

      // Dashboard
      'todayRevenue': 'Today\'s Revenue',
      // Daily revenue and stats labels
      'totalSales': 'Total sales',
      'collected': 'Collected',
      'purchases': 'Purchases',
      'netProfit': 'Net profit',
      'invoiceCountSingle': 'invoice',
      'invoiceCountPlural': 'invoices',
      'totalProducts': 'Total Products',
      'totalClients': 'Total Clients',
      'lowStock': 'Low Stock',
      'recentActivities': 'Recent Activities',
      'viewAll': 'View All',
      'noRecentActivity': 'No recent activity',
      'weeklyRevenue': 'Weekly Revenue',
      'salesByProduct': 'Sales by Product',
      'stockByCategory': 'Stock by Category',

      // Common
      'add': 'Add',
      'edit': 'Edit',
      'delete': 'Delete',
      'save': 'Save',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'search': 'Search',
      'filter': 'Filter',
      'name': 'Name',
      'description': 'Description',
      'price': 'Price',
      'quantity': 'Quantity',
      'total': 'Total',
      'date': 'Date',
      'status': 'Status',

      // Products
      'addProduct': 'Add Product',
      'editProduct': 'Edit Product',
      'productName': 'Product Name',
      'productDescription': 'Product Description',
      'salePrice': 'Sale Price',
      'purchasePrice': 'Purchase Price',
      'stock': 'Stock',
      'category': 'Category',
      'barcode': 'Barcode',
      'unit': 'Unit',
      'threshold': 'Alert Threshold',

      // ===== Product Transactions Report =====
      'productTransactionReport': 'Products transactions report',
      'selectDateRangeFirst': 'Please select a date range',
      'errorLoadingReport': 'Error loading report',
      'noDataToExport': 'No data to export',
      'transactionType': 'Type',
      'allCategories': 'All categories',
      'minimumQuantity': 'Minimum quantity',
      'viewReport': 'View report',
      'exportToExcel': 'Export to Excel',
      'noDataFound': 'No data found',
      'exportFailed': 'Export failed',

      // Labels for date range
      'startDate': 'Start date',
      'endDate': 'End date',

      // Product Form Fields
      'basicInfo': 'Basic Information',
      'priceStock': 'Price and Stock',
      'advancedOptions': 'Advanced Options',
      'productNameRequired': 'Name is required',
      'productNameHint': 'Ex: iPhone 15 Pro',
      'descriptionHint': 'Detailed product description',
      'noCategory': 'No category',
      'barcodeHint': '1234567890123',
      'sku': 'SKU',
      'skuHint': 'PROD-001',
      'scanBarcodeTooltip': 'Scan barcode',
      'generateBarcodeTooltip': 'No barcode? Generate',
      'printBarcodeTooltip': 'Print barcode',
      'purchasePriceRequired': 'Purchase price is required',
      'purchasePriceHint': '0.00',
      'salePriceRequired': 'Sale price is required',
      'salePriceHint': '0.00',
      'invalidPrice': 'Invalid price',
      'stockQuantityRequired': 'Quantity is required',
      'stockQuantityHint': '0',
      'invalidQuantity': 'Invalid quantity',
      'stockAlertThreshold': 'Stock Alert Threshold *',
      'stockAlertThresholdHint': '10',
      'stockAlertThresholdHelper': 'Alert when stock falls below this value',
      'thresholdRequired': 'Threshold is required',
      'invalidThreshold': 'Invalid threshold',

      // ======== Invoice Details ========
      'invoice': 'Invoice',
      'invoiceNumber': 'Invoice No.',
      'invoiceDate': 'Date',
      // 'dueDate': 'Due Date',
      // 'subtotal': 'Subtotal',
      'taxAmount': 'VAT',
      'discountAmount': 'Discount',
      // 'paidAmount': 'Paid Amount', // doublon commenté
      // 'remainingAmount': 'Remaining Amount', // doublon commenté
      'unitPrice': 'Unit Price',
      'itemTotal': 'Total',
      'tvaRate': 'VAT Rate',
      'currencyName': 'Currency',
      'summary': 'SUMMARY',
      'paymentInfo': 'PAYMENT INFORMATION',
      'notes': 'NOTES',
      'invoiceImage': 'INVOICE IMAGE',
      'shareInvoice': 'Share Invoice',
      'sendByEmail': 'Send by Email',
      'pdfStandard': 'Standard PDF',
      'pdfThermal': 'Thermal PDF',
      'thankYou': 'Thank you for your visit!',
      'salesInvoice': 'SALES INVOICE',
      'purchaseVoucher': 'PURCHASE VOUCHER',
      'billedTo': 'BILLED TO:',
      'supplier': 'SUPPLIER:',
      'article': 'Item',
      'qtyShort': 'Qty',
      'unitPriceShort': 'U.Price',
      'totalShort': 'Total',
      'pdfSubtotal': 'Subtotal:',
      'pdfDiscount': 'Discount:',
      'pdfTax': 'VAT:',
      'pdfTotal': 'TOTAL:',
      'pdfPaid': 'Paid Amount:',
      'pdfRemaining': 'Remaining:',
      'pdfDate': 'Date',
      'pdfDueDate': 'Due Date',
      'pdfInvoiceNumber': 'No.',
      'pdfItem': 'Item',
      'pdfQty': 'Qty',
      'pdfUnitPrice': 'Unit Price',
      'pdfTotalCol': 'Total',
      'pdfThankYou': 'Thank you for your visit!',
      'pdfInvoice': 'SALES INVOICE',
      'pdfVoucher': 'PURCHASE VOUCHER',
      'pdfBilledTo': 'BILLED TO:',
      'pdfSupplier': 'SUPPLIER:',
      'pdfNotes': 'NOTES',
      'pdfPaymentInfo': 'PAYMENT INFORMATION',
      'pdfImage': 'INVOICE IMAGE',
      'pdfShare': 'Share',
      'pdfSendByEmail': 'Send by Email',
      'pdfCancel': 'Cancel',
      'activeProduct': 'Active Product',
      'activeProductDescription': 'Product is visible and available for sale',
      'productImage': 'Product Image',
      'noImageSelected': 'No image selected',
      'profitPerUnit': 'Profit per unit',
      'productDetails': 'Details',
      'productStatus': 'Status',
      'active': 'Active',
      'inactive': 'Inactive',
      'createdOn': 'Created on',
      'modifiedOn': 'Modified on',
      'noDescription': 'No description',
      'notDefined': 'Not defined',

      // Messages de succès et d'erreur
      'productCreatedSuccess': 'Product created successfully',
      'productUpdatedSuccess': 'Product updated successfully',
      'saveError': 'Error saving',
      'saveErrorMessage': 'Error saving: {error}',

      // Actions rapides et autres
      'adjustStock': 'Adjust Stock',
      'stockAdjustment': 'Adjust Stock',
      'addStock': 'Add',
      'removeStock': 'Remove',
      'setStock': 'Set',
      'newQuantity': 'New Quantity',
      'reason': 'Reason',
      'reasonHint': 'Reason for adjustment (optional)',
      'userNotConnected': 'Error: User not connected',
      'existingProductDialog': 'Existing Product',
      'existingProductMessage': 'A product with this barcode already exists. Do you want to edit it?',

      // Import et messages
      'productsFoundInExcel': '{count} products found in Excel file',
      'noProductsFoundInExcel': 'No products found in Excel file',
      'errorReadingFile': 'Error reading file: {error}',
      'selectCategory': 'Select a category',
      'supportedFileFormats': 'Supported file formats',
      'acceptedFormats': '📁 Accepted formats:',
      'requiredColumns': '📋 Required columns:',
      'optionalColumns': '📋 Optional columns:',
      'productNameRequiredForImport': '• name - Product name (required)',
      'barcodeColumn': '• barcode - Barcode',
      'imageColumn': '• image - Image URL',
      'descriptionColumn': '• description - Description',
      'purchasePriceColumn': '• purchase_price - Purchase price',
      'salePriceColumn': '• sale_price - Sale price',
      'stockColumn': '• stock - Stock quantity',
      'unitColumn': '• unit - Unit of measure',

      // Settings
      'theme': 'Theme',
      'language': 'Language',
      'scanSound': 'Scan Sound',
      'companySettings': 'Company Settings',
      'companyName': 'Company Name',
      'companyLogo': 'Company Logo',
      'administration': 'Administration',
      'globalProducts': 'Global Products',
      'userManagement': 'User Management',

      // Themes
      'lightTheme': 'Light',
      'darkTheme': 'Dark',
      'systemTheme': 'System',

      // Sounds
      'classicBeep': 'Classic Beep',
      'success': 'Success',
      'notification': 'Notification',
      'cashRegister': 'Cash Register',
      'noSound': 'No Sound',

      // Messages
      'chooseLanguage': 'Choose Language',
      'chooseTheme': 'Choose Theme',
      'chooseScanSound': 'Choose Scan Sound',
      'testSound': 'Test Sound',

      // Navigation supplémentaire
      'categories': 'Categories',
      'home': 'Home',
      'reports': 'Reports',
      'pos': 'Point of Sale',

      // Dépenses
      'expenses': 'Expenses',
      'addExpense': 'Add Expense',
      'expenseType': 'Expense Type',
      'amount': 'Amount',
      'rent': 'Rent',
      'electricity': 'Electricity',
      'wifi': 'Internet/WiFi',
      'other': 'Other',
      'monthlyExpenses': 'Monthly Expenses',

      // Import/Export
      'importProducts': 'Import Products',
      'exportData': 'Export Data',
      'selectFile': 'Select File',
      'importFromExcel': 'Import from Excel',

      // Recherche avancée
      'searchByName': 'Search by Name',
      'searchByBarcode': 'Search by Barcode',
      'searchByCategory': 'Search by Category',
      'advancedSearch': 'Advanced Search',
      'noResults': 'No results found',
      'scanBarcode': 'Scan Barcode',
      'searchProducts': 'Search Products',

      // Messages d'interface
      'welcome': 'Welcome',
      'loading': 'Loading...',
      'error': 'Error',
      'successMessage': 'Success',
      'retry': 'Retry',
      'close': 'Close',
      'back': 'Back',
      'next': 'Next',
      'previous': 'Previous',
      'finish': 'Finish',

      // Formulaires
      'required': 'Required',
      'optional': 'Optional',
      'pleaseEnter': 'Please enter',
      'invalidFormat': 'Invalid format',

      // Actions
      'create': 'Create',
      'update': 'Update',
      'remove': 'Remove',
      'duplicate': 'Duplicate',
      'share': 'Share',
      'print': 'Print',

      // Factures
      // 'invoice': 'Invoice',
      // 'invoiceNumber': 'Invoice Number',
      // 'invoiceDate': 'Invoice Date',
      'dueDate': 'Due Date',
      'subtotal': 'Subtotal',
      // 'taxAmount': 'Tax Amount',
      // 'discountAmount': 'Discount Amount',
      'paidAmount': 'Paid Amount',
'remainingAmount': 'Remaining Amount',
//    'unitPrice': 'Unit Price', // doublon commenté
'itemTotalLabel': 'Item Total',
      'tvaRateLabel': 'TVA Rate',
      // 'currencyName': 'Currency', // Doublon commenté

      // Support
      'support': 'Support',
      'contactUs': 'Contact Us',
      'sendMessage': 'Send Message',
      'yourEmail': 'Your Email',
      'subject': 'Subject',
      'message': 'Message',
      'phone': 'Phone',
      'whatsapp': 'WhatsApp',
      'availability': 'Availability',
      'responseTime': 'Response Time',
      'supportedLanguages': 'Supported Languages',
      'email': 'Email',

      // Paramètres
      'appSettings': 'App Settings',
      'businessSettings': 'Business Settings',
      'notifications': 'Notifications',
      'pushNotifications': 'Push Notifications',
      'dataBackup': 'Data Backup',
      'aboutSupport': 'About Support',
      'logout': 'Logout',
      'version': 'Version',
      'termsOfService': 'Terms of Service',
      'advancedSettings': 'Advanced Settings',
      'dataManagement': 'Data Management and Reset',

      // Écrans et contenus
      'noDataAvailable': 'No data available',
      'refreshData': 'Refresh data',
      'viewDetails': 'View details',
      'editItem': 'Edit item',
      'deleteItem': 'Delete item',
      'confirmDelete': 'Confirm deletion',
      'deleteConfirmation': 'Are you sure you want to delete this item?',
      'yes': 'Yes',
      'no': 'No',

      // Actions rapides et navigation
      'quickActions': 'Quick Actions',
      'quickActionsSubtitle': 'Quick access to main functions',
      'sale': 'Sale',
      'purchase': 'Purchase',
      'createInvoice': 'Create Invoice',
      'manageStock': 'Manage Stock',
      'viewAllClients': 'View All Clients',
      'viewAllSuppliers': 'View All Suppliers',
      'addSupplier': 'Add Supplier',
      'addCategory': 'Add Category',

      // Formulaires et champs
      'profile': 'Profile',
      'fullName': 'Full Name',
      'businessName': 'Business Name',
      'phoneNumber': 'Phone Number',
      'address': 'Address',
      'subscriptionStatus': 'Subscription Status',
      'subscriptionType': 'Subscription Type',
      'subscriptionStartDate': 'Subscription Start Date',
      'subscriptionEndDate': 'Subscription End Date',
      'lastPaymentDate': 'Last Payment Date',
      'lastLoginDate': 'Last Login Date',
      'activeSubscription': 'Active Subscription',
      'expiredSubscription': 'Expired Subscription',
      'noActiveSubscription': 'No Active Subscription',
      'subscriptionRemainingDays': 'You have {days} days of subscription remaining',
      'subscriptionRemainingHours': 'You have {hours} hours of subscription remaining',
      'subscriptionRemainingTime': 'You have {days} days and {hours} hours of subscription remaining',
      'subscriptionExpired': 'Subscription Expired',
      'refreshSubscription': 'Refresh Subscription',
      'subscriptionUpdated': 'Subscription status updated!',

      // Messages et notifications
      'noSalesDataAvailable': 'No sales data available',
      'noNotifications': 'No notifications',
      'ok': 'OK',
      'warning': 'Warning',
      'info': 'Information',

      // Scanner et codes-barres
      'manualBarcodeEntry': 'Manual Barcode Entry',
      'manualBarcodeEntryDescription': 'Enter the barcode manually below',
      'scanError': 'Scan error',
      'barcodeScanner': 'Scan Barcode',
      'multipleLabelsPerPage': 'Multiple labels per page',
      'numberOfLabels': 'Number of labels: ',

      // Images et sélection
      'takePhoto': 'Take Photo',
      'chooseFromGallery': 'Choose from Gallery',
      'removeImage': 'Remove Image',
      'chooseImage': 'Choose Image',
      'permissionRequired': 'Permission Required',
      'imageSelectionError': 'Error selecting image',
      'imageSelectionNotImplemented': 'Image selection not implemented',

      // Clients et fournisseurs
      'anonymousClient': 'Anonymous Client',
      'anonymousSupplier': 'Anonymous Supplier',
      'activeSupplier': 'Active Supplier',
      'activeSupplierDescription': 'The supplier can receive orders',
      'supplierDetails': 'Supplier Details',
      'clientDetails': 'Client Details',

      // Factures et POS
      'tax': 'Tax:',
      'modifyQuantity': 'Modify Quantity',
      'modifyPrice': 'Modify Price',
      'product': 'Product:',
      'currentPrice': 'Current Price:',
      'newUnitPrice': 'New Unit Price (DH)',
      'modify': 'Modify',
      'clearCart': 'Clear Cart',
      'clearCartConfirmation': 'Are you sure you want to clear the cart?',
      'clear': 'Clear',
      'newTransaction': 'New Transaction',
      'finalizePurchase': 'Finalize Purchase',

      // POS / Point of sale
      'posSaleTitle': 'Point of Sale',
      'posPurchaseTitle': 'Purchase',
      'barcodeEntryHint': 'Scan or enter the barcode',
      'quantityShort': 'Qty',
      'closeScannerTooltip': 'Close scanner',
      'scannerTooltip': 'Scan',
      'clientOptionalLabel': 'Client (optional)',
      'supplierLabel': 'Supplier',
      'selectSupplierError': 'Please select a supplier or choose anonymous',
      'emptyCartTitle': 'Empty cart',
      'emptyCartSubtitle': 'Scan or enter a barcode to add products',
      'unitPriceLabel': 'Unit price',
      'quantityLabel': 'Quantity',
      'amountPaid': 'Amount paid',
      'changeLabelPositive': 'Change',
      'changeLabelNegative': 'Due',
      'finalizeSale': 'Finalize sale',
      'saleSuccess': 'Sale successful',
      'purchaseSuccess': 'Purchase recorded',
      'invoiceTotalLabel': 'Total',
      'invoicePaidLabel': 'Paid',
      'invoiceChangeToReturnLabel': 'Change to return',
      'creditAddedLabel': 'Credit added',
      'invoiceCreationError': 'Error while creating the invoice',
      'partialPaymentError': 'Please select a client for a partial payment',
      'creditLimitExceeded': 'Credit limit exceeded for this client',
      'genericErrorPrefix': 'Error',
      'errorLoadingSuppliers': 'Error loading suppliers',
      'productNotFound': 'Product not found',
      'totalAmountLabel': 'Total amount',
      'invoiceImageOptional': 'Invoice image (optional)',

      // Catégories
      'deleteCategory': 'Delete',
      'confirmDeleteCategory': 'Confirm Deletion',
      'deleteCategoryConfirmation': 'Are you sure you want to delete the category "{name}"?',
      'categoryDeletedSuccess': 'Category "{name}" deleted successfully',
      'categoryDeleteError': 'Error deleting category',

      // Crédits
      'makePayment': 'Make Payment',
      'pleaseEnterAmount': 'Please enter an amount',
      'amountExceedsRemaining': 'Amount cannot exceed remaining amount',
      'paymentError': 'Payment error',
      'loadHistoryError': 'Error loading history',

      // Recherche
      'noResultsFound': 'No results found',

      // Paramètres avancés
      'advancedSettingsTitle': 'Advanced Settings',
      'completeReset': 'Complete Reset',
      'businessDataReset': 'Business Data Reset',
      'completeResetDescription': 'This action will delete ALL your data:\n• Products\n• Invoices\n• Clients\n• Settings\n• Images\n\nYou will become like a new user.',
      'businessDataResetDescription': 'This action will delete your business data:\n• Products\n• Invoices\n• Clients\n• Suppliers\n\nYour settings will be preserved.',
      'typeToConfirm': 'To confirm, type exactly:',
      'typeHere': 'Type here...',

      // Gestion des appareils
      'authorize': 'Authorize',
      'revoke': 'Revoke',
      'removeDevice': 'Remove',

      // Sauvegarde Google Drive
      'googleDriveBackup': 'Google Drive Backup',
      'connectToGoogleDrive': 'Connect to Google Drive',
      'disconnect': 'Disconnect',
      'backup': 'Backup',
      'refresh': 'Refresh',
      'size': 'Size: {size}',
      'restore': 'Restore',
      'confirmRestore': 'Confirm Restore',

      // Paramètres de l'entreprise
      'chooseCurrency': 'Choose Currency',
      'moroccanDirham': 'Moroccan Dirham (DH)',
      'euro': 'Euro (€)',
      'usDollar': 'US Dollar (\$)',
      'clearAllData': 'Clear All Data',
      'logoutConfirmation': 'Logout',
      'logoutConfirmationMessage': 'Are you sure you want to logout?',
      'exitConfirmationMessage': 'Are you sure you want to exit the application?',
      'chooseSound': 'Choose Sound',

      // Support
      'needHelp': 'Need Help?',
      'ourTeamIsHere': 'Our team is here to help',
      'otherContactMethods': 'Other Contact Methods',
      'availabilityHours': 'Availability Hours',
      'supportedLanguagesList': 'French, English, Arabic',
      'responseTimeHours': '24-48 hours',
      'emailAppOpened': 'Email app opened successfully',
      'cannotOpenEmailApp': 'Cannot open email app',
      'cannotOpenPhoneApp': 'Cannot open phone app',
      'cannotOpenWhatsApp': 'Cannot open WhatsApp',
      'messageMinLength': 'Message must contain at least 10 characters',
      'describeYourProblem': 'Describe your problem or question...',
      'subjectOfMessage': 'Subject of your message',
      'sending': 'Sending...',
      'sendMessageButton': 'Send Message',

      // Autorisation d'appareil
      'deviceAuthorization': 'Device Authorization',
      'deviceInfo': 'Information',
      'deviceRegisteredAutomatically': '• Your device has been automatically registered',
      'adminMustAuthorize': '• An administrator must authorize it manually',
      'youWillReceiveNotification': '• You will receive a notification once authorized',
      'cannotAccessApp': '• In the meantime, you cannot access the application',

      // Champs manquants pour les produits
      'rupture': 'Out of Stock',
      'stockFaible': 'Low Stock',
      'tous': 'All',
      'marge': 'Margin',
      'valeur': 'Value',
      'piece': 'piece',
      'modifier': 'Modify',
      'ruptureDeStock': 'Out of Stock',
      'stockSuffisant': 'Sufficient Stock',
      'stockActuel': 'Current Stock',
      'valeurStock': 'Stock Value',
      'produitsNecessitantAttention': 'Products requiring attention',
      'gererLesStocks': 'Manage Stock',
      'voirAutresProduits': 'View {count} other products',
      'stockOptimalPourTousLesProduits': 'Optimal stock for all products',
      'produitsEnStockFaible': 'products in low stock',
      'faible': 'Low',
      'okStatus': 'OK',
      'min': 'Min',
      'ruptureLabel': 'OUT OF STOCK',
      'faibleLabel': 'LOW',
      'chargement': 'Loading...',
      'erreurDeChargement': 'Loading error',
      'gestionDesStocks': 'Stock Management',
      'alertesDeStock': 'Stock Alerts',
      'produitsNecessitentAttention': 'products require your attention',
      'stockFaibleLabel': 'Low Stock',
      'produitsEnStockFaibleLabel': 'products in low stock',

      // Champs manquants pour le dashboard
      'bonjour': 'Good morning',
      'bonApresMidi': 'Good afternoon',
      'bonsoir': 'Good evening',
      'utilisateur': 'User',
      'apercuActivite': 'Here is an overview of your activity today',
      'actionsRapides': 'Quick Actions',
      'facture': 'Invoice',
      'scanner': 'Scanner',
      'nouvelleFacture': 'New invoice',
      'ajouterProduit': 'Add product',
      'nouveauClient': 'New client',
      'ajouterCategorie': 'Add category',
      'nouveauFournisseur': 'New supplier',
      'scannerProduit': 'Scan product',
      'pointDeVente': 'Point of Sale',
      'accesRapideVente': 'Quick access to sales and purchase functions',
      'vente': 'Sale',
      'achat': 'Purchase',
      'aucuneNotification': 'No notifications',
      'fermer': 'Close',
      'revenusDuJour': 'Today\'s Revenue',
      'produits': 'Products',
      // Stock alerts messages
      'needAttentionSingular': 'needs your attention',
      'needAttentionPlural': 'need your attention',
      'allProductsSufficientStock': 'All your products have sufficient stock',
      'seeOtherProducts': 'See {count} other products',

      // ====== Invoice type selection ======
      'invoiceTypeChoiceTitle': 'Choose invoice type',
      'invoiceTypeChoiceSubtitle': 'Select the type of transaction you want to perform',
      'salesInvoiceTitle': 'Sales Invoice',
      'salesInvoiceSubtitle': 'Sell products to a customer',
      'purchaseVoucherTitle': 'Purchase Voucher',
      'purchaseVoucherSubtitle': 'Record a purchase of goods',
      'includedFeaturesLabel': 'Included features',
      'featureBarcodeScanner': 'Barcode scanner',
      'featureClientManagement': 'Client management',
      'featureCalculateChange': 'Change calculation',
      'featureCreditManagement': 'Credit management',
      'featureAutoStockUpdate': 'Automatic stock update',
      'featureSupplierManagement': 'Supplier management',
      'featureAutoAddToStock': 'Automatic addition to stock',
      'featureCostTracking': 'Cost tracking',

      // ====== Add/Edit Supplier ======
      'addSupplierTitle': 'Add supplier',
      'editSupplierTitle': 'Edit supplier',
      'supplierCompanyNameLabel': 'Company name',
      'supplierCompanyNameHint': 'e.g., ABC Ltd',
      'supplierCompanyNameRequired': 'Company name is required',
      'supplierContactPersonLabel': 'Contact person',
      'supplierContactPersonHint': 'e.g., John Doe',
      'supplierContactInfo': 'Contact information',
      'supplierPhoneLabel': 'Phone',
      'supplierPhoneHint': 'e.g., 0612345678',
      'supplierEmailLabel': 'Email',
      'supplierEmailHint': 'e.g., contact@example.com',
      'supplierAddressLabel': 'Address',
      'supplierAddressHint': 'e.g., 123 Main Street',
      'supplierCityLabel': 'City',
      'supplierCityHint': 'e.g., Casablanca',
      'supplierNotesOptions': 'Notes and options',
      'supplierNotesLabel': 'Notes',
      'supplierNotesHint': 'Internal notes about the supplier...',
      'supplierActiveLabel': 'Supplier active',
      'supplierActiveHelper': 'The supplier can be selected in orders',
      'supplierCreatedSuccess': 'Supplier created successfully',
      'supplierUpdatedSuccess': 'Supplier updated successfully',
      'supplierSaveError': 'Error while saving the supplier',
      // ======== Category Screens ========
      'categoriesSearchHint': 'Search for a category...',
      'categoriesTotal': 'Total',
      'categoriesActive': 'Active',
      'categoriesProducts': 'Products',
      'categoriesEmptyTitle': 'No category',
      'categoriesEmptySubtitle': 'Create your first category to organize your products',
      'createCategory': 'Create a category',
      'editCategory': 'Edit category',
      'addCategoryTitle': 'Add category',
      'categoryPreview': 'Preview',
      'categoryNameLabel': 'Category name *',
      'categoryNameHint': 'E.g., Electronics, Clothing...',
      'categoryNameRequired': 'Name is required',
      'categoryDescriptionHint': 'Category description (optional)',
      'categoryImagePlaceholder': 'Category image',
      'categoryColor': 'Category color',
      'options': 'Options',
      'categoryActive': 'Active category',
      'categoryActiveHelper': 'The category is visible and usable',
      'categoryCreatedSuccess': 'Category created successfully',
      'categoryUpdatedSuccess': 'Category updated successfully',
      'categoryImageUploadError': 'Category created but image upload error: {error}',

      // ======== Client Screens ========
      'clientsSearchHint': 'Search by name, phone or email...',
      'filterAllClients': 'All',
      'filterPositiveCredit': 'Positive credit',
      'filterNegativeCredit': 'Negative credit',
      'filterActiveClients': 'Active',
      'sortByName': 'Name',
      'sortByCredit': 'Credit',
      'sortByLastPurchase': 'Last purchase',
      'clientsTotalLabel': 'Total',
      'clientsPositiveCreditShort': 'Credit +',
      'clientsNegativeCreditShort': 'Credit -',
      'totalCreditLabel': 'Total credit',
      'clientsEmptyTitle': 'No client',
      'clientsEmptySubtitle': 'Start by adding your first client',
      'addClient': 'Add a client',
      'editClient': 'Edit client',
      'addClientTitle': 'Add client',
      'clientPreview': 'Client preview',
      'creditLabel': 'Credit:',
      'totalPurchasesLabel': 'Total purchases:',
      'personalInfo': 'Personal information',
      'clientNameLabel': 'Full name *',
      'clientNameHint': 'e.g., Ahmed Ben Ali',
      'clientNameRequired': 'Name is required',
      'contactInfo': 'Contact information',
      'phoneLabel': 'Phone',
      'phoneHint': '+1 555-123-4567',
      'emailLabel': 'Email',
      'emailHint': 'client@example.com',
      'invalidEmail': 'Invalid email',
      'addressLabel': 'Address',
      'addressHint': 'Street, district...',
      'cityLabel': 'City',
      'cityHint': 'Casablanca, Rabat...',
      'creditAndLimits': 'Credit and limits',
      'creditLimitLabel': 'Credit limit',
      'creditLimitHint': '0.00',
      'creditLimitHelper': 'Maximum amount the client can have in credit',
      'creditLimitRequired': 'Credit limit is required',
      'invalidAmount': 'Invalid amount',
      'currentCreditLabel': 'Current credit:',
      'notesOptions': 'Notes and options',
      'notesLabel': 'Notes',
      'notesHint': 'Internal notes about the client...',
      'clientActive': 'Active client',
      'clientActiveHelper': 'The client can make purchases',
      'clientCreatedSuccess': 'Client created successfully',
      'clientUpdatedSuccess': 'Client updated successfully',

      // ======== Credit Screens ========
      'clientsWithCreditsTitle': 'Clients with Credits',
      'loadingCredits': 'Loading credits...',
      'creditsSummary': 'Credits summary',
      'clientsLabel': 'Clients',
      'creditsLabel': 'Credits',
      'totalAmount': 'Total amount',
      'noCreditsTitle': 'No credit',
      'noCreditsSubtitle': 'No client has an ongoing credit',
      'overdueLabel': 'Overdue',
      'creditsCountLabel': 'Credits',
      // 'totalAmountLabel': 'Total amount', // duplicate removed, defined earlier

      // ======== Invoice Screens ========
      'invoicesSearchHint': 'Search by number, client...',
      'filterAllInvoices': 'All',
      'filterDraft': 'Draft',
      'filterSent': 'Sent',
      'filterPaid': 'Paid',
      'filterOverdue': 'Overdue',
      'sortByDate': 'Date',
      'sortByAmount': 'Amount',
      'sortByClient': 'Client',
      'sortByStatus': 'Status',
      'pending': 'Pending',
      'paid': 'Paid',
      'newInvoice': 'New invoice',
      'invoicesEmptyTitle': 'No invoice',
      'invoicesEmptySubtitle': 'Create your first invoice to get started',
      // ======== Suppliers Screens ========
      'suppliersSearchHint': 'Search for a supplier...',
      'suppliersTotalLabel': 'Total',
      'suppliersActiveLabel': 'Active',
      'suppliersProductsLabel': 'Products',
      'suppliersEmptyTitle': 'No suppliers',
      'suppliersEmptySubtitle': 'Start by adding your first supplier',
      // 'addSupplier': 'Add a supplier', // duplicate removed, defined earlier

      // ======== تفاصيل الفاتورة (إضافة مفاتيح ناقصة) ========
      // 'invoice': 'فاتورة', // Doublon commenté
      // 'invoiceNumber': 'رقم الفاتورة', // Doublon commenté
      // 'invoiceDate': 'التاريخ', // Doublon commenté
      // 'dueDate': 'تاريخ الاستحقاق', // Doublon commenté
      // 'subtotal': 'المجموع الفرعي', // Doublon commenté
      // 'taxAmount': 'الضريبة', // Doublon commenté
      // 'discountAmount': 'الخصم', // Doublon commenté
      // 'paidAmount': 'المبلغ المدفوع', // Doublon commenté
      // 'remainingAmount': 'المبلغ المتبقي', // Doublon commenté
      // 'unitPrice': 'سعر الوحدة', // Doublon commenté
      // 'itemTotal': 'المجموع', // Doublon commenté
      // 'tvaRate': 'نسبة الضريبة', // Doublon commenté
      // 'currency': 'العملة', // Doublon commenté
      // 'summary': 'الملخص', // Doublon commenté
      // 'paymentInfo': 'معلومات الدفع', // Doublon commenté
      // 'notes': 'ملاحظات', // Doublon commenté
      // 'invoiceImage': 'صورة الفاتورة', // Doublon commenté
      // 'shareInvoice': 'مشاركة الفاتورة', // Doublon commenté
      // 'sendByEmail': 'إرسال بالبريد الإلكتروني', // Doublon commenté
      // 'pdfStandard': 'PDF عادي', // Doublon commenté
      // 'pdfThermal': 'PDF حراري', // Doublon commenté
      // 'cancel': 'إلغاء', // Doublon commenté
      // 'thankYou': 'شكرًا لزيارتكم!', // Doublon commenté
      // 'salesInvoice': 'فاتورة مبيعات', // Doublon commenté
      // 'purchaseVoucher': 'سند شراء', // Doublon commenté
      // 'billedTo': 'مُصدر إلى:', // Doublon commenté
      // 'supplier': 'المورد:', // Doublon commenté
      // 'article': 'الصنف', // Doublon commenté
      // 'qtyShort': 'الكمية', // Doublon commenté
      // 'unitPriceShort': 'س.وحدة', // Doublon commenté
      // 'totalShort': 'المجموع', // Doublon commenté
      // 'pdfSubtotal': 'المجموع الفرعي:', // Doublon commenté
      // 'pdfDiscount': 'الخصم:', // Doublon commenté
      // 'pdfTax': 'الضريبة:', // Doublon commenté
      // 'pdfTotal': 'الإجمالي:', // Doublon commenté
      // 'pdfPaid': 'المبلغ المدفوع:', // Doublon commenté
      // 'pdfRemaining': 'المتبقي:', // Doublon commenté
      // 'pdfDate': 'التاريخ', // Doublon commenté
      // 'pdfDueDate': 'تاريخ الاستحقاق', // Doublon commenté
      // 'pdfInvoiceNumber': 'رقم', // Doublon commenté
      // 'pdfItem': 'الصنف', // Doublon commenté
      // 'pdfQty': 'الكمية', // Doublon commenté
      // 'pdfUnitPrice': 'سعر الوحدة', // Doublon commenté
      // 'pdfTotalCol': 'المجموع', // Doublon commenté
      // 'pdfThankYou': 'شكرًا لزيارتكم!', // Doublon commenté
      // 'pdfInvoice': 'فاتورة مبيعات', // Doublon commenté
      // 'pdfVoucher': 'سند شراء', // Doublon commenté
      // 'pdfBilledTo': 'مُصدر إلى:', // Doublon commenté
      // 'pdfSupplier': 'المورد:', // Doublon commenté
      // 'pdfNotes': 'ملاحظات', // Doublon commenté
      // 'pdfPaymentInfo': 'معلومات الدفع', // Doublon commenté
      // 'pdfImage': 'صورة الفاتورة', // Doublon commenté
      // 'pdfShare': 'مشاركة', // Doublon commenté
      // 'pdfSendByEmail': 'إرسال بالبريد الإلكتروني', // Doublon commenté
      // 'pdfCancel': 'إلغاء', // Doublon commenté
          'standardPdf': 'Standard PDF',
          'thermalPdf': 'Thermal PDF',
          'invoiceCustomizationTitle': 'Invoice customization',
          'chooseLogo': 'Choose a logo',
          'companyNameLabel': 'Company name',
          'primaryColorLabel': 'Primary color',
          'secondaryColorLabel': 'Secondary color',
          'fontSizeLabel': 'Font size',
          'showLogo': 'Show logo',
          'showCompanyInfo': 'Show company information',
          'showHeader': 'Show header',
          'showFooter': 'Show footer',
          'headerTextLabel': 'Header text',
          'headerTextHint': 'Text that will appear at the top of the invoice',
          'footerTextLabel': 'Footer text',
          'footerTextHint': 'Text that will appear at the bottom of the invoice',
          'reset': 'Reset',
          'invoiceCustomizationSaved': 'Customization saved successfully',
          'invoiceCustomizationReset': 'Customization reset',
          'pleaseCheckInput': 'Please check the entered information',
          'customizePdf': 'Customize PDF',
          'itemLabel': 'Item',
          'clientHeader': 'CLIENT',
          'pdfPreview': 'PDF preview',
          'companyInfoSectionTitle': 'Company information',
          'chooseLogoShort': 'Choose logo',
          'appearanceSectionTitle': 'Appearance',
          'headerFooterSectionTitle': 'Header & footer',
          'showCustomHeader': 'Show custom header',
          'showCustomFooter': 'Show custom footer',
          'websiteLabel': 'Website',
          'logoPickError': 'Error selecting logo: {error}',
          'displayOptionsSectionTitle': 'Display options',
          'logoAndCompanyInfoTitle': 'Company logo & information',
          'colorsAndStyleTitle': 'Colors & style',
    },
    'ar': {
      // Navigation
      'dashboard': 'لوحة التحكم',
      'products': 'المنتجات',
      'invoices': 'الفواتير',
      'clients': 'العملاء',
      'suppliers': 'الموردين',
      'settings': 'الإعدادات',
      'more': 'المزيد',

      // Dashboard
      'todayRevenue': 'إيرادات اليوم',
      // Daily revenue and stats labels
      'totalSales': 'إجمالي المبيعات',
      'collected': 'المُحصّل',
      'purchases': 'المشتريات',
      'netProfit': 'صافي الربح',
      'invoiceCountSingle': 'فاتورة',
      'invoiceCountPlural': 'فواتير',
      'totalProducts': 'إجمالي المنتجات',
      'totalClients': 'إجمالي العملاء',
      'lowStock': 'مخزون منخفض',
      'recentActivities': 'الأنشطة الحديثة',
      'viewAll': 'عرض الكل',
      'noRecentActivity': 'لا توجد أنشطة حديثة',
      'weeklyRevenue': 'الإيرادات الأسبوعية',
      'salesByProduct': 'المبيعات حسب المنتج',
      'stockByCategory': 'المخزون حسب الفئة',

      // Common
      'add': 'إضافة',
      'edit': 'تعديل',
      'delete': 'حذف',
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'confirm': 'تأكيد',
      'search': 'بحث',
      'filter': 'تصفية',
      'name': 'الاسم',
      'description': 'الوصف',
      'price': 'السعر',
      'quantity': 'الكمية',
      'total': 'المجموع',
      'date': 'التاريخ',
      'status': 'الحالة',

      // Products
      'addProduct': 'إضافة منتج',
      'editProduct': 'تعديل المنتج',
      'productName': 'اسم المنتج',
      'productDescription': 'وصف المنتج',
      'salePrice': 'سعر البيع',
      'purchasePrice': 'سعر الشراء',
      'stock': 'المخزون',
      'category': 'الفئة',
      'barcode': 'الرمز الشريطي',
      'unit': 'الوحدة',
      'threshold': 'حد التنبيه',

      // ===== تقرير معاملات المنتجات =====
      'productTransactionReport': 'تقرير معاملات المنتجات',
      'selectDateRangeFirst': 'يرجى تحديد فترة زمنية',
      'errorLoadingReport': 'حدث خطأ أثناء تحميل التقرير',
      'noDataToExport': 'لا توجد بيانات للتصدير',
      'transactionType': 'النوع',
      'allCategories': 'جميع الفئات',
      'minimumQuantity': 'الكمية الدنيا',
      'viewReport': 'عرض التقرير',
      'exportToExcel': 'تصدير إلى إكسل',
      'noDataFound': 'لا توجد بيانات',
      'exportFailed': 'فشل التصدير',

      // تسميات نطاق التاريخ
      'startDate': 'تاريخ البداية',
      'endDate': 'تاريخ النهاية',

      // Product Form Fields
      'basicInfo': 'المعلومات الأساسية',
      'priceStock': 'السعر والمخزون',
      'advancedOptions': 'الخيارات المتقدمة',
      'productNameRequired': 'اسم المنتج مطلوب',
      'productNameHint': 'مثال: آيفون 15 برو',
      'descriptionHint': 'وصف مفصل للمنتج',
      'noCategory': 'لا توجد فئة',
      'barcodeHint': '1234567890123',
      'sku': 'رمز المنتج',
      'skuHint': 'PROD-001',
      'scanBarcodeTooltip': 'مسح الرمز الشريطي',
      'generateBarcodeTooltip': 'لا يوجد رمز شريطي؟ إنشاء',
      'printBarcodeTooltip': 'طباعة الرمز الشريطي',
      'purchasePriceRequired': 'سعر الشراء مطلوب',
      'purchasePriceHint': '0.00',
      'salePriceRequired': 'سعر البيع مطلوب',
      'salePriceHint': '0.00',
      'invalidPrice': 'سعر غير صحيح',
      'stockQuantityRequired': 'الكمية مطلوبة',
      'stockQuantityHint': '0',
      'invalidQuantity': 'كمية غير صحيحة',
      'stockAlertThreshold': 'حد تنبيه المخزون *',
      'stockAlertThresholdHint': '10',
      'stockAlertThresholdHelper': 'تنبيه عندما ينخفض المخزون عن هذه القيمة',
      'thresholdRequired': 'الحد مطلوب',
      'invalidThreshold': 'حد غير صحيح',
      'activeProduct': 'المنتج نشط',
      'activeProductDescription': 'المنتج مرئي ومتاح للبيع',
      'productImage': 'صورة المنتج',
      'noImageSelected': 'لم يتم اختيار صورة',
      'profitPerUnit': 'الربح لكل وحدة',
      'productDetails': 'التفاصيل',
      'productStatus': 'الحالة',
      'active': 'نشط',
      'inactive': 'غير نشط',
      'createdOn': 'تم الإنشاء في',
      'modifiedOn': 'تم التعديل في',
      'noDescription': 'لا يوجد وصف',
      'notDefined': 'غير محدد',

      // Messages de succès et d'erreur
      'productCreatedSuccess': 'تم إنشاء المنتج بنجاح',
      'productUpdatedSuccess': 'تم تحديث المنتج بنجاح',
      'saveError': 'خطأ في الحفظ',
      'saveErrorMessage': 'خطأ في الحفظ: {error}',

      // Actions rapides et autres
      'adjustStock': 'تعديل المخزون',
      'stockAdjustment': 'تعديل المخزون',
      'addStock': 'إضافة',
      'removeStock': 'إزالة',
      'setStock': 'تعيين',
      'newQuantity': 'الكمية الجديدة',
      'reason': 'السبب',
      'reasonHint': 'سبب التعديل (اختياري)',
      'userNotConnected': 'خطأ: المستخدم غير متصل',
      'existingProductDialog': 'المنتج موجود',
      'existingProductMessage': 'يوجد منتج بهذا الرمز الشريطي بالفعل. هل تريد تعديله؟',

      // Import et messages
      'productsFoundInExcel': '{count} منتج تم العثور عليه في ملف إكسل',
      'noProductsFoundInExcel': 'لم يتم العثور على منتجات في ملف إكسل',
      'errorReadingFile': 'خطأ في قراءة الملف: {error}',
      'selectCategory': 'اختر فئة',
      'supportedFileFormats': 'صيغ الملفات المدعومة',
      'acceptedFormats': '📁 الصيغ المقبولة:',
      'requiredColumns': '📋 الأعمدة المطلوبة:',
      'optionalColumns': '📋 الأعمدة الاختيارية:',
      'productNameRequiredForImport': '• name - اسم المنتج (مطلوب)',
      'barcodeColumn': '• barcode - الرمز الشريطي',
      'imageColumn': '• image - رابط الصورة',
      'descriptionColumn': '• description - الوصف',
      'purchasePriceColumn': '• purchase_price - سعر الشراء',
      'salePriceColumn': '• sale_price - سعر البيع',
      'stockColumn': '• stock - كمية المخزون',
      'unitColumn': '• unit - وحدة القياس',

      // Settings
      'theme': 'المظهر',
      'language': 'اللغة',
      'scanSound': 'صوت المسح',
      'companySettings': 'إعدادات الشركة',
      'companyName': 'اسم الشركة',
      'companyLogo': 'شعار الشركة',
      'administration': 'الإدارة',
      'globalProducts': 'المنتجات العامة',
      'userManagement': 'إدارة المستخدمين',

      // Themes
      'lightTheme': 'فاتح',
      'darkTheme': 'داكن',
      'systemTheme': 'النظام',

      // Sounds
      'classicBeep': 'صفير كلاسيكي',
      'success': 'نجاح',
      'notification': 'إشعار',
      'cashRegister': 'صندوق النقد',
      'noSound': 'بدون صوت',

      // Messages
      'chooseLanguage': 'اختر اللغة',
      'chooseTheme': 'اختر المظهر',
      'chooseScanSound': 'اختر صوت المسح',
      'testSound': 'اختبار الصوت',

      // Navigation supplémentaire
      'categories': 'الفئات',
      'home': 'الرئيسية',
      'reports': 'التقارير',
      'pos': 'نقطة البيع',

      // Dépenses
      'expenses': 'المصروفات',
      'addExpense': 'إضافة مصروف',
      'expenseType': 'نوع المصروف',
      'amount': 'المبلغ',
      'rent': 'الإيجار',
      'electricity': 'الكهرباء',
      'wifi': 'الإنترنت/واي فاي',
      'other': 'أخرى',
      'monthlyExpenses': 'المصروفات الشهرية',

      // Import/Export
      'importProducts': 'استيراد المنتجات',
      'exportData': 'تصدير البيانات',
      'selectFile': 'اختيار ملف',
      'importFromExcel': 'استيراد من إكسل',

      // Recherche avancée
      'searchByName': 'البحث بالاسم',
      'searchByBarcode': 'البحث بالرمز الشريطي',
      'searchByCategory': 'البحث بالفئة',
      'advancedSearch': 'البحث المتقدم',
      'noResults': 'لا توجد نتائج',
      'scanBarcode': 'مسح الرمز الشريطي',
      'searchProducts': 'البحث عن المنتجات',

      // Messages d'interface
      'welcome': 'مرحباً',
      'loading': 'جاري التحميل...',
      'error': 'خطأ',
      'successMessage': 'نجح',
      'retry': 'إعادة المحاولة',
      'close': 'إغلاق',
      'back': 'رجوع',
      'next': 'التالي',
      'previous': 'السابق',
      'finish': 'إنهاء',

      // Formulaires
      'required': 'مطلوب',
      'optional': 'اختياري',
      'pleaseEnter': 'يرجى إدخال',
      'invalidFormat': 'تنسيق غير صحيح',

      // Actions
      'create': 'إنشاء',
      'update': 'تحديث',
      'remove': 'إزالة',
      'duplicate': 'نسخ',
      'share': 'مشاركة',
      'print': 'طباعة',

      // Factures
      'invoice': 'الفاتورة',
      'invoiceNumber': 'رقم الفاتورة',
      'invoiceDate': 'تاريخ الفاتورة',
      'dueDate': 'تاريخ الاستحقاق',
      'subtotal': 'الإجمالي الفرعي',
      'taxAmount': 'مبلغ الضريبة',
      'discountAmount': 'مبلغ الخصم',
      'paidAmount': 'المبلغ المدفوع',
      'remainingAmount': 'المبلغ المتبقي',
      'unitPrice': 'السعر الوحدوي',
      'itemTotal': 'المجموع الكلي للصنف',
      'tvaRate': 'معدل الضريبة',
      'currency': 'العملة',

      // Support
      'support': 'الدعم',
      'contactUs': 'اتصل بنا',
      'sendMessage': 'إرسال رسالة',
      'yourEmail': 'بريدك الإلكتروني',
      'subject': 'الموضوع',
      'message': 'الرسالة',
      'contactInfo': 'معلومات الاتصال',
      'phone': 'الهاتف',
      'whatsapp': 'واتساب',
      'availability': 'التوفر',
      'responseTime': 'وقت الاستجابة',
      'supportedLanguages': 'اللغات المدعومة',
      'email': 'البريد الإلكتروني',

      // Paramètres
      'appSettings': 'إعدادات التطبيق',
      'businessSettings': 'إعدادات الشركة',
      'notifications': 'الإشعارات',
      'pushNotifications': 'الإشعارات النظامية',
      'dataBackup': 'نسخة احتياطية للبيانات',
      'aboutSupport': 'حول الدعم',
      'logout': 'تسجيل الخروج',
      'version': 'الإصدار',
      'termsOfService': 'شروط الخدمة',
      'advancedSettings': 'الإعدادات المتقدمة',
      'dataManagement': 'إدارة البيانات وإعادة التعيين',

      // Écrans et contenus
      'noDataAvailable': 'لا توجد بيانات متاحة',
      'refreshData': 'تحديث البيانات',
      'viewDetails': 'عرض التفاصيل',
      'editItem': 'تعديل العنصر',
      'deleteItem': 'حذف العنصر',
      'confirmDelete': 'تأكيد الحذف',
      'deleteConfirmation': 'هل أنت متأكد من أنك تريد حذف هذا العنصر؟',
      'yes': 'نعم',
      'no': 'لا',

      // Actions rapides et navigation
      'quickActions': 'إجراءات سريعة',
      'quickActionsSubtitle': 'الوصول السريع إلى الوظائف الرئيسية',
      'sale': 'بيع',
      'purchase': 'شراء',
      'createInvoice': 'إنشاء فاتورة',
      'manageStock': 'إدارة المخزون',
      'viewAllClients': 'عرض جميع العملاء',
      'viewAllSuppliers': 'عرض جميع الموردين',
      'addSupplier': 'إضافة مورد',
      'addClient': 'إضافة عميل',
      'addCategory': 'إضافة فئة',

      // Formulaires et champs
      'profile': 'الملف الشخصي',
      'fullName': 'الاسم الكامل',
      'businessName': 'اسم الشركة',
      'phoneNumber': 'رقم الهاتف',
      'address': 'العنوان',
      'subscriptionStatus': 'حالة الاشتراك',
      'subscriptionType': 'نوع الاشتراك',
      'subscriptionStartDate': 'تاريخ بداية الاشتراك',
      'subscriptionEndDate': 'تاريخ انتهاء الاشتراك',
      'lastPaymentDate': 'تاريخ آخر دفعة',
      'lastLoginDate': 'تاريخ آخر تسجيل دخول',
      'activeSubscription': 'اشتراك نشط',
      'expiredSubscription': 'اشتراك منتهي الصلاحية',
      'noActiveSubscription': 'لا يوجد اشتراك نشط',
      'subscriptionRemainingDays': 'يتبقى لك {days} أيام من الاشتراك',
      'subscriptionRemainingHours': 'يتبقى لك {hours} ساعات من الاشتراك',
      'subscriptionRemainingTime': 'يتبقى لك {days} أيام و {hours} ساعات من الاشتراك',
      'subscriptionExpired': 'انتهت صلاحية الاشتراك',
      'refreshSubscription': 'تحديث الاشتراك',
      'subscriptionUpdated': 'تم تحديث حالة الاشتراك!',

      // Messages et notifications
      'noSalesDataAvailable': 'لا توجد بيانات مبيعات متاحة',
      'noNotifications': 'لا توجد إشعارات',
      'ok': 'موافق',
      'warning': 'تحذير',
      'info': 'معلومات',

      // Scanner et codes-barres
      'manualBarcodeEntry': 'إدخال الرمز الشريطي يدوياً',
      'manualBarcodeEntryDescription': 'أدخل الرمز الشريطي يدوياً أدناه',
      'scanError': 'خطأ في المسح',
      'barcodeScanner': 'مسح الرمز الشريطي',
      'multipleLabelsPerPage': 'عدة ملصقات في الصفحة',
      'numberOfLabels': 'عدد الملصقات: ',

      // Images et sélection
      'takePhoto': 'التقاط صورة',
      'chooseFromGallery': 'اختيار من المعرض',
      'removeImage': 'إزالة الصورة',
      'chooseImage': 'اختيار صورة',
      'permissionRequired': 'مطلوب إذن',
      'imageSelectionError': 'خطأ في اختيار الصورة',
      'imageSelectionNotImplemented': 'اختيار الصورة غير مطبق',

      // Clients et fournisseurs
      'anonymousClient': 'عميل مجهول',
      'anonymousSupplier': 'مورد مجهول',
      'activeSupplier': 'مورد نشط',
      'activeSupplierDescription': 'يمكن للمورد استلام الطلبات',
      'supplierDetails': 'تفاصيل المورد',
      'clientDetails': 'تفاصيل العميل',

      // Factures et POS
      'tax': 'الضريبة:',
      'modifyQuantity': 'تعديل الكمية',
      'modifyPrice': 'تعديل السعر',
      'product': 'المنتج:',
      'currentPrice': 'السعر الحالي:',
      'newUnitPrice': 'السعر الوحدوي الجديد (درهم)',
      'modify': 'تعديل',
      'clearCart': 'تفريغ السلة',
      'clearCartConfirmation': 'هل أنت متأكد من أنك تريد تفريغ السلة؟',
      'clear': 'تفريغ',
      'newTransaction': 'معاملة جديدة',
      'finalizePurchase': 'إتمام الشراء',

      // POS / نقطة البيع
      'posSaleTitle': 'نقطة البيع',
      'posPurchaseTitle': 'إيصال شراء',
      'barcodeEntryHint': 'قم بمسح أو إدخال الرمز الشريطي',
      'quantityShort': 'الكمية',
      'closeScannerTooltip': 'إغلاق الماسح',
      'scannerTooltip': 'مسح',
      'clientOptionalLabel': 'العميل (اختياري)',
      'supplierLabel': 'المورّد',
      'selectSupplierError': 'يرجى اختيار مورّد أو اختيار مجهول',
      'emptyCartTitle': 'سلة فارغة',
      'emptyCartSubtitle': 'قم بمسح أو إدخال الرمز الشريطي لإضافة منتجات',
      'unitPriceLabel': 'سعر الوحدة',
      'quantityLabel': 'الكمية',
      'amountPaid': 'المبلغ المدفوع',
      'changeLabelPositive': 'الباقي',
      'changeLabelNegative': 'النقص',
      'finalizeSale': 'إتمام البيع',
      'saleSuccess': 'عملية بيع ناجحة',
      'purchaseSuccess': 'تم تسجيل الشراء',
      'invoiceTotalLabel': 'الإجمالي',
      'invoicePaidLabel': 'مدفوع',
      'invoiceChangeToReturnLabel': 'المبلغ المعاد',
      'creditAddedLabel': 'تم إضافة رصيد',
      'invoiceCreationError': 'خطأ أثناء إنشاء الفاتورة',
      'partialPaymentError': 'يرجى اختيار عميل للدفع الجزئي',
      'creditLimitExceeded': 'تجاوز حد الائتمان لهذا العميل',
      'genericErrorPrefix': 'خطأ',
      'errorLoadingSuppliers': 'خطأ أثناء تحميل الموردين',
      'productNotFound': 'المنتج غير موجود',
      'totalAmountLabel': 'المبلغ الإجمالي',
      'invoiceImageOptional': 'صورة الفاتورة (اختياري)',

      // Catégories
      'deleteCategory': 'حذف',
      'confirmDeleteCategory': 'تأكيد الحذف',
      'deleteCategoryConfirmation': 'هل أنت متأكد من أنك تريد حذف الفئة "{name}"؟',
      'categoryDeletedSuccess': 'تم حذف الفئة "{name}" بنجاح',
      'categoryDeleteError': 'خطأ في حذف الفئة',

      // Crédits
      'makePayment': 'إجراء الدفع',
      'pleaseEnterAmount': 'يرجى إدخال مبلغ',
      'invalidAmount': 'مبلغ غير صحيح',
      'amountExceedsRemaining': 'لا يمكن أن يتجاوز المبلغ المبلغ المتبقي',
      'paymentError': 'خطأ في الدفع',
      'loadHistoryError': 'خطأ في تحميل التاريخ',

      // Recherche
      'noResultsFound': 'لم يتم العثور على نتائج',

      // Paramètres avancés
      'advancedSettingsTitle': 'الإعدادات المتقدمة',
      'completeReset': 'إعادة تعيين كاملة',
      'businessDataReset': 'إعادة تعيين بيانات الأعمال',
      'completeResetDescription': 'سيؤدي هذا الإجراء إلى حذف جميع بياناتك:\n• المنتجات\n• الفواتير\n• العملاء\n• الإعدادات\n• الصور\n\nستصبح مثل مستخدم جديد.',
      'businessDataResetDescription': 'سيؤدي هذا الإجراء إلى حذف بيانات أعمالك:\n• المنتجات\n• الفواتير\n• العملاء\n• الموردين\n\nسيتم الحفاظ على إعداداتك.',
      'typeToConfirm': 'للتأكيد، اكتب بالضبط:',
      'typeHere': 'اكتب هنا...',

      // Gestion des appareils
      'authorize': 'تفويض',
      'revoke': 'إلغاء التفويض',
      'removeDevice': 'إزالة',

      // Sauvegarde Google Drive
      'googleDriveBackup': 'نسخة احتياطية من Google Drive',
      'connectToGoogleDrive': 'الاتصال بـ Google Drive',
      'disconnect': 'قطع الاتصال',
      'backup': 'نسخة احتياطية',
      'refresh': 'تحديث',
      'size': 'الحجم: {size}',
      'restore': 'استعادة',
      'confirmRestore': 'تأكيد الاستعادة',

      // Paramètres de l'entreprise
      'chooseCurrency': 'اختيار العملة',
      'moroccanDirham': 'الدرهم المغربي (درهم)',
      'euro': 'اليورو (€)',
      'usDollar': 'الدولار الأمريكي (\$)',
      'clearAllData': 'مسح جميع البيانات',
      'logoutConfirmation': 'تسجيل الخروج',
      'logoutConfirmationMessage': 'هل أنت متأكد من أنك تريد تسجيل الخروج؟',
      'exitConfirmationMessage': 'هل أنت متأكد أنك تريد الخروج من التطبيق؟',
      'chooseSound': 'اختيار الصوت',

      // Support
      'needHelp': 'تحتاج مساعدة؟',
      'ourTeamIsHere': 'فريقنا هنا لمساعدتك',
      'otherContactMethods': 'طرق الاتصال الأخرى',
      'availabilityHours': 'ساعات التوفر',
      'supportedLanguagesList': 'الفرنسية، الإنجليزية، العربية',
      'responseTimeHours': '24-48 ساعة',
      'emailAppOpened': 'تم فتح تطبيق البريد الإلكتروني بنجاح',
      'cannotOpenEmailApp': 'لا يمكن فتح تطبيق البريد الإلكتروني',
      'cannotOpenPhoneApp': 'لا يمكن فتح تطبيق الهاتف',
      'cannotOpenWhatsApp': 'لا يمكن فتح واتساب',
      'messageMinLength': 'يجب أن تحتوي الرسالة على 10 أحرف على الأقل',
      'describeYourProblem': 'صف مشكلتك أو سؤالك...',
      'subjectOfMessage': 'موضوع رسالتك',
      'sending': 'جاري الإرسال...',
      'sendMessageButton': 'إرسال الرسالة',

      // Autorisation d'appareil
      'deviceAuthorization': 'تفويض الجهاز',
      'deviceInfo': 'معلومات',
      'deviceRegisteredAutomatically': '• تم تسجيل جهازك تلقائياً',
      'adminMustAuthorize': '• يجب على المسؤول تفويضه يدوياً',
      'youWillReceiveNotification': '• ستتلقى إشعاراً بمجرد التفويض',
      'cannotAccessApp': '• في الوقت الحالي، لا يمكنك الوصول إلى التطبيق',

      // Champs manquants pour les produits
      'rupture': 'نفاد المخزون',
      'stockFaible': 'مخزون منخفض',
      'tous': 'الكل',
      'marge': 'الهامش',
      'valeur': 'القيمة',
      'piece': 'قطعة',
      'modifier': 'تعديل',
      'ruptureDeStock': 'نفاد المخزون',
      'stockSuffisant': 'مخزون كافي',
      'stockActuel': 'المخزون الحالي',
      'valeurStock': 'قيمة المخزون',
      'produitsNecessitantAttention': 'المنتجات التي تحتاج انتباه',
      'gererLesStocks': 'إدارة المخزون',
      'voirAutresProduits': 'عرض {count} منتجات أخرى',
      'stockOptimalPourTousLesProduits': 'مخزون مثالي لجميع المنتجات',
      'produitsEnStockFaible': 'منتجات في مخزون منخفض',
      'faible': 'منخفض',
      'okStatus': 'موافق',
      'min': 'الحد الأدنى',
      'ruptureLabel': 'نفاد المخزون',
      'faibleLabel': 'منخفض',
      'chargement': 'جاري التحميل...',
      'erreurDeChargement': 'خطأ في التحميل',
      'gestionDesStocks': 'إدارة المخزون',
      'alertesDeStock': 'تنبيهات المخزون',
      'produitsNecessitentAttention': 'منتجات تحتاج انتباهك',
      'stockFaibleLabel': 'مخزون منخفض',
      'produitsEnStockFaibleLabel': 'منتجات في مخزون منخفض',

      // Champs manquants pour le dashboard
      'bonjour': 'صباح الخير',
      'bonApresMidi': 'مساء الخير',
      'bonsoir': 'مساء الخير',
      'utilisateur': 'مستخدم',
      'apercuActivite': 'إليك نظرة عامة على نشاطك اليوم',
      'actionsRapides': 'إجراءات سريعة',
      'facture': 'فاتورة',
      'scanner': 'ماسح ضوئي',
      'nouvelleFacture': 'فاتورة جديدة',
      'ajouterProduit': 'إضافة منتج',
      'nouveauClient': 'عميل جديد',
      'ajouterCategorie': 'إضافة فئة',
      'nouveauFournisseur': 'مورد جديد',
      'scannerProduit': 'مسح منتج',
      'pointDeVente': 'نقطة البيع',
      'accesRapideVente': 'وصول سريع لوظائف البيع والشراء',
      'vente': 'بيع',
      'achat': 'شراء',
      'aucuneNotification': 'لا توجد إشعارات',
      'fermer': 'إغلاق',
      'revenusDuJour': 'إيرادات اليوم',
      'produits': 'المنتجات',
      // Stock alerts messages
      'needAttentionSingular': 'يحتاج إلى اهتمامك',
      'needAttentionPlural': 'يحتاجون إلى اهتمامك',
      'allProductsSufficientStock': 'جميع منتجاتك لديها مخزون كافٍ',
      'seeOtherProducts': 'عرض {count} منتج آخر',

      // ====== Invoice type selection ======
      'invoiceTypeChoiceTitle': 'اختر نوع الفاتورة',
      'invoiceTypeChoiceSubtitle': 'اختر نوع المعاملة التي تريد إجراؤها',
      'salesInvoiceTitle': 'فاتورة بيع',
      'salesInvoiceSubtitle': 'بيع منتجات للعميل',
      'purchaseVoucherTitle': 'قسيمة شراء',
      'purchaseVoucherSubtitle': 'تسجيل شراء السلع',
      'includedFeaturesLabel': 'الميزات المتضمنة',
      'featureBarcodeScanner': 'ماسح الباركود',
      'featureClientManagement': 'إدارة العملاء',
      'featureCalculateChange': 'حساب الباقي',
      'featureCreditManagement': 'إدارة الائتمان',
      'featureAutoStockUpdate': 'تحديث المخزون تلقائيًا',
      'featureSupplierManagement': 'إدارة الموردين',
      'featureAutoAddToStock': 'إضافة تلقائية إلى المخزون',
      'featureCostTracking': 'تتبع التكاليف',

      // ====== Add/Edit Supplier ======
      'addSupplierTitle': 'إضافة مورد',
      'editSupplierTitle': 'تعديل المورد',
      'supplierCompanyNameLabel': 'اسم الشركة',
      'supplierCompanyNameHint': 'مثال: شركة ABC',
      'supplierCompanyNameRequired': 'اسم الشركة مطلوب',
      'supplierContactPersonLabel': 'الشخص المسؤول',
      'supplierContactPersonHint': 'مثال: محمد علي',
      'supplierContactInfo': 'معلومات الاتصال',
      'supplierPhoneLabel': 'الهاتف',
      'supplierPhoneHint': 'مثال: 0612345678',
      'supplierEmailLabel': 'البريد الإلكتروني',
      'supplierEmailHint': 'مثال: contact@exemple.com',
      'supplierAddressLabel': 'العنوان',
      'supplierAddressHint': 'مثال: شارع 123 الرئيسي',
      'supplierCityLabel': 'المدينة',
      'supplierCityHint': 'مثال: الدار البيضاء',
      'supplierNotesOptions': 'ملاحظات وخيارات',
      'supplierNotesLabel': 'ملاحظات',
      'supplierNotesHint': 'ملاحظات داخلية عن المورد...',
      'supplierActiveLabel': 'المورد نشط',
      'supplierActiveHelper': 'يمكن اختيار المورد في الطلبات',
      'supplierCreatedSuccess': 'تم إنشاء المورد بنجاح',
      'supplierUpdatedSuccess': 'تم تحديث بيانات المورد بنجاح',
      'supplierSaveError': 'حدث خطأ أثناء حفظ المورد',
      // ======== شاشات التصنيفات ========
      'categoriesSearchHint': 'البحث عن فئة...',
      'categoriesTotal': 'الإجمالي',
      'categoriesActive': 'النشطة',
      'categoriesProducts': 'المنتجات',
      'categoriesEmptyTitle': 'لا توجد فئة',
      'categoriesEmptySubtitle': 'أنشئ أول فئة لتنظيم منتجاتك',
      'createCategory': 'إنشاء فئة',
      'editCategory': 'تعديل الفئة',
      'addCategoryTitle': 'إضافة فئة',
      'categoryPreview': 'معاينة',
      'categoryNameLabel': 'اسم الفئة *',
      'categoryNameHint': 'مثال: إلكترونيات، ملابس...',
      'categoryNameRequired': 'الاسم مطلوب',
      'categoryDescriptionHint': 'وصف الفئة (اختياري)',
      'categoryImagePlaceholder': 'صورة الفئة',
      'categoryColor': 'لون الفئة',
      'options': 'خيارات',
      'categoryActive': 'فئة نشطة',
      'categoryActiveHelper': 'الفئة مرئية وقابلة للاستخدام',
      'categoryCreatedSuccess': 'تم إنشاء الفئة بنجاح',
      'categoryUpdatedSuccess': 'تم تعديل الفئة بنجاح',
      'categoryImageUploadError': 'تم إنشاء الفئة ولكن حدث خطأ في رفع الصورة: {error}',

      // ======== شاشات العملاء ========
      'clientsSearchHint': 'البحث بالاسم أو الهاتف أو البريد الإلكتروني...',
      'filterAllClients': 'الكل',
      'filterPositiveCredit': 'رصيد إيجابي',
      'filterNegativeCredit': 'رصيد سلبي',
      'filterActiveClients': 'النشطون',
      'sortByName': 'الاسم',
      'sortByCredit': 'الرصيد',
      'sortByLastPurchase': 'آخر عملية شراء',
      'clientsTotalLabel': 'الإجمالي',
      'clientsPositiveCreditShort': 'رصيد +',
      'clientsNegativeCreditShort': 'رصيد -',
      'totalCreditLabel': 'إجمالي الرصيد',
      'clientsEmptyTitle': 'لا يوجد عملاء',
      'clientsEmptySubtitle': 'ابدأ بإضافة أول عميل',
      'editClient': 'تعديل العميل',
      'addClientTitle': 'إضافة عميل',
      'clientPreview': 'معاينة العميل',
      'creditLabel': 'الرصيد:',
      'totalPurchasesLabel': 'إجمالي المشتريات:',
      'personalInfo': 'المعلومات الشخصية',
      'clientNameLabel': 'الاسم الكامل *',
      'clientNameHint': 'مثال: أحمد بن علي',
      'clientNameRequired': 'الاسم مطلوب',
      'phoneLabel': 'الهاتف',
      'phoneHint': '+212 6 12 34 56 78',
      'emailLabel': 'البريد الإلكتروني',
      'emailHint': 'client@example.com',
      'invalidEmail': 'بريد إلكتروني غير صالح',
      'addressLabel': 'العنوان',
      'addressHint': 'الشارع، الحي...',
      'cityLabel': 'المدينة',
      'cityHint': 'الدار البيضاء، الرباط...',
      'creditAndLimits': 'الرصيد والحدود',
      'creditLimitLabel': 'حد الرصيد',
      'creditLimitHint': '0.00',
      'creditLimitHelper': 'الحد الأقصى للرصيد الذي يمكن أن يمتلكه العميل',
      'creditLimitRequired': 'حد الرصيد مطلوب',
      'currentCreditLabel': 'الرصيد الحالي:',
      'notesOptions': 'ملاحظات وخيارات',
      'notesLabel': 'ملاحظات',
      'notesHint': 'ملاحظات داخلية حول العميل...',
      'clientActive': 'عميل نشط',
      'clientActiveHelper': 'يمكن للعميل إجراء عمليات شراء',
      'clientCreatedSuccess': 'تم إنشاء العميل بنجاح',
      'clientUpdatedSuccess': 'تم تعديل العميل بنجاح',

      // ======== شاشات الأرصدة ========
      'clientsWithCreditsTitle': 'العملاء ذوو أرصدة',
      'loadingCredits': 'جارٍ تحميل الأرصدة...',
      'creditsSummary': 'ملخص الأرصدة',
      'clientsLabel': 'العملاء',
      'creditsLabel': 'الأرصدة',
      'totalAmount': 'إجمالي المبلغ',
      'noCreditsTitle': 'لا توجد أرصدة',
      'noCreditsSubtitle': 'لا يوجد عميل لديه رصيد قيد التنفيذ',
      'overdueLabel': 'متأخر',
      'creditsCountLabel': 'الأرصدة',
      // 'totalAmountLabel': 'إجمالي المبلغ', // duplicate removed, defined earlier

      // ======== شاشات الفواتير ========
      'invoicesSearchHint': 'البحث حسب الرقم أو العميل...',
      'filterAllInvoices': 'الكل',
      'filterDraft': 'مسودة',
      'filterSent': 'مرسلة',
      'filterPaid': 'مدفوعة',
      'filterOverdue': 'متأخرة',
      'sortByDate': 'التاريخ',
      'sortByAmount': 'المبلغ',
      'sortByClient': 'العميل',
      'sortByStatus': 'الحالة',
      'pending': 'قيد الانتظار',
      'paid': 'مدفوعة',
      'newInvoice': 'فاتورة جديدة',
      'invoicesEmptyTitle': 'لا توجد فواتير',
      'invoicesEmptySubtitle': 'أنشئ فاتورتك الأولى للبدء',
      // ======== شاشات الموردين ========
      'suppliersSearchHint': 'البحث عن مورد...',
      'suppliersTotalLabel': 'الإجمالي',
      'suppliersActiveLabel': 'نشط',
      'suppliersProductsLabel': 'منتجات',
      'suppliersEmptyTitle': 'لا يوجد موردون',
      'suppliersEmptySubtitle': 'ابدأ بإضافة أول مورد لك',
      // 'addSupplier': 'إضافة مورد', // duplicate removed, defined earlier
          'standardPdf': 'PDF Standard',
          'thermalPdf': 'PDF Thermique',
          'invoiceCustomizationTitle': 'تخصيص الفاتورة',
          'chooseLogo': 'اختر شعارًا',
          'companyNameLabel': 'اسم الشركة',
          'primaryColorLabel': 'اللون الأساسي',
          'secondaryColorLabel': 'اللون الثانوي',
          'fontSizeLabel': 'حجم الخط',
          'showLogo': 'إظهار الشعار',
          'showCompanyInfo': 'عرض معلومات الشركة',
          'showHeader': 'إظهار الرأس',
          'showFooter': 'إظهار التذييل',
          'headerTextLabel': 'نص الرأس',
          'headerTextHint': 'نص سيظهر أعلى الفاتورة',
          'footerTextLabel': 'نص التذييل',
          'footerTextHint': 'نص سيظهر أسفل الفاتورة',
          'reset': 'إعادة تعيين',
          'invoiceCustomizationSaved': 'تم حفظ التخصيص بنجاح',
          'invoiceCustomizationReset': 'تمت إعادة تعيين التخصيص',
          'pleaseCheckInput': 'يرجى التحقق من المعلومات المدخلة',
          'customizePdf': 'تخصيص PDF',
          'itemLabel': 'الصنف',
          'clientHeader': 'العميل',
          'pdfPreview': 'معاينة PDF',
          'companyInfoSectionTitle': 'معلومات الشركة',
          'chooseLogoShort': 'اختر الشعار',
          'appearanceSectionTitle': 'المظهر',
          'headerFooterSectionTitle': 'الرأس والتذييل',
          'showCustomHeader': 'إظهار رأس مخصص',
          'showCustomFooter': 'إظهار تذييل مخصص',
          'websiteLabel': 'الموقع الإلكتروني',
          'logoPickError': 'حدث خطأ أثناء اختيار الشعار: {error}',
          'displayOptionsSectionTitle': 'خيارات العرض',
          'logoAndCompanyInfoTitle': 'شعار الشركة ومعلومات الشركة',
          'colorsAndStyleTitle': 'الألوان والنمط',
          'currencyName': 'Currency',
      'summary': 'ملخص',
      'paymentInfo': 'معلومات الدفع',
      'notes': 'ملاحظات',
      'invoiceImage': 'صورة الفاتورة',
      'shareInvoice': 'مشاركة الفاتورة',
      'sendByEmail': 'إرسال عبر البريد الإلكتروني',
      'pdfStandard': 'PDF قياسي',
      'pdfThermal': 'PDF حراري',
      'thankYou': 'شكراً لزيارتكم!',
      'salesInvoice': 'فاتورة بيع',
      'purchaseVoucher': 'سند شراء',
      'billedTo': 'المفوّت إليه:',
      'supplier': 'المورّد:',
      'article': 'الصنف',
      'qtyShort': 'الكمية',
      'unitPriceShort': 'سعر.و',
      'totalShort': 'الإجمالي',
      'pdfSubtotal': 'الإجمالي الفرعي:',
      'pdfDiscount': 'الخصم:',
      'pdfTax': 'الضريبة:',
      'pdfTotal': 'الإجمالي:',
      'pdfPaid': 'المدفوع:',
      'pdfRemaining': 'المتبقي:',
      'pdfDate': 'التاريخ',
      'pdfDueDate': 'الاستحقاق',
      'pdfInvoiceNumber': 'رقم',
      'pdfItem': 'الصنف',
      'pdfQty': 'كمية',
      'pdfUnitPrice': 'سعر.و',
      'pdfTotalCol': 'الإجمالي',
      'pdfThankYou': 'شكراً لزيارتكم!',
      'pdfInvoice': 'فاتورة بيع',
      'pdfVoucher': 'سند شراء',
      'pdfBilledTo': 'المفوّت إليه:',
      'pdfSupplier': 'المورّد:',
      'pdfNotes': 'ملاحظات',
      'pdfPaymentInfo': 'معلومات الدفع',
      'pdfImage': 'صورة الفاتورة',
      'pdfShare': 'مشاركة',
      'pdfSendByEmail': 'إرسال بريد',
      'pdfCancel': 'إلغاء',
      'itemTotalLabel': 'Item Total',
      'tvaRateLabel': 'TVA Rate',
},
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['fr', 'en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
