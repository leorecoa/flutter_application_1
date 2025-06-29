class ReciboModel {
  final String id;
  final String clienteNome;
  final String clienteEmail;
  final String servicoNome;
  final double valor;
  final DateTime data;
  final String assinaturaDigital;
  final String? observacoes;

  const ReciboModel({
    required this.id,
    required this.clienteNome,
    required this.clienteEmail,
    required this.servicoNome,
    required this.valor,
    required this.data,
    required this.assinaturaDigital,
    this.observacoes,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'clienteNome': clienteNome,
    'clienteEmail': clienteEmail,
    'servicoNome': servicoNome,
    'valor': valor,
    'data': data.toIso8601String(),
    'assinaturaDigital': assinaturaDigital,
    'observacoes': observacoes,
  };

  factory ReciboModel.fromJson(Map<String, dynamic> json) => ReciboModel(
    id: json['id'],
    clienteNome: json['clienteNome'],
    clienteEmail: json['clienteEmail'],
    servicoNome: json['servicoNome'],
    valor: json['valor'].toDouble(),
    data: DateTime.parse(json['data']),
    assinaturaDigital: json['assinaturaDigital'],
    observacoes: json['observacoes'],
  );
}