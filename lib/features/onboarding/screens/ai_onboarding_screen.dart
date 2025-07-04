import 'package:flutter/material.dart';
import '../../../core/theme/segments/business_segment.dart';
import '../models/ai_suggestion.dart';
import '../models/onboarding_step.dart';
import '../services/ai_onboarding_service.dart';

class AiOnboardingScreen extends StatefulWidget {
  final String tenantId;
  final String businessName;
  final BusinessSegment segment;

  const AiOnboardingScreen({
    required this.tenantId,
    required this.businessName,
    required this.segment,
    super.key,
  });

  @override
  State<AiOnboardingScreen> createState() => _AiOnboardingScreenState();
}

class _AiOnboardingScreenState extends State<AiOnboardingScreen> {
  bool _isLoading = true;
  List<OnboardingStep> _steps = [];
  int _currentStepIndex = 0;
  List<AiSuggestion> _currentSuggestions = [];
  bool _loadingSuggestions = false;

  @override
  void initState() {
    super.initState();
    _loadOnboardingPlan();
  }

  Future<void> _loadOnboardingPlan() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final steps = await AiOnboardingService.generateOnboardingPlan(
        tenantId: widget.tenantId,
        businessName: widget.businessName,
        segment: widget.segment,
      );

      if (mounted) {
        setState(() {
          _steps = steps;
          _isLoading = false;
        });

        // Carrega sugestões para o primeiro passo
        if (_steps.isNotEmpty) {
          _loadSuggestions(_steps[0]);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar plano de onboarding: $e')),
        );
      }
    }
  }

  Future<void> _loadSuggestions(OnboardingStep step) async {
    setState(() {
      _loadingSuggestions = true;
    });

    try {
      final suggestions = await AiOnboardingService.generateSuggestions(
        tenantId: widget.tenantId,
        step: step,
        segment: widget.segment,
      );

      if (mounted) {
        setState(() {
          _currentSuggestions = suggestions;
          _loadingSuggestions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingSuggestions = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar sugestões: $e')),
        );
      }
    }
  }

  void _nextStep() {
    if (_currentStepIndex < _steps.length - 1) {
      setState(() {
        _currentStepIndex++;
      });

      _loadSuggestions(_steps[_currentStepIndex]);
    } else {
      // Finalizar onboarding
      Navigator.of(context).pop(true);
    }
  }

  void _previousStep() {
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
      });

      _loadSuggestions(_steps[_currentStepIndex]);
    }
  }

  Future<void> _acceptSuggestion(AiSuggestion suggestion) async {
    // Atualiza o estado da sugestão
    final updatedSuggestion = suggestion.accept();

    setState(() {
      final index =
          _currentSuggestions.indexWhere((s) => s.id == suggestion.id);
      if (index != -1) {
        _currentSuggestions[index] = updatedSuggestion;
      }
    });

    // Registra o feedback
    await AiOnboardingService.recordSuggestionFeedback(
      tenantId: widget.tenantId,
      suggestionId: suggestion.id,
      accepted: true,
    );

    // Exibe confirmação
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sugestão aplicada com sucesso')),
      );
    }
  }

  Future<void> _rejectSuggestion(AiSuggestion suggestion) async {
    // Atualiza o estado da sugestão
    final updatedSuggestion = suggestion.reject();

    setState(() {
      final index =
          _currentSuggestions.indexWhere((s) => s.id == suggestion.id);
      if (index != -1) {
        _currentSuggestions[index] = updatedSuggestion;
      }
    });

    // Registra o feedback
    await AiOnboardingService.recordSuggestionFeedback(
      tenantId: widget.tenantId,
      suggestionId: suggestion.id,
      accepted: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuração Assistida'),
        leading: _currentStepIndex > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousStep,
              )
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(false),
              ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _steps.isEmpty
              ? _buildEmptyState()
              : _buildOnboardingContent(),
      bottomNavigationBar: _isLoading || _steps.isEmpty
          ? null
          : BottomAppBar(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Passo ${_currentStepIndex + 1} de ${_steps.length}'),
                    ElevatedButton(
                      onPressed: _nextStep,
                      child: Text(_currentStepIndex < _steps.length - 1
                          ? 'Próximo'
                          : 'Concluir'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Não foi possível carregar o plano de onboarding',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Tente novamente mais tarde',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadOnboardingPlan,
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingContent() {
    final currentStep = _steps[_currentStepIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título e descrição da etapa
          Text(
            currentStep.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            currentStep.description,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),

          // Conteúdo específico da etapa
          _buildStepContent(currentStep),
          const SizedBox(height: 24),

          // Sugestões da IA
          _buildAiSuggestions(),
        ],
      ),
    );
  }

  Widget _buildStepContent(OnboardingStep step) {
    // Conteúdo específico para cada tipo de etapa
    switch (step.type) {
      case OnboardingStepType.info:
        return _buildInfoStep(step);
      case OnboardingStepType.business:
        return _buildBusinessStep(step);
      case OnboardingStepType.services:
        return _buildServicesStep(step);
      case OnboardingStepType.schedule:
        return _buildScheduleStep(step);
      case OnboardingStepType.customization:
        return _buildCustomizationStep(step);
      default:
        return const Center(
          child: Text('Conteúdo em desenvolvimento'),
        );
    }
  }

  Widget _buildInfoStep(OnboardingStep step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(widget.segment.icon,
                        size: 32, color: widget.segment.primaryColor),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.businessName,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.segment.displayName,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Vamos configurar seu negócio para começar a receber agendamentos. '
                  'Nossa IA irá sugerir as melhores configurações com base no seu tipo de negócio.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessStep(OnboardingStep step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informações do Negócio',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: widget.businessName,
          decoration: const InputDecoration(
            labelText: 'Nome do Negócio',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Descrição',
            border: OutlineInputBorder(),
            hintText: 'Descreva seu negócio brevemente',
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Endereço',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Telefone',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'E-mail',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget _buildServicesStep(OnboardingStep step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Serviços',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'Adicione os serviços que você oferece. Nossa IA pode sugerir serviços populares para o seu segmento.',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Novo Serviço',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nome do Serviço',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Duração (min)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Preço (R\$)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Adicionar Serviço'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Serviços Adicionados',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Nenhum serviço adicionado ainda.',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildScheduleStep(OnboardingStep step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Horários de Funcionamento',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'Configure os horários em que você atende. Nossa IA pode sugerir horários típicos para o seu segmento.',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),
        _buildDayScheduleCard('Segunda-feira', '09:00', '18:00'),
        _buildDayScheduleCard('Terça-feira', '09:00', '18:00'),
        _buildDayScheduleCard('Quarta-feira', '09:00', '18:00'),
        _buildDayScheduleCard('Quinta-feira', '09:00', '18:00'),
        _buildDayScheduleCard('Sexta-feira', '09:00', '18:00'),
        _buildDayScheduleCard('Sábado', '09:00', '13:00'),
        _buildDayScheduleCard('Domingo', null, null, closed: true),
      ],
    );
  }

  Widget _buildDayScheduleCard(String day, String? start, String? end,
      {bool closed = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                day,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 3,
              child: closed
                  ? const Text('Fechado', style: TextStyle(color: Colors.red))
                  : Row(
                      children: [
                        Expanded(
                          child: Text(start ?? ''),
                        ),
                        const Text(' - '),
                        Expanded(
                          child: Text(end ?? ''),
                        ),
                      ],
                    ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomizationStep(OnboardingStep step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personalização',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'Personalize a aparência do seu aplicativo. Nossa IA pode sugerir um tema baseado no seu segmento.',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cores',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Cor Primária'),
                          const SizedBox(height: 8),
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: widget.segment.primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Cor Secundária'),
                          const SizedBox(height: 8),
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: widget.segment.secondaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Estilo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Fonte'),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(widget.segment.fontFamily),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Bordas'),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                                '${widget.segment.borderRadius.toInt()} px'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAiSuggestions() {
    if (_loadingSuggestions) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_currentSuggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.lightbulb, color: Colors.amber),
            SizedBox(width: 8),
            Text(
              'Sugestões da IA',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._currentSuggestions
            .map((suggestion) => _buildSuggestionCard(suggestion)),
      ],
    );
  }

  Widget _buildSuggestionCard(AiSuggestion suggestion) {
    if (suggestion.isAccepted || suggestion.isRejected) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getSuggestionIcon(suggestion.type), color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    suggestion.title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(suggestion.confidence),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${suggestion.confidence}%',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(suggestion.description),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => _rejectSuggestion(suggestion),
                  child: const Text('Ignorar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _acceptSuggestion(suggestion),
                  child: const Text('Aplicar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSuggestionIcon(AiSuggestionType type) {
    switch (type) {
      case AiSuggestionType.service:
        return Icons.room_service;
      case AiSuggestionType.schedule:
        return Icons.schedule;
      case AiSuggestionType.price:
        return Icons.attach_money;
      case AiSuggestionType.setting:
        return Icons.settings;
      case AiSuggestionType.marketing:
        return Icons.campaign;
      case AiSuggestionType.integration:
        return Icons.integration_instructions;
      case AiSuggestionType.customization:
        return Icons.palette;
      default:
        return Icons.lightbulb;
    }
  }

  Color _getConfidenceColor(int confidence) {
    if (confidence >= 90) {
      return Colors.green;
    } else if (confidence >= 70) {
      return Colors.blue;
    } else if (confidence >= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
