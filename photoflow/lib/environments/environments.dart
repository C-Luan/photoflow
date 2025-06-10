class Environments {
  static const String _baseURL = 'http://localhost:3000';

  //🔹 Endpoints de Autenticação e Usuários
  static const String login = '$_baseURL/login';

  //🔹 Endpoints de Categorias de Serviço

  // Usado para:
  // POST /
  // GET /
  static const String categorias = '$_baseURL/categorias';
  static const String agendamentos = '$_baseURL/agendamentos';

  // Usado para rotas que precisam de um ID.
  // A função recebe o ID e constrói a URL dinamicamente.
  // GET /categorias/:id    (buscar uma categoria específica)
  // PUT /categorias/:id    (atualizar uma categoria específica)
  // DELETE /categorias/:id (deletar uma categoria específica)
  static String categoriaById(int id) {
    return '$_baseURL/categorias/$id';
  }
}
