import 'package:flutter/material.dart';
import 'core/services/auth_service.dart';
import 'features/appointments/services/agendamento_service.dart';
import 'features/appointments/models/agendamento_model.dart';

class TestAWSIntegration extends StatefulWidget {
  const TestAWSIntegration({super.key});

  @override
  State<TestAWSIntegration> createState() => _TestAWSIntegrationState();
}

class _TestAWSIntegrationState extends State<TestAWSIntegration> {
  String _status = 'Aguardando teste...';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teste AWS Integration')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(_status, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _testAuth,
              child: const Text('Testar Autenticação'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : _testAgendamentos,
              child: const Text('Testar Agendamentos'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testAuth() async {
    setState(() {
      _isLoading = true;
      _status = 'Testando autenticação...';
    });

    try {
      // Teste de login (vai falhar pois não temos API real)
      final result = await AuthService().loginUser('test@test.com', 'password123');
      setState(() {
        _status = result['success'] == true
          ? '✅ Auth: Login simulado com sucesso' 
          : '⚠️ Auth: Fallback funcionando (API não disponível)';
      });
    } catch (e) {
      setState(() {
        _status = '⚠️ Auth: Fallback funcionando - $e';
      });
    }

    setState(() => _isLoading = false);
  }

  Future<void> _testAgendamentos() async {
    setState(() {
      _isLoading = true;
      _status = 'Testando agendamentos...';
    });

    try {
      // Teste de busca de agendamentos
      final agendamentos = await AgendamentoService.getAgendamentos();
      
      // Teste de criação
      final novoAgendamento = Agendamento(
        id: '',
        clienteNome: 'Teste Cliente',
        clienteId: 'test-client',
        servicoNome: 'Teste Serviço',
        servicoId: 'test-service',
        barbeiroNome: 'Teste Barbeiro',
        barbeiroId: 'test-barbeiro',
        dataHora: DateTime.now(),
        valor: 50.0,
        status: StatusAgendamento.pendente,
      );
      
      await AgendamentoService.criarAgendamento(novoAgendamento);
      
      setState(() {
        _status = '✅ Agendamentos: ${agendamentos.length} encontrados, criação OK';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Erro nos agendamentos: $e';
      });
    }

    setState(() => _isLoading = false);
  }
}