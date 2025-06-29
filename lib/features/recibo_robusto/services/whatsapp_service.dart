import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/logger_service.dart';
import '../models/recibo_model.dart';

class WhatsAppService {
  // Twilio Configuration
  static const String _twilioAccountSid = 'YOUR_TWILIO_ACCOUNT_SID';
  static const String _twilioAuthToken = 'YOUR_TWILIO_AUTH_TOKEN';
  static const String _twilioWhatsAppNumber = 'whatsapp:+14155238886';
  
  // Z-API Configuration (alternative)
  static const String _zapiUrl = 'https://api.z-api.io';
  static const String _zapiInstanceId = 'YOUR_INSTANCE_ID';
  static const String _zapiToken = 'YOUR_TOKEN';

  /// Envia recibo via WhatsApp usando Twilio
  static Future<bool> enviarReciboPorWhatsAppTwilio({
    required ReciboModel recibo,
    required String telefoneDestino,
    required String pdfUrl,
  }) async {
    try {
      LoggerService.info('Enviando WhatsApp via Twilio para: $telefoneDestino');

      final url = Uri.parse(
        'https://api.twilio.com/2010-04-01/Accounts/$_twilioAccountSid/Messages.json'
      );

      final credentials = base64Encode(utf8.encode('$_twilioAccountSid:$_twilioAuthToken'));
      
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'From': _twilioWhatsAppNumber,
          'To': 'whatsapp:$telefoneDestino',
          'Body': _buildWhatsAppMessage(recibo, pdfUrl),
        },
      );

      if (response.statusCode == 201) {
        LoggerService.info('WhatsApp enviado com sucesso via Twilio');
        return true;
      } else {
        LoggerService.error('Erro Twilio: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      LoggerService.error('Erro ao enviar WhatsApp via Twilio', e, stackTrace);
      return false;
    }
  }

  /// Envia recibo via WhatsApp usando Z-API
  static Future<bool> enviarReciboPorWhatsAppZAPI({
    required ReciboModel recibo,
    required String telefoneDestino,
    required String pdfUrl,
  }) async {
    try {
      LoggerService.info('Enviando WhatsApp via Z-API para: $telefoneDestino');

      final url = Uri.parse('$_zapiUrl/instances/$_zapiInstanceId/token/$_zapiToken/send-text');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': _formatPhoneNumber(telefoneDestino),
          'message': _buildWhatsAppMessage(recibo, pdfUrl),
        }),
      );

      if (response.statusCode == 200) {
        LoggerService.info('WhatsApp enviado com sucesso via Z-API');
        return true;
      } else {
        LoggerService.error('Erro Z-API: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      LoggerService.error('Erro ao enviar WhatsApp via Z-API', e, stackTrace);
      return false;
    }
  }

  /// Envia documento PDF via WhatsApp usando Z-API
  static Future<bool> enviarDocumentoPorWhatsApp({
    required ReciboModel recibo,
    required String telefoneDestino,
    required String pdfUrl,
  }) async {
    try {
      LoggerService.info('Enviando documento WhatsApp para: $telefoneDestino');

      final url = Uri.parse('$_zapiUrl/instances/$_zapiInstanceId/token/$_zapiToken/send-document');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': _formatPhoneNumber(telefoneDestino),
          'document': pdfUrl,
          'caption': 'Recibo - GAP Barber & Studio',
        }),
      );

      if (response.statusCode == 200) {
        LoggerService.info('Documento WhatsApp enviado com sucesso');
        return true;
      } else {
        LoggerService.error('Erro ao enviar documento: ${response.statusCode}');
        return false;
      }
    } catch (e, stackTrace) {
      LoggerService.error('Erro ao enviar documento WhatsApp', e, stackTrace);
      return false;
    }
  }

  static String _buildWhatsAppMessage(ReciboModel recibo, String pdfUrl) {
    return '''
🏪 *GAP Barber & Studio*

Olá *${recibo.clienteNome}*! 👋

Seu recibo está pronto! ✅

📅 *Data:* ${recibo.data.day}/${recibo.data.month}/${recibo.data.year}
✂️ *Serviço:* ${recibo.servicoNome}
💰 *Valor:* R\$ ${recibo.valor.toStringAsFixed(2)}

📄 *Acesse seu recibo:*
$pdfUrl

Obrigado pela preferência! 🙏
    ''';
  }

  static String _formatPhoneNumber(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanPhone.startsWith('55')) {
      return cleanPhone;
    } else if (cleanPhone.length == 11) {
      return '55$cleanPhone';
    }
    
    return cleanPhone;
  }
}