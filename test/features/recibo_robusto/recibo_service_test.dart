import 'package:flutter_test/flutter_test.dart';
import 'package:agenda_facil/features/recibo_robusto/models/recibo_model.dart';
import 'package:agenda_facil/features/recibo_robusto/services/recibo_service.dart';

void main() {
  group('ReciboService Tests', () {
    late ReciboModel reciboValido;
    late ReciboModel reciboInvalido;

    setUp(() {
      reciboValido = ReciboModel(
        id: 'TEST-001',
        clienteNome: 'João Silva',
        clienteEmail: 'joao@teste.com',
        servicoNome: 'Corte + Barba',
        valor: 55.0,
        data: DateTime.now(),
        assinaturaDigital: 'GAP-12345678',
      );

      reciboInvalido = ReciboModel(
        id: 'TEST-002',
        clienteNome: '',
        clienteEmail: 'email-invalido',
        servicoNome: '',
        valor: -10.0,
        data: DateTime.now(),
        assinaturaDigital: '',
      );
    });

    group('validarRecibo', () {
      test('deve validar recibo correto', () {
        // Act
        final resultado = ReciboService.validarRecibo(reciboValido);

        // Assert
        expect(resultado, isTrue);
      });

      test('deve rejeitar recibo com nome vazio', () {
        // Arrange
        final recibo = ReciboModel(
          id: 'TEST',
          clienteNome: '',
          clienteEmail: 'teste@email.com',
          servicoNome: 'Corte',
          valor: 30.0,
          data: DateTime.now(),
          assinaturaDigital: 'GAP-123',
        );

        // Act
        final resultado = ReciboService.validarRecibo(recibo);

        // Assert
        expect(resultado, isFalse);
      });

      test('deve rejeitar recibo com email inválido', () {
        // Arrange
        final recibo = ReciboModel(
          id: 'TEST',
          clienteNome: 'João',
          clienteEmail: 'email-sem-arroba',
          servicoNome: 'Corte',
          valor: 30.0,
          data: DateTime.now(),
          assinaturaDigital: 'GAP-123',
        );

        // Act
        final resultado = ReciboService.validarRecibo(recibo);

        // Assert
        expect(resultado, isFalse);
      });

      test('deve rejeitar recibo com valor negativo', () {
        // Arrange
        final recibo = ReciboModel(
          id: 'TEST',
          clienteNome: 'João',
          clienteEmail: 'joao@email.com',
          servicoNome: 'Corte',
          valor: -5.0,
          data: DateTime.now(),
          assinaturaDigital: 'GAP-123',
        );

        // Act
        final resultado = ReciboService.validarRecibo(recibo);

        // Assert
        expect(resultado, isFalse);
      });

      test('deve rejeitar recibo com serviço vazio', () {
        // Arrange
        final recibo = ReciboModel(
          id: 'TEST',
          clienteNome: 'João',
          clienteEmail: 'joao@email.com',
          servicoNome: '',
          valor: 30.0,
          data: DateTime.now(),
          assinaturaDigital: 'GAP-123',
        );

        // Act
        final resultado = ReciboService.validarRecibo(recibo);

        // Assert
        expect(resultado, isFalse);
      });
    });

    group('criarAssinaturaDigital', () {
      test('deve criar assinatura única', () {
        // Act
        final assinatura1 = ReciboService.criarAssinaturaDigital('RECIBO-001');
        final assinatura2 = ReciboService.criarAssinaturaDigital('RECIBO-002');

        // Assert
        expect(assinatura1, isNotEmpty);
        expect(assinatura2, isNotEmpty);
        expect(assinatura1, isNot(equals(assinatura2)));
        expect(assinatura1, startsWith('GAP-'));
        expect(assinatura1.length, equals(12)); // GAP- + 8 caracteres
      });

      test('deve criar assinatura com formato correto', () {
        // Act
        final assinatura = ReciboService.criarAssinaturaDigital('TEST');

        // Assert
        expect(assinatura, matches(RegExp(r'^GAP-[A-Z0-9]{8}$')));
      });
    });

    group('gerarPDF', () {
      test('deve gerar PDF com sucesso', () async {
        // Act
        final pdfBytes = await ReciboService.gerarPDF(reciboValido);

        // Assert
        expect(pdfBytes, isNotNull);
        expect(pdfBytes!.length, greaterThan(0));
      });

      test('deve retornar null em caso de erro', () async {
        // Act
        final pdfBytes = await ReciboService.gerarPDF(reciboInvalido);

        // Assert
        expect(pdfBytes, isNull);
      });
    });
  });
}