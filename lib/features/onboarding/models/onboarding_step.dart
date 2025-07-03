/// Modelo para etapas do onboarding
class OnboardingStep {
  /// Identificador único da etapa
  final String id;
  
  /// Título da etapa
  final String title;
  
  /// Descrição da etapa
  final String description;
  
  /// Tipo de etapa
  final OnboardingStepType type;
  
  /// Ordem da etapa no fluxo
  final int order;
  
  /// Dados adicionais específicos do tipo de etapa
  final Map<String, dynamic>? data;
  
  /// Indica se a etapa é obrigatória
  final bool isRequired;
  
  /// Indica se a etapa foi concluída
  final bool isCompleted;
  
  OnboardingStep({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.order,
    this.data,
    this.isRequired = true,
    this.isCompleted = false,
  });
  
  /// Cria uma etapa a partir de um mapa JSON
  factory OnboardingStep.fromJson(Map<String, dynamic> json) {
    return OnboardingStep(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: OnboardingStepType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => OnboardingStepType.info,
      ),
      order: json['order'],
      data: json['data'],
      isRequired: json['isRequired'] ?? true,
      isCompleted: json['isCompleted'] ?? false,
    );
  }
  
  /// Converte a etapa para um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'order': order,
      'data': data,
      'isRequired': isRequired,
      'isCompleted': isCompleted,
    };
  }
  
  /// Cria uma cópia da etapa com alguns valores alterados
  OnboardingStep copyWith({
    String? id,
    String? title,
    String? description,
    OnboardingStepType? type,
    int? order,
    Map<String, dynamic>? data,
    bool? isRequired,
    bool? isCompleted,
  }) {
    return OnboardingStep(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      order: order ?? this.order,
      data: data ?? this.data,
      isRequired: isRequired ?? this.isRequired,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// Tipos de etapas de onboarding
enum OnboardingStepType {
  /// Etapa informativa
  info,
  
  /// Etapa de configuração de perfil
  profile,
  
  /// Etapa de configuração de negócio
  business,
  
  /// Etapa de configuração de serviços
  services,
  
  /// Etapa de configuração de horários
  schedule,
  
  /// Etapa de configuração de pagamentos
  payment,
  
  /// Etapa de configuração de notificações
  notifications,
  
  /// Etapa de configuração de integrações
  integrations,
  
  /// Etapa de convite de equipe
  team,
  
  /// Etapa de personalização de interface
  customization,
}