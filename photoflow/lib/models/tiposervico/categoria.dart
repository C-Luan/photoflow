import 'dart:developer';

import 'package:photoflow/models/tiposervico/tiposervico.dart';

class CategoriaServico {
  final int id;
  final String nome;
  final String descricao;
  final List<Tiposervico> tiposServicos;

  CategoriaServico({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.tiposServicos,
  });

  @override
  String toString() {
    return 'CategoriaServico{id: $id, nome: $nome, descricao: $descricao, tipos: ${tiposServicos.length}}';
  }

  /// Construtor de fábrica ajustado para receber a lista de Tipos de Serviço.
  factory CategoriaServico.fromJson(Map<String, dynamic> json) {
    // 1. Pega a lista de 'tiposServicos' do JSON.
    //    Usamos 'as List? ?? []' para garantir que, se a chave não existir ou for nula,
    //    teremos uma lista vazia em vez de um erro.
    var tiposJsonList = json['tiposServico'] as List? ?? [];

    // 2. Mapeia a lista de JSON para uma lista de objetos Tiposervico.
    //    Para cada 'item' na lista JSON, ele chama 'Tiposervico.fromJson'.
    List<Tiposervico> tiposServicosList = tiposJsonList
        .map((item) => Tiposervico.fromJson(item as Map<String, dynamic>))
        .toList();

    // 3. Retorna a instância de CategoriaServico com a lista já convertida.
    return CategoriaServico(
      id: json['id'] as int,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String,
      tiposServicos: tiposServicosList, // Usa a lista processada.
    );
  }
}
