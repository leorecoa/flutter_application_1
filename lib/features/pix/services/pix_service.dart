class PixService {
  static Future<Map<String, dynamic>> generatePix({
    required String empresaId,
    required double valor,
    required String descricao,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    
    return {
      'transaction_id': 'mock_${DateTime.now().millisecondsSinceEpoch}',
      'pix_code': '00020126580014BR.GOV.BCB.PIX...',
      'valor': valor,
      'vencimento': '2025-08-01',
    };
  }
  
  static Future<List<Map<String, dynamic>>> getHistory() async {
    await Future.delayed(const Duration(seconds: 1));
    
    return [
      {
        'empresa_id': 'clinica-abc-123',
        'valor': 99.90,
        'status': 'PAGO',
        'vencimento': '2025-07-01',
        'descricao': 'Mensalidade Julho 2025',
      },
    ];
  }
}