import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../../core/services/logger_service.dart';
import '../models/recibo_model.dart';

class PDFGenerator {
  static Future<Uint8List> gerarReciboPDF(ReciboModel recibo) async {
    try {
      LoggerService.info('Iniciando geração de PDF para recibo: ${recibo.id}');
      
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                pw.SizedBox(height: 30),
                _buildReciboInfo(recibo),
                pw.SizedBox(height: 30),
                _buildTotal(recibo),
                pw.Spacer(),
                _buildAssinatura(recibo),
              ],
            );
          },
        ),
      );

      final pdfBytes = await pdf.save();
      LoggerService.info('PDF gerado com sucesso: ${pdfBytes.length} bytes');
      return pdfBytes;
    } catch (e, stackTrace) {
      LoggerService.error('Erro ao gerar PDF', e, stackTrace);
      rethrow;
    }
  }

  static pw.Widget _buildHeader() {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Text(
            'RECIBO DE PAGAMENTO',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'GAP Barber & Studio',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.Text('CNPJ: 12.345.678/0001-90'),
          pw.Text('Rua Esmeraldino Bandeira, 68, Graças - Brasil'),
        ],
      ),
    );
  }

  static pw.Widget _buildReciboInfo(ReciboModel recibo) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'DADOS DO RECIBO',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        _buildInfoRow('Recibo Nº:', recibo.id),
        _buildInfoRow('Cliente:', recibo.clienteNome),
        _buildInfoRow('E-mail:', recibo.clienteEmail),
        _buildInfoRow('Serviço:', recibo.servicoNome),
        _buildInfoRow('Data:', DateFormat('dd/MM/yyyy HH:mm').format(recibo.data)),
        if (recibo.observacoes != null)
          _buildInfoRow('Observações:', recibo.observacoes!),
      ],
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }

  static pw.Widget _buildTotal(ReciboModel recibo) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'VALOR TOTAL:',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            'R\$ ${recibo.valor.toStringAsFixed(2)}',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildAssinatura(ReciboModel recibo) {
    return pw.Column(
      children: [
        pw.Container(
          width: 200,
          height: 1,
          color: PdfColors.grey600,
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          'GAP Barber & Studio',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          'Assinatura Digital: ${recibo.assinaturaDigital}',
          style: const pw.TextStyle(fontSize: 10),
        ),
      ],
    );
  }
}