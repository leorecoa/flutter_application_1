import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/auth_service.dart';
import '../../../core/config/app_config.dart';

class PagamentoService {
  final AuthService _authService = AuthService();
  
  static const String _baseUrl = AppConfig.apiBaseUrl;

  Future<Map<String, dynamic>> criarPagamentoPix({
    required double valor,
    required String descricao,
  }) async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) {
        throw Exception('Usuário não autenticado');
      }

      final url = Uri.parse('$_baseUrl/api/pagamento/pix');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'valor': valor,
          'descricao': descricao,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Erro ao criar pagamento PIX');
      }
    } catch (e) {
      print('Erro PIX Service: $e');
      throw Exception('Falha ao processar PIX: $e');
    }
  }

  Future<Map<String, dynamic>> criarPagamentoStripe({
    required double valor,
    required String descricao,
  }) async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) {
        throw Exception('Usuário não autenticado');
      }

      final url = Uri.parse('$_baseUrl/api/pagamento/stripe');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'valor': valor,
          'descricao': descricao,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Erro ao criar pagamento Stripe');
      }
    } catch (e) {
      print('Erro Stripe Service: $e');
      throw Exception('Falha ao processar Stripe: $e');
    }
  }

  Future<Map<String, dynamic>?> verificarStatusPagamento(String transacaoId) async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) {
        throw Exception('Usuário não autenticado');
      }

      final url = Uri.parse('$_baseUrl/api/pagamento/$transacaoId/status');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'];
      } else {
        return null;
      }
    } catch (e) {
      print('Erro ao verificar status: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> obterHistoricoPagamentos() async {
    try {
      final token = await _authService.getAuthToken();
      if (token == null) {
        throw Exception('Usuário não autenticado');
      }

      final url = Uri.parse('$_baseUrl/api/pagamento/historico');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        return [];
      }
    } catch (e) {
      print('Erro ao obter histórico: $e');
      return [];
    }
  }

  // Método para validar código PIX copia e cola
  bool validarCodigoPix(String codigo) {
    if (codigo.isEmpty) return false;
    
    // Validação básica do BR Code PIX
    // - Deve começar com código específico
    // - Ter tamanho mínimo
    // - Terminar com CRC16
    if (codigo.length < 100) return false;
    if (!codigo.startsWith('00020')) return false;
    
    return true;
  }

  // Método para extrair valor do código PIX
  double? extrairValorPix(String codigo) {
    try {
      final regex = RegExp(r'54\d{2}(\d+\.\d{2})');
      final match = regex.firstMatch(codigo);
      if (match != null) {
        return double.tryParse(match.group(1) ?? '');
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Status de pagamento em formato legível
  String obterStatusLegivel(String status) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return 'Aguardando Pagamento';
      case 'pago':
        return 'Pago';
      case 'cancelado':
        return 'Cancelado';
      case 'expirado':
        return 'Expirado';
      case 'falhou':
        return 'Falhou';
      default:
        return 'Status Desconhecido';
    }
  }

  // Cor do status para UI
  String obterCorStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return 'orange';
      case 'pago':
        return 'green';
      case 'cancelado':
      case 'expirado':
      case 'falhou':
        return 'red';
      default:
        return 'grey';
    }
  }

  // Formatação de valor monetário
  String formatarValor(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  // Formatação de data
  String formatarData(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day.toString().padLeft(2, '0')}/'
             '${date.month.toString().padLeft(2, '0')}/'
             '${date.year} às '
             '${date.hour.toString().padLeft(2, '0')}:'
             '${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Data inválida';
    }
  }

  // Tempo restante para expiração
  String obterTempoRestante(String expiresAt) {
    try {
      final expiry = DateTime.parse(expiresAt);
      final now = DateTime.now();
      final diff = expiry.difference(now);

      if (diff.isNegative) {
        return 'Expirado';
      }

      final minutes = diff.inMinutes;
      final seconds = diff.inSeconds % 60;

      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } catch (e) {
      return '--:--';
    }
  }

  // Verificar se transação expirou
  bool isTransacaoExpirada(String expiresAt) {
    try {
      final expiry = DateTime.parse(expiresAt);
      return DateTime.now().isAfter(expiry);
    } catch (e) {
      return true;
    }
  }
}