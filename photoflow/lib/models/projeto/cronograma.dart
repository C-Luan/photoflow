class CronogramaProjeto {
  final DateTime data;
  final String evento;
  bool concluido = true;
  CronogramaProjeto({
    required this.data,
    this.concluido = true,
    required this.evento,
  });
  factory CronogramaProjeto.fromJson(Map<String, dynamic> json) {
    return CronogramaProjeto(
      data: DateTime.parse(json['data'] as String),
      evento: json['descricao'] as String,
      concluido: json['concluido'] as bool? ?? true,
    );
  }
  @override
  String toString() {
    return 'CronogramaProjeto{  dataInicio: $data, descricao: $evento}';
  }
}
