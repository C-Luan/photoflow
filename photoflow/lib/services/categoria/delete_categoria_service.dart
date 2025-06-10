// File: lib/services/categoria_servico/delete_categoria_service.dart

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:photoflow/environments/environments.dart';

/// Deleta uma categoria de serviço.
///
/// Corresponde a `DELETE /categorias/:id`.
/// Retorna a `Response` do servidor em caso de sucesso ou `null` em caso de falha.
Future<Response?> deleteCategoriaService(
    {required int id, required String token}) async {
  final _httpClient = Dio();

  try {
    final response = await _httpClient
        .delete(
          Environments.categoriaById(id),
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200 || response.statusCode == 204) {
      print("Categoria ID $id deletada com sucesso.");
    }
    return response;
  } on DioException catch (e) {
    print("Erro de rede (Dio) ao deletar categoria ID $id:");
    if (e.response != null) {
      print("Status Code: ${e.response?.statusCode}");
      print("Data: ${e.response?.data}");
    } else {
      print("Erro de requisição: ${e.message}");
    }
    return null;
  } catch (e) {
    print("Erro inesperado em deleteCategoriaService: $e");
    return null;
  }
}
