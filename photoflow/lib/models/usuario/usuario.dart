class Usuario {
  String? nome;
  String? telefone;
  String email;

  Usuario({this.nome, this.telefone, required this.email});

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      nome: json['nome'] as String?,
      telefone: json['telefone'] as String?,
      email: json['email'] as String,
    );
  }
}
