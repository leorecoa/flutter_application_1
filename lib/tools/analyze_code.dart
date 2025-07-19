import 'dart:io';
import '../core/utils/code_analyzer.dart';

/// Script para analisar o código do projeto
void main() async {
  print('Iniciando análise de código...');
  
  final rootDir = Directory.current.path;
  final analyzer = CodeAnalyzer(rootDir);
  
  await analyzer.analyzeProject();
  
  print('Análise concluída!');
}