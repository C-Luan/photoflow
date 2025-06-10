// File: lib/panels/sections/relatorio_section.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/report_cards.dart';

class RelatorioSection extends StatelessWidget {
  final Map<String, dynamic> dadosResumo;
  final String periodoSelecionado;
  final List<String> opcoesPeriodo;
  final ValueChanged<String> onPeriodoChanged;
  final VoidCallback onExport;

  const RelatorioSection({
    super.key,
    required this.dadosResumo,
    required this.periodoSelecionado,
    required this.opcoesPeriodo,
    required this.onPeriodoChanged,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    // Placeholder para os conteúdos dos cards de detalhe
    Widget faturamentoCategoriaContent = Center(
      child: Text("Sem dados para o período selecionado.",
          style: TextStyle(color: Colors.grey.shade600)),
    );

    Widget agendamentosRecentesContent = Center(
      child: Text("Sem dados para o período selecionado.",
          style: TextStyle(color: Colors.grey.shade600)),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linha do Título e Filtros
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Relatório Financeiro",
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  // Filtro de Período
                  PopupMenuButton<String>(
                    initialValue: periodoSelecionado,
                    onSelected: (String newValue) => onPeriodoChanged(newValue),
                    itemBuilder: (BuildContext context) {
                      return opcoesPeriodo.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        children: [
                          Text(periodoSelecionado,
                              style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_drop_down,
                              size: 20, color: Colors.grey.shade700),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Botão Exportar
                  ElevatedButton.icon(
                    icon: const Icon(Icons.download_outlined, size: 18),
                    label: const Text("Exportar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                    onPressed: onExport,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Cards de Resumo
          LayoutBuilder(builder: (context, constraints) {
            bool useRow = constraints.maxWidth > 700;
            return useRow
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        _buildSummaryCards(context, currencyFormat, useRow),
                  )
                : Column(
                    children:
                        _buildSummaryCards(context, currencyFormat, useRow),
                  );
          }),
          const SizedBox(height: 24),

          // Seções de Detalhes
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 800) {
                // Layout empilhado para telas menores
                return Column(
                  children: [
                    ReportDetailCard(
                      title: "Faturamento por Categoria",
                      content: faturamentoCategoriaContent,
                      height: 300,
                    ),
                    const SizedBox(height: 20),
                    ReportDetailCard(
                      title: "Agendamentos Recentes",
                      content: agendamentosRecentesContent,
                      height: 300,
                    ),
                  ],
                );
              } else {
                // Layout lado a lado para telas maiores
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ReportDetailCard(
                        title: "Faturamento por Categoria",
                        content: faturamentoCategoriaContent,
                        height: 350,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ReportDetailCard(
                        title: "Agendamentos Recentes",
                        content: agendamentosRecentesContent,
                        height: 350,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSummaryCards(
      BuildContext context, NumberFormat currencyFormat, bool useRow) {
    return [
      SummaryCard(
        title: "Faturamento Total",
        value: currencyFormat.format(dadosResumo['faturamentoTotal']),
        iconData: Icons.monetization_on_outlined,
        iconColor: Colors.orange,
        percentageChange: dadosResumo['faturamentoPercentual'],
      ),
      SizedBox(width: useRow ? 16 : 0, height: useRow ? 0 : 16),
      SummaryCard(
        title: "Total de Agendamentos",
        value: dadosResumo['totalAgendamentos'].toString(),
        iconData: Icons.calendar_month_outlined,
        iconColor: Colors.deepPurpleAccent,
        percentageChange: dadosResumo['agendamentosPercentual'],
      ),
      SizedBox(width: useRow ? 16 : 0, height: useRow ? 0 : 16),
      SummaryCard(
        title: "Ticket Médio",
        value: currencyFormat.format(dadosResumo['ticketMedio']),
        iconData: Icons.sell_outlined,
        iconColor: Colors.pinkAccent,
        percentageChange: dadosResumo['ticketMedioPercentual'],
      ),
    ];
  }
}
