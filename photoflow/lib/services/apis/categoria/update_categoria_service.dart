// File: lib/services/categoria_servico/update_categoria_service.dart

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:photoflow/environments/environments.dart';

/// Atualiza uma categoria de serviço existente.
///
/// Corresponde a `PUT /categorias/:id`.
/// Retorna a `Response` do servidor em caso de sucesso ou `null` em caso de falha.
Future<Response?> updateCategoriaService(
    {required int id,
    required String nome,
    required String descricao,
    required String token}) async {
  final _httpClient = Dio();

  try {
    final response = await _httpClient
        .put(
          Environments.categoriaById(id),
          data: {
            'nome': nome,
            'descricao': descricao,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      print("Categoria ID $id atualizada com sucesso.");
    }
    return response;
  } on DioException catch (e) {
    print("Erro de rede (Dio) ao atualizar categoria ID $id:");
    if (e.response != null) {
      print("Status Code: ${e.response?.statusCode}");
      print("Data: ${e.response?.data}");
    } else {
      print("Erro de requisição: ${e.message}");
    }
    return null;
  } catch (e) {
    print("Erro inesperado em updateCategoriaService: $e");
    return null;
  }
}