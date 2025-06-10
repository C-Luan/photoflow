// File: lib/services/categoria_servico/create_categoria_service.dart

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:photoflow/environments/environments.dart';

Future<Response?> createAgendamentoService({required Map data}) async {
  final httpClient = Dio();
  String? token = await FirebaseAuth.instance.currentUser!.getIdToken();
  try {
    final response = await httpClient
        .post(
          Environments.agendamentos,
          data: data,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 201) {
      if (kDebugMode) {
        print("Agendamento criado com sucesso.");
      }
    }
    return response;
  } on DioException catch (e) {
    if (kDebugMode) {
      print("Erro de rede (Dio) ao criar categoria:");
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
      print("Erro inesperado em createCategoriaService: $e");
    }
    return null;
  }
}
