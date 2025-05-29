import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/agendamento/agendamento.dart';

class AgendaPanel extends StatefulWidget {
  const AgendaPanel({Key? key}) : super(key: key);

  @override
  _AgendaPanelState createState() => _AgendaPanelState();
}

class _AgendaPanelState extends State<AgendaPanel> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Usaremos um Map para armazenar os eventos (Agendamento).
  Map<DateTime, List<Agendamento>> _events = {};
  List<Agendamento> _selectedDayAppointments = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadAppointments(); // Carrega os agendamentos
    _selectedDayAppointments = _getAppointmentsForDay(_selectedDay!);
  }

  void _loadAppointments() {
    // TODO: Substitua por sua lógica de carregamento de dados (API, Firebase, etc.)
    // Usando seu modelo Agendamento para dados mockados:
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    // Note que o campo 'data' no seu Agendamento pode incluir a hora.
    // Para o TableCalendar, ele agrupará pelo dia.
    // A hora específica será útil ao listar os agendamentos do dia.
    setState(() {
      _events = {
        today: [
          Agendamento(
            id: '1',
            nome: 'Maria Silva',
            email: 'maria@email.com',
            telefone: '99999-1111',
            data: DateTime(
                today.year, today.month, today.day, 10, 0), // Hoje às 10:00
            servico: 'Ensaio Externo',
          ),
          Agendamento(
            id: '2',
            nome: 'Joana e Pedro',
            email: 'joana.pedro@email.com',
            telefone: '99999-2222',
            data: DateTime(
                today.year, today.month, today.day, 15, 30), // Hoje às 15:30
            servico: 'Cobertura Casamento',
          ),
        ],
        tomorrow: [
          Agendamento(
            id: '3',
            nome: 'Empresa X',
            email: 'contato@empresax.com',
            telefone: '99999-3333',
            data: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 14,
                0), // Amanhã às 14:00
            servico: 'Vídeo Institucional',
          ),
        ],
        // Adicione mais agendamentos para outros dias se desejar
        DateTime(now.year, now.month, now.day + 5): [
          Agendamento(
            id: '4',
            nome: 'Carlos Souza',
            email: 'carlos@email.com',
            telefone: '99999-4444',
            data: DateTime(now.year, now.month, now.day + 5, 9,
                0), // Daqui a 5 dias às 09:00
            servico: 'Fotografia Produto',
          ),
        ]
      };
    });
  }

  List<Agendamento> _getAppointmentsForDay(DateTime day) {
    DateTime normalizedDay = DateTime(day.year, day.month, day.day);
    // Retorna os eventos para o dia normalizado, ordenados pela hora do agendamento.
    var appointments = _events[normalizedDay] ?? [];
    appointments.sort((a, b) => a.data.compareTo(b.data)); // Ordena pela hora
    return appointments;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedDayAppointments = _getAppointmentsForDay(selectedDay);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      // Removi o Scaffold daqui, assumindo que está dentro de uma view maior
      children: [
        TableCalendar<Agendamento>(
          // Alterado para TableCalendar<Agendamento>
          locale: 'pt_BR',
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: _onDaySelected,
          eventLoader: (day) {
            // A função `_getAppointmentsForDay` já retorna `List<Agendamento>`
            return _getAppointmentsForDay(day);
          },
          onFormatChanged: (format) {
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarStyle: CalendarStyle(
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
          headerStyle: HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            formatButtonShowsNext: false,
          ),
          // Você pode customizar como os marcadores de evento são construídos:
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isNotEmpty) {
                // Exemplo: um ponto para cada evento, até 3 pontos
                return Positioned(
                  right: 1,
                  bottom: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      events.length > 3
                          ? 3
                          : events.length, // Limita a 3 marcadores visuais
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 0.5),
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // Cor diferente se for um evento importante, por exemplo
                          color: Colors.deepPurpleAccent,
                        ),
                      ),
                    ),
                  ),
                );
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 16.0),
        Expanded(
          child: _selectedDayAppointments.isNotEmpty
              ? ListView.builder(
                  itemCount: _selectedDayAppointments.length,
                  itemBuilder: (context, index) {
                    final agendamento = _selectedDayAppointments[index];
                    // Formata a hora para exibição
                    final horaFormatada =
                        TimeOfDay.fromDateTime(agendamento.data)
                            .format(context);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 4.0),
                      child: ListTile(
                        leading: Icon(Icons.event_available,
                            color: Theme.of(context).primaryColor),
                        title: Text(
                            '${agendamento.servico} - ${agendamento.nome}'),
                        subtitle: Text(
                            'Horário: $horaFormatada\nTelefone: ${agendamento.telefone}'),
                        // Adicione mais interações ou informações aqui
                        onTap: () {
                          // Ex: Mostrar um diálogo com todos os detalhes
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(agendamento.servico),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Cliente: ${agendamento.nome}'),
                                  Text('Email: ${agendamento.email}'),
                                  Text('Telefone: ${agendamento.telefone}'),
                                  Text(
                                      'Data: ${agendamento.data.day}/${agendamento.data.month}/${agendamento.data.year}'),
                                  Text('Hora: $horaFormatada'),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  child: Text('Fechar'),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                )
              : Center(
                  child: Text('Nenhum agendamento para este dia.'),
                ),
        ),
      ],
    );
  }
}
