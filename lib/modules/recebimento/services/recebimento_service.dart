import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/api_client.dart';

class RecebimentoService {
  final ApiClient client;
  RecebimentoService(this.client);

  Future<List<dynamic>> listarRecebimentos() async {
    final resp = await client.dio.get('/api/recebimentos');
    if (resp.statusCode == 200) return resp.data as List;
    throw Exception('Falha ao listar recebimentos');
  }

  Future<Map<String, dynamic>> detalhes(int id) async {
    final resp = await client.dio.get('/api/recebimentos/$id');
    return resp.data as Map<String, dynamic>;
  }

  Future<String> uploadFotoInicio(int id, File foto) async {
    final form = FormData.fromMap({
      'foto': await MultipartFile.fromFile(foto.path, filename: 'inicio.jpg'),
    });
    final resp = await client.dio.post('/api/recebimentos/$id/foto-inicio', data: form);
    return resp.data['path'] as String;
  }

  Future<String> uploadFotoFim(int id, File foto) async {
    final form = FormData.fromMap({
      'foto': await MultipartFile.fromFile(foto.path, filename: 'fim.jpg'),
    });
    final resp = await client.dio.post('/api/recebimentos/$id/foto-fim', data: form);
    return resp.data['path'] as String;
  }

  Future<void> finalizar(int id, {File? fotoFim, String? assinaturaBase64}) async {
    final form = FormData.fromMap({
      'confirmacao': '1',
      if (fotoFim != null)
        'foto_fim_veiculo': await MultipartFile.fromFile(fotoFim.path, filename: 'fim.jpg'),
      if (assinaturaBase64 != null) 'assinatura': assinaturaBase64,
    });
    await client.dio.post('/api/recebimentos/$id/finalizar', data: form);
  }
}
