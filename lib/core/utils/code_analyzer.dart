import 'dart:io';

/// Analisador de código para o projeto
class CodeAnalyzer {
  final String rootPath;

  CodeAnalyzer(this.rootPath);

  /// Analisa o projeto inteiro
  Future<void> analyzeProject() async {
    print('Analisando projeto em: $rootPath');

    // Lista de diretórios para analisar
    final directories = ['lib', 'test'];

    for (final dir in directories) {
      final dirPath = '$rootPath/$dir';
      if (Directory(dirPath).existsSync()) {
        await _analyzeDirectory(dirPath);
      }
    }
  }

  /// Analisa um diretório específico
  Future<void> _analyzeDirectory(String dirPath) async {
    print('Analisando diretório: $dirPath');

    final dir = Directory(dirPath);
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        await _analyzeFile(entity);
      }
    }
  }

  /// Analisa um arquivo específico
  Future<void> _analyzeFile(File file) async {
    try {
      final content = await file.readAsString();

      // Análises básicas
      _checkFileSize(file, content);
      _checkImportStatements(content);
      _checkCodeComplexity(content);
    } catch (e) {
      print('Erro ao analisar arquivo ${file.path}: $e');
    }
  }

  /// Verifica o tamanho do arquivo
  void _checkFileSize(File file, String content) {
    final lines = content.split('\n').length;
    if (lines > 500) {
      print('⚠️  Arquivo muito grande: ${file.path} ($lines linhas)');
    }
  }

  /// Verifica as declarações de import
  void _checkImportStatements(String content) {
    final importLines = content
        .split('\n')
        .where((line) => line.trim().startsWith('import'))
        .length;

    if (importLines > 20) {
      print('⚠️  Muitos imports detectados ($importLines)');
    }
  }

  /// Verifica a complexidade do código
  void _checkCodeComplexity(String content) {
    final methods = RegExp(
      r'void\s+\w+\s*\(|Future<.*>\s+\w+\s*\(',
    ).allMatches(content).length;

    if (methods > 10) {
      print('⚠️  Muitos métodos detectados ($methods)');
    }
  }
}
