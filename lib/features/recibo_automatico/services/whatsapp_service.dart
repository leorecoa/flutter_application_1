import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recibo.dart';

class WhatsAppService {
  static const String _apiUrl = 'https://api.z-api.io'; // ou Twilio
  static const String _instanceId = 'YOUR_INSTANCE_ID';
  static const String _token = 'YOUR_TOKEN';

  static Future<bool> enviarReciboWhatsApp(Recibo recibo, String pdfUrl) async {
    try {
      final phoneNumber = _formatPhoneNumber(recibo.clienteTelefone);
      final message = _buildWhatsAppMessage(recibo, pdfUrl);

      print('📱 Enviando WhatsApp para: $phoneNumber');
      print('📱 Mensagem: $message');
      print('📱 PDF URL: $pdfUrl');

      // Simulação do envio via WhatsApp API
      /*
      final response = await http.post(
        Uri.parse('$_apiUrl/instances/$_instanceId/token/$_token/send-text'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone': phoneNumber,
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ WhatsApp enviado com sucesso!');
        return true;
      } else {
        print('❌ Erro ao enviar WhatsApp: ${response.statusCode}');
        return false;
      }
      */

      await Future.delayed(const Duration(seconds: 1)); // Simular delay
      print('✅ WhatsApp enviado com sucesso!');
      return true;
    } catch (e) {
      print('❌ Erro ao enviar WhatsApp: $e');
      return false;
    }
  }

  static String _formatPhoneNumber(String phone) {
    // Remove caracteres especiais e adiciona código do país se necessário
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanPhone.startsWith('55')) {
      return cleanPhone;
    } else if (cleanPhone.length == 11) {
      return '55$cleanPhone';
    } else if (cleanPhone.length == 10) {
      return '55$cleanPhone';
    }
    
    return cleanPhone;
  }

  static String _buildWhatsAppMessage(Recibo recibo, String pdfUrl) {
    return '''
🏪 *GAP Barber & Studio*

Olá *${recibo.clienteNome}*! 👋

Seu recibo do atendimento realizado está pronto! ✅

📅 *Data:* ${recibo.dataAtendimento.day}/${recibo.dataAtendimento.month}/${recibo.dataAtendimento.year}
✂️ *Serviço:* ${recibo.servicoNome}
👨‍💼 *Profissional:* ${recibo.barbeiroNome}
💰 *Valor:* R\$ ${recibo.valor.toStringAsFixed(2)}

📄 *Acesse seu recibo aqui:*
$pdfUrl

🔐 *Código de Autenticação:* ${recibo.codigoAutenticacao}

_Este link expira em 24 horas por segurança._

Obrigado pela preferência! 🙏
    ''';
  }

  static Future<bool> enviarReciboComDocumento(Recibo recibo, String pdfUrl) async {
    try {
      final phoneNumber = _formatPhoneNumber(recibo.clienteTelefone);
      
      print('📱 Enviando documento WhatsApp para: $phoneNumber');
      print('📱 PDF URL: $pdfUrl');

      // Envio de documento via WhatsApp API
      /*
      final response = await http.post(
        Uri.parse('$_apiUrl/instances/$_instanceId/token/$_token/send-document'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone': phoneNumber,
          'document': pdfUrl,
          'caption': 'Recibo - GAP Barber & Studio',
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Documento WhatsApp enviado com sucesso!');
        return true;
      }
      */

      await Future.delayed(const Duration(seconds: 1));
      print('✅ Documento WhatsApp enviado com sucesso!');
      return true;
    } catch (e) {
      print('❌ Erro ao enviar documento WhatsApp: $e');
      return false;
    }
  }
}