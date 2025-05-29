class EquipeProjeto {
  final String id;
  final String nome;
  final String funcao;
  
  EquipeProjeto({
    required this.id,
    required this.nome,
    required this.funcao,
  });

  factory EquipeProjeto.fromJson(Map<String, dynamic> json) {
    return EquipeProjeto(
      id: json['id'] as String,
      nome: json['nome'] as String,
      funcao: json['descricao'] as String,
    );
  }
}