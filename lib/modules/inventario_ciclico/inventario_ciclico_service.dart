import '../../core/api_client.dart';
import '../../core/config/app_config.dart';
import '../../utils/user_service.dart';
import 'models/inventario_ciclico_requisicao.dart';

class InventarioCiclicoService {
  static const String _baseUrl = AppConfig.apiBaseUrl;

  final ApiClient _apiClient;

  InventarioCiclicoService({ApiClient? apiClient})
    : _apiClient =
          apiClient ??
          ApiClient(baseUrl: _baseUrl, getToken: UserService.getToken);

  Future<List<InventarioCiclicoRequisicao>> getRequisicoes({
    String? status,
  }) async {
    final query = <String, dynamic>{
      if (status != null && status.trim().isNotEmpty) 'status': status.trim(),
    };

    final response = await _apiClient.dio.get(
      '/inventario-ciclico/requisicoes',
      queryParameters: query.isEmpty ? null : query,
    );

    final lista = _extractList(response.data);
    return lista.map(InventarioCiclicoRequisicao.fromJson).toList();
  }

  Future<Map<String, dynamic>> getItens(int idInventario) async {
    final response = await _apiClient.dio.get(
      '/inventario-ciclico/requisicoes/$idInventario/itens',
    );
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> contarItem({
    required int idItem,
    required double quantidadeFisica,
    String? posicao,
  }) async {
    final payload = <String, dynamic>{
      'quantidade_fisica': quantidadeFisica,
      if (posicao != null && posicao.trim().isNotEmpty)
        'posicao': posicao.trim(),
    };

    final response = await _apiClient.dio.post(
      '/inventario-ciclico/itens/$idItem/contar',
      data: payload,
    );
    return _asMap(response.data);
  }

  static List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data.whereType<Map>().map(_normalizeMap).toList();
    }

    if (data is Map) {
      final normalizedData = _normalizeMap(data);
      final nested =
          normalizedData['data'] ??
          normalizedData['requisicoes'] ??
          normalizedData['itens'] ??
          normalizedData['items'];

      if (nested is List) {
        return nested.whereType<Map>().map(_normalizeMap).toList();
      }

      if (normalizedData.containsKey('id') ||
          normalizedData.containsKey('id_inventario') ||
          normalizedData.containsKey('idInventario') ||
          normalizedData.containsKey('cod_requisicao') ||
          normalizedData.containsKey('codRequisicao')) {
        return [normalizedData];
      }
    }

    return const [];
  }

  static Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map) return _normalizeMap(data);
    if (data is List) return {'data': data};
    return {'data': data};
  }

  static Map<String, dynamic> _normalizeMap(Map map) {
    return Map<String, dynamic>.from(map);
  }
}
