class Cliente {
  String id;
  String nome;
  String email;
  String telefone;

  Cliente({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
  });

  @override
  String toString() {
    return 'Cliente{id: $id, nome: $nome, email: $email, telefone: $telefone}';
  }
}