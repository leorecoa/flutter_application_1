import 'package:flutter_test/flutter_test.dart';
import 'package:agenda_facil/features/recibo_robusto/models/recibo_model.dart';
import 'package:agenda_facil/features/recibo_robusto/utils/pdf_generator.dart';

void main() {
  group('PDFGenerator Tests', () {
    late ReciboModel reciboTeste;

    setUp(() {
      reciboTeste = ReciboModel(
        id: 'TEST-001',
        clienteNome: 'João Silva',
        clienteEmail: 'joao@teste.com',
        servicoNome: 'Corte + Barba',
        valor: 55.0,
        data: DateTime(2024, 12, 15, 14, 30),
        assinaturaDigital: 'GAP-12345678',
        observacoes: 'Cliente preferencial',
      );
    });

    test('deve gerar PDF com sucesso', () async {
      // Act
      final pdfBytes = await PDFGenerator.gerarReciboPDF(reciboTeste);

      // Assert
      expect(pdfBytes, isNotNull);
      expect(pdfBytes.length, greaterThan(0));
      expect(pdfBytes.runtimeType.toString(), 'Uint8List');
    });

    test('deve gerar PDF com dados corretos', () async {
      // Act
      final pdfBytes = await PDFGenerator.gerarReciboPDF(reciboTeste);

      // Assert
      expect(pdfBytes.length, greaterThan(1000)); // PDF mínimo
      // Verificar se é um PDF válido (começa com %PDF)
      final pdfHeader = String.fromCharCodes(pdfBytes.take(4));
      expect(pdfHeader, equals('%PDF'));
    });

    test('deve gerar PDF mesmo sem observações', () async {
      // Arrange
      final reciboSemObservacoes = ReciboModel(
        id: 'TEST-002',
        clienteNome: 'Maria Santos',
        clienteEmail: 'maria@teste.com',
        servicoNome: 'Corte',
        valor: 35.0,
        data: DateTime.now(),
        assinaturaDigital: 'GAP-87654321',
      );

      // Act
      final pdfBytes = await PDFGenerator.gerarReciboPDF(reciboSemObservacoes);

      // Assert
      expect(pdfBytes, isNotNull);
      expect(pdfBytes.length, greaterThan(0));
    });

    test('deve lançar exceção com dados inválidos', () async {
      // Arrange
      final reciboInvalido = ReciboModel(
        id: '',
        clienteNome: '',
        clienteEmail: '',
        servicoNome: '',
        valor: -1,
        data: DateTime.now(),
        assinaturaDigital: '',
      );

      // Act & Assert
      expect(
        () async => await PDFGenerator.gerarReciboPDF(reciboInvalido),
        throwsA(isA<Exception>()),
      );
    });
  });
}