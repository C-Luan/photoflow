// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
// Certifique-se que os caminhos para seus modelos estão corretos
import 'package:photoflow/models/projeto/projeto.dart';
import 'package:photoflow/models/tiposervico/tiposervico.dart';
import 'package:photoflow/models/tiposervico/categoria.dart';
import 'package:photoflow/models/cliente/cliente.dart';
import 'package:photoflow/models/projeto/etapa_projeto.dart';

// Constante para breakpoint
const double kProjetosDesktopBreakpoint = 700.0;

// Classe Tuple2
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
  bool _isSortPanelVisible = false;
  String? _sortByField;
  bool _sortAscending = true;
  final List<String> _sortableFields = [
    "Data de Início", "Nome do Cliente", "Prazo Final", "Status (Etapa)",
    "Valor" // Adicionado Valor
  ];

  // --- PLACEHOLDERS DE MODELO ---
  // Remova-os e use seus imports reais.
  // class Cliente { String nome; Cliente({required this.nome}); factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(nome: json['nome'] ?? 'Cliente Desconhecido'); }
  // class EtapaProjeto { String nome; int? id; EtapaProjeto({required this.nome, this.id}); factory EtapaProjeto.fromJson(Map<String, dynamic> json) => EtapaProjeto(nome: json['nome'] ?? 'Etapa Desconhecida', id: json['id']); }
  // class CategoriaServico { final int id; final String nome; final String descricao; CategoriaServico({required this.id, required this.nome, required this.descricao}); factory CategoriaServico.fromJson(Map<String, dynamic> json) => CategoriaServico(id: json['id'], nome: json['nome'], descricao: json['descricao']); @override bool operator ==(Object other) => identical(this, other) || other is CategoriaServico && runtimeType == other.runtimeType && id == other.id; @override int get hashCode => id.hashCode; @override String toString() => nome;}
  // class Tiposervico { int? id; int categoriaId; String nome; String descricao; CategoriaServico? categoria; Tiposervico({this.id, required this.categoriaId, required this.nome, required this.descricao, this.categoria}); factory Tiposervico.fromJson(Map<String, dynamic> json) => Tiposervico(id:json['id'], categoriaId: json['categoria_id'], nome: json['nome'], descricao: json['descricao'], categoria: json['categoria'] !=null ? CategoriaServico.fromJson(json['categoria']) : null); @override bool operator ==(Object other) => identical(this, other) || other is Tiposervico && runtimeType == other.runtimeType && id == other.id; @override int get hashCode => id.hashCode; @override String toString() => nome;}
  // --- FIM DOS PLACEHOLDERS DE MODELO ---

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

  void _loadProjetos() {
    final cliente1 = Cliente(nome: "Maria Silva");
    final cliente2 = Cliente(nome: "João Pereira");
    final cliente3 = Cliente(nome: "Ana Costa");
    final cliente4 = Cliente(nome: "Carlos Mendes");
    final cliente5 = Cliente(nome: "Fernanda Lima");
    final cliente6 = Cliente(nome: "Roberto Alves");

    final categoriaCasamento = CategoriaServico(
        id: 1, nome: "Casamento", descricao: "Serviços de casamento");
    final categoriaEnsaio =
        CategoriaServico(id: 2, nome: "Ensaio", descricao: "Ensaios diversos");
    final categoriaCorp = CategoriaServico(
        id: 3, nome: "Corporativo", descricao: "Eventos corporativos");

    final tipoCasamento = Tiposervico(
        id: 101,
        categoriaId: 1,
        nome: "Casamento Completo",
        descricao: "Cobertura total",
        categoria: categoriaCasamento);
    final tipoPreWedding = Tiposervico(
        id: 201,
        categoriaId: 2,
        nome: "Ensaio Pré-Wedding",
        descricao: "Ensaio antes do casamento",
        categoria: categoriaEnsaio);
    final tipoGestante = Tiposervico(
        id: 202,
        categoriaId: 2,
        nome: "Ensaio Gestante",
        descricao: "Ensaio de gestante",
        categoria: categoriaEnsaio);
    final tipoCorporativo = Tiposervico(
        id: 301,
        categoriaId: 3,
        nome: "Evento Corporativo",
        descricao: "Cobertura de evento",
        categoria: categoriaCorp);
    final tipoAniversario = Tiposervico(
        id: 102,
        categoriaId: 1,
        nome: "Aniversário",
        descricao: "Festa de aniversário",
        categoria: categoriaCasamento);
    final tipoEnsaioPessoal = Tiposervico(
        id: 203,
        categoriaId: 2,
        nome: "Ensaio Pessoal",
        descricao: "Retratos",
        categoria: categoriaEnsaio);

    final etapaFinalizado = EtapaProjeto(nome: "Finalizado", id: 5);
    final etapaEmExecucao = EtapaProjeto(nome: "Em Execução", id: 3);
    final etapaAgendado = EtapaProjeto(nome: "Agendado", id: 1);
    final etapaPendente = EtapaProjeto(
        nome: "Revisão Cliente",
        id: 4); // Exemplo de etapa para um projeto pendente
    final etapaCancelada = EtapaProjeto(
        nome: "Planejamento",
        id: 2); // Exemplo de etapa para um projeto cancelado
    final today = DateTime.now();

    // TODO: Substitua pela sua lógica real de carregamento de dados.
    setState(() {
      _allProjetos = [
        Projeto(
            cliente: cliente1,
            tipoServico: tipoCasamento,
            etapaProjeto: etapaFinalizado,
            categoriaServico: categoriaCasamento,
            observacao: "Casamento da Maria",
            conclusao: true,
            dataInicio: DateTime(2023, 10, 1),
            dataFim: DateTime(2023, 10, 24),
            prazo: DateTime(2023, 10, 25),
            valor: 2500.00,
            cancelado: false,
            pendente: false),
        Projeto(
            cliente: cliente2,
            tipoServico: tipoPreWedding,
            etapaProjeto: etapaEmExecucao,
            categoriaServico: categoriaEnsaio,
            observacao: "Ensaio do João",
            conclusao: false,
            dataInicio: DateTime(2023, 10, 18),
            dataFim: null,
            prazo: today.add(Duration(days: 5)),
            valor: 850.00,
            cancelado: false,
            pendente: false),
        Projeto(
            cliente: cliente3,
            tipoServico: tipoGestante,
            etapaProjeto: etapaAgendado,
            categoriaServico: categoriaEnsaio,
            observacao: "Ensaio da Ana",
            conclusao: false,
            dataInicio: DateTime(2023, 11, 1),
            dataFim: null,
            prazo: today,
            valor: 600.00,
            cancelado: false,
            pendente: false),
        Projeto(
            cliente: cliente4,
            tipoServico: tipoCorporativo,
            etapaProjeto: etapaCancelada,
            categoriaServico: categoriaCorp,
            observacao: "Evento cancelado pelo cliente.",
            conclusao: false,
            dataInicio: DateTime(2023, 9, 1),
            dataFim: null,
            prazo: DateTime(2023, 9, 30),
            valor: 1200.00,
            cancelado: true,
            pendente: false),
        Projeto(
            cliente: cliente5,
            tipoServico: tipoAniversario,
            etapaProjeto: etapaPendente,
            categoriaServico: categoriaCasamento,
            observacao: "Aguardando pagamento final",
            conclusao: false,
            dataInicio: DateTime(2023, 11, 1),
            dataFim: null,
            prazo: today.subtract(Duration(days: 3)),
            valor: 750.00,
            cancelado: false,
            pendente: true),
        Projeto(
            cliente: cliente6,
            tipoServico: tipoEnsaioPessoal,
            etapaProjeto: etapaAgendado,
            categoriaServico: categoriaEnsaio,
            observacao: "Ensaio pessoal Roberto",
            conclusao: false,
            dataInicio: DateTime(2023, 11, 10),
            dataFim: null,
            prazo: today.add(Duration(days: 20)),
            valor: 450.00,
            cancelado: false,
            pendente: false),
      ];
      _populateDynamicFiltersFromData();
      _applyAllFilters();
    });
  }

  void _populateDynamicFiltersFromData() {
    // ... (Lógica como antes para popular _etapasDisponiveisParaFiltro, _tiposServicoParaFiltro, _categoriasServicoParaFiltro) ...
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
    // ... (Lógica de filtragem como antes) ...
    List<Projeto> tempProjetos = List.from(_allProjetos);
    if (_selectedProjectFilterTab != "Todos") {
      tempProjetos = tempProjetos
          .where((p) =>
              _getProjectStatusAndColor(p).item1 == _selectedProjectFilterTab)
          .toList();
    } // Modificado para usar o status real para filtro de aba
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
              (p.valor?.toString().contains(query) ?? false))
          .toList();
    } // Adicionado valor na busca

    setState(() {
      _filteredProjetos = tempProjetos;
      _applySorting();
    });
  }

  void _clearAllFilters() {
    // ... (Como antes) ...
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
    if (_sortByField == null || _filteredProjetos.isEmpty) {
      // Ordenação padrão se nenhuma for selecionada (ex: por data de início mais nova)
      if (_filteredProjetos.isNotEmpty) {
        _filteredProjetos.sort((a, b) => b.dataInicio.compareTo(a.dataInicio));
      }
      // setState(() {}); // Para atualizar a UI com a ordenação padrão se _sortByField for null
      return;
    }

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
        case "Valor": // Nova ordenação por valor
          double valA =
              a.valor ?? 0.0; // Trata valor nulo como 0 para ordenação
          double valB = b.valor ?? 0.0;
          r = valA.compareTo(valB);
          break;
      }
      return _sortAscending ? r : -r;
    });
    // setState(() {}); // O setState será chamado pelo "Aplicar" do painel de sort ou por _applyAllFilters
  }

  // ATUALIZADO: _getProjectStatusAndColor para incluir cancelado e pendente
  Tuple2<String, Color> _getProjectStatusAndColor(Projeto projeto) {
    if (projeto.cancelado) return Tuple2("Cancelado", Colors.grey.shade500);
    if (projeto.conclusao) return Tuple2("Concluído", Colors.green.shade600);
    if (projeto.pendente) return Tuple2("Pendente", Colors.orange.shade700);

    // Assegure que etapaProjeto e etapaProjeto.nome não sejam nulos
    final etapaNome = projeto.etapaProjeto.nome.toLowerCase();
    switch (etapaNome) {
      case "em execução":
      case "em andamento":
        return Tuple2("Em Andamento", Colors.blue.shade600);
      case "agendado":
      case "planejamento":
        return Tuple2("Agendado", Colors.purple.shade600);
      default:
        return Tuple2(projeto.etapaProjeto.nome,
            Colors.blueGrey.shade600); // Cor padrão para outras etapas
    }
  }

  // ATUALIZADO: _getProjectProgress para considerar cancelado e pendente
  double _getProjectProgress(Projeto projeto) {
    if (projeto.cancelado)
      return 0.0; // Ou 1.0 se quiser preencher a barra com cor de cancelado
    if (projeto.conclusao) return 1.0;
    if (projeto.pendente) return 0.75; // Exemplo: 75% se pendente de algo final

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

  Widget _buildProjectSummaryCard(
      {required String title,
      required int count,
      required IconData iconData,
      required Color iconColor}) {
    // ... (Como antes) ...
    return Expanded(
        child: Card(
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
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade700)),
                        const SizedBox(height: 4),
                        Text(count.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold)),
                      ])
                ]))));
  }

  Widget _buildProjectCard(Projeto projeto) {
    final statusInfo = _getProjectStatusAndColor(projeto); // (nome, cor)
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

    // Formata o título do projeto: Tipo de Serviço + Sobrenome do Cliente (Exemplo)
    String projectTitle = projeto.tipoServico.nome;
    List<String> clientNameParts = projeto.cliente.nome.split(" ");
    if (clientNameParts.length > 1) {
      projectTitle += " ${clientNameParts.last}";
    } else {
      projectTitle += " ${projeto.cliente.nome}";
    }

    return Card(
      elevation: 2.5, // Um pouco mais de elevação para o estilo do card
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(10.0)), // Bordas levemente arredondadas
      clipBehavior: Clip.antiAlias, // Garante que o conteúdo respeite as bordas
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Para empurrar ações para baixo
          children: [
            Column(
              // Conteúdo principal do card
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Linha 1: Título do Projeto e Valor
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        projectTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 17), // Fonte um pouco maior
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    if (projeto.valor != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          currencyFormat.format(projeto.valor),
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // Linha 2: Data de Início
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 15, color: Colors.grey.shade700),
                    const SizedBox(width: 6),
                    Text(dateFormat.format(projeto.dataInicio),
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade700)),
                  ],
                ),
                const SizedBox(height: 6),

                // Linha 3: Nome do Cliente
                Row(
                  children: [
                    Icon(Icons.person_outline,
                        size: 16, color: Colors.grey.shade700),
                    const SizedBox(width: 6),
                    Expanded(
                      // Para o nome do cliente não estourar
                      child: Text(projeto.cliente.nome,
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade700),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Linha 4: Tags/Chips (Categoria, Tipo de Serviço) e Status Badge
                Row(
                  spacing: 20,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Wrap(
                      spacing: 6.0,
                      runSpacing: 4.0,
                      children: [
                        _buildTagChip(projeto.categoriaServico.nome,
                            Colors.purple.shade50),
                        // O segundo chip pode ser o nome do tipo de serviço se for curto, ou uma subcategoria
                        // _buildTagChip(projeto.tipoServico.nome, Colors.blue.shade50),
                      ],
                    ),
                    Wrap(
                      spacing: 6.0,
                      runSpacing: 4.0,
                      children: [
                        _buildTagChip(statusInfo.item1, statusInfo.item2),
                        // O segundo chip pode ser o nome do tipo de serviço se for curto, ou uma subcategoria
                        // _buildTagChip(projeto.tipoServico.nome, Colors.blue.shade50),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Linha 5: Prazo Final e Contador (se aplicável)
                if (mostrarContadorPrazo) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.hourglass_empty_outlined,
                          size: 14, color: Colors.grey.shade700),
                      const SizedBox(width: 4),
                      Text("Prazo: ${dateFormat.format(projeto.prazo)}",
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade700)),
                      const SizedBox(width: 8),
                      if (prazoText.isNotEmpty)
                        Expanded(
                          child: Text(
                            prazoText,
                            style: TextStyle(
                                fontSize: 11,
                                color: prazoColor,
                                fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ] else if (projeto.conclusao && projeto.dataFim != null) ...[
                  Text("Concluído em: ${dateFormat.format(projeto.dataFim!)}",
                      style: TextStyle(
                          fontSize: 12, color: Colors.green.shade700)),
                  const SizedBox(height: 8),
                ] else if (projeto.cancelado) ...[
                  Text("Prazo original: ${dateFormat.format(projeto.prazo)}",
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                ],

                // Linha 6: Barra de Progresso (mantida conforme solicitado)
                if (!projeto.cancelado) ...[
                  // Não mostra progresso se cancelado
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          statusInfo.item2), // Usa a cor do status
                      minHeight: 7, // Um pouco mais espessa
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text("${(progressValue * 100).toStringAsFixed(0)}%",
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600)),
                  ),
                ],
              ],
            ),

            // Linha 7: Ações (empurrada para baixo pelo Flexible Space ou MainAxisAlignment.spaceBetween no Column principal)
            // Ou usando Spacer() no Column principal se a altura for fixa.
            // Como a altura do card é dinâmica pelo Wrap na grade, vamos usar MainAxisAlignment.spaceBetween no Column principal.
            Padding(
              // Adiciona um pouco de padding acima dos botões
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      // TODO: Implementar navegação para detalhes do projeto
                    },
                    style: OutlinedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        side: BorderSide(
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.7)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    child: Text("Ver detalhes",
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor)),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit_outlined,
                            size: 20, color: Colors.grey.shade700),
                        tooltip: "Editar Projeto",
                        splashRadius: 20,
                        onPressed: () {
                          // TODO: Implementar edição do projeto
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline,
                            size: 20, color: Colors.red.shade400),
                        tooltip: "Excluir Projeto",
                        splashRadius: 20,
                        onPressed: () {
                          // TODO: Implementar exclusão do projeto
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// Helper para as Tags/Chips
  Widget _buildTagChip(String label, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11,
            color: (backgroundColor.computeLuminance() > 0.5
                    ? Colors.black87
                    : Colors.white)
                .withOpacity(0.8),
            fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildEtapaFilterTab(String title) {
    // ... (Como antes) ...
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
    // ... (Como antes) ...
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
    // Adicionar contadores para pendente e cancelado se desejar nos summary cards

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sub-Header (FotoGerente, Novo Projeto)
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
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0))),
              onPressed: () {
                // TODO: Chamar o NovoProjetoDialog.dart que foi criado em arquivo separado.
                // Você precisará de uma função como _abrirDialogNovoProjeto() em _ProjetosScreenState
                // que chame `showDialog` e passe as listas de tipos de serviço e etapas.
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("TODO: Chamar Dialog Novo Projeto")));
              },
            ),
          ]),
          const SizedBox(height: 24),

          // Cards de Resumo
          LayoutBuilder(builder: (context, constraints) {
            bool useRow = constraints.maxWidth > kProjetosDesktopBreakpoint;
            List<Widget> summaryItems = [
              _buildProjectSummaryCard(
                  title: "Projetos Concluídos",
                  count: concluidosCount,
                  iconData: Icons.check_circle_outline,
                  iconColor: Colors.green),
              SizedBox(width: useRow ? 16 : 0, height: useRow ? 0 : 16),
              _buildProjectSummaryCard(
                  title: "Em Andamento",
                  count: emAndamentoCount,
                  iconData: Icons.hourglass_top_outlined,
                  iconColor: Colors.blue),
              SizedBox(width: useRow ? 16 : 0, height: useRow ? 0 : 16),
              _buildProjectSummaryCard(
                  title: "Agendados",
                  count: agendadosCount,
                  iconData: Icons.calendar_today_outlined,
                  iconColor: Colors.purple),
            ];
            // TODO: Adicionar cards para Pendentes e Cancelados se desejar
            return useRow
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: summaryItems)
                : Column(children: summaryItems);
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
                  backgroundColor: _isFilterPanelVisible
                      ? Theme.of(context).primaryColor.withOpacity(0.8)
                      : Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
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

          // Painel de Filtros Condicional
          if (_isFilterPanelVisible) _buildFilterPanelContent(),

          // Painel de Ordenação Condicional
          if (_isSortPanelVisible) _buildSortPanel(),

          const SizedBox(height: 20),

          // Grid de Projetos
          _filteredProjetos.isEmpty
              ? Center(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Text("Nenhum projeto encontrado.",
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 16))))
              : LayoutBuilder(builder: (context, constraints) {
                  int crossAxisCount = 3;
                  double cardHeight =
                      310; // Aumentei um pouco mais a altura do card
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
