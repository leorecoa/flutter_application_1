import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';

class PdfGenerator {
  static Future<void> generateFinancialReport({
    required BuildContext context,
    required Map<String, dynamic> data,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('RELATÓRIO FINANCEIRO', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Período: ${_formatDate(startDate)} a ${_formatDate(endDate)}'),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Métrica', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Valor', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  pw.TableRow(children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Receita Total')),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('R\$ ${(data['totalRevenue'] ?? 0).toStringAsFixed(2)}')),
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Total de Agendamentos')),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${data['totalAppointments'] ?? 0}')),
                  ]),
                  pw.TableRow(children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Ticket Médio')),
                    pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('R\$ ${(data['averageTicket'] ?? 0).toStringAsFixed(2)}')),
                  ]),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}