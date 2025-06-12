import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photoflow/environments/environments.dart';

Future<Response?> deleteProjetoService(String id) async {
  final httpClient = Dio();
  String? token = await FirebaseAuth.instance.currentUser?.getIdToken();

  if (token == null) return null;

  try {
    return await httpClient.delete(
      Environments.projetoById(id),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  } catch (e) {
    print("Erro ao deletar projeto: $e");
    return null;
  }
}
