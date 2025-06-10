import 'dart:developer';

import 'package:photoflow/models/tiposervico/categoria.dart';

class Tiposervico {
  int? id;
  int categoriaId;
  String nome;
  String descricao;
  String? createdAt;
  String? updatedAt;
  CategoriaServico? categoria;
  Tiposervico({
    this.id,
    required this.categoriaId,
    required this.nome,
    required this.descricao,
    this.createdAt,
    this.categoria,
    this.updatedAt,
  });

  factory Tiposervico.fromJson(Map<String, dynamic> json) {
    log(json.toString());
    return Tiposervico(
      id: json['id'],
      nome: json['nome'],
      categoriaId: json['categoriaId'],
      descricao: json['descricao'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      categoria: json['categoria'] != null
          ? CategoriaServico.fromJson(json['categoria'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'categoria_id': categoriaId,
      'descricao': descricao,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
