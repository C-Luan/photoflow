import 'package:photoflow/models/tiposervico/tiposervico.dart';

class Agendamento {
  String id;
  String nome;
  String email;
  String telefone;
  DateTime data;
  String servico;
  Tiposervico? tipoServico;
  Agendamento({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.data,
    required this.servico,
    this.tipoServico,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'data': data,
      'servico': servico,
    };
  }

  @override
  String toString() {
    return 'Agendamento{id: $id, nome: $nome, email: $email, telefone: $telefone, data: $data, servico: $servico}';
  }
}
