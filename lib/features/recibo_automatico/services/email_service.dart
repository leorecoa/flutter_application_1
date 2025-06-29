import 'dart:typed_data';
import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import '../models/recibo.dart';

class EmailService {
  static final Logger _logger = Logger();
  
  // AWS SES Configuration - Replace with your actual values
  static const String _smtpHost = 'email-smtp.us-east-1.amazonaws.com';
  static const int _smtpPort = 587;
  static const String _username = 'YOUR_SES_SMTP_USERNAME'; // Replace with actual SES SMTP username
  static const String _password = 'YOUR_SES_SMTP_PASSWORD'; // Replace with actual SES SMTP password
  static const String _fromEmail = 'noreply@gapbarber.com.br'; // Replace with verified SES email
  static const String _fromName = 'GAP Barber & Studio';

  static Future<bool> enviarReciboEmail(Recibo recibo, Uint8List pdfBytes) async {
    try {
      _logger.i('Iniciando envio de email para: ${recibo.clienteEmail}');
      
      const subject = 'Recibo do seu atendimento - GAP Barber & Studio';
      final htmlBody = _buildEmailBody(recibo);
      final textBody = _buildTextBody(recibo);
      
      // Configure SMTP server for AWS SES
      final smtpServer = SmtpServer(
        _smtpHost,
        port: _smtpPort,
        username: _username,
        password: _password,
        ssl: false, // SES uses STARTTLS
        allowInsecure: false,
      );
      
      // Create message with PDF attachment
      final message = Message()
        ..from = Address(_fromEmail, _fromName)
        ..recipients.add(recibo.clienteEmail)
        ..subject = subject
        ..html = htmlBody
        ..text = textBody
        ..attachments.add(await _createPDFAttachment(pdfBytes, recibo.id));
      
      // Send email via SMTP
      final sendReport = await send(message, smtpServer);
      
      _logger.i('Email enviado com sucesso: ${sendReport.toString()}');
      return true;
    } catch (e, stackTrace) {
      _logger.e('Erro ao enviar email', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  static String _buildEmailBody(Recibo recibo) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .header { background: linear-gradient(135deg, #1E3A8A, #3B82F6); color: white; padding: 20px; text-align: center; }
            .content { padding: 20px; }
            .info-box { background: #f8f9fa; padding: 15px; border-radius: 8px; margin: 10px 0; }
            .total { background: #e3f2fd; padding: 15px; border-radius: 8px; font-weight: bold; }
            .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
        </style>
    </head>
    <body>
        <div class="header">
            <h1>GAP Barber & Studio</h1>
            <p>Recibo do seu atendimento</p>
        </div>
        
        <div class="content">
            <p>Olá <strong>${recibo.clienteNome}</strong>,</p>
            
            <p>Obrigado por escolher a GAP Barber & Studio! Segue o recibo do seu atendimento:</p>
            
            <div class="info-box">
                <h3>Detalhes do Atendimento</h3>
                <p><strong>Data/Hora:</strong> ${DateFormat('dd/MM/yyyy HH:mm').format(recibo.dataAtendimento)}</p>
                <p><strong>Serviço:</strong> ${recibo.servicoNome}</p>
                <p><strong>Profissional:</strong> ${recibo.barbeiroNome}</p>
                <p><strong>Forma de Pagamento:</strong> ${recibo.formaPagamento}</p>
            </div>
            
            <div class="total">
                <p>Valor Total: R\$ ${recibo.valor.toStringAsFixed(2)}</p>
            </div>
            
            <p>O recibo completo em PDF está anexado a este e-mail.</p>
            
            <p><strong>Código de Autenticação:</strong> ${recibo.codigoAutenticacao}</p>
            
            <p>Esperamos vê-lo novamente em breve!</p>
        </div>
        
        <div class="footer">
            <p>GAP Barber & Studio<br>
            Rua Esmeraldino Bandeira, 68, Graças - Brasil<br>
            Tel: (81) 99999-9999</p>
        </div>
    </body>
    </html>
    ''';
  }

  static String _buildTextBody(Recibo recibo) {
    return '''
    GAP Barber & Studio - Recibo do seu atendimento
    
    Olá ${recibo.clienteNome},
    
    Obrigado por escolher a GAP Barber & Studio!
    
    Detalhes do Atendimento:
    - Data/Hora: ${DateFormat('dd/MM/yyyy HH:mm').format(recibo.dataAtendimento)}
    - Serviço: ${recibo.servicoNome}
    - Profissional: ${recibo.barbeiroNome}
    - Forma de Pagamento: ${recibo.formaPagamento}
    - Valor Total: R\$ ${recibo.valor.toStringAsFixed(2)}
    
    Código de Autenticação: ${recibo.codigoAutenticacao}
    
    O recibo completo em PDF está anexado a este e-mail.
    
    Esperamos vê-lo novamente em breve!
    
    GAP Barber & Studio
    Rua Esmeraldino Bandeira, 68, Graças - Brasil
    Tel: (81) 99999-9999
    ''';
  }
  
  /// Creates a temporary PDF file attachment for email
  static Future<FileAttachment> _createPDFAttachment(Uint8List pdfBytes, String reciboId) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/recibo_$reciboId.pdf');
      await file.writeAsBytes(pdfBytes);
      
      _logger.d('PDF temporário criado: ${file.path}');
      
      return FileAttachment(
        file,
        fileName: 'recibo_$reciboId.pdf',
        contentType: 'application/pdf',
      );
    } catch (e, stackTrace) {
      _logger.e('Erro ao criar anexo PDF', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}