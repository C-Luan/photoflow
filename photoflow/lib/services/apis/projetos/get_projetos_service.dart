import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photoflow/environments/environments.dart';

Future<Response?> getProjetosService() async {
  final httpClient = Dio();
  String? token = await FirebaseAuth.instance.currentUser?.getIdToken();

  if (token == null) return null;

  try {
    return await httpClient.get(
      Environments.projetos,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  } catch (e) {
    print("Erro ao buscar projetos: $e");
    return null;
  }
}
Future<Response?> getProjetoByIdService(String id) async {
  final httpClient = Dio();
  String? token = await FirebaseAuth.instance.currentUser?.getIdToken();

  if (token == null) return null;

  try {
    return await httpClient.get(
      Environments.projetoById(id),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  } catch (e) {
    print("Erro ao buscar projeto por ID: $e");
    return null;
  }
}