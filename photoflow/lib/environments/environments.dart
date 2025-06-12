class Environments {
  static const String _baseURL = 'http://localhost:3000';

  //🔹 Endpoints de Autenticação e Usuários
  static const String login = '$_baseURL/login';

  //🔹 Endpoints de Categorias de Serviço
  static const String categorias = '$_baseURL/categorias';
  static const String clientes = '$_baseURL/clientes';
  static const String etapaprojeto = '$_baseURL/etapaprojeto';
  static const String agendamentos = '$_baseURL/agendamentos';

  //🔹 Endpoints de Projetos
  static const String projetos = '$_baseURL/projetos';

  static String projetoById(String id) {
    return '$_baseURL/projetos/$id';
  }

  static String categoriaById(int id) {
    return '$_baseURL/categorias/$id';
  }
}
