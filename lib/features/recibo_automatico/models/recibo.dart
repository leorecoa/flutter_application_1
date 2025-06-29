class Recibo {
  final String id;
  final String clienteNome;
  final String clienteEmail;
  final String clienteTelefone;
  final String servicoNome;
  final String barbeiroNome;
  final double valor;
  final String formaPagamento;
  final DateTime dataAtendimento;
  final String codigoAutenticacao;
  final String? observacoes;
  final String pdfUrl;

  const Recibo({
    required this.id,
    required this.clienteNome,
    required this.clienteEmail,
    required this.clienteTelefone,
    required this.servicoNome,
    required this.barbeiroNome,
    required this.valor,
    required this.formaPagamento,
    required this.dataAtendimento,
    required this.codigoAutenticacao,
    required this.pdfUrl,
    this.observacoes,
  });

  static String gerarCodigoAutenticacao() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'GAP-${DateTime.now().year}-$random';
  }
}