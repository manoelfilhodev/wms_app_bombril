class InventarioCiclicoRequisicao {
  final int id;
  final String? codRequisicao;
  final String? dataRequisicao;
  final String? status;
  final String? usuarioCriador;
  final int totalItens;
  final int contados;
  final int progresso;

  const InventarioCiclicoRequisicao({
    required this.id,
    this.codRequisicao,
    this.dataRequisicao,
    this.status,
    this.usuarioCriador,
    required this.totalItens,
    required this.contados,
    required this.progresso,
  });

  factory InventarioCiclicoRequisicao.fromJson(Map<String, dynamic> json) {
    final totalItens = _toInt(
      json['total_itens'] ??
          json['totalItens'] ??
          json['total'] ??
          json['qtd_total'],
    );
    final contados = _toInt(
      json['contados'] ??
          json['itens_contados'] ??
          json['qtd_contados'] ??
          json['total_contados'],
    );

    final progressoApi = _toInt(json['progresso'] ?? json['progress']);
    final progressoCalculado = totalItens > 0
        ? ((contados / totalItens) * 100).round()
        : 0;

    return InventarioCiclicoRequisicao(
      id: _toInt(json['id'] ?? json['id_inventario'] ?? json['idInventario']),
      codRequisicao: _toStringOrNull(
        json['cod_requisicao'] ??
            json['codigo_requisicao'] ??
            json['codRequisicao'] ??
            json['codigo'],
      ),
      dataRequisicao: _toStringOrNull(
        json['data_requisicao'] ??
            json['dataRequisicao'] ??
            json['created_at'] ??
            json['data'],
      ),
      status: _toStringOrNull(json['status']),
      usuarioCriador: _toStringOrNull(
        json['usuario_criador'] ??
            json['usuarioCriador'] ??
            json['criado_por'] ??
            json['nome_usuario'],
      ),
      totalItens: totalItens,
      contados: contados,
      progresso: progressoApi > 0 ? progressoApi : progressoCalculado,
    );
  }

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      final parsedInt = int.tryParse(value);
      if (parsedInt != null) return parsedInt;
      final parsedDouble = double.tryParse(value);
      if (parsedDouble != null) return parsedDouble.round();
    }
    return fallback;
  }

  static String? _toStringOrNull(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
