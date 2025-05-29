// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:photoflow/models/projeto/projeto.dart';
import 'package:photoflow/models/cliente/cliente.dart';
import 'package:photoflow/models/tiposervico/tiposervico.dart';
import 'package:photoflow/models/tiposervico/categoria.dart';
import 'package:photoflow/models/projeto/etapa_projeto.dart';
import 'package:photoflow/models/projeto/equipe_projeto.dart';
import 'package:photoflow/models/projeto/cronograma.dart';

// Defina um breakpoint para mobile aqui ou importe de uma constante global
const double kMobileBreakpointDialog = 600.0;

// Classe Tuple2 (se não estiver usando Dart 3 records ou não tiver em um local global)
class Tuple2<T1, T2> {
  final T1 item1;
  final T2 item2;
  Tuple2(this.item1, this.item2);
}

// Placeholders (remova se tiver os modelos reais importados)
// class EquipeProjeto { final String nome; final String funcao; EquipeProjeto({required this.nome, required this.funcao}); }
// class CronogramaProjeto { final DateTime data; final String evento; final bool concluido; CronogramaProjeto({required this.data, required this.evento, required this.concluido}); }

class ProjetoDetalhesDialog extends StatelessWidget {
  final Projeto projeto;

  const ProjetoDetalhesDialog({super.key, required this.projeto});

  // ... (Todos os seus métodos _buildInfoPrincipalItem, _buildSectionTitle, _buildListItem,
  //      _buildCronogramaItem, _buildTarefaItem, _buildPagamentoItem, _getProjectStatusAndColor
  //      permanecem OS MESMOS da resposta anterior. Cole-os aqui.)
  // Vou colar eles abaixo para garantir que o exemplo seja completo.

  Widget _buildInfoPrincipalItem(
      BuildContext context, String label, String value,
      {bool isValor = false, bool isStatus = false, Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              flex: 2,
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500))),
          Expanded(
              flex: 3,
              child: Text(value,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: isValor || isStatus
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isValor
                          ? Theme.of(context).primaryColor
                          : (isStatus ? statusColor : Colors.black87)))),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
      child: Text(title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold, fontSize: 17)),
    );
  }

  Widget _buildListItem(String text,
      {IconData? icon = Icons.circle, double iconSize = 7, Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0, left: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Icon(icon,
                  size: iconSize, color: iconColor ?? Colors.grey.shade700)),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text,
                  style: TextStyle(
                      fontSize: 14, color: Colors.grey.shade800, height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildCronogramaItem(
      BuildContext context, CronogramaProjeto item, bool isLast) {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    return Padding(
      padding: const EdgeInsets.only(
          left: 4.0, bottom: 8.0), // Espaçamento entre itens do cronograma
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(children: [
            Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: item.concluido
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade300),
                child: item.concluido
                    ? Icon(Icons.check, color: Colors.white, size: 10)
                    : null),
            if (!isLast)
              Container(width: 2, height: 45, color: Colors.grey.shade300),
          ]),
          const SizedBox(width: 16),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(dateFormat.format(item.data),
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                  const SizedBox(height: 2),
                  Text(item.evento,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade900,
                          height: 1.3)),
                ]),
          )),
        ],
      ),
    );
  }

  Widget _buildTarefaItem(BuildContext context, String nome, bool concluida) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: concluida ? Colors.green.shade50 : Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color:
                  concluida ? Colors.green.shade200 : Colors.orange.shade200)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
            child: Text(nome,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade800))),
        Text(concluida ? "Concluído" : "Pendente",
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: concluida
                    ? Colors.green.shade700
                    : Colors.orange.shade700)),
      ]),
    );
  }

  Widget _buildPagamentoItem(BuildContext context, String data,
      String descricao, String valor, bool pago) {
    final currencyFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.shade200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(data,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          Text(pago ? "Pago" : "Pendente",
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color:
                      pago ? Colors.green.shade700 : Colors.orange.shade700)),
        ]),
        const SizedBox(height: 6),
        Text(descricao,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800)),
        const SizedBox(height: 4),
        Text(currencyFormat.format(double.tryParse(valor) ?? 0.0),
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColorDark)),
      ]),
    );
  }

  Tuple2<String, Color> _getProjectStatusAndColor(
      Projeto projeto, BuildContext context) {
    if (projeto.cancelado) return Tuple2("Cancelado", Colors.grey.shade500);
    if (projeto.conclusao) return Tuple2("Concluído", Colors.green.shade700);
    if (projeto.pendente) return Tuple2("Pendente", Colors.orange.shade700);
    final etapaNome = projeto.etapaProjeto.nome.toLowerCase();
    switch (etapaNome) {
      case "em execução":
      case "em andamento":
        return Tuple2("Em Andamento", Colors.blue.shade700);
      case "agendado":
      case "planejamento":
        return Tuple2("Agendado", Colors.purple.shade700);
      default:
        return Tuple2(
            projeto.etapaProjeto.nome, Theme.of(context).colorScheme.secondary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final statusInfo = _getProjectStatusAndColor(projeto, context);

    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < kMobileBreakpointDialog;

    // Mock data para listas que não estão no modelo Projeto ainda
    // TODO: Remova quando integrar com dados reais do modelo Projeto
    final List<EquipeProjeto> equipeExemplo = projeto.equipe.isNotEmpty
        ? projeto.equipe
        : [
            EquipeProjeto(id: '', nome: "Carlos", funcao: "Fotógrafo"),
            EquipeProjeto(id: '', nome: "Mariana", funcao: "Maquiadora")
          ];
    final List<CronogramaProjeto> cronogramaExemplo =
        projeto.cronograma.isNotEmpty
            ? projeto.cronograma
            : [
                CronogramaProjeto(
                    data: DateTime(2023, 4, 20),
                    evento: "Contrato assinado",
                    concluido: true),
                CronogramaProjeto(
                    data: DateTime(2023, 5, 2),
                    evento: "Sessão realizada",
                    concluido: true),
                CronogramaProjeto(
                    data: DateTime(2023, 5, 5),
                    evento: "Seleção enviada",
                    concluido: true),
                CronogramaProjeto(
                    data: DateTime(2023, 5, 12),
                    evento: "Entrega final",
                    concluido: false),
              ];
    final List<Map<String, dynamic>> tarefasExemplo = [
      {"nome": "Sessão fotográfica", "concluida": true},
      {"nome": "Seleção das fotos", "concluida": true},
      {"nome": "Edição básica", "concluida": true},
      {"nome": "Entrega (prévia online)", "concluida": false}
    ];
    final List<Map<String, String>> pagamentosExemplo = [
      {
        "data": "20/04/2023",
        "descricao": "Sinal (50%)",
        "valor": (projeto.valor * 0.5).toStringAsFixed(2),
        "pago": "true"
      },
      {
        "data": "12/05/2023",
        "descricao": "Restante na Entrega",
        "valor": (projeto.valor * 0.5).toStringAsFixed(2),
        "pago": "false"
      }
    ];

    return AlertDialog(
      insetPadding: isMobile
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
      shape: isMobile
          ? RoundedRectangleBorder(borderRadius: BorderRadius.zero)
          : RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      titlePadding: EdgeInsets.fromLTRB(isMobile ? 16.0 : 20.0,
          isMobile ? 16.0 : 20.0, isMobile ? 12.0 : 20.0, 10.0),
      contentPadding:
          EdgeInsets.zero, // Padding será aplicado pelo SizedBox e ListView
      actionsPadding: EdgeInsets.fromLTRB(isMobile ? 16.0 : 20.0, 10.0,
          isMobile ? 16.0 : 20.0, isMobile ? 16.0 : 20.0),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              projeto.tipoServico.nome,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold, fontSize: isMobile ? 18 : 20),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            splashRadius: 20,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
        ],
      ),
      content: SizedBox(
        width: isMobile ? screenWidth : 600, // Largura do conteúdo
        height: isMobile
            ? MediaQuery.of(context).size.height
            : MediaQuery.of(context).size.height *
                0.8, // Altura para mobile é a tela toda, para desktop é 80%
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16.0 : 20.0,
              vertical: isMobile ? 12.0 : 0),
          child: ListBody(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16.0),
                margin: EdgeInsets.only(
                    bottom: isMobile ? 16.0 : 20.0, top: isMobile ? 8.0 : 10.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade800.withOpacity(0.5)
                      : Colors.grey.shade100.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: LayoutBuilder(builder: (context, constraints) {
                  bool useSingleColumn = constraints.maxWidth < 450;
                  if (useSingleColumn) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoPrincipalItem(
                            context, "Cliente", projeto.cliente.nome),
                        _buildInfoPrincipalItem(
                            context, "Status", statusInfo.item1,
                            isStatus: true, statusColor: statusInfo.item2),
                        _buildInfoPrincipalItem(context, "Data do Projeto",
                            dateFormat.format(projeto.dataInicio)),
                        _buildInfoPrincipalItem(context, "Categoria",
                            projeto.categoriaServico.nome),
                        _buildInfoPrincipalItem(context, "Prazo de Entrega",
                            dateFormat.format(projeto.prazo)),
                        _buildInfoPrincipalItem(
                            context, "Serviço", projeto.tipoServico.nome),
                        _buildInfoPrincipalItem(context, "Local",
                            "Definir no Modelo"), // TODO: Modelo
                        _buildInfoPrincipalItem(context, "Valor",
                            currencyFormat.format(projeto.valor),
                            isValor: true),
                      ],
                    );
                  } else {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              _buildInfoPrincipalItem(
                                  context, "Cliente", projeto.cliente.nome),
                              _buildInfoPrincipalItem(
                                  context,
                                  "Data do Projeto",
                                  dateFormat.format(projeto.dataInicio)),
                              _buildInfoPrincipalItem(
                                  context,
                                  "Prazo de Entrega",
                                  dateFormat.format(projeto.prazo)),
                              _buildInfoPrincipalItem(context, "Local",
                                  "Definir no Modelo"), // TODO: Modelo
                            ])),
                        const SizedBox(width: 24),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              _buildInfoPrincipalItem(
                                  context, "Status", statusInfo.item1,
                                  isStatus: true,
                                  statusColor: statusInfo.item2),
                              _buildInfoPrincipalItem(context, "Categoria",
                                  projeto.categoriaServico.nome),
                              _buildInfoPrincipalItem(
                                  context, "Serviço", projeto.tipoServico.nome),
                              _buildInfoPrincipalItem(context, "Valor",
                                  currencyFormat.format(projeto.valor),
                                  isValor: true),
                            ])),
                      ],
                    );
                  }
                }),
              ),

              _buildSectionTitle(context, "Descrição"),
              Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                child: Text(
                  projeto.tipoServico.descricao.isNotEmpty
                      ? projeto.tipoServico.descricao
                      : "Nenhuma descrição fornecida.",
                  style: TextStyle(
                      fontSize: 14, color: Colors.grey.shade800, height: 1.5),
                ),
              ),

              LayoutBuilder(builder: (context, constraints) {
                bool useSingleColumn = constraints.maxWidth <
                    550; // Ponto de quebra para Equipe/Equipamento
                final equipeWidget = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context, "Equipe"),
                      if (equipeExemplo.isEmpty)
                        _buildListItem("Nenhuma equipe definida.")
                      else
                        ...equipeExemplo.map((m) => _buildListItem(
                            "${m.nome} (${m.funcao})",
                            icon: Icons.person_outline_rounded)),
                    ]);
                final equipamentoWidget = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context, "Equipamento"),
                      _buildListItem("Sony A7III (Exemplo)",
                          icon: Icons.camera_alt_outlined),
                      _buildListItem("Sony 85mm f/1.4 (Exemplo)",
                          icon: Icons.camera_outlined),
                    ]);
                if (useSingleColumn)
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [equipeWidget, equipamentoWidget]);
                return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: equipeWidget),
                      const SizedBox(width: 20),
                      Expanded(child: equipamentoWidget)
                    ]);
              }),

              _buildSectionTitle(context, "Cronograma"),
              if (cronogramaExemplo.isEmpty)
                _buildListItem("Nenhum cronograma definido.")
              else
                Column(
                    children: cronogramaExemplo
                        .asMap()
                        .entries
                        .map((entry) => _buildCronogramaItem(
                            context,
                            entry.value,
                            entry.key == cronogramaExemplo.length - 1))
                        .toList()),

              LayoutBuilder(builder: (context, constraints) {
                bool useSingleColumn = constraints.maxWidth <
                    550; // Ponto de quebra para Tarefas/Pagamentos
                final tarefasWidget = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context, "Tarefas"),
                      ...tarefasExemplo.map((t) => _buildTarefaItem(context,
                          t["nome"] as String, t["concluida"] as bool)),
                    ]);
                final pagamentosWidget = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context, "Pagamentos"),
                      ...pagamentosExemplo.map((p) => _buildPagamentoItem(
                          context,
                          p["data"]!,
                          p["descricao"]!,
                          p["valor"]!,
                          p["pago"] == "true")),
                    ]);
                if (useSingleColumn)
                  return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [tarefasWidget, pagamentosWidget]);
                return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: tarefasWidget),
                      const SizedBox(width: 20),
                      Expanded(child: pagamentosWidget)
                    ]);
              }),

              _buildSectionTitle(context, "Observações"),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.blueGrey.shade100)),
                child: Text(
                    projeto.observacao.isNotEmpty
                        ? projeto.observacao
                        : "Nenhuma observação.",
                    style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.blueGrey.shade800)),
              ),
              const SizedBox(height: 20), // Espaço antes dos botões de ação
            ],
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.end,
      actions: <Widget>[
        OutlinedButton(
          onPressed: () {/* TODO: Implementar Edição */},
          child: const Text("Editar Projeto"),
          style: OutlinedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          icon: Icon(Icons.assessment_outlined, size: 18),
          label: const Text("Gerar Relatório"),
          onPressed: () {/* TODO: Implementar Gerar Relatório */},
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColorDark,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
        ),
      ],
    );
  }
}
