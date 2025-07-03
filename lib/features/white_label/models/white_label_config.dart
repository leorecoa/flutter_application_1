import 'package:flutter/material.dart';
import '../../../core/theme/segments/business_segment.dart';

/// Configuração de white label para personalização da interface
class WhiteLabelConfig {
  /// Nome da empresa
  final String companyName;

  /// Logotipo da empresa (URL)
  final String? logoUrl;

  /// Cor primária da marca
  final Color primaryColor;

  /// Cor secundária da marca
  final Color? secondaryColor;

  /// Cor de fundo da interface
  final Color? backgroundColor;

  /// Família de fonte principal
  final String? fontFamily;

  /// Raio de borda para elementos da interface
  final double? borderRadius;

  /// Segmento de negócio
  final BusinessSegment segment;

  /// Texto de boas-vindas personalizado
  final String? welcomeText;

  /// URL do favicon
  final String? faviconUrl;

  /// Domínio personalizado
  final String? customDomain;

  /// Termos de serviço personalizados
  final String? termsOfServiceUrl;

  /// Política de privacidade personalizada
  final String? privacyPolicyUrl;

  /// Informações de contato de suporte
  final String? supportEmail;

  /// Número de telefone de suporte
  final String? supportPhone;

  /// Redes sociais
  final Map<String, String>? socialMedia;

  /// Imagens personalizadas para a interface
  final Map<String, String>? customImages;

  /// Textos personalizados para a interface
  final Map<String, String>? customTexts;

  WhiteLabelConfig({
    required this.companyName,
    this.logoUrl,
    required this.primaryColor,
    this.secondaryColor,
    this.backgroundColor,
    this.fontFamily,
    this.borderRadius,
    required this.segment,
    this.welcomeText,
    this.faviconUrl,
    this.customDomain,
    this.termsOfServiceUrl,
    this.privacyPolicyUrl,
    this.supportEmail,
    this.supportPhone,
    this.socialMedia,
    this.customImages,
    this.customTexts,
  });

  /// Cria uma configuração a partir de um mapa JSON
  factory WhiteLabelConfig.fromJson(Map<String, dynamic> json) {
    return WhiteLabelConfig(
      companyName: json['companyName'] ?? 'AgendaFácil',
      logoUrl: json['logoUrl'],
      primaryColor:
          _colorFromHex(json['primaryColor']) ?? const Color(0xFF2196F3),
      secondaryColor: _colorFromHex(json['secondaryColor']),
      backgroundColor: _colorFromHex(json['backgroundColor']),
      fontFamily: json['fontFamily'],
      borderRadius: json['borderRadius']?.toDouble(),
      segment: _segmentFromString(json['segment']),
      welcomeText: json['welcomeText'],
      faviconUrl: json['faviconUrl'],
      customDomain: json['customDomain'],
      termsOfServiceUrl: json['termsOfServiceUrl'],
      privacyPolicyUrl: json['privacyPolicyUrl'],
      supportEmail: json['supportEmail'],
      supportPhone: json['supportPhone'],
      socialMedia: json['socialMedia'] != null
          ? Map<String, String>.from(json['socialMedia'])
          : null,
      customImages: json['customImages'] != null
          ? Map<String, String>.from(json['customImages'])
          : null,
      customTexts: json['customTexts'] != null
          ? Map<String, String>.from(json['customTexts'])
          : null,
    );
  }

  /// Converte a configuração para um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'logoUrl': logoUrl,
      'primaryColor': _colorToHex(primaryColor),
      'secondaryColor':
          secondaryColor != null ? _colorToHex(secondaryColor!) : null,
      'backgroundColor':
          backgroundColor != null ? _colorToHex(backgroundColor!) : null,
      'fontFamily': fontFamily,
      'borderRadius': borderRadius,
      'segment': segment.name,
      'welcomeText': welcomeText,
      'faviconUrl': faviconUrl,
      'customDomain': customDomain,
      'termsOfServiceUrl': termsOfServiceUrl,
      'privacyPolicyUrl': privacyPolicyUrl,
      'supportEmail': supportEmail,
      'supportPhone': supportPhone,
      'socialMedia': socialMedia,
      'customImages': customImages,
      'customTexts': customTexts,
    };
  }

  /// Converte uma string hexadecimal para Color
  static Color? _colorFromHex(String? hexString) {
    if (hexString == null) return null;

    final hexColor = hexString.replaceAll('#', '');
    if (hexColor.length == 6) {
      return Color(int.parse('FF$hexColor', radix: 16));
    } else if (hexColor.length == 8) {
      return Color(int.parse(hexColor, radix: 16));
    }
    return null;
  }

  /// Converte um Color para string hexadecimal
  static String _colorToHex(Color color) {
    // ignore: deprecated_member_use
    return '#${color.red.toRadixString(16).padLeft(2, '0')}${color.green.toRadixString(16).padLeft(2, '0')}${color.blue.toRadixString(16).padLeft(2, '0')}';
  }

  /// Converte uma string para BusinessSegment
  static BusinessSegment _segmentFromString(String? segment) {
    if (segment == null) return BusinessSegment.generic;

    try {
      return BusinessSegment.values.firstWhere(
        (e) => e.name == segment,
        orElse: () => BusinessSegment.generic,
      );
    } catch (_) {
      return BusinessSegment.generic;
    }
  }

  /// Cria uma cópia da configuração com alguns valores alterados
  WhiteLabelConfig copyWith({
    String? companyName,
    String? logoUrl,
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    String? fontFamily,
    double? borderRadius,
    BusinessSegment? segment,
    String? welcomeText,
    String? faviconUrl,
    String? customDomain,
    String? termsOfServiceUrl,
    String? privacyPolicyUrl,
    String? supportEmail,
    String? supportPhone,
    Map<String, String>? socialMedia,
    Map<String, String>? customImages,
    Map<String, String>? customTexts,
  }) {
    return WhiteLabelConfig(
      companyName: companyName ?? this.companyName,
      logoUrl: logoUrl ?? this.logoUrl,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      fontFamily: fontFamily ?? this.fontFamily,
      borderRadius: borderRadius ?? this.borderRadius,
      segment: segment ?? this.segment,
      welcomeText: welcomeText ?? this.welcomeText,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      customDomain: customDomain ?? this.customDomain,
      termsOfServiceUrl: termsOfServiceUrl ?? this.termsOfServiceUrl,
      privacyPolicyUrl: privacyPolicyUrl ?? this.privacyPolicyUrl,
      supportEmail: supportEmail ?? this.supportEmail,
      supportPhone: supportPhone ?? this.supportPhone,
      socialMedia: socialMedia ?? this.socialMedia,
      customImages: customImages ?? this.customImages,
      customTexts: customTexts ?? this.customTexts,
    );
  }
}
