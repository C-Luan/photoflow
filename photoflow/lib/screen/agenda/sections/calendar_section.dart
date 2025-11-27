// File: lib/panels/sections/calendar_section.dart

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart' as tc;
import 'package:syncfusion_flutter_calendar/calendar.dart' as sfc;

// Project imports:
import 'package:photoflow/models/agendamento/agendamento.dart';
import 'package:photoflow/models/tiposervico/categoria.dart';
import 'package:photoflow/models/tiposervico/tiposervico.dart';

import '../data/sf_appointment_data_source.dart';
import '../dialogs/novo_agendamento_dialog.dart';

const double kDesktopBreakpoint = 700.0;

class CalendarSection extends StatelessWidget {
  // State from parent
  final DateTime focusedDay;
  final DateTime selectedDay;
  final List<Agendamento> allAgendamentos;
  final List<Agendamento> selectedDayAppointments;
  final Map<DateTime, List<Agendamento>> tcEvents;
  final tc.CalendarFormat tcCalendarFormat;
  final sfc.CalendarView sfCalendarView;
  final sfc.CalendarController sfCalendarController;
  final List<CategoriaServico> categorias;
  final List<Tiposervico> tiposServico;

  // Callbacks
  final Function(DateTime, DateTime) onTcDaySelected;
  final Function(tc.CalendarFormat) onTcFormatChanged;
  final Function(DateTime) onTcPageChanged;
  final Function(sfc.CalendarTapDetails) onSfCalendarTapped;
  final ValueChanged<sfc.CalendarView> onSfViewChanged;
  final Function(Agendamento) onNewAppointmentSaved;

  const CalendarSection({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.allAgendamentos,
    required this.selectedDayAppointments,
    required this.tcEvents,
    required this.tcCalendarFormat,
    required this.sfCalendarView,
    required this.sfCalendarController,
    required this.categorias,
    required this.tiposServico,
    required this.onTcDaySelected,
    required this.onTcFormatChanged,
    required this.onTcPageChanged,
    required this.onSfCalendarTapped,
    required this.onSfViewChanged,
    required this.onNewAppointmentSaved,
  });

  List<Agendamento> _getTcEventsForDay(DateTime day) {
    return tcEvents[DateTime(day.year, day.month, day.day)] ?? [];
  }

  List<sfc.Appointment> _getSfDataSource() {
    return allAgendamentos.map((ag) {
      return sfc.Appointment(
        startTime: ag.data,
        endTime: ag.data.add(const Duration(hours: 1)),
        subject: '${ag.servico} - ${ag.cliente.nome}',
        color: Colors.teal,
        id: ag.id,
        notes: 'Tel: ${ag.telefone}',
      );
    }).toList();
  }

  Future<void> _showNovoAgendamentoDialog(BuildContext context) async {
     await Navigator.of(context).push(
            PageRouteBuilder(
              opaque:
                  false, // Set to false for translucent background if desired
              pageBuilder: (context, animation, secondaryAnimation) =>
                  NovoAgendamentoDialog(
          categorias: categorias,
          todosTiposServico: tiposServico,
          initialDate: selectedDay,
          onSave: onNewAppointmentSaved,
        ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    // Define the slide-in transition from right to left
                    const begin = Offset(
                      1.0,
                      0.0,
                    ); // Start from the right (1.0 on X axis)
                    const end = Offset
                        .zero; // End at its normal position (0.0 on X axis)
                    const curve = Curves.easeOut; // A smooth easing curve

                    var tween = Tween(
                      begin: begin,
                      end: end,
                    ).chain(CurveTween(curve: curve));

                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
            ));
    // return showDialog<void>(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (BuildContext dialogContext) {
        
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isDesktop = constraints.maxWidth > kDesktopBreakpoint;
        if (isDesktop) {
          return _buildDesktopView(context);
        } else {
          return _buildMobileView(context);
        }
      },
    );
  }

  // Restante dos métodos de build (_buildTableCalendarWidget, _buildSfCalendarWidget, etc.)
  // movidos para cá e transformados em métodos privados desta classe.
  // Exemplo:
  Widget _buildDesktopView(BuildContext context) {
    return Column(children: [
      _buildSfCalendarViewSwitcher(context),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildSfCalendarWidget(isDesktop: true),
        ),
      ),
    ]);
  }

  Widget _buildMobileView(BuildContext context) {
    return Column(children: [
      _buildTableCalendarWidget(context),
      const SizedBox(height: 8.0),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          'Agendamentos para ${DateFormat.yMd('pt_BR').format(selectedDay)}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      Expanded(child: _buildAppointmentsList()),
    ]);
  }

  Widget _buildSfCalendarViewSwitcher(BuildContext context) {
    // ... lógica do seu `_buildSfCalendarViewSwitcher` original
    // Substituir `setState` por chamadas a `onSfViewChanged`
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Wrap(
        spacing: 8.0,
        alignment: WrapAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () => onSfViewChanged(sfc.CalendarView.day),
            // ... estilo
            child: const Text('Dia'),
          ),
          ElevatedButton(
            onPressed: () => onSfViewChanged(sfc.CalendarView.week),
            // ... estilo
            child: const Text('Semana'),
          ),
          ElevatedButton(
            onPressed: () => onSfViewChanged(sfc.CalendarView.month),
            // ... estilo
            child: const Text('Mês'),
          ),
          const SizedBox(width: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Inserir Agendamento'),
            onPressed: () => _showNovoAgendamentoDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList() {
    // ... sua implementação de _buildAppointmentsListForCalendarSectionWidget
    if (selectedDayAppointments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Nenhum agendamento para ${DateFormat.yMd('pt_BR').format(selectedDay)}.')
        )
      );
    }
    return ListView.builder(
      itemCount: selectedDayAppointments.length,
      itemBuilder: (context, index) {
        // ... construção do Card/ListTile
        return Card(/*...*/);
      },
    );
  }

  Widget _buildSfCalendarWidget({bool isDesktop = true}) {
    return sfc.SfCalendar(
      controller: sfCalendarController,
      view: sfCalendarView,
      dataSource: SfAppointmentDataSource(_getSfDataSource()),
      initialSelectedDate: selectedDay,
      initialDisplayDate: selectedDay,
      monthViewSettings: const sfc.MonthViewSettings(
          appointmentDisplayMode: sfc.MonthAppointmentDisplayMode.appointment,
          showAgenda: true,
          agendaItemHeight: 50),
      timeSlotViewSettings:
          const sfc.TimeSlotViewSettings(startHour: 7, endHour: 22),
      onTap: onSfCalendarTapped,
      headerStyle: sfc.CalendarHeaderStyle(
          textAlign: TextAlign.center,
          textStyle: TextStyle(fontSize: isDesktop ? 22 : 18)),
    );
  }

  Widget _buildTableCalendarWidget(BuildContext context) {
    return tc.TableCalendar<Agendamento>(
      locale: 'pt_BR',
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: focusedDay,
      calendarFormat: tcCalendarFormat,
      selectedDayPredicate: (day) => tc.isSameDay(selectedDay, day),
      onDaySelected: onTcDaySelected,
      eventLoader: _getTcEventsForDay,
      onFormatChanged: onTcFormatChanged,
      onPageChanged: onTcPageChanged,
      calendarStyle: tc.CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.orangeAccent.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: Colors.blueAccent,
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: const tc.HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
      ),
    );
  }
}