class InvoiceCustomizationModel {
  final String id;
  final String userId;
  final String companyName;
  final String? companyAddress;
  final String? companyPhone;
  final String? companyEmail;
  final String? companyWebsite;
  final String? logoPath;
  final String? headerText;
  final String? footerText;
  final bool showLogo;
  final bool showCompanyInfo;
  final bool showHeader;
  final bool showFooter;
  final String primaryColor;
  final String secondaryColor;
  final String fontFamily;
  final double fontSize;
  final DateTime createdAt;
  final DateTime updatedAt;

  InvoiceCustomizationModel({
    required this.id,
    required this.userId,
    required this.companyName,
    this.companyAddress,
    this.companyPhone,
    this.companyEmail,
    this.companyWebsite,
    this.logoPath,
    this.headerText,
    this.footerText,
    this.showLogo = true,
    this.showCompanyInfo = true,
    this.showHeader = false,
    this.showFooter = false,
    this.primaryColor = '#2196F3',
    this.secondaryColor = '#FFC107',
    this.fontFamily = 'Helvetica',
    this.fontSize = 12.0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InvoiceCustomizationModel.fromJson(Map<String, dynamic> json) {
    return InvoiceCustomizationModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      companyName: json['company_name']?.toString() ?? '',
      companyAddress: json['company_address']?.toString(),
      companyPhone: json['company_phone']?.toString(),
      companyEmail: json['company_email']?.toString(),
      companyWebsite: json['company_website']?.toString(),
      logoPath: json['logo_path']?.toString(),
      headerText: json['header_text']?.toString(),
      footerText: json['footer_text']?.toString(),
      showLogo: json['show_logo'] == true,
      showCompanyInfo: json['show_company_info'] == true,
      showHeader: json['show_header'] == true,
      showFooter: json['show_footer'] == true,
      primaryColor: json['primary_color']?.toString() ?? '#2196F3',
      secondaryColor: json['secondary_color']?.toString() ?? '#FFC107',
      fontFamily: json['font_family']?.toString() ?? 'Helvetica',
      fontSize: (json['font_size'] as num?)?.toDouble() ?? 12.0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'company_name': companyName,
      'company_address': companyAddress,
      'company_phone': companyPhone,
      'company_email': companyEmail,
      'company_website': companyWebsite,
      'logo_path': logoPath,
      'header_text': headerText,
      'footer_text': footerText,
      'show_logo': showLogo,
      'show_company_info': showCompanyInfo,
      'show_header': showHeader,
      'show_footer': showFooter,
      'primary_color': primaryColor,
      'secondary_color': secondaryColor,
      'font_family': fontFamily,
      'font_size': fontSize,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  InvoiceCustomizationModel copyWith({
    String? id,
    String? userId,
    String? companyName,
    String? companyAddress,
    String? companyPhone,
    String? companyEmail,
    String? companyWebsite,
    String? logoPath,
    String? headerText,
    String? footerText,
    bool? showLogo,
    bool? showCompanyInfo,
    bool? showHeader,
    bool? showFooter,
    String? primaryColor,
    String? secondaryColor,
    String? fontFamily,
    double? fontSize,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvoiceCustomizationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      companyName: companyName ?? this.companyName,
      companyAddress: companyAddress ?? this.companyAddress,
      companyPhone: companyPhone ?? this.companyPhone,
      companyEmail: companyEmail ?? this.companyEmail,
      companyWebsite: companyWebsite ?? this.companyWebsite,
      logoPath: logoPath ?? this.logoPath,
      headerText: headerText ?? this.headerText,
      footerText: footerText ?? this.footerText,
      showLogo: showLogo ?? this.showLogo,
      showCompanyInfo: showCompanyInfo ?? this.showCompanyInfo,
      showHeader: showHeader ?? this.showHeader,
      showFooter: showFooter ?? this.showFooter,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Méthode pour créer une configuration par défaut
  static InvoiceCustomizationModel createDefault(String userId) {
    final now = DateTime.now();
    return InvoiceCustomizationModel(
      id: now.millisecondsSinceEpoch.toString(),
      userId: userId,
      companyName: 'Mon Entreprise',
      companyAddress: 'Adresse de l\'entreprise',
      companyPhone: '+212 6XX XXX XXX',
      companyEmail: 'contact@monentreprise.ma',
      companyWebsite: 'www.monentreprise.ma',
      headerText: 'Merci de votre confiance',
      footerText: 'Conditions de paiement: 30 jours',
      createdAt: now,
      updatedAt: now,
    );
  }
}