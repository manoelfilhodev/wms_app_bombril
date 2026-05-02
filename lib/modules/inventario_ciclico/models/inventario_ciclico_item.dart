class InventarioCiclicoItem {
  final int idItem;
  final String? material;
  final String? descricao;
  final String? posicao;
  final double quantidadeSistema;
  final double? quantidadeFisica;
  final String? tipoAjuste;
  final int necessitaAjuste;
  final int ajustado;
  final int? contadoPor;
  final String? updatedAt;

  const InventarioCiclicoItem({
    required this.idItem,
    this.material,
    this.descricao,
    this.posicao,
    required this.quantidadeSistema,
    this.quantidadeFisica,
    this.tipoAjuste,
    required this.necessitaAjuste,
    required this.ajustado,
    this.contadoPor,
    this.updatedAt,
  });

  factory InventarioCiclicoItem.fromJson(Map<String, dynamic> json) {
    return InventarioCiclicoItem(
      idItem: _toInt(json['id_item'] ?? json['item_id'] ?? json['id']),
      material: _toStringOrNull(json['material'] ?? json['sku'] ?? json['ean']),
      descricao: _toStringOrNull(
        json['descricao'] ?? json['description'] ?? json['nome'],
      ),
      posicao: _toStringOrNull(
        json['posicao'] ?? json['ficha'] ?? json['endereco'],
      ),
      quantidadeSistema: _toDouble(
        json['quantidade_sistema'] ??
            json['qtd_sistema'] ??
            json['quantidadeSistema'] ??
            json['quantidade'],
      ),
      quantidadeFisica: _toNullableDouble(
        json['quantidade_fisica'] ??
            json['qtd_fisica'] ??
            json['quantidadeFisica'],
      ),
      tipoAjuste: _toStringOrNull(json['tipo_ajuste'] ?? json['tipoAjuste']),
      necessitaAjuste: _toInt(
        json['necessita_ajuste'] ?? json['necessitaAjuste'],
      ),
      ajustado: _toInt(json['ajustado']),
      contadoPor: _toNullableInt(json['contado_por'] ?? json['contadoPor']),
      updatedAt: _toStringOrNull(json['updated_at'] ?? json['updatedAt']),
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

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    return _toInt(value);
  }

  static double _toDouble(dynamic value, {double fallback = 0}) {
    if (value == null) return fallback;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final normalized = value.replaceAll(',', '.');
      final parsed = double.tryParse(normalized);
      if (parsed != null) return parsed;
    }
    return fallback;
  }

  static double? _toNullableDouble(dynamic value) {
    if (value == null) return null;
    return _toDouble(value);
  }

  static String? _toStringOrNull(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
