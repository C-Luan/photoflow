import 'package:photoflow/models/tiposervico/tiposervico.dart';

class Agendamento {
  String? id;
  String nome;
  String email;
  String telefone;
  DateTime data;
  int servico;
  String? observacoes;
  Tiposervico? tipoServico;
  Agendamento({
    this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.data,
    this.observacoes,
    required this.servico,
    this.tipoServico,
  });

  factory Agendamento.fromJson(Map<String, dynamic> json) {
    return Agendamento(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      telefone: json['telefone'],
      data: DateTime.parse(json['data']),
      observacoes: json['observacoes'],
      servico: json['tipoServicoId'],
      tipoServico: json['tipoServico'] == null
          ? null
          : Tiposervico.fromJson(json['tipoServico']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'data': data.toIso8601String(),
      'observacoes': observacoes,
      'tipoServicoId': servico,
    };
  }

  @override
  String toString() {
    return 'Agendamento{id: $id, nome: $nome, email: $email, telefone: $telefone, data: $data, servico: $servico}';
  }
}
