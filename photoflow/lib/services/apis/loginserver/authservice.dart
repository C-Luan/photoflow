import 'package:dio/dio.dart';
import 'package:photoflow/environments/environments.dart';

class AuthserviceVps {
  final _httpClient = Dio();

  // A função agora pode retornar um valor nulo em caso de falha.
  Future<Response?> authService(String tokenFirebase) async {
    try {
      // A chamada de rede está dentro de um bloco try/catch.
      final response = await _httpClient
          .post(
            Environments.login,
            options: Options(
              headers: {
                // 1. Cabeçalho "Authorization" com "A" maiúsculo (melhor prática).
                'Authorization': 'Bearer $tokenFirebase',
                // 2. O cabeçalho "Content-Type" foi removido pois não há corpo na requisição.
              },
            ),
          )
          .timeout(const Duration(seconds: 30));

      // Verificação explícita de sucesso
      if (response.statusCode == 200) {
        print("Servidor VPS confirmou o token com sucesso.");
      }

      return response;
    } on DioException catch (e) {
      // 3. Captura erros específicos do Dio para um debug mais detalhado.
      print("Erro de rede (Dio) ao chamar o serviço de autenticação:");
      // Imprime a resposta do servidor se houver uma (ex: erro 401, 403)
      if (e.response != null) {
        print("Status Code: ${e.response?.statusCode}");
        print("Data: ${e.response?.data}");
      } else {
        // Erro de conexão, timeout, etc.
        print("Erro de requisição: ${e.message}");
      }
      return null; // Retorna nulo para indicar falha.
    } catch (e) {
      // Captura qualquer outro erro inesperado.
      print("Erro inesperado no authService: $e");
      return null;
    }
  }
}
