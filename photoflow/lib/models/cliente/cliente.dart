class Cliente {
  String? id;
  String nome;
  String? email;
  String? telefone;

  Cliente({
    this.id,
    required this.nome,
    this.email,
    this.telefone,
  });
  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'] as String,
      nome: json['nome'] as String,
      email: json['email'] as String,
      telefone: json['telefone'] as String,
    );
  }
  @override
  String toString() {
    return 'Cliente{id: $id, nome: $nome, email: $email, telefone: $telefone}';
  }
}
