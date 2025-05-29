// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';
// Se você decidir usar FluentIcons e tiver o pacote:
// import 'package:fluentui_system_icons/fluentui_system_icons.dart';

// Project imports:
// Certifique-se que o caminho para seu modelo Agendamento está correto
import 'package:photoflow/models/agendamento/agendamento.dart';
import 'package:photoflow/models/tiposervico/categoria.dart';
import 'package:photoflow/models/tiposervico/tiposervico.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart' as sfc;
import 'package:table_calendar/table_calendar.dart' as tc;

// Se você tiver AuthProvider e UserProvider e quiser usá-los para o menu:
// import 'package:provider/provider.dart';
// import 'package:photoflow/providers/auth_provider.dart'; // Ajuste o caminho
// import 'package:photoflow/providers/user_provider.dart'; // Ajuste o caminho

const double kDesktopBreakpoint = 700.0;

// Enum para as seções principais
enum MainSection { calendario, agendamentos, relatorio }

class AgendaPanel extends StatefulWidget {
  const AgendaPanel({super.key});

  @override
  AgendaPanelState createState() => AgendaPanelState();
}

class AgendaPanelState extends State<AgendaPanel> {
  // --- Estado para a Navegação Principal ---
  MainSection _selectedMainSection = MainSection.calendario;
  // Listas para os novos dropdowns
  List<CategoriaServico> _listaTodasCategorias = [];
  List<Tiposervico> _listaTodosTiposServico = [];

  // Para o diálogo
  List<Tiposervico> _tiposServicoFiltradosParaDialog = [];
  CategoriaServico? _categoriaSelecionadaDialog;
  Tiposervico? _tipoServicoSelecionadoDialog;
  // --- Estados Comuns para a seção Calendário e Lista de Agendamentos ---
  List<Agendamento> _allAgendamentos = []; // Todos os agendamentos carregados
  List<Agendamento> _selectedDayAppointments =
      []; // Agendamentos para o dia selecionado (usado no calendário)
  DateTime _currentlySelectedDate =
      DateTime.now(); // Data selecionada em qualquer calendário

  // --- Estados para TableCalendar (Mobile - Seção Calendário) ---
  tc.CalendarFormat _tcCalendarFormat = tc.CalendarFormat.month;
  DateTime _tcFocusedDay = DateTime.now();
  Map<DateTime, List<Agendamento>> _tcEvents =
      {}; // Dados formatados para o TableCalendar

  // --- Estados para Syncfusion SfCalendar (Desktop - Seção Calendário) ---
  sfc.CalendarView _sfCalendarView = sfc.CalendarView.month;
  final sfc.CalendarController _sfCalendarController = sfc.CalendarController();

  // Simula o carregamento de categorias e tipos de serviço
  void _loadCategoriasETiposServico() {
    // TODO: Substitua por sua lógica real de carregamento (API, Firebase, etc.)
    setState(() {
      _listaTodasCategorias = [
        CategoriaServico(
            id: 1,
            nome: "Fotografia de Eventos",
            descricao: "Cobertura de eventos sociais e corporativos."),
        CategoriaServico(
            id: 2,
            nome: "Ensaios Fotográficos",
            descricao: "Ensaios temáticos, pessoais, etc."),
        CategoriaServico(
            id: 3,
            nome: "Serviços Corporativos",
            descricao: "Fotografia e vídeo para empresas."),
      ];

      _listaTodosTiposServico = [
        // Eventos
        Tiposervico(
            id: 101,
            categoriaId: 1,
            nome: "Casamento - Pacote Básico",
            descricao: "Cobertura da cerimônia e recepção por 4 horas."),
        Tiposervico(
            id: 102,
            categoriaId: 1,
            nome: "Aniversário Infantil",
            descricao: "Registro fotográfico da festa."),
        Tiposervico(
            id: 103,
            categoriaId: 1,
            nome: "Evento Corporativo",
            descricao: "Cobertura de palestras, workshops, etc."),
        // Ensaios
        Tiposervico(
            id: 201,
            categoriaId: 2,
            nome: "Ensaio Gestante Externo",
            descricao: "Sessão de fotos em locação externa."),
        Tiposervico(
            id: 202,
            categoriaId: 2,
            nome: "Ensaio Newborn Estúdio",
            descricao: "Sessão com recém-nascido em estúdio."),
        Tiposervico(
            id: 203,
            categoriaId: 2,
            nome: "Ensaio Individual",
            descricao: "Retratos pessoais."),
        // Corporativos
        Tiposervico(
            id: 301,
            categoriaId: 3,
            nome: "Retratos Corporativos (Headshots)",
            descricao: "Fotos para perfil profissional."),
        Tiposervico(
            id: 302,
            categoriaId: 3,
            nome: "Fotografia de Produtos",
            descricao: "Fotos para catálogos e e-commerce."),
      ];
    });
  }

  @override
  void initState() {
    super.initState();
    _loadCategoriasETiposServico();
    _loadAppointments(); // Carrega os dados iniciais
    // Define a data selecionada e atualiza a lista de agendamentos para essa data
    _updateSelectedDayAppointmentsList(_currentlySelectedDate);
    // Inicializa o foco e datas dos calendários
    _tcFocusedDay = _currentlySelectedDate;
    _sfCalendarController.selectedDate = _currentlySelectedDate;
    _sfCalendarController.displayDate = _currentlySelectedDate;
  }

  void _loadAppointments() {
    // TODO: Substitua pela sua lógica real de carregamento de dados (API, Firebase, etc.)
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    // Simulação de dados
    setState(() {
      _allAgendamentos = [
        Agendamento(
            id: '1',
            nome: 'Maria Silva',
            email: 'm@s.com',
            telefone: '111',
            data: DateTime(today.year, today.month, today.day, 10, 0),
            servico:
                'Ensaio Externo' /*, categoria: "Retrato", valor: 250.0 */),
        Agendamento(
            id: '2',
            nome: 'Joana e Pedro',
            email: 'j@p.com',
            telefone: '222',
            data: DateTime(today.year, today.month, today.day, 15, 30),
            servico:
                'Cobertura Casamento' /*, categoria: "Evento", valor: 1200.0 */),
        Agendamento(
            id: '3',
            nome: 'Empresa X',
            email: 'e@x.com',
            telefone: '333',
            data: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 14, 0),
            servico:
                'Vídeo Institucional' /*, categoria: "Corporativo", valor: 800.0 */),
      ];
      _prepareTableCalendarEvents(); // Prepara os eventos para o table_calendar (mobile)
      _updateSelectedDayAppointmentsList(
          _currentlySelectedDate); // Atualiza a lista de agendamentos do dia (para a view do calendário)
    });
  }

  Future<void> _showNovoAgendamentoDialog(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    final _nomeClienteController = TextEditingController();
    final _dataController = TextEditingController();
    final _horaController = TextEditingController();
    // _categoriaSelecionadaDialog e _tipoServicoSelecionadoDialog já são membros da classe _AgendaPanelState
    // Reinicializa eles para este diálogo específico para não carregar seleções anteriores
    _categoriaSelecionadaDialog = null;
    _tipoServicoSelecionadoDialog = null;
    _tiposServicoFiltradosParaDialog = []; // Limpa a lista de tipos filtrados

    final _valorController = TextEditingController();
    final _observacoesController = TextEditingController();

    DateTime?
        _selectedDateInDialog; // Data selecionada DENTRO do picker do diálogo
    TimeOfDay?
        _selectedTimeInDialog; // Hora selecionada DENTRO do picker do diálogo

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          // Crucial para atualizar o estado INTERNO do diálogo
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Novo Agendamento'),
                  IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.of(dialogContext).pop()),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Nome do Cliente (como antes)
                      Text("Nome do Cliente",
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      SizedBox(height: 4),
                      TextFormField(
                        controller: _nomeClienteController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Nome completo"),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Nome é obrigatório.'
                            : null,
                      ),
                      SizedBox(height: 16),

                      // Data e Hora (como antes, mas usando _selectedDateInDialog e _selectedTimeInDialog)
                      Row(
                        /* ... Seu Row de Data e Hora ... */
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text("Data",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500)),
                                SizedBox(height: 4),
                                TextFormField(
                                  controller: _dataController,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'dd/mm/aaaa',
                                      suffixIcon: Icon(Icons.calendar_today)),
                                  readOnly: true,
                                  onTap: () async {
                                    DateTime? picked = await showDatePicker(
                                        context: context,
                                        initialDate: _selectedDateInDialog ??
                                            _currentlySelectedDate,
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2101),
                                        locale: const Locale('pt', 'BR'));
                                    if (picked != null) {
                                      setDialogState(() {
                                        _selectedDateInDialog = picked;
                                        _dataController.text =
                                            DateFormat('dd/MM/yyyy')
                                                .format(picked);
                                      });
                                    }
                                  },
                                  validator: (v) => v == null || v.isEmpty
                                      ? 'Data é obrigatória.'
                                      : null,
                                ),
                              ])),
                          SizedBox(width: 16),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text("Hora",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500)),
                                SizedBox(height: 4),
                                TextFormField(
                                  controller: _horaController,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: '--:--',
                                      suffixIcon: Icon(Icons.access_time)),
                                  readOnly: true,
                                  onTap: () async {
                                    TimeOfDay? picked = await showTimePicker(
                                        context: context,
                                        initialTime: _selectedTimeInDialog ??
                                            TimeOfDay.now(),
                                        builder: (c, w) => MediaQuery(
                                            data: MediaQuery.of(c).copyWith(
                                                alwaysUse24HourFormat: true),
                                            child: w!));
                                    if (picked != null) {
                                      setDialogState(() {
                                        _selectedTimeInDialog = picked;
                                        _horaController.text =
                                            picked.format(context);
                                      });
                                    }
                                  },
                                  validator: (v) => v == null || v.isEmpty
                                      ? 'Hora é obrigatória.'
                                      : null,
                                ),
                              ])),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Dropdown de Categoria
                      Text("Categoria",
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      SizedBox(height: 4),
                      DropdownButtonFormField<CategoriaServico>(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Selecione uma categoria"),
                        value: _categoriaSelecionadaDialog,
                        isExpanded: true,
                        items:
                            _listaTodasCategorias.map((CategoriaServico cat) {
                          return DropdownMenuItem<CategoriaServico>(
                            value: cat,
                            child:
                                Text(cat.nome, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (CategoriaServico? newValue) {
                          setDialogState(() {
                            _categoriaSelecionadaDialog = newValue;
                            _tipoServicoSelecionadoDialog =
                                null; // Reseta o tipo de serviço
                            _tiposServicoFiltradosParaDialog.clear();
                            if (newValue != null) {
                              _tiposServicoFiltradosParaDialog =
                                  _listaTodosTiposServico
                                      .where(
                                          (ts) => ts.categoriaId == newValue.id)
                                      .toList();
                            }
                            // Limpar o campo de texto 'Tipo de Serviço' (o antigo) se ainda existir
                            // _tipoServicoController.clear(); // Se você tinha um controller para o campo de texto
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Selecione uma categoria.' : null,
                      ),
                      SizedBox(height: 16),

                      // Dropdown de Tipo de Serviço (dependente da categoria)
                      Text("Tipo de Serviço",
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      SizedBox(height: 4),
                      DropdownButtonFormField<Tiposervico>(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Selecione um tipo de serviço"),
                        value: _tipoServicoSelecionadoDialog,
                        isExpanded: true,
                        // Desabilita se nenhuma categoria estiver selecionada ou não houver tipos filtrados
                        disabledHint: _categoriaSelecionadaDialog == null
                            ? Text("Selecione uma categoria primeiro")
                            : Text(
                                "Nenhum tipo de serviço para esta categoria"),
                        items: _tiposServicoFiltradosParaDialog
                            .map((Tiposervico ts) {
                          return DropdownMenuItem<Tiposervico>(
                            value: ts,
                            child:
                                Text(ts.nome, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (_tiposServicoFiltradosParaDialog.isEmpty &&
                                    _categoriaSelecionadaDialog !=
                                        null) // Se não há itens, não permite alteração
                                ||
                                _categoriaSelecionadaDialog ==
                                    null // Ou se categoria não foi selecionada
                            ? null // Desabilita onChanged
                            : (Tiposervico? newValue) {
                                setDialogState(() {
                                  _tipoServicoSelecionadoDialog = newValue;
                                  // Opcional: Preencher observações ou valor com base no tipo de serviço
                                  // if (newValue != null) {
                                  // _observacoesController.text = newValue.descricao;
                                  // }
                                });
                              },
                        validator: (value) => value == null
                            ? 'Selecione um tipo de serviço.'
                            : null,
                      ),
                      SizedBox(height: 16),

                      // Valor (como antes)
                      Text("Valor (R\$)",
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      SizedBox(height: 4),
                      TextFormField(
                          controller: _valorController,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(), hintText: "0,00"),
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          validator: (v) {
                            if (v != null &&
                                v.isNotEmpty &&
                                num.tryParse(v.replaceAll(',', '.')) == null)
                              return 'Valor inválido.';
                            return null;
                          }),
                      SizedBox(height: 16),

                      // Observações (como antes)
                      Text("Observações",
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      SizedBox(height: 4),
                      TextFormField(
                        controller: _observacoesController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Detalhes adicionais..."),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancelar'),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: TextButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                ),
                ElevatedButton(
                  child: Text('Salvar'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_selectedDateInDialog != null &&
                          _selectedTimeInDialog != null &&
                          _categoriaSelecionadaDialog != null &&
                          _tipoServicoSelecionadoDialog != null) {
                        final DateTime dataHoraFinal = DateTime(
                          _selectedDateInDialog!.year,
                          _selectedDateInDialog!.month,
                          _selectedDateInDialog!.day,
                          _selectedTimeInDialog!.hour,
                          _selectedTimeInDialog!.minute,
                        );

                        final novoAgendamento = Agendamento(
                          id: DateTime.now()
                              .millisecondsSinceEpoch
                              .toString(), // ID temporário
                          nome: _nomeClienteController.text,
                          email: '', // TODO: Coletar email se necessário
                          telefone: '', // TODO: Coletar telefone se necessário
                          data: dataHoraFinal,
                          // Use o nome do tipo de serviço selecionado
                          servico: _tipoServicoSelecionadoDialog!.nome,
                          // Use o nome da categoria selecionada

                          // Você pode querer salvar os IDs também:
                          // categoriaId: _categoriaSelecionadaDialog!.id,
                          // tipoServicoId: _tipoServicoSelecionadoDialog!.id,
                          // descricaoServico: _tipoServicoSelecionadoDialog!.descricao,
                        );

                        // --- ATENÇÃO: Modifique seu modelo Agendamento ---
                        // Seu modelo Agendamento precisa ter os campos `categoria` (String?) e `valor` (double?)
                        // e potencialmente campos para os IDs se quiser guardá-los.

                        setState(() {
                          // setState do AgendaPanelState
                          _allAgendamentos.add(novoAgendamento);
                          _prepareTableCalendarEvents();
                          _updateSelectedDayAppointmentsList(
                              _currentlySelectedDate);
                        });

                        Navigator.of(dialogContext).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Agendamento salvo!')));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'Verifique todos os campos obrigatórios.')));
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
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

  // Atualiza a lista de agendamentos exibida na seção "Calendário" para o dia selecionado
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

  // --- Callbacks para TableCalendar (Mobile - Seção Calendário) ---
  void _onTcDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!tc.isSameDay(_currentlySelectedDate, selectedDay)) {
      setState(() {
        _currentlySelectedDate = selectedDay;
        _tcFocusedDay = focusedDay;
        _updateSelectedDayAppointmentsList(selectedDay);
      });
    }
  }

  List<Agendamento> _getTcEventsForDay(DateTime day) {
    return _tcEvents[DateTime(day.year, day.month, day.day)] ?? [];
  }

  // --- Callbacks para SfCalendar (Desktop - Seção Calendário) ---
  void _onSfCalendarTapped(sfc.CalendarTapDetails details) {
    if (details.targetElement == sfc.CalendarElement.calendarCell ||
        details.targetElement == sfc.CalendarElement.appointment) {
      if (details.date != null &&
          (_currentlySelectedDate.year != details.date!.year ||
              _currentlySelectedDate.month != details.date!.month ||
              _currentlySelectedDate.day != details.date!.day)) {
        setState(() {
          _currentlySelectedDate = details.date!;
          _sfCalendarController.selectedDate = _currentlySelectedDate;
          _updateSelectedDayAppointmentsList(details.date!);
        });
      }
    }
  }

  List<sfc.Appointment> _getSfDataSource() {
    return _allAgendamentos.map((ag) {
      return sfc.Appointment(
        startTime: ag.data,
        endTime: ag.data
            .add(const Duration(hours: 1)), // Assumindo 1 hora de duração
        subject: '${ag.servico} - ${ag.nome}',
        color: Colors.teal, // Pode ser customizado baseado no agendamento
        id: ag.id,
        notes: 'Tel: ${ag.telefone}', // Exemplo de nota
      );
    }).toList();
  }

  // --- Widgets de Construção para a Seção Calendário ---
  Widget _buildTableCalendarWidget() {
    return tc.TableCalendar<Agendamento>(
      locale: 'pt_BR',
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _tcFocusedDay,
      calendarFormat: _tcCalendarFormat,
      selectedDayPredicate: (day) => tc.isSameDay(_currentlySelectedDate, day),
      onDaySelected: _onTcDaySelected,
      eventLoader: _getTcEventsForDay,
      onFormatChanged: (format) {
        if (_tcCalendarFormat != format) {
          setState(() {
            _tcCalendarFormat = format;
          });
        }
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _tcFocusedDay = focusedDay;
        });
      },
      calendarStyle: tc.CalendarStyle(
        todayDecoration: BoxDecoration(
            color: Colors.orangeAccent.withOpacity(0.5),
            shape: BoxShape.circle),
        selectedDecoration: BoxDecoration(
            color: Theme.of(context).primaryColor, shape: BoxShape.circle),
        markerDecoration:
            BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
      ),
      headerStyle:
          tc.HeaderStyle(formatButtonVisible: true, titleCentered: true),
    );
  }

  Widget _buildSfCalendarWidget({bool isDesktop = true}) {
    return sfc.SfCalendar(
      controller: _sfCalendarController,
      view: _sfCalendarView,
      dataSource: _SfAppointmentDataSource(_getSfDataSource()),
      initialSelectedDate: _currentlySelectedDate,
      initialDisplayDate: _currentlySelectedDate,
      monthViewSettings: const sfc.MonthViewSettings(
          appointmentDisplayMode: sfc.MonthAppointmentDisplayMode.appointment,
          showAgenda: true,
          agendaItemHeight: 50),
      timeSlotViewSettings:
          const sfc.TimeSlotViewSettings(startHour: 7, endHour: 22),
      onTap: _onSfCalendarTapped,
      headerStyle: sfc.CalendarHeaderStyle(
          textAlign: TextAlign.center,
          textStyle: TextStyle(fontSize: isDesktop ? 22 : 18)),
    );
  }

  Widget _buildAppointmentsListForCalendarSectionWidget() {
    // Renomeado para clareza
    if (_selectedDayAppointments.isEmpty) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
            'Nenhum agendamento para ${DateFormat.yMd('pt_BR').format(_currentlySelectedDate)}.'),
      ));
    }
    return ListView.builder(
      itemCount: _selectedDayAppointments.length,
      itemBuilder: (context, index) {
        final agendamento = _selectedDayAppointments[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          child: ListTile(
            leading: Icon(Icons.event_note,
                color: Theme.of(context).primaryColorDark),
            title: Text('${agendamento.servico}'),
            subtitle: Text(
                'Cliente: ${agendamento.nome}\nHorário: ${DateFormat.Hm('pt_BR').format(agendamento.data)}'),
            onTap: () {
              // TODO: Mostrar detalhes completos do agendamento
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text(agendamento.servico),
                        content: Text(
                            'Detalhes para ${agendamento.nome}...\nEmail: ${agendamento.email}\nTelefone: ${agendamento.telefone}'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Fechar'))
                        ],
                      ));
            },
          ),
        );
      },
    );
  }

  Widget _buildSfCalendarViewSwitcher() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        alignment: WrapAlignment.center,
        children: <Widget>[
          ElevatedButton(
              onPressed: () =>
                  setState(() => _sfCalendarView = sfc.CalendarView.day),
              style: ElevatedButton.styleFrom(
                  backgroundColor: _sfCalendarView == sfc.CalendarView.day
                      ? Colors.indigo
                      : Colors.grey[300],
                  foregroundColor: _sfCalendarView == sfc.CalendarView.day
                      ? Colors.white
                      : Colors.black87),
              child: Text('Dia')),
          ElevatedButton(
              onPressed: () =>
                  setState(() => _sfCalendarView = sfc.CalendarView.week),
              style: ElevatedButton.styleFrom(
                  backgroundColor: _sfCalendarView == sfc.CalendarView.week
                      ? Colors.indigo
                      : Colors.grey[300],
                  foregroundColor: _sfCalendarView == sfc.CalendarView.week
                      ? Colors.white
                      : Colors.black87),
              child: Text('Semana')),
          ElevatedButton(
              onPressed: () =>
                  setState(() => _sfCalendarView = sfc.CalendarView.month),
              style: ElevatedButton.styleFrom(
                  backgroundColor: _sfCalendarView == sfc.CalendarView.month
                      ? Colors.indigo
                      : Colors.grey[300],
                  foregroundColor: _sfCalendarView == sfc.CalendarView.month
                      ? Colors.white
                      : Colors.black87),
              child: Text('Mês')),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > kDesktopBreakpoint;
        if (isDesktop) {
          return Column(children: [
            _buildSfCalendarViewSwitcher(),
            Expanded(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Expanded(
                      flex: 2,
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _buildSfCalendarWidget(isDesktop: true))),
                  VerticalDivider(width: 1, thickness: 1),
                  Expanded(
                      flex: 1,
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(children: [
                            Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                child: Text(
                                    'Agendamentos para ${DateFormat.yMd('pt_BR').format(_currentlySelectedDate)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge)),
                            Expanded(
                                child:
                                    _buildAppointmentsListForCalendarSectionWidget()), // Usando o nome atualizado
                          ]))),
                ])),
          ]);
        } else {
          return Column(children: [
            _buildTableCalendarWidget(),
            const SizedBox(height: 8.0),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                    'Agendamentos para ${DateFormat.yMd('pt_BR').format(_currentlySelectedDate)}',
                    style: Theme.of(context).textTheme.titleMedium)),
            Expanded(
                child:
                    _buildAppointmentsListForCalendarSectionWidget()), // Usando o nome atualizado
          ]);
        }
      },
    );
  }

  String _periodoRelatorioSelecionado = "Este Mês"; // Exemplo
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

  // Placeholder de dados para os cards de resumo
  final Map<String, dynamic> _dadosResumoRelatorio = {
    'faturamentoTotal': 0.0,
    'faturamentoPercentual': 0.0,
    'totalAgendamentos': 0,
    'agendamentosPercentual': 0.0,
    'ticketMedio': 0.0,
    'ticketMedioPercentual': 0.0,
  };

  // --- Helper Widget para os Cards de Resumo ---
  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData iconData,
    required Color iconColor,
    required double percentageChange,
    required BuildContext context, // Pass context for Theme
  }) {
    bool isPositive = percentageChange >= 0;
    return Expanded(
      // Para que os cards dividam o espaço em uma Row
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: iconColor.withOpacity(0.15),
                    child: Icon(iconData, size: 14, color: iconColor),
                  )
                ],
              ),
              SizedBox(height: 8),
              Text(value,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isPositive ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    "${percentageChange.abs().toStringAsFixed(0)}% em relação ao período anterior",
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widget para as Seções Maiores de Detalhes do Relatório ---
  Widget _buildReportDetailCard({
    required String title,
    required Widget content,
    double? height, // Altura opcional para os cards
  }) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Container(
        // Container para definir altura, se especificada
        height: height,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Divider(height: 24),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }

  // --- Widget para a Seção Relatórios ---
  Widget _buildRelatorioSection() {
    // Formatter para moeda
    final currencyFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    // Conteúdo para "Faturamento por Categoria" (placeholder)
    Widget faturamentoCategoriaContent = Center(
      child: Text("Sem dados para o período selecionado.",
          style: TextStyle(color: Colors.grey.shade600)),
      // TODO: Substituir por um gráfico ou lista de categorias e seus faturamentos
      // Ex: charts_flutter.BarChart(...) ou uma ListView
    );

    // Conteúdo para "Agendamentos Recentes" (placeholder)
    Widget agendamentosRecentesContent = Column(
      children: [
        // Cabeçalho da "tabela" improvisada
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Text("DATA",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700))),
            Expanded(
                flex: 2,
                child: Text("CLIENTE",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700))),
            Expanded(
                flex: 2,
                child: Text("SERVIÇO",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700))),
            Expanded(
                child: Text("VALOR",
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700))),
          ],
        ),
        Divider(height: 16),
        Expanded(
          child: Center(
            child: Text("Sem dados para o período selecionado.",
                style: TextStyle(color: Colors.grey.shade600)),
            // TODO: Substituir por uma ListView dos agendamentos recentes
            // Ex: ListView.builder com ListTile ou DataRows customizadas
          ),
        ),
      ],
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linha do Título, Filtro de Período e Botão Exportar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  // Filtro de Período (usando PopupMenuButton como exemplo)
                  PopupMenuButton<String>(
                    initialValue: _periodoRelatorioSelecionado,
                    onSelected: (String newValue) {
                      setState(() {
                        _periodoRelatorioSelecionado = newValue;
                        // TODO: Recarregar dados do relatório com base no novo período
                      });
                    },
                    itemBuilder: (BuildContext context) {
                      return _opcoesPeriodoRelatorio.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        children: [
                          Text(_periodoRelatorioSelecionado,
                              style: TextStyle(fontSize: 13)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_drop_down,
                              size: 20, color: Colors.grey.shade700),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: Icon(Icons.download_outlined,
                        size: 18), // Ou Icons.file_download
                    label: Text("Exportar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.green, // Cor diferente para Exportar
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                    onPressed: () {
                      // TODO: Implementar lógica de exportação (PDF, CSV, etc.)
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Exportar clicado!")));
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Cards de Resumo
          LayoutBuilder(// Para tornar os cards de resumo responsivos
              builder: (context, constraints) {
            bool useRow = constraints.maxWidth > 600; // Define um breakpoint
            List<Widget> summaryCards = [
              _buildSummaryCard(
                context: context,
                title: "Faturamento Total",
                value: currencyFormat
                    .format(_dadosResumoRelatorio['faturamentoTotal']),
                iconData: Icons.monetization_on_outlined,
                iconColor: Colors.orange,
                percentageChange:
                    _dadosResumoRelatorio['faturamentoPercentual'],
              ),
              SizedBox(width: useRow ? 16 : 0, height: useRow ? 0 : 16),
              _buildSummaryCard(
                context: context,
                title: "Total de Agendamentos",
                value: _dadosResumoRelatorio['totalAgendamentos'].toString(),
                iconData: Icons.calendar_month_outlined,
                iconColor: Colors.deepPurpleAccent,
                percentageChange:
                    _dadosResumoRelatorio['agendamentosPercentual'],
              ),
              SizedBox(width: useRow ? 16 : 0, height: useRow ? 0 : 16),
              _buildSummaryCard(
                context: context,
                title: "Ticket Médio",
                value:
                    currencyFormat.format(_dadosResumoRelatorio['ticketMedio']),
                iconData: Icons.sell_outlined, // Ou Icons.local_offer_outlined
                iconColor: Colors.pinkAccent,
                percentageChange:
                    _dadosResumoRelatorio['ticketMedioPercentual'],
              ),
            ];

            return useRow
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: summaryCards)
                : Column(children: summaryCards);
          }),

          const SizedBox(height: 24),

          // Seções de Detalhes (Faturamento por Categoria e Agendamentos Recentes)
          LayoutBuilder(
            builder: (context, constraints) {
              // Em telas menores, empilha os cards de detalhes. Em maiores, lado a lado.
              if (constraints.maxWidth < 800) {
                // Breakpoint para empilhar
                return Column(
                  children: [
                    _buildReportDetailCard(
                      title: "Faturamento por Categoria",
                      content: faturamentoCategoriaContent,
                      height: 300, // Altura fixa para exemplo
                    ),
                    const SizedBox(height: 20),
                    _buildReportDetailCard(
                      title: "Agendamentos Recentes",
                      content: agendamentosRecentesContent,
                      height: 300, // Altura fixa para exemplo
                    ),
                  ],
                );
              } else {
                // Lado a lado para telas maiores
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildReportDetailCard(
                        title: "Faturamento por Categoria",
                        content: faturamentoCategoriaContent,
                        height: 350, // Altura pode ser diferente para desktop
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildReportDetailCard(
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

// --- Widget para a Seção Lista de Agendamentos ---
  Widget _buildAgendamentosSection() {
    // Placeholder para o controller do campo de busca, se você for implementar a busca
    // final TextEditingController _searchController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(24.0), // Padding geral para a seção
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linha do Título, Busca e Botão Novo Agendamento
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
                    width: 250, // Largura do campo de busca
                    child: TextField(
                      // controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Buscar Agendamentos...",
                        prefixIcon: Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide:
                              BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        isDense:
                            true, // Para reduzir a altura padrão do TextField
                      ),
                      onChanged: (value) {
                        // TODO: Implementar lógica de busca/filtro
                        // Ex: filtrar _allAgendamentos e atualizar um _filteredAgendamentos na UI
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: Icon(Icons.add, size: 18),
                    label: Text("Novo Agendamento"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15), // Ajuste de padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () {
                      _showNovoAgendamentoDialog(context);
                      // TODO: Implementar navegação ou diálogo para novo agendamento
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Novo Agendamento clicado!")));
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Card contendo a Tabela de Agendamentos
          Expanded(
            child: Card(
              elevation: 2.0, // Sombra sutil para o card
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              clipBehavior: Clip
                  .antiAlias, // Garante que o conteúdo respeite as bordas arredondadas
              child: _allAgendamentos.isEmpty
                  ? Center(
                      // Mensagem centralizada se não houver agendamentos
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          "Nenhum agendamento encontrado",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      // Permite rolagem se a tabela for maior que o espaço
                      scrollDirection:
                          Axis.vertical, // Rolagem vertical para as linhas
                      child: SingleChildScrollView(
                        // Rolagem horizontal para as colunas, se necessário
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowHeight: 48, // Altura do cabeçalho
                          dataRowMinHeight:
                              48, // Altura mínima da linha de dados
                          dataRowMaxHeight:
                              56, // Altura máxima da linha de dados
                          headingRowColor: MaterialStateProperty.resolveWith(
                              (states) => Colors.grey.shade100),
                          headingTextStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                              fontSize: 13), // Ajuste no estilo do cabeçalho
                          columns: const [
                            DataColumn(label: Text('DATA')),
                            DataColumn(label: Text('HORA')),
                            DataColumn(label: Text('CLIENTE')),
                            DataColumn(label: Text('SERVIÇO')),
                            DataColumn(label: Text('CATEGORIA')),
                            DataColumn(label: Text('VALOR')),
                            DataColumn(label: Text('AÇÕES')),
                          ],
                          rows: _allAgendamentos.map((agendamento) {
                            // Usar _allAgendamentos para a lista completa
                            return DataRow(
                              cells: [
                                DataCell(Text(DateFormat('dd/MM/yyyy')
                                    .format(agendamento.data))),
                                DataCell(Text(DateFormat('HH:mm')
                                    .format(agendamento.data))),
                                DataCell(Text(agendamento.nome)),
                                DataCell(Text(agendamento.servico)),
                                DataCell(Text(
                                    "N/A")), // Use .categoria se existir no modelo
                                DataCell(
                                    Text("R\$ --,--")), // Use .valor se existir
                                DataCell(Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit_outlined,
                                          color: Colors.blueAccent, size: 20),
                                      tooltip: "Editar",
                                      splashRadius: 20,
                                      onPressed: () {
                                        // TODO: Implementar edição
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete_outline,
                                          color: Colors.redAccent, size: 20),
                                      tooltip: "Excluir",
                                      splashRadius: 20,
                                      onPressed: () {
                                        // TODO: Implementar exclusão
                                      },
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

  // --- Widget da Barra de Menu Principal (Estilo `MenuBarHome.dart`) ---
  Widget _buildMainMenuBar() {
    // Exemplo: Pegando dados do Provider (descomente e ajuste se necessário)
    // final userProvider = Provider.of<UserProvider>(context, listen: false); // ou .watch
    // String userName = userProvider.isUserLoaded ? userProvider.user!.nome.split(' ')[0] : "Usuário";
    String userName = "Usuário"; // Placeholder

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 24, vertical: 12), // Reduzi padding vertical
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Tooltip(
                message: "PhotoFlow",
                child: Icon(Icons.camera_enhance,
                    size: 36, color: Theme.of(context).primaryColor)),
            const SizedBox(width: 30), // Reduzi um pouco o espaço
            _buildStyledMenuItem(
                text: 'Calendário',
                icon: Icons.calendar_today,
                isSelected: _selectedMainSection == MainSection.calendario,
                onPressed: () => setState(
                    () => _selectedMainSection = MainSection.calendario)),
            _buildStyledMenuItem(
                text: 'Agendamentos',
                icon: Icons.list_alt,
                isSelected: _selectedMainSection == MainSection.agendamentos,
                onPressed: () => setState(
                    () => _selectedMainSection = MainSection.agendamentos)),
            _buildStyledMenuItem(
                text: 'Relatório',
                icon: Icons.bar_chart,
                isSelected: _selectedMainSection == MainSection.relatorio,
                onPressed: () => setState(
                    () => _selectedMainSection = MainSection.relatorio)),
          ]),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: Theme.of(context).hoverColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: Row(children: [
                CircleAvatar(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.1),
                    radius: 14,
                    child: Icon(Icons.person,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 16)),
                const SizedBox(width: 8),
                Text(userName,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ]),
            ),
            const SizedBox(width: 16),
            _buildStyledMenuItem(
                text: 'Sair',
                icon: Icons.exit_to_app,
                isLogout: true,
                onPressed: () {
                  // TODO: Implementar logout real (AuthProvider, navegação para login)
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Logout não implementado.")));
                }),
          ]),
        ],
      ),
    );
  }

  Widget _buildStyledMenuItem(
      {required String text,
      required IconData icon,
      required VoidCallback onPressed,
      bool isSelected = false,
      bool isLogout = false}) {
    Color? foregroundColor;
    FontWeight fontWeight = FontWeight.normal;
    if (isLogout) {
      foregroundColor = Theme.of(context).colorScheme.error;
    } else if (isSelected) {
      foregroundColor = Theme.of(context).primaryColor;
      fontWeight = FontWeight.bold;
    } else {
      foregroundColor = Theme.of(context)
          .textTheme
          .bodyMedium
          ?.color
          ?.withOpacity(0.7); // Um pouco mais suave para não selecionado
    }
    return TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: foregroundColor,
        textStyle: TextStyle(
            fontSize: 15, fontWeight: fontWeight), // Aumentei a fonte um pouco
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ).copyWith(overlayColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
        if (states.contains(MaterialState.hovered))
          return foregroundColor?.withOpacity(0.08);
        if (states.contains(MaterialState.pressed))
          return foregroundColor?.withOpacity(0.12);
        return null;
      })),
      onPressed: onPressed,
      icon: Icon(icon, size: 18), // Reduzi o tamanho do ícone
      label: Text(text),
    );
  }

  // --- Widget para o Rodapé ---
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      color: Theme.of(context)
          .dividerColor
          .withOpacity(0.05), // Cor mais sutil para o rodapé
      child: Center(
        child: Text(
          "© ${DateTime.now().year} PhotoFlow - Sistema de Agendamento para Estúdios de Fotografia",
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ),
    );
  }

  // --- Build Principal do AgendaPanelState ---
  @override
  Widget build(BuildContext context) {
    Widget currentSectionWidget;
    switch (_selectedMainSection) {
      case MainSection.calendario:
        currentSectionWidget = _buildCalendarSection();
        break;
      case MainSection.agendamentos:
        currentSectionWidget = _buildAgendamentosSection();
        break;
      case MainSection.relatorio:
        currentSectionWidget = _buildRelatorioSection();
        break;
    }

    return Scaffold(
      // Adicionado Scaffold para melhor estrutura e cor de fundo
      backgroundColor: Theme.of(context)
          .colorScheme
          .surface
          .withOpacity(0.05), // Um fundo geral muito sutil
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMainMenuBar(),
          Expanded(
              child: Padding(
            // Adicionado padding em volta da seção principal
            padding: const EdgeInsets.symmetric(
                horizontal: kIsWeb ? 8.0 : 0,
                vertical: kIsWeb ? 8.0 : 0), // Padding condicional para web
            child: currentSectionWidget,
          )),
          _buildFooter(),
        ],
      ),
    );
  }
}

// DataSource para Syncfusion SfCalendar (como antes)
class _SfAppointmentDataSource extends sfc.CalendarDataSource {
  _SfAppointmentDataSource(List<sfc.Appointment> source) {
    appointments = source;
  }
}
