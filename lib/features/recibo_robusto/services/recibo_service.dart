import 'dart:typed_data';
import '../../../core/services/logger_service.dart';
import '../models/recibo_model.dart';
import '../utils/pdf_generator.dart';
import 'email_service.dart';
import 'whatsapp_service.dart';

class ReciboService {
  /// Processa e envia recibo completo por email
  static Future<bool> processarEEnviarRecibo({
    required ReciboModel recibo,
  }) async {
    try {
      LoggerService.info('Processando recibo: ${recibo.id}');

      // 1. Gerar PDF
      final pdfBytes = await PDFGenerator.gerarReciboPDF(recibo);

      // 2. Enviar por email
      final emailEnviado = await EmailService.enviarReciboPorEmail(
        recibo: recibo,
        pdfBytes: pdfBytes,
      );

      if (emailEnviado) {
        LoggerService.info('Recibo processado e enviado com sucesso');
        return true;
      } else {
        LoggerService.warning('Falha no envio do email');
        return false;
      }
    } catch (e, stackTrace) {
      LoggerService.error('Erro ao processar recibo', e, stackTrace);
      return false;
    }
  }

  /// Processa e envia recibo por email e WhatsApp
  static Future<Map<String, bool>> processarEEnviarReciboCompleto({
    required ReciboModel recibo,
    required String telefoneWhatsApp,
    required String pdfUrl,
  }) async {
    try {
      LoggerService.info('Processando recibo completo: ${recibo.id}');

      // 1. Gerar PDF
      final pdfBytes = await PDFGenerator.gerarReciboPDF(recibo);

      // 2. Enviar por email
      final emailEnviado = await EmailService.enviarReciboPorEmail(
        recibo: recibo,
        pdfBytes: pdfBytes,
      );

      // 3. Enviar por WhatsApp
      final whatsappEnviado = await WhatsAppService.enviarReciboPorWhatsAppZAPI(
        recibo: recibo,
        telefoneDestino: telefoneWhatsApp,
        pdfUrl: pdfUrl,
      );

      final resultado = {
        'email': emailEnviado,
        'whatsapp': whatsappEnviado,
      };

      LoggerService.info('Resultado do envio: $resultado');
      return resultado;
    } catch (e, stackTrace) {
      LoggerService.error('Erro ao processar recibo completo', e, stackTrace);
      return {'email': false, 'whatsapp': false};
    }
  }

  /// Gera apenas o PDF do recibo
  static Future<Uint8List?> gerarPDF(ReciboModel recibo) async {
    try {
      return await PDFGenerator.gerarReciboPDF(recibo);
    } catch (e, stackTrace) {
      LoggerService.error('Erro ao gerar PDF', e, stackTrace);
      return null;
    }
  }

  /// Cria assinatura digital única
  static String criarAssinaturaDigital(String reciboId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final hash = (reciboId.hashCode + timestamp).abs().toString();
    return 'GAP-${hash.substring(0, 8).toUpperCase()}';
  }

  /// Valida dados do recibo antes do processamento
  static bool validarRecibo(ReciboModel recibo) {
    if (recibo.clienteNome.isEmpty) {
      LoggerService.warning('Nome do cliente vazio');
      return false;
    }
    
    if (recibo.clienteEmail.isEmpty || !recibo.clienteEmail.contains('@')) {
      LoggerService.warning('Email inválido: ${recibo.clienteEmail}');
      return false;
    }
    
    if (recibo.valor <= 0) {
      LoggerService.warning('Valor inválido: ${recibo.valor}');
      return false;
    }
    
    if (recibo.servicoNome.isEmpty) {
      LoggerService.warning('Nome do serviço vazio');
      return false;
    }

    return true;
  }
}