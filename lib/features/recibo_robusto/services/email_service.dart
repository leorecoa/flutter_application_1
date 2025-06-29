import 'dart:typed_data';
import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import '../models/recibo_model.dart';

class EmailService {
  static final Logger _logger = Logger();
  
  // AWS SES Configuration - Replace with your actual values
  static const String _smtpHost = 'email-smtp.us-east-1.amazonaws.com';
  static const int _smtpPort = 587;
  static const String _username = 'YOUR_SES_SMTP_USERNAME'; // Replace with actual SES SMTP username
  static const String _password = 'YOUR_SES_SMTP_PASSWORD'; // Replace with actual SES SMTP password
  static const String _fromEmail = 'noreply@gapbarber.com.br'; // Replace with verified SES email
  static const String _fromName = 'GAP Barber & Studio';

  static Future<bool> enviarReciboPorEmail({
    required ReciboModel recibo,
    required Uint8List pdfBytes,
  }) async {
    try {
      _logger.i('Iniciando envio de email para: ${recibo.clienteEmail}');

      final smtpServer = SmtpServer(
        _smtpHost,
        port: _smtpPort,
        username: _username,
        password: _password,
        ssl: false,
        allowInsecure: false,
      );

      final message = Message()
        ..from = const Address(_fromEmail, _fromName)
        ..recipients.add(recibo.clienteEmail)
        ..subject = 'Recibo do seu atendimento - GAP Barber & Studio'
        ..html = _buildHtmlBody(recibo)
        ..text = _buildTextBody(recibo)
        ..attachments.add(await _createPDFAttachment(pdfBytes, recibo.id));

      final sendReport = await send(message, smtpServer);
      
      _logger.i('Email enviado com sucesso: ${sendReport.toString()}');
      return true;
    } catch (e, stackTrace) {
      _logger.e('Erro ao enviar email', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  static String _buildHtmlBody(ReciboModel recibo) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .header { background: #1E3A8A; color: white; padding: 20px; text-align: center; }
            .content { padding: 20px; }
            .total { background: #f0f9ff; padding: 15px; border-radius: 8px; font-weight: bold; }
        </style>
    </head>
    <body>
        <div class="header">
            <h1>GAP Barber & Studio</h1>
            <p>Recibo do seu atendimento</p>
        </div>
        
        <div class="content">
            <p>Olá <strong>${recibo.clienteNome}</strong>,</p>
            
            <p>Obrigado por escolher a GAP Barber & Studio!</p>
            
            <p><strong>Serviço:</strong> ${recibo.servicoNome}</p>
            <p><strong>Data:</strong> ${recibo.data.day}/${recibo.data.month}/${recibo.data.year}</p>
            
            <div class="total">
                <p>Valor Total: R\$ ${recibo.valor.toStringAsFixed(2)}</p>
            </div>
            
            <p>O recibo completo em PDF está anexado a este e-mail.</p>
            
            <p>Esperamos vê-lo novamente em breve!</p>
        </div>
    </body>
    </html>
    ''';
  }

  static String _buildTextBody(ReciboModel recibo) {
    return '''
    GAP Barber & Studio - Recibo do seu atendimento
    
    Olá ${recibo.clienteNome},
    
    Obrigado por escolher a GAP Barber & Studio!
    
    Serviço: ${recibo.servicoNome}
    Data: ${recibo.data.day}/${recibo.data.month}/${recibo.data.year}
    Valor Total: R\$ ${recibo.valor.toStringAsFixed(2)}
    
    O recibo completo em PDF está anexado a este e-mail.
    
    Esperamos vê-lo novamente em breve!
    
    GAP Barber & Studio
    ''';
  }

  static Future<FileAttachment> _createPDFAttachment(Uint8List pdfBytes, String reciboId) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/recibo_$reciboId.pdf');
    await file.writeAsBytes(pdfBytes);
    
    return FileAttachment(
      file,
      fileName: 'recibo_$reciboId.pdf',
      contentType: 'application/pdf',
    );
  }
}