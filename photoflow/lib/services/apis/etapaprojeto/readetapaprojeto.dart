// File: lib/services/categoria_servico/get_categorias_service.dart

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:photoflow/environments/environments.dart';

Future<Response?> getEtapaprojetoService({required String token}) async {
  final httpClient = Dio();

  try {
    final response = await httpClient
        .get(
          Environments.etapaprojeto,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
            },
          ),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      print("Categorias buscadas com sucesso.");
    }
    return response;
  } on DioException catch (e) {
    if (kDebugMode) {
      print("Erro de rede (Dio) ao buscar categorias:");
    }
    if (e.response != null) {
      if (kDebugMode) {
        print("Status Code: ${e.response?.statusCode}");
      }
      if (kDebugMode) {
        print("Data: ${e.response?.data}");
      }
    } else {
      if (kDebugMode) {
        print("Erro de requisição: ${e.message}");
      }
    }
    return null;
  } catch (e) {
    if (kDebugMode) {
      print("Erro inesperado em getCategoriasService: $e");
    }
    return null;
  }
}
