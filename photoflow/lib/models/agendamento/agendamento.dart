import 'package:photoflow/models/cliente/cliente.dart';
import 'package:photoflow/models/tiposervico/tiposervico.dart';

class Agendamento {
  String? id;
  Cliente cliente;
  String email;
  String telefone;
  DateTime data;
  int servico;
  String? observacoes;
  Tiposervico? tipoServico;
  Agendamento({
    this.id,
    required this.cliente,
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
      cliente: Cliente.fromJson(json['cliente']),
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
      'clienteId': cliente.id,
      'email': email,
      'telefone': telefone,
      'data': data.toIso8601String(),
      'observacoes': observacoes,
      'tipoServicoId': servico,
    };
  }

  @override
  String toString() {
    return 'Agendamento{id: $id, nome: ${cliente.nome}, email: $email, telefone: $telefone, data: $data, servico: $servico}';
  }
}
