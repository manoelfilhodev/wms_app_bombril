import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/config/app_config.dart';
import '../../utils/user_service.dart';

class ContagemLivreService {
  static Future<bool> salvarContagem(List<Map<String, dynamic>> itens) async {
    try {
      final usuarioId = await UserService.getUserId();
      final token = await UserService.getToken();

      if (usuarioId == null) {
        debugPrint("Usuário não encontrado.");
        return false;
      }

      final response = await http.post(
        AppConfig.apiUri('/contagem-livre'),
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "usuario_id": usuarioId,
          // se quiser depois pode salvar também unidade/empresa aqui
          "itens": itens,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint("Erro API: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Exceção: $e");
      return false;
    }
  }
}
