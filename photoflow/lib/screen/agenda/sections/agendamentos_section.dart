// File: lib/panels/sections/agendamentos_section.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photoflow/models/agendamento/agendamento.dart';

class AgendamentosSection extends StatefulWidget {
  final List<Agendamento> agendamentos;
  final VoidCallback onAdd;
  final Function(Agendamento) onEdit;
  final Function(Agendamento) onDelete;

  const AgendamentosSection({
    super.key,
    required this.agendamentos,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  _AgendamentosSectionState createState() => _AgendamentosSectionState();
}

class _AgendamentosSectionState extends State<AgendamentosSection> {
  late List<Agendamento> _filteredAgendamentos;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredAgendamentos = widget.agendamentos;
    _searchController.addListener(_filterAgendamentos);
  }

  @override
  void didUpdateWidget(covariant AgendamentosSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Se a lista de agendamentos externa mudar, atualiza o filtro.
    if (widget.agendamentos != oldWidget.agendamentos) {
      _filterAgendamentos();
    }
  }

  void _filterAgendamentos() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredAgendamentos = widget.agendamentos.where((ag) {
        return ag.nome.toLowerCase().contains(query) ||
            ag.servico.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho com Título, Busca e Botão
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Lista de Agendamentos",
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  SizedBox(
                    width: 250,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Buscar por cliente ou serviço...",
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 12),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Novo Agendamento"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: widget.onAdd,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tabela de Dados
          Expanded(
            child: Card(
              elevation: 2.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              clipBehavior: Clip.antiAlias,
              child: _filteredAgendamentos.isEmpty
                  ? Center(
                      child: Text(
                        _searchController.text.isNotEmpty
                            ? "Nenhum resultado encontrado"
                            : "Nenhum agendamento cadastrado",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.grey.shade600),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowHeight: 48,
                          headingRowColor: MaterialStateProperty.resolveWith(
                              (states) => Colors.grey.shade100),
                          headingTextStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                              fontSize: 13),
                          columns: const [
                            DataColumn(label: Text('DATA')),
                            DataColumn(label: Text('HORA')),
                            DataColumn(label: Text('CLIENTE')),
                            DataColumn(label: Text('SERVIÇO')),
                            DataColumn(label: Text('CATEGORIA')),
                            DataColumn(label: Text('VALOR')),
                            DataColumn(label: Text('AÇÕES')),
                          ],
                          rows: _filteredAgendamentos.map((agendamento) {
                            return DataRow(
                              cells: [
                                DataCell(Text(DateFormat('dd/MM/yyyy')
                                    .format(agendamento.data))),
                                DataCell(Text(DateFormat('HH:mm')
                                    .format(agendamento.data))),
                                DataCell(Text(agendamento.nome)),
                                DataCell(Text(agendamento.servico)),
                                DataCell(Text("N/A")), // Placeholder
                                DataCell(Text("R\$ --,--")), // Placeholder
                                DataCell(Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined,
                                          color: Colors.blueAccent, size: 20),
                                      tooltip: "Editar",
                                      splashRadius: 20,
                                      onPressed: () => widget.onEdit(agendamento),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.redAccent, size: 20),
                                      tooltip: "Excluir",
                                      splashRadius: 20,
                                      onPressed: () => widget.onDelete(agendamento),
                                    ),
                                  ],
                                )),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}