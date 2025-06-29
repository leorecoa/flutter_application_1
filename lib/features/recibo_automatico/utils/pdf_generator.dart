import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/recibo.dart';

class PDFGenerator {
  static Future<Uint8List> gerarReciboPDF(Recibo recibo) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              pw.SizedBox(height: 20),
              _buildBarbeariInfo(),
              pw.SizedBox(height: 20),
              _buildClienteInfo(recibo),
              pw.SizedBox(height: 20),
              _buildServicoInfo(recibo),
              pw.SizedBox(height: 20),
              _buildPagamentoInfo(recibo),
              pw.SizedBox(height: 30),
              _buildTotal(recibo),
              pw.SizedBox(height: 20),
              _buildAutenticacao(recibo),
              pw.Spacer(),
              _buildAssinatura(),
            ],
          );
        },
      ),
    );

    return pdf.save();
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
          pw.Container(
            width: 100,
            height: 2,
            color: PdfColors.blue900,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildBarbeariInfo() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'GAP Barber & Studio',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text('CNPJ: 12.345.678/0001-90'),
          pw.Text('Rua Esmeraldino Bandeira, 68, Graças - Brasil'),
          pw.Text('Tel: (81) 99999-9999'),
          pw.Text('Email: contato@gapbarber.com.br'),
        ],
      ),
    );
  }

  static pw.Widget _buildClienteInfo(Recibo recibo) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'DADOS DO CLIENTE',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 8),
        _buildInfoRow('Nome:', recibo.clienteNome),
        _buildInfoRow('Email:', recibo.clienteEmail),
        _buildInfoRow('Telefone:', recibo.clienteTelefone),
        _buildInfoRow('Data/Hora:', DateFormat('dd/MM/yyyy HH:mm').format(recibo.dataAtendimento)),
      ],
    );
  }

  static pw.Widget _buildServicoInfo(Recibo recibo) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'SERVIÇO PRESTADO',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 8),
        _buildInfoRow('Serviço:', recibo.servicoNome),
        _buildInfoRow('Profissional:', recibo.barbeiroNome),
        if (recibo.observacoes != null)
          _buildInfoRow('Observações:', recibo.observacoes!),
      ],
    );
  }

  static pw.Widget _buildPagamentoInfo(Recibo recibo) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'INFORMAÇÕES DE PAGAMENTO',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 8),
        _buildInfoRow('Forma de Pagamento:', recibo.formaPagamento),
        _buildInfoRow('Data do Pagamento:', DateFormat('dd/MM/yyyy HH:mm').format(recibo.dataAtendimento)),
      ],
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
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

  static pw.Widget _buildTotal(Recibo recibo) {
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
            'VALOR TOTAL PAGO:',
            style: pw.TextStyle(
              fontSize: 16,
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

  static pw.Widget _buildAutenticacao(Recibo recibo) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.blue900),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'CÓDIGO DE AUTENTICAÇÃO',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            recibo.codigoAutenticacao,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildAssinatura() {
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
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          'Assinatura Digital',
          style: const pw.TextStyle(fontSize: 10),
        ),
      ],
    );
  }
}