// Flutter imports:
import 'dart:developer';

import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
// Certifique-se que os caminhos para seus modelos estão corretos
import 'package:photoflow/models/projeto/projeto.dart';
import 'package:photoflow/models/tiposervico/tiposervico.dart';
import 'package:photoflow/models/tiposervico/categoria.dart';
import 'package:photoflow/models/projeto/etapa_projeto.dart';
import 'package:photoflow/screen/projetos/dialog/detalhes_projetos.dart';
import 'package:photoflow/screen/projetos/dialog/novo_projeto_dialog.dart';
import 'package:photoflow/services/apis/projetos/create_projeto_service.dart';
import 'package:photoflow/services/apis/projetos/get_projetos_service.dart';
// Se NovoProjetoDialog estiver em um arquivo separado, importe-o também.
// import 'caminho/para/seu/novo_projeto_dialog.dart';

// Constante para breakpoint
const double kProjetosDesktopBreakpoint = 700.0;

// Classe Tuple2 (se não estiver usando Dart 3 records ou não tiver em um local global)
class Tuple2<T1, T2> {
  final T1 item1;
  final T2 item2;
  Tuple2(this.item1, this.item2);
}

class ProjetosScreen extends StatefulWidget {
  const ProjetosScreen({super.key});

  @override
  State<ProjetosScreen> createState() => _ProjetosScreenState();
}

class _ProjetosScreenState extends State<ProjetosScreen> {
  List<Projeto> _allProjetos = [];
  List<Projeto> _filteredProjetos = [];

  // Estados dos Filtros
  String _selectedProjectFilterTab = "Todos";
  final TextEditingController _projectSearchController =
      TextEditingController();
  DateTime? _filtroDataInicioProjetos;
  DateTime? _filtroDataFimProjetos;
  Tiposervico? _filtroTipoServicoSelecionado;
  CategoriaServico? _filtroCategoriaServicoSelecionada;
  DateTime? _filtroPrazoSelecionado;
  List<String> _etapasDisponiveisParaFiltro = [];
  List<Tiposervico> _tiposServicoParaFiltro = [];
  List<CategoriaServico> _categoriasServicoParaFiltro = [];
  final TextEditingController _filtroDataInicioController =
      TextEditingController();
  final TextEditingController _filtroDataFimController =
      TextEditingController();
  final TextEditingController _filtroPrazoController = TextEditingController();
  bool _isFilterPanelVisible = false;

  // Estados para Ordenação
  bool _isSortPanelVisible = false;
  String? _sortByField;
  bool _sortAscending = true;
  final List<String> _sortableFields = [
    "Data de Início",
    "Nome do Cliente",
    "Prazo Final",
    "Status (Etapa)",
    "Valor"
  ];

  @override
  void initState() {
    super.initState();
    _loadProjetos();
    _projectSearchController.addListener(_applyAllFilters);
  }

  @override
  void dispose() {
    _projectSearchController.removeListener(_applyAllFilters);
    _projectSearchController.dispose();
    _filtroDataInicioController.dispose();
    _filtroDataFimController.dispose();
    _filtroPrazoController.dispose();
    super.dispose();
  }

// CORREÇÃO: Usando async/await para garantir o carregamento antes de atualizar o estado.
  Future<void> _loadProjetos() async {
    try {
      // 1. Aguarda a resposta do serviço
      final onValue = await getProjetosService();
      if (onValue == null || onValue.data == null) {
        log("Serviço não retornou dados.");
        // Limpa os dados existentes se a resposta for nula
        if (mounted) {
          setState(() {
            _allProjetos = [];
            _populateDynamicFiltersFromData(); // Irá limpar os filtros dinâmicos
            _applyAllFilters(); // Irá aplicar sobre a lista vazia
          });
        }
        return;
      }

      log("Dados recebidos do servidor: ${onValue.data}");

      // 2. Processa os dados recebidos
      final List<Projeto> projetosCarregados = [];
      for (var i in onValue.data) {
        try {
          projetosCarregados.add(Projeto.fromJson(i));
        } catch (e) {
          log("Erro ao desserializar projeto: $i, Erro: $e");
        }
      }

      // 3. Atualiza o estado DENTRO de um único setState, já com os dados prontos.
      // A verificação 'mounted' é uma boa prática em métodos async dentro de StateObjects.
      if (mounted) {
        setState(() {
          _allProjetos = projetosCarregados;
          // Agora que _allProjetos está preenchida, podemos popular os filtros
          // e aplicar a lógica de exibição.
          _populateDynamicFiltersFromData();
          _applyAllFilters();
        });
      }
    } catch (e) {
      log("Ocorreu um erro ao carregar os projetos: $e");
      // Opcional: Mostrar um SnackBar ou mensagem de erro para o usuário
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Falha ao carregar projetos. Verifique sua conexão."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _populateDynamicFiltersFromData() {
    if (_allProjetos.isEmpty) {
      setState(() {
        _etapasDisponiveisParaFiltro = [];
        _tiposServicoParaFiltro = [];
        _categoriasServicoParaFiltro = [];
      });
      return;
    }
    final etapas =
        _allProjetos.map((p) => p.etapaProjeto.nome).toSet().toList();
    etapas.sort();
    final tipos = _allProjetos
        .map((p) => p.tipoServico)
        .fold<Map<int?, Tiposervico>>({}, (map, tipo) {
          if (tipo.id != null) map.putIfAbsent(tipo.id, () => tipo);
          return map;
        })
        .values
        .toList();
    tipos.sort((a, b) => a.nome.compareTo(b.nome));
    final categorias = _allProjetos
        .map((p) => p.categoriaServico)
        .fold<Map<int, CategoriaServico>>({}, (map, cat) {
          map.putIfAbsent(cat.id, () => cat);
          return map;
        })
        .values
        .toList();
    categorias.sort((a, b) => a.nome.compareTo(b.nome));
    setState(() {
      _etapasDisponiveisParaFiltro = etapas;
      _tiposServicoParaFiltro = tipos;
      _categoriasServicoParaFiltro = categorias;
      if (!_etapasDisponiveisParaFiltro.contains(_selectedProjectFilterTab) &&
          _selectedProjectFilterTab != "Todos") {
        _selectedProjectFilterTab = "Todos";
      }
    });
  }

  void _applyAllFilters() {
    List<Projeto> tempProjetos = List.from(_allProjetos);
    // Filtro por Etapa usa o status real, que pode ser Cancelado/Pendente
    if (_selectedProjectFilterTab != "Todos") {
      tempProjetos = tempProjetos
          .where((p) =>
              _getProjectStatusAndColor(p).item1 == _selectedProjectFilterTab)
          .toList();
    }
    if (_filtroDataInicioProjetos != null) {
      tempProjetos = tempProjetos
          .where((p) => !p.dataInicio.isBefore(_filtroDataInicioProjetos!))
          .toList();
    }
    if (_filtroDataFimProjetos != null) {
      DateTime endDateInclusive = DateTime(
          _filtroDataFimProjetos!.year,
          _filtroDataFimProjetos!.month,
          _filtroDataFimProjetos!.day,
          23,
          59,
          59);
      tempProjetos = tempProjetos
          .where((p) => !p.dataInicio.isAfter(endDateInclusive))
          .toList();
    }
    if (_filtroTipoServicoSelecionado != null) {
      tempProjetos = tempProjetos
          .where((p) => p.tipoServico.id == _filtroTipoServicoSelecionado!.id)
          .toList();
    }
    if (_filtroCategoriaServicoSelecionada != null) {
      tempProjetos = tempProjetos
          .where((p) =>
              p.categoriaServico.id == _filtroCategoriaServicoSelecionada!.id)
          .toList();
    }
    if (_filtroPrazoSelecionado != null) {
      DateTime prazoInclusive = DateTime(
          _filtroPrazoSelecionado!.year,
          _filtroPrazoSelecionado!.month,
          _filtroPrazoSelecionado!.day,
          23,
          59,
          59);
      tempProjetos =
          tempProjetos.where((p) => !p.prazo.isAfter(prazoInclusive)).toList();
    }
    String query = _projectSearchController.text.toLowerCase();
    if (query.isNotEmpty) {
      tempProjetos = tempProjetos
          .where((p) =>
              p.cliente.nome.toLowerCase().contains(query) ||
              p.tipoServico.nome.toLowerCase().contains(query) ||
              p.categoriaServico.nome.toLowerCase().contains(query) ||
              p.observacao.toLowerCase().contains(query) ||
              (p.valor.toString().contains(query)))
          .toList();
    }

    setState(() {
      _filteredProjetos = tempProjetos;
      _applySorting();
    });
  }

  void _clearAllFilters() {
    setState(() {
      _selectedProjectFilterTab = "Todos";
      _projectSearchController.clear();
      _filtroDataInicioProjetos = null;
      _filtroDataFimProjetos = null;
      _filtroTipoServicoSelecionado = null;
      _filtroCategoriaServicoSelecionada = null;
      _filtroPrazoSelecionado = null;
      _filtroDataInicioController.clear();
      _filtroDataFimController.clear();
      _filtroPrazoController.clear();
      _isFilterPanelVisible = false;
      _applyAllFilters();
    });
  }

  void _applySorting() {
    if (_sortByField == null && _filteredProjetos.isNotEmpty) {
      // Aplica ordenação padrão se nenhuma estiver selecionada
      _filteredProjetos.sort((a, b) =>
          b.dataInicio.compareTo(a.dataInicio)); // Ex: mais novos primeiro
      // setState(() {}); // Não é necessário se _applyAllFilters sempre chama _applySorting e faz setState
      return;
    }
    if (_filteredProjetos.isEmpty || _sortByField == null) return;

    _filteredProjetos.sort((a, b) {
      int r = 0;
      switch (_sortByField) {
        case "Data de Início":
          r = a.dataInicio.compareTo(b.dataInicio);
          break;
        case "Nome do Cliente":
          r = a.cliente.nome
              .toLowerCase()
              .compareTo(b.cliente.nome.toLowerCase());
          break;
        case "Prazo Final":
          r = a.prazo.compareTo(b.prazo);
          break;
        case "Status (Etapa)":
          r = _getProjectStatusAndColor(a)
              .item1
              .toLowerCase()
              .compareTo(_getProjectStatusAndColor(b).item1.toLowerCase());
          break;
        case "Valor":
          double valA = a.valor;
          double valB = b.valor;
          r = valA.compareTo(valB);
          break;
      }
      return _sortAscending ? r : -r;
    });
    // setState(() {}); // O setState é chamado no "Aplicar" do painel de sort ou por _applyAllFilters
  }

  Tuple2<String, Color> _getProjectStatusAndColor(Projeto projeto) {
    if (projeto.cancelado) return Tuple2("Cancelado", Colors.grey.shade500);
    if (projeto.conclusao) return Tuple2("Concluído", Colors.green.shade600);
    if (projeto.pendente) return Tuple2("Pendente", Colors.orange.shade700);
    final etapaNome = projeto.etapaProjeto.nome.toLowerCase();
    switch (etapaNome) {
      case "em execução":
      case "em andamento":
        return Tuple2("Em Andamento", Colors.blue.shade600);
      case "agendado":
      case "planejamento":
        return Tuple2("Agendado", Colors.purple.shade600);
      default:
        return Tuple2(projeto.etapaProjeto.nome, Colors.blueGrey.shade600);
    }
  }

  double _getProjectProgress(Projeto projeto) {
    if (projeto.cancelado) return 0.0;
    if (projeto.conclusao) return 1.0;
    if (projeto.pendente) return 0.75;
    final etapaNome = projeto.etapaProjeto.nome.toLowerCase();
    switch (etapaNome) {
      case "em execução":
      case "em andamento":
        return 0.5;
      case "agendado":
      case "planejamento":
        return 0.1;
      case "revisão":
        return 0.8;
      default:
        return 0.05;
    }
  }

  // CORRIGIDO: _buildProjectSummaryCard não retorna Expanded
  Widget _buildProjectSummaryCard(
      {required String title,
      required int count,
      required IconData iconData,
      required Color iconColor}) {
    return Card(
      // Retorna o Card diretamente
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(color: Colors.grey.shade300, width: 1)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(children: [
          CircleAvatar(
              radius: 20,
              backgroundColor: iconColor.withOpacity(0.1),
              child: Icon(iconData, size: 20, color: iconColor)),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
            const SizedBox(height: 4),
            Text(count.toString(),
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ]),
        ]),
      ),
    );
  }

  Widget _buildProjectCard(Projeto projeto) {
    // ... (Implementação completa como na resposta anterior, com contador de prazo e valor)
    final statusInfo = _getProjectStatusAndColor(projeto);
    final progressValue = _getProjectProgress(projeto);
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    String prazoText = "";
    Color prazoColor = Colors.grey.shade700;
    bool mostrarContadorPrazo = !projeto.conclusao && !projeto.cancelado;

    if (mostrarContadorPrazo) {
      final DateTime hoje = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
      final DateTime prazoProjeto =
          DateTime(projeto.prazo.year, projeto.prazo.month, projeto.prazo.day);
      final int diasRestantes = prazoProjeto.difference(hoje).inDays;
      if (diasRestantes > 1) {
        prazoText = "Faltam $diasRestantes dias";
        prazoColor = Colors.orange.shade700;
      } else if (diasRestantes == 1) {
        prazoText = "Falta 1 dia";
        prazoColor = Colors.orange.shade800;
      } else if (diasRestantes == 0) {
        prazoText = "Prazo é Hoje!";
        prazoColor = Colors.red.shade700;
      } else {
        prazoText =
            "Prazo Esgotado há ${diasRestantes.abs()} dia${diasRestantes.abs() == 1 ? '' : 's'}";
        prazoColor = Colors.red.shade900;
      }
    }
    String projectTitle = projeto.tipoServico.nome;
    List<String> clientNameParts = projeto.cliente.nome.split(" ");
    if (clientNameParts.length > 1) {
      projectTitle += " ${clientNameParts.last}";
    } else {
      projectTitle += " ${projeto.cliente.nome}";
    }

    return Card(
        elevation: 2.5,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: Text(projectTitle,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2)),
                              if (projeto.valor != null)
                                Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(
                                        currencyFormat.format(projeto.valor),
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .primaryColor))),
                            ]),
                        const SizedBox(height: 10),
                        Row(children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 15, color: Colors.grey.shade700),
                          const SizedBox(width: 6),
                          Text(dateFormat.format(projeto.dataInicio),
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey.shade700))
                        ]),
                        const SizedBox(height: 6),
                        Row(children: [
                          Icon(Icons.person_outline,
                              size: 16, color: Colors.grey.shade700),
                          const SizedBox(width: 6),
                          Expanded(
                              child: Text(projeto.cliente.nome,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700),
                                  overflow: TextOverflow.ellipsis))
                        ]),
                        const SizedBox(height: 12),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Wrap(spacing: 6.0, runSpacing: 4.0, children: [
                                _buildTagChip(projeto.categoriaServico.nome,
                                    Colors.purple.shade50)
                              ]),
                              const Spacer(),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: statusInfo.item2.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Text(statusInfo.item1,
                                      style: TextStyle(
                                          color: statusInfo.item2,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600))),
                            ]),
                        const SizedBox(height: 12),
                        if (mostrarContadorPrazo) ...[
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.hourglass_empty_outlined,
                                    size: 14, color: Colors.grey.shade700),
                                const SizedBox(width: 4),
                                Text(
                                    "Prazo: ${dateFormat.format(projeto.prazo)}",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700)),
                                const SizedBox(width: 8),
                                if (prazoText.isNotEmpty)
                                  Expanded(
                                      child: Text(prazoText,
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: prazoColor,
                                              fontWeight: FontWeight.w600),
                                          overflow: TextOverflow.ellipsis))
                              ]),
                          const SizedBox(height: 8)
                        ] else if (projeto.conclusao &&
                            projeto.dataFim != null) ...[
                          Text(
                              "Concluído em: ${dateFormat.format(projeto.dataFim!)}",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.green.shade700)),
                          const SizedBox(height: 8)
                        ] else if (projeto.cancelado) ...[
                          Text(
                              "Prazo original: ${dateFormat.format(projeto.prazo)}",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade600)),
                          const SizedBox(height: 8)
                        ],
                        if (!projeto.cancelado) ...[
                          ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                  value: progressValue,
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      statusInfo.item2),
                                  minHeight: 7)),
                          const SizedBox(height: 4),
                          Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                  "${(progressValue * 100).toStringAsFixed(0)}%",
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600)))
                        ],
                      ]),
                  Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OutlinedButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (builder) =>
                                          ProjetoDetalhesDialog(
                                              projeto: projeto));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "Ver Detalhes Clicado (TODO: Chamar Dialog)")));
                                },
                                style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    side: BorderSide(
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.7)),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8))),
                                child: Text("Ver detalhes",
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            Theme.of(context).primaryColor))),
                            Row(children: [
                              IconButton(
                                  icon: Icon(Icons.edit_outlined,
                                      size: 20, color: Colors.grey.shade700),
                                  tooltip: "Editar Projeto",
                                  splashRadius: 20,
                                  onPressed: () {/* TODO: Editar */}),
                              IconButton(
                                  icon: Icon(Icons.delete_outline,
                                      size: 20, color: Colors.red.shade400),
                                  tooltip: "Excluir Projeto",
                                  splashRadius: 20,
                                  onPressed: () {/* TODO: Excluir */})
                            ])
                          ]))
                ])));
  }

  Widget _buildTagChip(String label, Color backgroundColor) {
    // ... (Implementação como na resposta anterior) ...
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: backgroundColor, borderRadius: BorderRadius.circular(6)),
        child: Text(label,
            style: TextStyle(
                fontSize: 11,
                color: (backgroundColor.computeLuminance() > 0.5
                        ? Colors.black87
                        : Colors.white)
                    .withOpacity(0.8),
                fontWeight: FontWeight.w500)));
  }

  Widget _buildEtapaFilterTab(String title) {
    // ... (Implementação como na resposta anterior) ...
    bool isSelected = _selectedProjectFilterTab == title;
    return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: TextButton(
            style: TextButton.styleFrom(
                backgroundColor: isSelected
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : Colors.transparent,
                foregroundColor: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade700,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                side: isSelected
                    ? BorderSide(
                        color: Theme.of(context).primaryColor, width: 1.5)
                    : BorderSide(color: Colors.grey.shade300, width: 1)),
            onPressed: () => setState(() {
                  _selectedProjectFilterTab = title;
                  _applyAllFilters();
                }),
            child: Text(title,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal))));
  }

  Widget _buildDatePickerFilter(
      {required BuildContext context,
      required String label,
      required TextEditingController controller,
      required DateTime? currentValue,
      required ValueChanged<DateTime?> onDateSelected,
      DateTime? firstDate,
      DateTime? lastDate}) {
    // ... (Implementação como na resposta anterior) ...
    final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    if (currentValue != null && controller.text.isEmpty) {
      controller.text = dateFormat.format(currentValue);
    } else if (currentValue == null && controller.text.isNotEmpty) {
      controller.clear();
    }
    return SizedBox(
        width: 180,
        child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
                labelText: label,
                hintText: 'dd/mm/aaaa',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                suffixIcon: Icon(Icons.calendar_today, size: 18),
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 14)),
            readOnly: true,
            onTap: () async {
              FocusScope.of(context).requestFocus(FocusNode());
              DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: currentValue ?? DateTime.now(),
                  firstDate: firstDate ?? DateTime(2000),
                  lastDate: lastDate ?? DateTime(2101),
                  locale: const Locale('pt', 'BR'));
              if (pickedDate != null) {
                controller.text = dateFormat.format(pickedDate);
                onDateSelected(pickedDate);
              }
            }));
  }

  Widget _buildFilterPanelContent() {
    // ... (Implementação como na resposta anterior) ...
    return Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3))
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Filtros Avançados",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Wrap(
              spacing: 16.0,
              runSpacing: 16.0,
              alignment: WrapAlignment.start,
              children: [
                _buildDatePickerFilter(
                    context: context,
                    label: "Data Início (De)",
                    controller: _filtroDataInicioController,
                    currentValue: _filtroDataInicioProjetos,
                    onDateSelected: (date) => setState(() {
                          _filtroDataInicioProjetos = date;
                          _applyAllFilters();
                        })),
                _buildDatePickerFilter(
                    context: context,
                    label: "Data Início (Até)",
                    controller: _filtroDataFimController,
                    currentValue: _filtroDataFimProjetos,
                    onDateSelected: (date) => setState(() {
                          _filtroDataFimProjetos = date;
                          _applyAllFilters();
                        }),
                    firstDate: _filtroDataInicioProjetos),
                SizedBox(
                    width: 200,
                    child: DropdownButtonFormField<CategoriaServico>(
                        decoration: InputDecoration(
                            labelText: "Categoria",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 14)),
                        value: _filtroCategoriaServicoSelecionada,
                        hint: Text("Todas"),
                        isExpanded: true,
                        items: [
                          DropdownMenuItem<CategoriaServico>(
                              value: null, child: Text("Todas Categorias")),
                          ..._categoriasServicoParaFiltro
                              .map((cat) => DropdownMenuItem<CategoriaServico>(
                                  value: cat,
                                  child: Text(cat.nome,
                                      overflow: TextOverflow.ellipsis)))
                              .toList()
                        ],
                        onChanged: (val) => setState(() {
                              _filtroCategoriaServicoSelecionada = val;
                              _applyAllFilters();
                            }))),
                SizedBox(
                    width: 200,
                    child: DropdownButtonFormField<Tiposervico>(
                        decoration: InputDecoration(
                            labelText: "Tipo de Serviço",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 14)),
                        value: _filtroTipoServicoSelecionado,
                        hint: Text("Todos"),
                        isExpanded: true,
                        items: [
                          DropdownMenuItem<Tiposervico>(
                              value: null, child: Text("Todos Tipos")),
                          ..._tiposServicoParaFiltro
                              .map((tipo) => DropdownMenuItem<Tiposervico>(
                                  value: tipo,
                                  child: Text(tipo.nome,
                                      overflow: TextOverflow.ellipsis)))
                              .toList()
                        ],
                        onChanged: (val) => setState(() {
                              _filtroTipoServicoSelecionado = val;
                              _applyAllFilters();
                            }))),
                _buildDatePickerFilter(
                    context: context,
                    label: "Prazo Final Até",
                    controller: _filtroPrazoController,
                    currentValue: _filtroPrazoSelecionado,
                    onDateSelected: (date) => setState(() {
                          _filtroPrazoSelecionado = date;
                          _applyAllFilters();
                        }))
              ]),
          const SizedBox(height: 20),
          Divider(),
          const SizedBox(height: 12),
          Text("Filtrar por Etapa",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                _buildEtapaFilterTab("Todos"),
                ..._etapasDisponiveisParaFiltro
                    .map((etapa) => _buildEtapaFilterTab(etapa))
                    .toList()
              ])),
          const SizedBox(height: 24),
          Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                  icon: Icon(Icons.clear_all, size: 18),
                  label: Text("Limpar Todos os Filtros"),
                  style: OutlinedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .error
                              .withOpacity(0.5))),
                  onPressed: _clearAllFilters))
        ]));
  }

  Widget _buildSortPanel() {
    // ... (Como antes) ...
    return Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3))
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Opções de Ordenação",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                        labelText: "Ordenar por",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 14)),
                    value: _sortByField,
                    hint: Text("Selecione o campo"),
                    isExpanded: true,
                    items: _sortableFields
                        .map((String field) => DropdownMenuItem<String>(
                            value: field, child: Text(field)))
                        .toList(),
                    onChanged: (String? newValue) =>
                        setState(() => _sortByField = newValue))),
            const SizedBox(width: 16),
            Expanded(
                flex: 3,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Direção",
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade700)),
                      Row(children: [
                        Expanded(
                            child: RadioListTile<bool>(
                                title: const Text('Crescente',
                                    style: TextStyle(fontSize: 14)),
                                value: true,
                                groupValue: _sortAscending,
                                onChanged: (bool? value) {
                                  if (value != null)
                                    setState(() => _sortAscending = value);
                                },
                                contentPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact)),
                        Expanded(
                            child: RadioListTile<bool>(
                                title: const Text('Decrescente',
                                    style: TextStyle(fontSize: 14)),
                                value: false,
                                groupValue: _sortAscending,
                                onChanged: (bool? value) {
                                  if (value != null)
                                    setState(() => _sortAscending = value);
                                },
                                contentPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact))
                      ])
                    ]))
          ]),
          const SizedBox(height: 20),
          Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                  icon: Icon(Icons.check_circle_outline, size: 18),
                  label: Text("Aplicar Ordenação"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12)),
                  onPressed: () => setState(() {
                        _applySorting();
                        _isSortPanelVisible = false;
                      })))
        ]));
  }

  @override
  Widget build(BuildContext context) {
    // ... (cálculo dos contadores como antes) ...
    int concluidosCount = _allProjetos
        .where((p) => _getProjectStatusAndColor(p).item1 == "Concluído")
        .length;
    int emAndamentoCount = _allProjetos
        .where((p) => _getProjectStatusAndColor(p).item1 == "Em Andamento")
        .length;
    int agendadosCount = _allProjetos
        .where((p) => _getProjectStatusAndColor(p).item1 == "Agendado")
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sub-Header
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Icon(Icons.camera_roll_outlined,
                  size: 32, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text("FotoGerente Projetos",
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ]),
            ElevatedButton.icon(
              icon: Icon(Icons.add, size: 18),
              label: Text("Novo Projeto"),
              style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0))),
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (builder) => NovoProjetoDialog(
                    onSave: (projeto) async {
                      await createProjetoService(data: projeto.toJson())
                          .then((onValue) {
                        _loadProjetos();
                      });
                    },
                  ),
                );
              },
            ),
          ]),
          const SizedBox(height: 24),
          // Cards de Resumo (LayoutBuilder CORRIGIDO)
          LayoutBuilder(builder: (context, constraints) {
            bool useRow = constraints.maxWidth > kProjetosDesktopBreakpoint;
            Widget cardConcluidos = _buildProjectSummaryCard(
                title: "Projetos Concluídos",
                count: concluidosCount,
                iconData: Icons.check_circle_outline,
                iconColor: Colors.green);
            Widget cardEmAndamento = _buildProjectSummaryCard(
                title: "Em Andamento",
                count: emAndamentoCount,
                iconData: Icons.hourglass_top_outlined,
                iconColor: Colors.blue);
            Widget cardAgendados = _buildProjectSummaryCard(
                title: "Agendados",
                count: agendadosCount,
                iconData: Icons.calendar_today_outlined,
                iconColor: Colors.purple);
            if (useRow) {
              return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: cardConcluidos),
                    const SizedBox(width: 16),
                    Expanded(child: cardEmAndamento),
                    const SizedBox(width: 16),
                    Expanded(child: cardAgendados),
                  ]);
            } else {
              return Column(children: [
                cardConcluidos,
                const SizedBox(height: 16),
                cardEmAndamento,
                const SizedBox(height: 16),
                cardAgendados,
              ]);
            }
          }),
          const SizedBox(height: 24),
          // Linha de Controles: Busca, Botão Filtros, Botão Ordenar
          Row(children: [
            Expanded(
                child: TextField(
                    controller: _projectSearchController,
                    decoration: InputDecoration(
                        hintText: "Buscar projetos...",
                        prefixIcon: Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor)),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        isDense: true))),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              icon: Icon(
                  _isFilterPanelVisible
                      ? Icons.filter_list_off
                      : Icons.filter_list,
                  size: 18),
              label: Text("Filtros"),
              style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0))),
              onPressed: () => setState(() {
                _isFilterPanelVisible = !_isFilterPanelVisible;
                if (_isFilterPanelVisible && _isSortPanelVisible)
                  _isSortPanelVisible = false;
              }),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              icon: Icon(_isSortPanelVisible ? Icons.sort : Icons.sort_by_alpha,
                  size: 18),
              label: Text("Ordenar"),
              style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                  side: BorderSide(
                      color: _isSortPanelVisible
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade400),
                  foregroundColor: _isSortPanelVisible
                      ? Theme.of(context).primaryColor
                      : null),
              onPressed: () => setState(() {
                _isSortPanelVisible = !_isSortPanelVisible;
                if (_isSortPanelVisible && _isFilterPanelVisible)
                  _isFilterPanelVisible = false;
              }),
            ),
          ]),
          if (_isFilterPanelVisible) _buildFilterPanelContent(),
          if (_isSortPanelVisible) _buildSortPanel(),
          const SizedBox(height: 20),
          _filteredProjetos.isEmpty
              ? Center(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Text("Nenhum projeto encontrado.",
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 16))))
              : LayoutBuilder(builder: (context, constraints) {
                  int crossAxisCount = 3;
                  double cardHeight = 320; // Ajustada altura do card
                  if (constraints.maxWidth < 1200) crossAxisCount = 2;
                  if (constraints.maxWidth < 760) crossAxisCount = 1;
                  double itemWidth =
                      (constraints.maxWidth - (crossAxisCount - 1) * 16) /
                          crossAxisCount;
                  if (crossAxisCount == 1) itemWidth = constraints.maxWidth;
                  return Wrap(
                    spacing: 16.0,
                    runSpacing: 16.0,
                    children: _filteredProjetos
                        .map((projeto) => SizedBox(
                            width: itemWidth - (crossAxisCount > 1 ? 0.1 : 0),
                            height: cardHeight,
                            child: _buildProjectCard(projeto)))
                        .toList(),
                  );
                }),
        ],
      ),
    );
  }
}
