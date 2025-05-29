class EtapaProjeto {
  int id;
  String nome;
  int? horas;

  EtapaProjeto({
    required this.id,
    required this.nome,
    this.horas,
  });

  factory EtapaProjeto.fromJson(Map<String, dynamic> json) {
    return EtapaProjeto(
      id: json['id'] as int,
      nome: json['nome'] as String,
      horas: json['horas'] != null ? json['horas'] as int : null,
    );
  }
}
