import 'dart:io';
import 'package:flutter/foundation.dart';

/// Classe utilitária para analisar e corrigir problemas comuns de código
class CodeAnalyzer {
  /// Lista de problemas encontrados
  final List<CodeIssue> issues = [];
  
  /// Diretório raiz do projeto
  final String rootDir;
  
  CodeAnalyzer(this.rootDir);
  
  /// Analisa todos os arquivos Dart no projeto
  Future<void> analyzeProject() async {
    final dartFiles = await _findDartFiles();
    
    for (final file in dartFiles) {
      await analyzeFile(file);
    }
    
    _printSummary();
  }
  
  /// Encontra todos os arquivos Dart no projeto
  Future<List<File>> _findDartFiles() async {
    final List<File> dartFiles = [];
    
    await _traverseDirectory(Directory(rootDir), (file) {
      if (file.path.endsWith('.dart') && 
          !file.path.contains('.dart_tool') &&
          !file.path.contains('.pub-cache') &&
          !file.path.contains('build/')) {
        dartFiles.add(file);
      }
    });
    
    return dartFiles;
  }
  
  /// Percorre recursivamente um diretório
  Future<void> _traverseDirectory(Directory directory, Function(File) onFile) async {
    try {
      final entities = directory.listSync();
      
      for (final entity in entities) {
        if (entity is File) {
          onFile(entity);
        } else if (entity is Directory) {
          await _traverseDirectory(entity, onFile);
        }
      }
    } catch (e) {
      debugPrint('Erro ao percorrer diretório: $e');
    }
  }
  
  /// Analisa um arquivo específico
  Future<void> analyzeFile(File file) async {
    try {
      final content = await file.readAsString();
      final lines = content.split('\n');
      
      _checkUnusedImports(file.path, content, lines);
      _checkMissingNullSafety(file.path, content, lines);
      _checkLongMethods(file.path, content, lines);
      _checkComplexWidgetTrees(file.path, content, lines);
      _checkMissingDocumentation(file.path, content, lines);
      _checkHardcodedStrings(file.path, content, lines);
    } catch (e) {
      debugPrint('Erro ao analisar arquivo ${file.path}: $e');
    }
  }
  
  /// Verifica imports não utilizados
  void _checkUnusedImports(String filePath, String content, List<String> lines) {
    final importRegex = RegExp(r'import\s+[\'"](.+?)[\'"];');
    final matches = importRegex.allMatches(content);
    
    for (final match in matches) {
      final importPath = match.group(1)!;
      final importName = importPath.split('/').last.replaceAll('.dart', '');
      
      // Verifica se o import é usado no código
      final usageRegex = RegExp('\\b$importName\\b');
      if (!usageRegex.hasMatch(content.substring(match.end))) {
        issues.add(CodeIssue(
          filePath: filePath,
          line: _getLineNumber(lines, match.start),
          message: 'Import não utilizado: $importPath',
          severity: IssueSeverity.warning,
          type: IssueType.unusedImport,
        ));
      }
    }
  }
  
  /// Verifica falta de null safety
  void _checkMissingNullSafety(String filePath, String content, List<String> lines) {
    final nonNullSafetyRegex = RegExp(r'@required\b');
    final matches = nonNullSafetyRegex.allMatches(content);
    
    for (final match in matches) {
      issues.add(CodeIssue(
        filePath: filePath,
        line: _getLineNumber(lines, match.start),
        message: 'Use "required" em vez de "@required" para null safety',
        severity: IssueSeverity.warning,
        type: IssueType.nullSafety,
      ));
    }
  }
  
  /// Verifica métodos muito longos
  void _checkLongMethods(String filePath, String content, List<String> lines) {
    final methodRegex = RegExp(r'(\w+)\s+(\w+)\s*\([^)]*\)\s*{');
    final matches = methodRegex.allMatches(content);
    
    for (final match in matches) {
      final methodName = match.group(2);
      final methodStart = match.start;
      
      // Encontra o fim do método
      int bracketCount = 1;
      int methodEnd = methodStart + match.group(0)!.length;
      
      while (bracketCount > 0 && methodEnd < content.length) {
        if (content[methodEnd] == '{') bracketCount++;
        if (content[methodEnd] == '}') bracketCount--;
        methodEnd++;
      }
      
      final methodContent = content.substring(methodStart, methodEnd);
      final methodLines = methodContent.split('\n').length;
      
      if (methodLines > 50) {
        issues.add(CodeIssue(
          filePath: filePath,
          line: _getLineNumber(lines, methodStart),
          message: 'Método $methodName muito longo ($methodLines linhas)',
          severity: IssueSeverity.warning,
          type: IssueType.longMethod,
        ));
      }
    }
  }
  
  /// Verifica árvores de widgets muito complexas
  void _checkComplexWidgetTrees(String filePath, String content, List<String> lines) {
    if (!filePath.contains('widget') && !filePath.contains('screen')) {
      return;
    }
    
    final nestedWidgetsRegex = RegExp(r'(Child|Builder|Container|Column|Row|Stack)\(');
    final matches = nestedWidgetsRegex.allMatches(content);
    
    // Conta a profundidade de aninhamento
    int maxDepth = 0;
    int currentDepth = 0;
    int deepestWidgetPosition = 0;
    
    for (int i = 0; i < content.length; i++) {
      if (content[i] == '(') {
        currentDepth++;
        if (currentDepth > maxDepth) {
          maxDepth = currentDepth;
          deepestWidgetPosition = i;
        }
      } else if (content[i] == ')') {
        currentDepth--;
      }
    }
    
    if (maxDepth > 10) {
      issues.add(CodeIssue(
        filePath: filePath,
        line: _getLineNumber(lines, deepestWidgetPosition),
        message: 'Árvore de widgets muito complexa (profundidade $maxDepth)',
        severity: IssueSeverity.warning,
        type: IssueType.complexWidgetTree,
      ));
    }
  }
  
  /// Verifica falta de documentação
  void _checkMissingDocumentation(String filePath, String content, List<String> lines) {
    final classRegex = RegExp(r'class\s+(\w+)');
    final matches = classRegex.allMatches(content);
    
    for (final match in matches) {
      final className = match.group(1);
      final lineNumber = _getLineNumber(lines, match.start);
      
      // Verifica se há documentação antes da classe
      bool hasDocumentation = false;
      for (int i = lineNumber - 1; i >= 0 && i >= lineNumber - 5; i--) {
        if (i < lines.length && lines[i].trim().startsWith('///')) {
          hasDocumentation = true;
          break;
        }
      }
      
      if (!hasDocumentation) {
        issues.add(CodeIssue(
          filePath: filePath,
          line: lineNumber,
          message: 'Classe $className sem documentação',
          severity: IssueSeverity.info,
          type: IssueType.missingDocumentation,
        ));
      }
    }
  }
  
  /// Verifica strings hardcoded
  void _checkHardcodedStrings(String filePath, String content, List<String> lines) {
    if (!filePath.contains('widget') && !filePath.contains('screen')) {
      return;
    }
    
    final hardcodedStringRegex = RegExp(r'Text\(\s*[\'"](.{10,}?)[\'"]');
    final matches = hardcodedStringRegex.allMatches(content);
    
    for (final match in matches) {
      final string = match.group(1);
      
      issues.add(CodeIssue(
        filePath: filePath,
        line: _getLineNumber(lines, match.start),
        message: 'String hardcoded: "$string"',
        severity: IssueSeverity.info,
        type: IssueType.hardcodedString,
      ));
    }
  }
  
  /// Obtém o número da linha a partir da posição no texto
  int _getLineNumber(List<String> lines, int position) {
    int currentPos = 0;
    for (int i = 0; i < lines.length; i++) {
      currentPos += lines[i].length + 1; // +1 para o caractere de nova linha
      if (currentPos > position) {
        return i + 1;
      }
    }
    return 1;
  }
  
  /// Imprime um resumo dos problemas encontrados
  void _printSummary() {
    final totalIssues = issues.length;
    final warnings = issues.where((i) => i.severity == IssueSeverity.warning).length;
    final infos = issues.where((i) => i.severity == IssueSeverity.info).length;
    
    print('\n===== ANÁLISE DE CÓDIGO =====');
    print('Total de problemas: $totalIssues');
    print('Avisos: $warnings');
    print('Informações: $infos');
    print('\nTipos de problemas:');
    
    final issueTypes = <IssueType, int>{};
    for (final issue in issues) {
      issueTypes[issue.type] = (issueTypes[issue.type] ?? 0) + 1;
    }
    
    for (final type in issueTypes.keys) {
      print('- ${_issueTypeToString(type)}: ${issueTypes[type]}');
    }
    
    print('\nArquivos com mais problemas:');
    final fileIssues = <String, int>{};
    for (final issue in issues) {
      final fileName = issue.filePath.split('/').last;
      fileIssues[fileName] = (fileIssues[fileName] ?? 0) + 1;
    }
    
    final sortedFiles = fileIssues.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    for (int i = 0; i < sortedFiles.length && i < 5; i++) {
      print('- ${sortedFiles[i].key}: ${sortedFiles[i].value} problemas');
    }
    
    print('=============================\n');
  }
  
  /// Converte um tipo de problema para string
  String _issueTypeToString(IssueType type) {
    switch (type) {
      case IssueType.unusedImport:
        return 'Imports não utilizados';
      case IssueType.nullSafety:
        return 'Problemas de null safety';
      case IssueType.longMethod:
        return 'Métodos muito longos';
      case IssueType.complexWidgetTree:
        return 'Árvores de widgets complexas';
      case IssueType.missingDocumentation:
        return 'Falta de documentação';
      case IssueType.hardcodedString:
        return 'Strings hardcoded';
      default:
        return 'Outro';
    }
  }
}

/// Representa um problema encontrado no código
class CodeIssue {
  final String filePath;
  final int line;
  final String message;
  final IssueSeverity severity;
  final IssueType type;
  
  CodeIssue({
    required this.filePath,
    required this.line,
    required this.message,
    required this.severity,
    required this.type,
  });
}

/// Severidade do problema
enum IssueSeverity {
  info,
  warning,
  error,
}

/// Tipo de problema
enum IssueType {
  unusedImport,
  nullSafety,
  longMethod,
  complexWidgetTree,
  missingDocumentation,
  hardcodedString,
}