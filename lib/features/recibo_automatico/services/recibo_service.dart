import 'dart:typed_data';
// import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:logger/logger.dart';
import '../models/recibo.dart';
import '../utils/pdf_generator.dart';
import 'email_service.dart';
import 'whatsapp_service.dart';
import '../../payments/models/payment_model.dart';

class ReciboService {
  static final Logger _logger = Logger();
  static const String _s3Bucket = 'agendafacil-recibos';
  static const String _s3Region = 'us-east-1';

  /// Processa pagamento confirmado e envia recibo automaticamente
  static Future<bool> processarPagamentoConfirmado(Payment payment) async {
    try {
      _logger.i('Processando pagamento confirmado: ${payment.id}');

      // 1. Criar objeto Recibo
      final recibo = await _criarRecibo(payment);

      // 2. Gerar PDF
      final pdfBytes = await PDFGenerator.gerarReciboPDF(recibo);

      // 3. Upload para S3
      final pdfUrl = await _uploadPDFToS3(recibo.id, pdfBytes);

      // 4. Atualizar recibo com URL
      final reciboComUrl = Recibo(
        id: recibo.id,
        clienteNome: recibo.clienteNome,
        clienteEmail: recibo.clienteEmail,
        clienteTelefone: recibo.clienteTelefone,
        servicoNome: recibo.servicoNome,
        barbeiroNome: recibo.barbeiroNome,
        valor: recibo.valor,
        formaPagamento: recibo.formaPagamento,
        dataAtendimento: recibo.dataAtendimento,
        codigoAutenticacao: recibo.codigoAutenticacao,
        observacoes: recibo.observacoes,
        pdfUrl: pdfUrl,
      );

      // 5. Enviar por email e WhatsApp
      final emailEnviado = await EmailService.enviarReciboEmail(reciboComUrl, pdfBytes);
      final whatsappEnviado = await WhatsAppService.enviarReciboWhatsApp(reciboComUrl, pdfUrl);

      // 6. Salvar registro do recibo
      await _salvarRegistroRecibo(reciboComUrl, emailEnviado, whatsappEnviado);

      _logger.i('Recibo processado com sucesso!');
      return true;
    } catch (e, stackTrace) {
      _logger.e('Erro ao processar recibo', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  static Future<Recibo> _criarRecibo(Payment payment) async {
    // Buscar dados adicionais do cliente (simulado)
    final clienteEmail = await _buscarEmailCliente(payment.clienteId);
    final clienteTelefone = await _buscarTelefoneCliente(payment.clienteId);

    return Recibo(
      id: 'REC-${payment.id}-${DateTime.now().millisecondsSinceEpoch}',
      clienteNome: payment.clienteNome,
      clienteEmail: clienteEmail,
      clienteTelefone: clienteTelefone,
      servicoNome: payment.servicoNome,
      barbeiroNome: payment.barbeiroNome,
      valor: payment.valor,
      formaPagamento: _getFormaPagamentoText(payment.formaPagamento),
      dataAtendimento: payment.data,
      codigoAutenticacao: Recibo.gerarCodigoAutenticacao(),
      observacoes: payment.observacoes,
      pdfUrl: '', // Será preenchido após upload
    );
  }

  static Future<String> _uploadPDFToS3(String reciboId, Uint8List pdfBytes) async {
    try {
      final fileName = 'recibos/$reciboId.pdf';
      
      // Simulação do upload para S3
      _logger.i('Uploading PDF to S3: $fileName');
      
      // Simulated S3 upload - replace with actual implementation

      await Future.delayed(const Duration(seconds: 1)); // Simular upload

      // Gerar URL pré-assinada com expiração de 24h
      final preSignedUrl = await _gerarUrlPreAssinada(fileName);
      
      _logger.i('PDF uploaded successfully: $preSignedUrl');
      return preSignedUrl;
    } catch (e, stackTrace) {
      _logger.e('Erro ao fazer upload do PDF', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  static Future<String> _gerarUrlPreAssinada(String fileName) async {
    try {
      // Simulação da geração de URL pré-assinada
      // Simulated pre-signed URL generation

      // URL simulada para desenvolvimento
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return 'https://$_s3Bucket.s3.$_s3Region.amazonaws.com/$fileName?expires=$timestamp';
    } catch (e, stackTrace) {
      _logger.e('Erro ao gerar URL pré-assinada', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  static Future<void> _salvarRegistroRecibo(Recibo recibo, bool emailEnviado, bool whatsappEnviado) async {
    try {
      // Salvar no banco de dados (simulado)
      _logger.i('Salvando registro do recibo: ${recibo.id}');
      _logger.i('Email enviado: $emailEnviado');
      _logger.i('WhatsApp enviado: $whatsappEnviado');

      // Simulated database save

      await Future.delayed(const Duration(milliseconds: 100));
      _logger.i('Registro salvo com sucesso!');
    } catch (e, stackTrace) {
      _logger.e('Erro ao salvar registro', error: e, stackTrace: stackTrace);
    }
  }

  static Future<String> _buscarEmailCliente(String clienteId) async {
    // Simulação - buscar email do cliente no banco
    await Future.delayed(const Duration(milliseconds: 100));
    return 'cliente@email.com'; // Mock
  }

  static Future<String> _buscarTelefoneCliente(String clienteId) async {
    // Simulação - buscar telefone do cliente no banco
    await Future.delayed(const Duration(milliseconds: 100));
    return '(81) 99999-9999'; // Mock
  }

  static String _getFormaPagamentoText(FormaPagamento forma) {
    switch (forma) {
      case FormaPagamento.pix:
        return 'PIX';
      case FormaPagamento.dinheiro:
        return 'Dinheiro';
      case FormaPagamento.cartao:
        return 'Cartão';
    }
  }

  /// Método para testar o envio de recibo
  static Future<void> testarEnvioRecibo() async {
    final paymentTeste = Payment(
      id: 'TEST-001',
      clienteNome: 'João Silva',
      clienteId: 'cliente-123',
      servicoNome: 'Corte + Barba',
      servicoId: 'servico-1',
      barbeiroNome: 'Carlos',
      barbeiroId: 'barbeiro-1',
      valor: 55.0,
      formaPagamento: FormaPagamento.pix,
      status: StatusPagamento.pago,
      data: DateTime.now(),
      observacoes: 'Cliente preferencial',
    );

    await processarPagamentoConfirmado(paymentTeste);
  }
}