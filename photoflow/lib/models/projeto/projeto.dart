import 'package:photoflow/models/projeto/cronograma.dart';
import 'package:photoflow/models/projeto/equipe_projeto.dart';
import 'package:photoflow/models/projeto/etapa_projeto.dart';
import 'package:photoflow/models/tiposervico/categoria.dart';
import 'package:photoflow/models/tiposervico/tiposervico.dart';

import '../cliente/cliente.dart';

class Projeto {
  Cliente cliente;
  double valor;

  Tiposervico tipoServico;
  EtapaProjeto etapaProjeto;
  CategoriaServico categoriaServico;
  String observacao;
  bool conclusao;
  DateTime dataInicio;
  DateTime? dataFim;
  DateTime prazo;
  bool cancelado;
  bool pendente;
  List<EquipeProjeto> equipe;
  List<CronogramaProjeto> cronograma;
  Projeto({
    required this.cliente,
    required this.tipoServico,
    required this.etapaProjeto,
    required this.categoriaServico,
    required this.observacao,
    required this.conclusao,
    required this.dataInicio,
    required this.prazo,
    required this.valor,
    this.equipe = const [],
    this.cronograma = const [],
    this.dataFim,
    this.pendente = false,
    this.cancelado = false,
  });

  factory Projeto.fromJson(Map<String, dynamic> json) {
    return Projeto(
      cliente: Cliente.fromJson(json['cliente']),
      tipoServico: Tiposervico.fromJson(json['tiposervico']),
      categoriaServico: CategoriaServico.fromJson(json['categoriaServico']),
      etapaProjeto: EtapaProjeto.fromJson(json['etapaProjeto']),
      observacao: json['observacao'] as String,
      conclusao: json['conclusao'] as bool,
      dataInicio: DateTime.parse(json['dataInicio'] as String),
      equipe: json['equipe'] != null
          ? (json['equipe'] as List)
              .map((e) => EquipeProjeto.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      dataFim: json['dataFim'] != null
          ? DateTime.parse(json['dataFim'] as String)
          : null,
      prazo: DateTime.parse(json['prazo'] as String),
      valor: (json['valor'] as num).toDouble(),
    );
  }
}
