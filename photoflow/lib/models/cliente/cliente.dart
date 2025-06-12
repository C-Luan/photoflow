// É necessário ter um modelo Projeto.dart se você for usar a lista de projetos.
// import 'projeto_model.dart';

import '../projeto/projeto.dart';

class Cliente {
  final String? id;
  final String nome;
  final String? email;
  final String? telefone;
  final String? cpf;
  final String? cnpj;
  final String? dataNascimento; // Mantido como String conforme o modelo
  final bool ativo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final List<Projeto>? projetos; // Descomente se você tiver a classe Projeto

  const Cliente({
    this.id,
    required this.nome,
    this.email,
    this.telefone,
    this.cpf,
    this.cnpj,
    this.dataNascimento,
    required this.ativo,
    this.createdAt,
    this.updatedAt,
    this.projetos, // Descomente se você tiver a classe Projeto
  });

  /// Construtor de fábrica para criar uma instância de Cliente a partir de um JSON.
  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'] as String,
      nome: json['nome'] as String,
      email: json['email'] as String?,
      telefone: json['telefone'] as String?,
      cpf: json['cpf'] as String?,
      cnpj: json['cnpj'] as String?,
      dataNascimento: json['datanascimento'] as String?,
      ativo: json['ativo'] ?? true,
      // Converte a string ISO 8601 do JSON para um objeto DateTime do Dart.
      // createdAt: DateTime.parse(json['created_at'] as String),
      // updatedAt: DateTime.parse(json['updated_at'] as String),

      projetos: json['projetos'] != null
          ? (json['projetos'] as List<dynamic>)
              .map((item) => Projeto.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  /// Método para converter a instância de Cliente em um mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'cpf': cpf,
      'cnpj': cnpj,
      'datanascimento': dataNascimento,
      'ativo': ativo,
      // Converte o objeto DateTime do Dart para uma string no formato ISO 8601.
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Cliente(id: $id, nome: $nome, email: $email, telefone: $telefone, cpf: $cpf, cnpj: $cnpj, ativo: $ativo)';
  }
}
