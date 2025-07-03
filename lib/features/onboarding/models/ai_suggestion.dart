/// Modelo para sugestões de IA durante o onboarding
class AiSuggestion {
  /// Identificador único da sugestão
  final String id;
  
  /// Título da sugestão
  final String title;
  
  /// Descrição da sugestão
  final String description;
  
  /// Tipo de sugestão
  final AiSuggestionType type;
  
  /// Dados específicos da sugestão
  final Map<String, dynamic> data;
  
  /// Confiança da IA na sugestão (0-100)
  final int confidence;
  
  /// Indica se a sugestão foi aceita pelo usuário
  final bool isAccepted;
  
  /// Indica se a sugestão foi rejeitada pelo usuário
  final bool isRejected;
  
  AiSuggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.data,
    required this.confidence,
    this.isAccepted = false,
    this.isRejected = false,
  });
  
  /// Cria uma sugestão a partir de um mapa JSON
  factory AiSuggestion.fromJson(Map<String, dynamic> json) {
    return AiSuggestion(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: AiSuggestionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AiSuggestionType.general,
      ),
      data: Map<String, dynamic>.from(json['data']),
      confidence: json['confidence'],
      isAccepted: json['isAccepted'] ?? false,
      isRejected: json['isRejected'] ?? false,
    );
  }
  
  /// Converte a sugestão para um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'data': data,
      'confidence': confidence,
      'isAccepted': isAccepted,
      'isRejected': isRejected,
    };
  }
  
  /// Cria uma cópia da sugestão com alguns valores alterados
  AiSuggestion copyWith({
    String? id,
    String? title,
    String? description,
    AiSuggestionType? type,
    Map<String, dynamic>? data,
    int? confidence,
    bool? isAccepted,
    bool? isRejected,
  }) {
    return AiSuggestion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      data: data ?? this.data,
      confidence: confidence ?? this.confidence,
      isAccepted: isAccepted ?? this.isAccepted,
      isRejected: isRejected ?? this.isRejected,
    );
  }
  
  /// Marca a sugestão como aceita
  AiSuggestion accept() {
    return copyWith(isAccepted: true, isRejected: false);
  }
  
  /// Marca a sugestão como rejeitada
  AiSuggestion reject() {
    return copyWith(isAccepted: false, isRejected: true);
  }
}

/// Tipos de sugestões de IA
enum AiSuggestionType {
  /// Sugestão geral
  general,
  
  /// Sugestão de serviço
  service,
  
  /// Sugestão de horário
  schedule,
  
  /// Sugestão de preço
  price,
  
  /// Sugestão de configuração
  setting,
  
  /// Sugestão de marketing
  marketing,
  
  /// Sugestão de integração
  integration,
  
  /// Sugestão de personalização
  customization,
}