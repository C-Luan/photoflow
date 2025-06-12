// File: lib/services/categoria_servico/create_categoria_service.dart

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:photoflow/environments/environments.dart';

Future<Response?> createCategoriaService(
    {required String nome,
    required String descricao,
    required String token}) async {
  final httpClient = Dio();

  try {
    final response = await httpClient
        .post(
          Environments.categorias,
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

    if (response.statusCode == 201) {
      print("Categoria '$nome' criada com sucesso.");
    }
    return response;
  } on DioException catch (e) {
    print("Erro de rede (Dio) ao criar categoria:");
    if (e.response != null) {
      print("Status Code: ${e.response?.statusCode}");
      print("Data: ${e.response?.data}");
    } else {
      print("Erro de requisição: ${e.message}");
    }
    return null;
  } catch (e) {
    print("Erro inesperado em createCategoriaService: $e");
    return null;
  }
}
