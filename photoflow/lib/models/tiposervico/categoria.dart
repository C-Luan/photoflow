class CategoriaServico {
  final int id;
  final String nome;
  final String descricao;

  CategoriaServico({
    required this.id,
    required this.nome,
    required this.descricao,
  });

  @override
  String toString() {
    return 'CategoriaServico{id: $id, nome: $nome, descricao: $descricao}';
  }

  factory CategoriaServico.fromJson(Map<String, dynamic> json) {
    return CategoriaServico(
      id: json['id'] as int,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String,
    );
  }
}
