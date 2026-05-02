import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/api_client.dart';

class ConferenciaService {
  final ApiClient client;
  ConferenciaService(this.client);

  Future<Map<String, dynamic>> listarItensCego(int recebimentoId) async {
    final resp = await client.dio.get('/api/recebimentos/$recebimentoId/itens-cego');
    return resp.data as Map<String, dynamic>;
  }

  Future<void> salvarItem({
    required int itemId,
    required int qtdConferida,
    required bool avariado,
    String? observacao,
    File? fotoAvaria,
  }) async {
    final form = FormData.fromMap({
      'qtd_conferida': qtdConferida,
      'avariado': avariado ? 1 : 0,
      if (observacao?.isNotEmpty == true) 'observacao': observacao,
      if (fotoAvaria != null)
        'foto_avaria': await MultipartFile.fromFile(fotoAvaria.path, filename: 'avaria.jpg'),
    });

    await client.dio.post('/api/conferencia/item/$itemId', data: form);
  }

  Future<void> fecharConferencia(int recebimentoId) async {
    await client.dio.post('/api/recebimentos/$recebimentoId/fechar');
  }
}
