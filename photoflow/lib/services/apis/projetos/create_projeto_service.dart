import 'dart:async';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:photoflow/environments/environments.dart';

Future<Response?> createProjetoService({required Map data}) async {
  final httpClient = Dio();
  String? token = await FirebaseAuth.instance.currentUser?.getIdToken();

  if (token == null) {
    if (kDebugMode) {
      print("Token não encontrado. Usuário não autenticado.");
    }
    return null;
  }

  try {
    final response = await httpClient
        .post(
          Environments.projetos,
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
        print("Projeto criado com sucesso.");
      }
      return response;
    }

    return response;
  } on DioException catch (e) {
    if (kDebugMode) {
      print("Erro de rede (Dio) ao criar projeto:");
    }
    if (e.response != null) {
      if (kDebugMode) {
        print("Status Code: ${e.response?.statusCode}");
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
      print("Erro inesperado em createProjetoService: $e");
    }
    return null;
  }
}
