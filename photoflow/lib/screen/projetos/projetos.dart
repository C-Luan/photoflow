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
import 'package:photoflow/screen/projetos/dialog/detalhes_projetos.dart';
import 'package:photoflow/screen/projetos/dialog/novo_projeto_dialog.dart';
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
    // Dados mockados existentes e novos
    final cliente1 = Cliente(nome: "Maria Silva");
    final cliente2 = Cliente(nome: "João Pereira");
    final cliente3 = Cliente(nome: "Ana Costa");
    final cliente4 = Cliente(nome: "Carlos Mendes");
    final cliente5 = Cliente(nome: "Fernanda Lima");
    final cliente6 = Cliente(nome: "Roberto Alves");
    // Novos clientes
    final cliente7 = Cliente(nome: "Beatriz Santos");
    final cliente8 = Cliente(nome: "Lucas Oliveira");
    final cliente9 = Cliente(nome: "Juliana Martins");
    final cliente10 = Cliente(nome: "Ricardo Gomes");

    // final categoriaCasamento = CategoriaServico(
    //     id: 1, nome: "Casamento", descricao: "Serviços de casamento");
    // final categoriaEnsaio =
    //     CategoriaServico(id: 2, nome: "Ensaio", descricao: "Ensaios diversos");
    // final categoriaCorp = CategoriaServico(
    //     id: 3, nome: "Corporativo", descricao: "Eventos corporativos");
    // final categoriaProduto = CategoriaServico(
    //     id: 4,
    //     nome: "Produto",
    //     descricao: "Fotografia de produtos"); // Nova categoria

    // final tipoCasamento = Tiposervico(
    //     id: 101,
    //     categoriaId: 1,
    //     nome: "Casamento Completo",
    //     descricao: "Cobertura total",
    //     categoria: categoriaCasamento);
    // final tipoPreWedding = Tiposervico(
    //     id: 201,
    //     categoriaId: 2,
    //     nome: "Ensaio Pré-Wedding",
    //     descricao: "Ensaio antes do casamento",
    //     categoria: categoriaEnsaio);
    // final tipoGestante = Tiposervico(
    //     id: 202,
    //     categoriaId: 2,
    //     nome: "Ensaio Gestante",
    //     descricao: "Ensaio de gestante",
    //     categoria: categoriaEnsaio);
    // final tipoCorporativo = Tiposervico(
    //     id: 301,
    //     categoriaId: 3,
    //     nome: "Evento Corporativo",
    //     descricao: "Cobertura de evento",
    //     categoria: categoriaCorp);
    // final tipoAniversario = Tiposervico(
    //     id: 102,
    //     categoriaId: 1,
    //     nome: "Aniversário",
    //     descricao: "Festa de aniversário",
    //     categoria: categoriaCasamento);
    // final tipoEnsaioPessoal = Tiposervico(
    //     id: 203,
    //     categoriaId: 2,
    //     nome: "Ensaio Pessoal",
    //     descricao: "Retratos",
    //     categoria: categoriaEnsaio);
    // // Novos tipos de serviço
    // final tipoProdutoStill = Tiposervico(
    //     id: 401,
    //     categoriaId: 4,
    //     nome: "Foto Still Produto",
    //     descricao: "Fotos de produto com fundo branco/neutro",
    //     categoria: categoriaProduto);
    // final tipoVideoReels = Tiposervico(
    //     id: 204,
    //     categoriaId: 2,
    //     nome: "Vídeo Reels Ensaio",
    //     descricao: "Vídeo curto para redes sociais",
    //     categoria: categoriaEnsaio);
    // final tipoInstitucional = Tiposervico(
    //     id: 302,
    //     categoriaId: 3,
    //     nome: "Vídeo Institucional",
    //     descricao: "Vídeo para apresentação da empresa",
    //     categoria: categoriaCorp);

    final etapaFinalizado = EtapaProjeto(nome: "Finalizado", id: 5);
    final etapaEmExecucao = EtapaProjeto(nome: "Em Execução", id: 3);
    final etapaAgendado = EtapaProjeto(nome: "Agendado", id: 1);
    final etapaPendente = EtapaProjeto(nome: "Revisão Cliente", id: 4);
    final etapaCancelada = EtapaProjeto(
        nome: "Planejamento",
        id: 2); // Etapa base para um projeto que foi cancelado
    final etapaEdicao = EtapaProjeto(nome: "Edição", id: 6); // Nova etapa

    final today = DateTime.now();
    final DateFormat mockDateFormat = DateFormat(
        'yyyy-MM-dd'); // Para facilitar a criação de datas passadas/futuras

    setState(() {
      _allProjetos = [
        // Projetos existentes
        // Projeto(
        //     cliente: cliente1,
        //     tipoServico: tipoCasamento,
        //     etapaProjeto: etapaFinalizado,
        //     categoriaServico: categoriaCasamento,
        //     observacao: "Casamento da Maria, tudo entregue.",
        //     conclusao: true,
        //     dataInicio: DateTime(2023, 10, 1),
        //     dataFim: DateTime(2023, 10, 24),
        //     prazo: DateTime(2023, 10, 25),
        //     valor: 2500.00),
        // Projeto(
        //     cliente: cliente2,
        //     tipoServico: tipoPreWedding,
        //     etapaProjeto: etapaEmExecucao,
        //     categoriaServico: categoriaEnsaio,
        //     observacao: "Ensaio do João, aguardando seleção.",
        //     conclusao: false,
        //     dataInicio: DateTime(2023, 10, 18),
        //     dataFim: null,
        //     prazo: today.add(Duration(days: 5)),
        //     valor: 850.00),
        // Projeto(
        //     cliente: cliente3,
        //     tipoServico: tipoGestante,
        //     etapaProjeto: etapaAgendado,
        //     categoriaServico: categoriaEnsaio,
        //     observacao: "Ensaio da Ana, confirmar local.",
        //     conclusao: false,
        //     dataInicio: today.add(Duration(days: 10)),
        //     dataFim: null,
        //     prazo: today.add(Duration(days: 30)),
        //     valor: 600.00), // Agendado para o futuro
        // Projeto(
        //     cliente: cliente4,
        //     tipoServico: tipoCorporativo,
        //     etapaProjeto: etapaCancelada,
        //     categoriaServico: categoriaCorp,
        //     observacao: "Evento cancelado pelo cliente devido à chuva.",
        //     conclusao: false,
        //     dataInicio: DateTime(2023, 9, 1),
        //     dataFim: null,
        //     prazo: DateTime(2023, 9, 30),
        //     valor: 1200.00,
        //     cancelado: true),
        // Projeto(
        //     cliente: cliente5,
        //     tipoServico: tipoAniversario,
        //     etapaProjeto: etapaPendente,
        //     categoriaServico: categoriaCasamento,
        //     observacao: "Aguardando pagamento final e aprovação das fotos.",
        //     conclusao: false,
        //     dataInicio: DateTime(2023, 11, 1),
        //     dataFim: null,
        //     prazo: today.subtract(Duration(days: 3)),
        //     valor: 750.00,
        //     pendente: true),
        // Projeto(
        //     cliente: cliente6,
        //     tipoServico: tipoEnsaioPessoal,
        //     etapaProjeto: etapaAgendado,
        //     categoriaServico: categoriaEnsaio,
        //     observacao: "Ensaio pessoal Roberto, local definido.",
        //     conclusao: false,
        //     dataInicio: today.add(Duration(days: 15)),
        //     dataFim: null,
        //     prazo: today.add(Duration(days: 45)),
        //     valor: 450.00), // Agendado para o futuro

        // // Novos projetos para mais exemplos
        // Projeto(
        //   cliente: cliente7,
        //   tipoServico: tipoProdutoStill,
        //   etapaProjeto: etapaEdicao, // Nova etapa "Edição"
        //   categoriaServico: categoriaProduto,
        //   observacao: "Fotos para catálogo de e-commerce, 20 produtos.",
        //   conclusao: false,
        //   dataInicio:
        //       today.subtract(Duration(days: 7)), // Iniciou semana passada
        //   prazo: today.add(Duration(days: 7)), // Prazo para daqui uma semana
        //   valor: 950.00,
        // ),
        // Projeto(
        //   cliente: cliente8,
        //   tipoServico: tipoVideoReels,
        //   etapaProjeto: etapaAgendado,
        //   categoriaServico: categoriaEnsaio,
        //   observacao: "Vídeo curto para Instagram, tema outono.",
        //   conclusao: false,
        //   dataInicio: today.add(Duration(days: 3)), // Inicia em 3 dias
        //   prazo: today.add(Duration(days: 10)),
        //   valor: 350.00,
        // ),
        // Projeto(
        //   cliente: cliente9,
        //   tipoServico: tipoInstitucional,
        //   etapaProjeto: etapaEmExecucao,
        //   categoriaServico: categoriaCorp,
        //   observacao: "Roteiro aprovado, iniciando filmagens externas.",
        //   conclusao: false,
        //   dataInicio: today.subtract(Duration(days: 10)),
        //   prazo: today.add(Duration(days: 20)),
        //   valor: 3200.00,
        // ),
        // Projeto(
        //   cliente: cliente10,
        //   tipoServico: tipoCasamento, // Outro casamento
        //   etapaProjeto: etapaPendente, // Pendente de alguma definição
        //   categoriaServico: categoriaCasamento,
        //   observacao: "Aguardando escolha do álbum pelos noivos.",
        //   conclusao:
        //       false, // Ainda não concluído, mas a etapa principal pode ter sido
        //   dataInicio: DateTime(2023, 8, 15), // Projeto mais antigo
        //   dataFim: null, // Ainda não tem data fim real
        //   prazo: DateTime(2023, 12, 30), // Prazo longo, mas está pendente
        //   valor: 2800.00,
        //   pendente: true,
        // ),
        // Projeto(
        //   cliente: cliente1, // Cliente repetido, outro projeto
        //   tipoServico: tipoEnsaioPessoal,
        //   etapaProjeto: etapaAgendado,
        //   categoriaServico: categoriaEnsaio,
        //   observacao: "Novo ensaio para Maria, desta vez em estúdio.",
        //   conclusao: false,
        //   dataInicio: today.add(Duration(days: 25)),
        //   prazo: today.add(Duration(days: 50)),
        //   valor: 500.00,
        // ),
      ];
      _populateDynamicFiltersFromData();
      _applyAllFilters();
    });
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
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (builder) => NovoProjetoDialog(
                      tiposDeServicoDisponiveis: _tiposServicoParaFiltro,
                      etapasDeProjetoDisponiveis: []),
                );
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("TODO: Chamar Dialog Novo Projeto")));
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
