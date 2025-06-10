// File: lib/panels/agenda_panel.dart

// Flutter imports:
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart' as sfc;
import 'package:table_calendar/table_calendar.dart' as tc;

// Project imports:
import 'package:photoflow/models/agendamento/agendamento.dart';
import 'package:photoflow/models/tiposervico/categoria.dart';
import 'package:photoflow/models/tiposervico/tiposervico.dart';

import '../../services/categoria/get_categorias_service.dart';
import 'dialogs/novo_agendamento_dialog.dart';
import 'sections/agendamentos_section.dart';
import 'sections/calendar_section.dart';
import 'sections/relatorio_section.dart';
import 'widgets/menubar.dart';

// Enum para as seções principais
enum MainSection { calendario, agendamentos, relatorio }

class AgendaPanel extends StatefulWidget {
  const AgendaPanel({super.key});

  @override
  AgendaPanelState createState() => AgendaPanelState();
}

class AgendaPanelState extends State<AgendaPanel> {
  // --- ESTADO PRINCIPAL ---

  // Navegação
  MainSection _selectedMainSection = MainSection.calendario;

  // Dados
  List<Agendamento> _allAgendamentos = [];
  List<CategoriaServico> _listaTodasCategorias = [];
  List<Tiposervico> _listaTodosTiposServico = [];

  // Calendário
  List<Agendamento> _selectedDayAppointments = [];
  DateTime _currentlySelectedDate = DateTime.now();
  tc.CalendarFormat _tcCalendarFormat = tc.CalendarFormat.month;
  DateTime _tcFocusedDay = DateTime.now();
  Map<DateTime, List<Agendamento>> _tcEvents = {};
  sfc.CalendarView _sfCalendarView = sfc.CalendarView.month;
  final sfc.CalendarController _sfCalendarController = sfc.CalendarController();
//loading
  bool _isLoadingCategorias = false;
  String? _categoriasError;
  // Relatório
  String _periodoRelatorioSelecionado = "Este Mês";
  final List<String> _opcoesPeriodoRelatorio = [
    "Hoje",
    "Ontem",
    "Esta Semana",
    "Semana Passada",
    "Este Mês",
    "Mês Passado",
    "Este Ano",
    "Personalizado"
  ];
  final Map<String, dynamic> _dadosResumoRelatorio = {
    'faturamentoTotal': 1850.0,
    'faturamentoPercentual': 15.2,
    'totalAgendamentos': 3,
    'agendamentosPercentual': -10.0,
    'ticketMedio': 616.67,
    'ticketMedioPercentual': 28.5,
  };

  // --- CICLO DE VIDA ---

  @override
  void initState() {
    super.initState();
    _fetchCategoriasDoServidor();
    // _loadCategoriasETiposServico();
    _loadAppointments();
    _tcFocusedDay = _currentlySelectedDate;
    _sfCalendarController.selectedDate = _currentlySelectedDate;
    _sfCalendarController.displayDate = _currentlySelectedDate;
  }

  // --- LÓGICA DE NEGÓCIOS E MANIPULAÇÃO DE DADOS ---

  void _loadAppointments() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    // Simulação de dados. Substitua pela sua fonte de dados real.
    setState(() {
      _allAgendamentos = [
        Agendamento(
            id: '1',
            nome: 'Maria Silva',
            email: 'm@s.com',
            telefone: '111',
            data: DateTime(today.year, today.month, today.day, 10, 0),
            servico: 'Ensaio Externo'),
        Agendamento(
            id: '2',
            nome: 'Joana e Pedro',
            email: 'j@p.com',
            telefone: '222',
            data: DateTime(today.year, today.month, today.day, 15, 30),
            servico: 'Cobertura Casamento'),
        Agendamento(
            id: '3',
            nome: 'Empresa X',
            email: 'e@x.com',
            telefone: '333',
            data: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 14, 0),
            servico: 'Vídeo Institucional'),
      ];
      _prepareTableCalendarEvents();
      _updateSelectedDayAppointmentsList(_currentlySelectedDate);
    });
  }

  void _addNewAppointment(Agendamento newAppointment) {
    setState(() {
      _allAgendamentos.add(newAppointment);
      _allAgendamentos.sort((a, b) => a.data.compareTo(b.data));
      _prepareTableCalendarEvents();
      _updateSelectedDayAppointmentsList(_currentlySelectedDate);
    });
  }

  void _prepareTableCalendarEvents() {
    _tcEvents.clear();
    for (var agendamento in _allAgendamentos) {
      final dayOnly = DateTime(
          agendamento.data.year, agendamento.data.month, agendamento.data.day);
      if (_tcEvents[dayOnly] == null) {
        _tcEvents[dayOnly] = [];
      }
      _tcEvents[dayOnly]!.add(agendamento);
    }
  }

  void _updateSelectedDayAppointmentsList(DateTime date) {
    setState(() {
      _selectedDayAppointments = _allAgendamentos.where((ag) {
        return ag.data.year == date.year &&
            ag.data.month == date.month &&
            ag.data.day == date.day;
      }).toList();
      _selectedDayAppointments.sort((a, b) => a.data.compareTo(b.data));
    });
  }

  // --- CALLBACKS E HANDLERS ---

  void _onTcDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!tc.isSameDay(_currentlySelectedDate, selectedDay)) {
      setState(() {
        _currentlySelectedDate = selectedDay;
        _tcFocusedDay = focusedDay;
        _sfCalendarController.selectedDate = _currentlySelectedDate;
        _updateSelectedDayAppointmentsList(selectedDay);
      });
    }
  }

  void _onSfCalendarTapped(sfc.CalendarTapDetails details) {
    if (details.targetElement == sfc.CalendarElement.calendarCell ||
        details.targetElement == sfc.CalendarElement.appointment) {
      if (details.date != null &&
          !tc.isSameDay(_currentlySelectedDate, details.date!)) {
        setState(() {
          _currentlySelectedDate = details.date!;
          _tcFocusedDay = details.date!;
          _updateSelectedDayAppointmentsList(details.date!);
        });
      }
    }
  }

  Future<void> _showNovoAgendamentoDialog() async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return NovoAgendamentoDialog(
          categorias: _listaTodasCategorias,
          todosTiposServico: _listaTodosTiposServico,
          initialDate: _currentlySelectedDate,
          onSave: _addNewAppointment,
        );
      },
    );
  }

  void _editAppointment(Agendamento agendamento) {
    // TODO: Implementar lógica de edição. Pode abrir o `NovoAgendamentoDialog` preenchido.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Ação 'Editar' para: ${agendamento.nome}")),
    );
  }

  void _deleteAppointment(Agendamento agendamento) {
    // TODO: Implementar lógica de exclusão com diálogo de confirmação.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Ação 'Excluir' para: ${agendamento.nome}")),
    );
  }

  void _exportReport() {
    // TODO: Implementar lógica de exportação (gerar PDF, CSV, etc.)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Exportar relatório clicado!")),
    );
  }

  void _handleLogout() {
    // TODO: Implementar lógica de logout (limpar provider, navegar para tela de login)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Logout não implementado.")),
    );
  }

  // --- MÉTODO BUILD PRINCIPAL ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MainMenuBar(
            selectedSection: _selectedMainSection,
            onSectionSelected: (section) =>
                setState(() => _selectedMainSection = section),
            onLogout: _handleLogout,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: kIsWeb ? 8.0 : 0,
                vertical: kIsWeb ? 8.0 : 0,
              ),
              child: _buildCurrentSection(),
            ),
          ),
        ],
      ),
    );
  }

  // --- ROTEADOR DE SEÇÃO ---

  Widget _buildCurrentSection() {
    switch (_selectedMainSection) {
      case MainSection.calendario:
        return CalendarSection(
          focusedDay: _tcFocusedDay,
          selectedDay: _currentlySelectedDate,
          allAgendamentos: _allAgendamentos,
          selectedDayAppointments: _selectedDayAppointments,
          tcEvents: _tcEvents,
          tcCalendarFormat: _tcCalendarFormat,
          sfCalendarView: _sfCalendarView,
          sfCalendarController: _sfCalendarController,
          categorias: _listaTodasCategorias,
          tiposServico: _listaTodosTiposServico,
          onTcDaySelected: _onTcDaySelected,
          onTcFormatChanged: (format) =>
              setState(() => _tcCalendarFormat = format),
          onTcPageChanged: (focusedDay) =>
              setState(() => _tcFocusedDay = focusedDay),
          onSfCalendarTapped: _onSfCalendarTapped,
          onSfViewChanged: (view) => setState(() => _sfCalendarView = view),
          onNewAppointmentSaved: _addNewAppointment,
        );

      case MainSection.agendamentos:
        return AgendamentosSection(
          agendamentos: _allAgendamentos,
          onAdd: _showNovoAgendamentoDialog,
          onEdit: _editAppointment,
          onDelete: _deleteAppointment,
        );

      case MainSection.relatorio:
        return RelatorioSection(
          dadosResumo: _dadosResumoRelatorio,
          periodoSelecionado: _periodoRelatorioSelecionado,
          opcoesPeriodo: _opcoesPeriodoRelatorio,
          onPeriodoChanged: (novoPeriodo) {
            setState(() {
              _periodoRelatorioSelecionado = novoPeriodo;
              // TODO: Adicionar lógica para recarregar os dados do relatório com base no novo período
            });
          },
          onExport: _exportReport,
        );
    }
  }

  /// Nova função para buscar os dados da API
  Future<void> _fetchCategoriasDoServidor() async {
    setState(() {
      _isLoadingCategorias = true;
      _categoriasError = null;
    });

    try {
      String token =
          await FirebaseAuth.instance.currentUser!.getIdToken() ?? '';

      final response = await getCategoriasService(token: token);

      if (response != null && response.statusCode == 200) {
        // Converte a lista de JSON para uma lista de objetos CategoriaServico
        final List<dynamic> responseData = response.data;

        final categorias = responseData
            .map((json) => CategoriaServico.fromJson(json))
            .toList();

        setState(() {
          _listaTodasCategorias = categorias;
          _isLoadingCategorias = false;
        });
      } else {
        setState(() {
          _categoriasError = "Falha ao buscar categorias do servidor.";
          _isLoadingCategorias = false;
        });
      }
    } catch (e) {
      setState(() {
        _categoriasError = "Ocorreu um erro inesperado: $e";
        _isLoadingCategorias = false;
      });
    }
  }
}
