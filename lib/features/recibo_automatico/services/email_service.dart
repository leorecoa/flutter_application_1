import 'dart:typed_data';
import 'package:intl/intl.dart';
import '../models/recibo.dart';

class EmailService {
  static const String _sesRegion = 'us-east-1';
  static const String _fromEmail = 'noreply@gapbarber.com.br';
  static const String _fromName = 'GAP Barber & Studio';

  static Future<bool> enviarReciboEmail(Recibo recibo, Uint8List pdfBytes) async {
    try {
      final subject = 'Recibo do seu atendimento - GAP Barber & Studio';
      final htmlBody = _buildEmailBody(recibo);
      final textBody = _buildTextBody(recibo);

      // Simulação do envio via AWS SES
      print('📧 Enviando email para: ${recibo.clienteEmail}');
      print('📧 Assunto: $subject');
      print('📧 PDF anexado: ${pdfBytes.length} bytes');

      // Aqui seria a integração real com AWS SES
      /*
      final sesClient = SesClient(
        region: _sesRegion,
        credentials: AwsClientCredentials(
          accessKey: 'YOUR_ACCESS_KEY',
          secretKey: 'YOUR_SECRET_KEY',
        ),
      );

      final message = Message(
        subject: Content(data: subject),
        body: Body(
          html: Content(data: htmlBody),
          text: Content(data: textBody),
        ),
      );

      final destination = Destination(toAddresses: [recibo.clienteEmail]);

      await sesClient.sendEmail(
        source: '$_fromName <$_fromEmail>',
        destination: destination,
        message: message,
        // Anexar PDF aqui
      );
      */

      await Future.delayed(const Duration(seconds: 1)); // Simular delay
      print('✅ Email enviado com sucesso!');
      return true;
    } catch (e) {
      print('❌ Erro ao enviar email: $e');
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
}