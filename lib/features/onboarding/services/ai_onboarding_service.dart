import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/segments/business_segment.dart';
import '../models/ai_suggestion.dart';
import '../models/onboarding_step.dart';

/// Serviço para onboarding assistido por IA
class AiOnboardingService {
  static String get _baseUrl => '${AppConfig.apiBaseUrl}/onboarding/ai';
  static const _uuid = Uuid();

  /// Gera um plano de onboarding personalizado com base nas informações do negócio
  static Future<List<OnboardingStep>> generateOnboardingPlan({
    required String tenantId,
    required String businessName,
    required BusinessSegment segment,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/plan'),
        headers: {
          'Content-Type': 'application/json',
          // Adicionar token de autenticação quando disponível
        },
        body: json.encode({
          'tenantId': tenantId,
          'businessName': businessName,
          'segment': segment.name,
          'additionalInfo': additionalInfo,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => OnboardingStep.fromJson(item)).toList();
      } else {
        throw Exception(
            'Falha ao gerar plano de onboarding: ${response.statusCode}');
      }
    } catch (e) {
      // Em caso de erro, retorna um plano padrão
      return _getDefaultOnboardingPlan(segment);
    }
  }

  /// Gera sugestões de IA para uma etapa específica do onboarding
  static Future<List<AiSuggestion>> generateSuggestions({
    required String tenantId,
    required OnboardingStep step,
    required BusinessSegment segment,
    Map<String, dynamic>? context,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/suggestions'),
        headers: {
          'Content-Type': 'application/json',
          // Adicionar token de autenticação quando disponível
        },
        body: json.encode({
          'tenantId': tenantId,
          'stepId': step.id,
          'stepType': step.type.name,
          'segment': segment.name,
          'context': context,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => AiSuggestion.fromJson(item)).toList();
      } else {
        throw Exception('Falha ao gerar sugestões: ${response.statusCode}');
      }
    } catch (e) {
      // Em caso de erro, retorna sugestões simuladas
      return _getMockSuggestions(step, segment);
    }
  }

  /// Registra feedback sobre uma sugestão de IA
  static Future<void> recordSuggestionFeedback({
    required String tenantId,
    required String suggestionId,
    required bool accepted,
    String? feedback,
  }) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/feedback'),
        headers: {
          'Content-Type': 'application/json',
          // Adicionar token de autenticação quando disponível
        },
        body: json.encode({
          'tenantId': tenantId,
          'suggestionId': suggestionId,
          'accepted': accepted,
          'feedback': feedback,
        }),
      );
    } catch (e) {
      // Ignora erros no registro de feedback
    }
  }

  /// Analisa o negócio e fornece insights
  static Future<Map<String, dynamic>> analyzeBusinessProfile({
    required String tenantId,
    required String businessName,
    required BusinessSegment segment,
    required String description,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/analyze'),
        headers: {
          'Content-Type': 'application/json',
          // Adicionar token de autenticação quando disponível
        },
        body: json.encode({
          'tenantId': tenantId,
          'businessName': businessName,
          'segment': segment.name,
          'description': description,
          'additionalData': additionalData,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Falha ao analisar perfil: ${response.statusCode}');
      }
    } catch (e) {
      // Em caso de erro, retorna insights simulados
      return _getMockBusinessInsights(segment);
    }
  }

  /// Gera um plano de onboarding padrão para o segmento
  static List<OnboardingStep> _getDefaultOnboardingPlan(
      BusinessSegment segment) {
    final steps = <OnboardingStep>[
      OnboardingStep(
        id: _uuid.v4(),
        title: 'Bem-vindo ao AgendaFácil',
        description: 'Vamos configurar seu negócio em poucos passos.',
        type: OnboardingStepType.info,
        order: 1,
      ),
      OnboardingStep(
        id: _uuid.v4(),
        title: 'Perfil da Empresa',
        description: 'Configure as informações básicas do seu negócio.',
        type: OnboardingStepType.business,
        order: 2,
      ),
      OnboardingStep(
        id: _uuid.v4(),
        title: 'Serviços',
        description: 'Adicione os serviços que você oferece.',
        type: OnboardingStepType.services,
        order: 3,
      ),
      OnboardingStep(
        id: _uuid.v4(),
        title: 'Horários',
        description: 'Configure sua disponibilidade para agendamentos.',
        type: OnboardingStepType.schedule,
        order: 4,
      ),
    ];

    // Adiciona etapas específicas para cada segmento
    switch (segment) {
      case BusinessSegment.salon:
        steps.add(OnboardingStep(
          id: _uuid.v4(),
          title: 'Profissionais',
          description: 'Adicione os profissionais do seu salão.',
          type: OnboardingStepType.team,
          order: 5,
        ));
        break;
      case BusinessSegment.clinic:
        steps.add(OnboardingStep(
          id: _uuid.v4(),
          title: 'Especialidades',
          description: 'Configure as especialidades da sua clínica.',
          type: OnboardingStepType.services,
          order: 5,
        ));
        break;
      case BusinessSegment.spa:
        steps.add(OnboardingStep(
          id: _uuid.v4(),
          title: 'Pacotes',
          description: 'Configure pacotes de serviços para seu spa.',
          type: OnboardingStepType.services,
          order: 5,
        ));
        break;
      default:
        break;
    }

    // Adiciona etapas finais comuns a todos os segmentos
    steps.add(OnboardingStep(
      id: _uuid.v4(),
      title: 'Pagamentos',
      description: 'Configure as formas de pagamento aceitas.',
      type: OnboardingStepType.payment,
      order: steps.length + 1,
    ));

    steps.add(OnboardingStep(
      id: _uuid.v4(),
      title: 'Personalização',
      description: 'Personalize a aparência do seu aplicativo.',
      type: OnboardingStepType.customization,
      order: steps.length + 1,
    ));

    return steps;
  }

  /// Gera sugestões simuladas para uma etapa
  static List<AiSuggestion> _getMockSuggestions(
      OnboardingStep step, BusinessSegment segment) {
    final suggestions = <AiSuggestion>[];

    switch (step.type) {
      case OnboardingStepType.services:
        if (segment == BusinessSegment.salon) {
          suggestions.addAll([
            AiSuggestion(
              id: _uuid.v4(),
              title: 'Adicionar serviços populares',
              description:
                  'Adicione os serviços mais comuns para salões de beleza.',
              type: AiSuggestionType.service,
              data: {
                'services': [
                  {'name': 'Corte de Cabelo', 'duration': 30, 'price': 50.0},
                  {'name': 'Coloração', 'duration': 120, 'price': 150.0},
                  {'name': 'Manicure', 'duration': 45, 'price': 35.0},
                  {'name': 'Pedicure', 'duration': 45, 'price': 40.0},
                  {
                    'name': 'Design de Sobrancelhas',
                    'duration': 20,
                    'price': 30.0
                  },
                ],
              },
              confidence: 90,
            ),
            AiSuggestion(
              id: _uuid.v4(),
              title: 'Configurar pacotes promocionais',
              description:
                  'Crie pacotes combinando serviços populares com desconto.',
              type: AiSuggestionType.service,
              data: {
                'packages': [
                  {
                    'name': 'Dia da Noiva',
                    'services': [
                      'Corte de Cabelo',
                      'Coloração',
                      'Manicure',
                      'Pedicure',
                      'Maquiagem'
                    ],
                    'discount': 15,
                  },
                  {
                    'name': 'Pacote Básico',
                    'services': ['Corte de Cabelo', 'Manicure'],
                    'discount': 10,
                  },
                ],
              },
              confidence: 85,
            ),
          ]);
        } else if (segment == BusinessSegment.clinic) {
          suggestions.add(
            AiSuggestion(
              id: _uuid.v4(),
              title: 'Adicionar consultas por especialidade',
              description:
                  'Configure consultas para diferentes especialidades médicas.',
              type: AiSuggestionType.service,
              data: {
                'services': [
                  {
                    'name': 'Consulta Clínica Geral',
                    'duration': 30,
                    'price': 150.0
                  },
                  {
                    'name': 'Consulta Dermatologia',
                    'duration': 30,
                    'price': 200.0
                  },
                  {'name': 'Consulta Nutrição', 'duration': 45, 'price': 180.0},
                  {
                    'name': 'Consulta Psicologia',
                    'duration': 60,
                    'price': 200.0
                  },
                ],
              },
              confidence: 90,
            ),
          );
        }
        break;

      case OnboardingStepType.schedule:
        suggestions.add(
          AiSuggestion(
            id: _uuid.v4(),
            title: 'Configurar horário comercial padrão',
            description:
                'Configure o horário de funcionamento típico para seu segmento.',
            type: AiSuggestionType.schedule,
            data: {
              'schedule': [
                {'day': 'monday', 'start': '09:00', 'end': '18:00'},
                {'day': 'tuesday', 'start': '09:00', 'end': '18:00'},
                {'day': 'wednesday', 'start': '09:00', 'end': '18:00'},
                {'day': 'thursday', 'start': '09:00', 'end': '18:00'},
                {'day': 'friday', 'start': '09:00', 'end': '18:00'},
                {'day': 'saturday', 'start': '09:00', 'end': '13:00'},
                {'day': 'sunday', 'start': null, 'end': null},
              ],
            },
            confidence: 85,
          ),
        );
        break;

      case OnboardingStepType.customization:
        suggestions.add(
          AiSuggestion(
            id: _uuid.v4(),
            title: 'Aplicar tema personalizado',
            description:
                'Aplique um tema visual otimizado para o seu segmento.',
            type: AiSuggestionType.customization,
            data: {
              'theme': {
                // ignore: deprecated_member_use
                'primaryColor':
                    // ignore: deprecated_member_use
                    '#${segment.primaryColor.red.toRadixString(16).padLeft(2, '0')}${segment.primaryColor.green.toRadixString(16).padLeft(2, '0')}${segment.primaryColor.blue.toRadixString(16).padLeft(2, '0')}',
                // ignore: deprecated_member_use
                'secondaryColor':
                    // ignore: deprecated_member_use
                    '#${segment.secondaryColor.red.toRadixString(16).padLeft(2, '0')}${segment.secondaryColor.green.toRadixString(16).padLeft(2, '0')}${segment.secondaryColor.blue.toRadixString(16).padLeft(2, '0')}',
                'borderRadius': segment.borderRadius,
                'fontFamily': segment.fontFamily,
              },
            },
            confidence: 95,
          ),
        );
        break;

      default:
        break;
    }

    return suggestions;
  }

  /// Gera insights simulados para um negócio
  static Map<String, dynamic> _getMockBusinessInsights(
      BusinessSegment segment) {
    final insights = <String, dynamic>{
      'marketAnalysis': {
        'competitionLevel': 'Médio',
        'growthPotential': 'Alto',
        'targetAudience': 'Adultos de 25 a 45 anos',
      },
      'recommendations': [
        'Ofereça descontos para primeiros clientes',
        'Implemente um programa de fidelidade',
        'Utilize redes sociais para divulgação',
      ],
      'optimizations': [
        'Configure notificações automáticas de lembrete',
        'Ative pagamentos online para reduzir faltas',
        'Ofereça reagendamento fácil para clientes',
      ],
    };

    // Adiciona insights específicos para cada segmento
    switch (segment) {
      case BusinessSegment.salon:
        insights['serviceRecommendations'] = [
          'Adicione serviços de tratamentos capilares',
          'Ofereça pacotes para datas especiais',
          'Considere serviços expressos para horários de almoço',
        ];
        break;
      case BusinessSegment.clinic:
        insights['serviceRecommendations'] = [
          'Ofereça pacotes de check-up',
          'Implemente telemedicina para retornos',
          'Crie planos de acompanhamento contínuo',
        ];
        break;
      case BusinessSegment.spa:
        insights['serviceRecommendations'] = [
          'Crie experiências temáticas sazonais',
          'Ofereça pacotes para casais',
          'Desenvolva programas de assinatura mensal',
        ];
        break;
      default:
        insights['serviceRecommendations'] = [
          'Analise quais serviços têm maior demanda',
          'Considere expandir seu portfólio gradualmente',
          'Ofereça promoções para horários de baixa demanda',
        ];
        break;
    }

    return insights;
  }
}
