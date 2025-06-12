import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:photoflow/environments/environments.dart';

Future<Response?> updateProjetoService(String id, Map data) async {
  final httpClient = Dio();
  String? token = await FirebaseAuth.instance.currentUser?.getIdToken();

  if (token == null) return null;

  try {
    final response = await httpClient.put(
      Environments.projetoById(id),
      data: data,
      options: Options(headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      }),
    );

    return response;
  } catch (e) {
    if (kDebugMode) print("Erro ao atualizar projeto: $e");
    return null;
  }
}
