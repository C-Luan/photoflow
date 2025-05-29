class Pagamento {
  String? id;
  String? idProjeto;
  String? idUsuario;
  String? dataPagamento;
  double? valorPago;
  String? statusPagamento;

  Pagamento({
    this.id,
    this.idProjeto,
    this.idUsuario,
    this.dataPagamento,
    this.valorPago,
    this.statusPagamento,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idProjeto': idProjeto,
      'idUsuario': idUsuario,
      'dataPagamento': dataPagamento,
      'valorPago': valorPago,
      'statusPagamento': statusPagamento,
    };
  }

  Pagamento.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    idProjeto = map['idProjeto'];
    idUsuario = map['idUsuario'];
    dataPagamento = map['dataPagamento'];
    valorPago = map['valorPago'];
    statusPagamento = map['statusPagamento'];
  }
}