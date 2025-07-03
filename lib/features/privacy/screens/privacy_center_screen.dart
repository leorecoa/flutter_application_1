import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/consent_model.dart';
import '../models/data_subject_request_model.dart';
import '../services/consent_service.dart';
import '../services/data_subject_request_service.dart';

class PrivacyCenterScreen extends StatefulWidget {
  const PrivacyCenterScreen({super.key});

  @override
  State<PrivacyCenterScreen> createState() => _PrivacyCenterScreenState();
}

class _PrivacyCenterScreenState extends State<PrivacyCenterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<ConsentModel> _consents = [];
  List<DataSubjectRequestModel> _requests = [];
  
  // Mock user ID para desenvolvimento
  final String _userId = 'user-123';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final consents = await ConsentService.getUserConsents(_userId);
      final requests = await DataSubjectRequestService.getUserRequests(_userId);
      
      if (mounted) {
        setState(() {
          _consents = consents;
          _requests = requests;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Central de Privacidade'),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Central de Privacidade',
                  style: AppTextStyles.h3.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gerencie seus dados pessoais e preferências de privacidade',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withAlpha(230)),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Consentimentos'),
              Tab(text: 'Solicitações'),
            ],
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildConsentsTab(),
                      _buildRequestsTab(),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tabController.index == 0 ? _showConsentDialog : _showRequestDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildConsentsTab() {
    if (_consents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.privacy_tip_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Nenhum consentimento registrado',
              style: AppTextStyles.h5,
            ),
            const SizedBox(height: 8),
            Text(
              'Clique no botão + para registrar um novo consentimento',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _consents.length,
      itemBuilder: (context, index) {
        final consent = _consents[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            title: Text(_getConsentTypeLabel(consent.type)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Status: ${_getConsentStatusLabel(consent.status)}'),
                Text('Atualizado em: ${_formatDate(consent.updatedAt ?? consent.createdAt)}'),
              ],
            ),
            trailing: Switch(
              value: consent.status == ConsentStatus.granted,
              onChanged: (value) => _updateConsent(consent, value),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequestsTab() {
    if (_requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Nenhuma solicitação registrada',
              style: AppTextStyles.h5,
            ),
            const SizedBox(height: 8),
            Text(
              'Clique no botão + para criar uma nova solicitação',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _requests.length,
      itemBuilder: (context, index) {
        final request = _requests[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            title: Text(_getRequestTypeLabel(request.type)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Status: ${_getRequestStatusLabel(request.status)}'),
                Text('Criado em: ${_formatDate(request.createdAt)}'),
                Text(
                  request.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showRequestDetails(request),
          ),
        );
      },
    );
  }

  void _showConsentDialog() {
    // Implementação do diálogo de consentimento
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('Novo Consentimento'),
        content: Text('Funcionalidade em desenvolvimento'),
        actions: [
          TextButton(
            onPressed: null,
            child: Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showRequestDialog() {
    // Implementação do diálogo de solicitação
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('Nova Solicitação'),
        content: Text('Funcionalidade em desenvolvimento'),
        actions: [
          TextButton(
            onPressed: null,
            child: Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showRequestDetails(DataSubjectRequestModel request) {
    // Implementação do diálogo de detalhes da solicitação
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getRequestTypeLabel(request.type)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${_getRequestStatusLabel(request.status)}'),
            const SizedBox(height: 8),
            Text('Criado em: ${_formatDate(request.createdAt)}'),
            if (request.completedAt != null)
              Text('Concluído em: ${_formatDate(request.completedAt!)}'),
            const SizedBox(height: 16),
            const Text('Descrição:'),
            const SizedBox(height: 4),
            Text(request.description),
            if (request.rejectionReason != null) ...[
              const SizedBox(height: 16),
              const Text('Motivo da rejeição:'),
              const SizedBox(height: 4),
              Text(request.rejectionReason!),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateConsent(ConsentModel consent, bool granted) async {
    try {
      final updatedConsent = await ConsentService.updateConsent(
        consentId: consent.id,
        userId: _userId,
        status: granted ? ConsentStatus.granted : ConsentStatus.denied,
      );
      
      if (!mounted) return;
      
      setState(() {
        final index = _consents.indexWhere((c) => c.id == consent.id);
        if (index != -1) {
          _consents[index] = updatedConsent;
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consentimento atualizado com sucesso')),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar consentimento: $e')),
      );
    }
  }

  String _getConsentTypeLabel(ConsentType type) {
    switch (type) {
      case ConsentType.marketing:
        return 'Marketing e Comunicações';
      case ConsentType.analytics:
        return 'Análise de Uso';
      case ConsentType.thirdParty:
        return 'Compartilhamento com Terceiros';
      case ConsentType.profiling:
        return 'Perfilamento';
      case ConsentType.location:
        return 'Dados de Localização';
      case ConsentType.cookies:
        return 'Cookies e Rastreamento';
      case ConsentType.communications:
        return 'Comunicações';
    }
  }

  String _getConsentStatusLabel(ConsentStatus status) {
    switch (status) {
      case ConsentStatus.granted:
        return 'Concedido';
      case ConsentStatus.denied:
        return 'Negado';
      case ConsentStatus.pending:
        return 'Pendente';
      case ConsentStatus.expired:
        return 'Expirado';
    }
  }

  String _getRequestTypeLabel(RequestType type) {
    switch (type) {
      case RequestType.access:
        return 'Acesso aos Dados';
      case RequestType.rectification:
        return 'Correção de Dados';
      case RequestType.erasure:
        return 'Exclusão de Dados';
      case RequestType.restriction:
        return 'Restrição de Processamento';
      case RequestType.portability:
        return 'Portabilidade de Dados';
      case RequestType.objection:
        return 'Objeção ao Processamento';
      case RequestType.automated:
        return 'Decisões Automatizadas';
    }
  }

  String _getRequestStatusLabel(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return 'Pendente';
      case RequestStatus.inProgress:
        return 'Em Andamento';
      case RequestStatus.completed:
        return 'Concluído';
      case RequestStatus.rejected:
        return 'Rejeitado';
      case RequestStatus.cancelled:
        return 'Cancelado';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}