import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MainDashboardScreen extends StatelessWidget {
  const MainDashboardScreen({super.key}); // Adicionado const

  @override
  Widget build(BuildContext context) {
    // O AppBar daqui será usado quando esta tela do dashboard estiver ativa.
    return Scaffold(
      // appBar: AppBar(
      //   // backgroundColor: Colors.white,
      //   elevation: 1, // Uma leve sombra para o AppBar
      //   title: Text(
      //     'Dashboard Financeiro',
      //     // style: Theme.of(context)
      //     //     .textTheme
      //     //     .titleLarge
      //     //     ?.copyWith(color: Colors.black87),
      //   ),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(
      //         Icons.search,
      //       ),
      //       onPressed: () {/* Ação de pesquisa */},
      //     ),
      //     IconButton(
      //       icon: const Icon(
      //         Icons.notifications_none_outlined,
      //       ),
      //       onPressed: () {/* Ação de notificações */},
      //     ),
      //     const Padding(
      //       // Adicionado const
      //       padding: EdgeInsets.symmetric(horizontal: 16.0),
      //       child: CircleAvatar(
      //         backgroundColor: Colors.blueGrey, // Cor de exemplo
      //         child: Text('JD', style: TextStyle(color: Colors.white)),
      //       ),
      //     ),
      //   ],
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
            20.0), // Padding geral para o conteúdo do dashboard
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            // Adicionado const se os filhos forem constantes
            _FinancialKpiSectionWidget(),
            SizedBox(height: 24),
            _FinancialChartsSectionWidget(),
            SizedBox(height: 24),
            _UpcomingAppointmentsSectionWidget(),
            SizedBox(height: 24),
            _ActiveProjectsSectionWidget(),
            SizedBox(height: 24),
            _ClientStatusSectionWidget(),
            SizedBox(height: 24),
            _BillsToPaySectionWidget(),
            SizedBox(height: 24),
            _InstallmentEntriesSectionWidget(),
            SizedBox(height: 24),
            _RecentTransactionsSectionWidget(),
            SizedBox(height: 24),
            _RecentContractsSectionWidget(),
            SizedBox(height: 40), // Espaço no final
          ],
        ),
      ),
    );
  }
}

// --- Widgets Reutilizáveis ---
class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final String? percentageChange;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String? subtitle;

  const _KpiCard({
    required this.title,
    required this.value,
    this.percentageChange,
    required this.icon,
    this.iconColor = Colors.white,
    required this.iconBackgroundColor,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    String formattedValue = value;
    try {
      double numericValue =
          double.parse(value.replaceAll('.', '').replaceAll(',', '.'));
      formattedValue = currencyFormatter.format(numericValue);
    } catch (e) {
      // Mantém o valor original
    }

    // return Expanded( // <--- REMOVA ESTE EXPANDED
    return Card(
      // <--- RETORNE O CARD DIRETAMENTE
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                    child: Text(title,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis)),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              formattedValue,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (percentageChange != null || subtitle != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  if (percentageChange != null)
                    Text(
                      percentageChange!,
                      style: TextStyle(
                        color: percentageChange!.startsWith('+')
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (percentageChange != null && subtitle != null)
                    const Text(" ", style: TextStyle(fontSize: 12)),
                  if (subtitle != null)
                    Expanded(
                        child: Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.labelSmall,
                      overflow: TextOverflow.ellipsis,
                    )),
                ],
              ),
            ]
          ],
        ),
      ),
    );
    // ); // Fim do Expanded removido
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAllPressed;
  final List<Widget>? actions; // Estes são os botões como Dia, Semana, Mês

  const _SectionTitle({
    super.key, // Adicionado super.key
    required this.title,
    this.onSeeAllPressed,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> trailingWidgets = [];
    if (actions != null && actions!.isNotEmpty) {
      trailingWidgets.addAll(actions!);
    } else if (onSeeAllPressed != null) {
      trailingWidgets.add(
        TextButton(
          onPressed: onSeeAllPressed,
          child: const Text('Ver todos',
              style: TextStyle(color: Colors.blueAccent)),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment
          .center, // Bom para alinhar título e botões verticalmente
      children: [
        Expanded(
          // Permite que o título ocupe o espaço disponível e use ellipsis
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            overflow:
                TextOverflow.ellipsis, // Evita que o título quebre o layout
            maxLines: 1, // Garante que o título não passe de uma linha
          ),
        ),
        if (trailingWidgets.isNotEmpty)
          const SizedBox(width: 8), // Espaço entre o título e os botões/link
        // Usa Wrap para os botões de ação, permitindo que quebrem a linha
        Wrap(
          spacing: 6.0, // Espaçamento horizontal entre os botões
          runSpacing:
              4.0, // Espaçamento vertical se os botões quebrarem a linha
          alignment: WrapAlignment.end, // Alinha os botões à direita
          crossAxisAlignment: WrapCrossAlignment
              .center, // Alinha verticalmente se houver quebra
          children: trailingWidgets,
        ),
      ],
    );
  }
}

class _ChartPlaceholder extends StatelessWidget {
  final String title;
  final double height;
  const _ChartPlaceholder({required this.title, this.height = 200});

  @override
  Widget build(BuildContext context) {
    // return Expanded( // <--- REMOVA ESTE EXPANDED
    return Card(
      // <--- RETORNE O CARD DIRETAMENTE
      child: Container(
        // O Container já tem uma altura definida pela propriedade 'height'
        height: height,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const Expanded(
              // Este Expanded interno está OK, pois seu pai (Column) está dentro de um Card com altura definida.
              child: Center(
                child: Icon(Icons.bar_chart, size: 50, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
    // ); // Fim do Expanded removido
  }
}

// --- Seções do Dashboard (Widgets como antes) ---
class _FinancialKpiSectionWidget extends StatelessWidget {
  const _FinancialKpiSectionWidget();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool useWrap = constraints.maxWidth < 800;

        final kpiCardsList = [
          _KpiCard(
              title: 'Saldo Total',
              value: '124500.00',
              percentageChange: '+12%',
              subtitle: 'desde o mês passado',
              icon: Icons.account_balance_wallet_outlined,
              iconBackgroundColor: Colors.green.shade100,
              iconColor: Colors.green.shade700),
          _KpiCard(
              title: 'Entradas (Mês)',
              value: '45750.00',
              percentageChange: '+8%',
              subtitle: 'desde o mês passado',
              icon: Icons.arrow_downward_outlined,
              iconBackgroundColor: Colors.blue.shade100,
              iconColor: Colors.blue.shade700),
          _KpiCard(
              title: 'Saídas (Mês)',
              value: '32180.00',
              percentageChange: '+5%',
              subtitle: 'desde o mês passado',
              icon: Icons.arrow_upward_outlined,
              iconBackgroundColor: Colors.red.shade100,
              iconColor: Colors.red.shade700),
          _KpiCard(
              title: 'Contas a Vencer',
              value: '18350.00',
              subtitle: 'Próximos 30 dias',
              icon: Icons.warning_amber_outlined,
              iconBackgroundColor: Colors.orange.shade100,
              iconColor: Colors.orange.shade700),
        ];

        if (useWrap) {
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: kpiCardsList.map((cardWidget) {
              // Renomeado para cardWidget para clareza
              double cardWidth = (constraints.maxWidth - 16) / 2;
              if (constraints.maxWidth < 450) {
                cardWidth = constraints.maxWidth;
              }
              // Agora 'cardWidget' (que é _KpiCard) não é mais um Expanded, então está OK.
              return SizedBox(width: cardWidth, child: cardWidget);
            }).toList(),
          );
        } else {
          // Row para telas mais largas
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ENVOLVA CADA _KpiCard COM Expanded AQUI
              Expanded(child: kpiCardsList[0]),
              const SizedBox(width: 16),
              Expanded(child: kpiCardsList[1]),
              const SizedBox(width: 16),
              Expanded(child: kpiCardsList[2]),
              const SizedBox(width: 16),
              Expanded(child: kpiCardsList[3]),
            ],
          );
        }
      },
    );
  }
}

class _FinancialChartsSectionWidget extends StatelessWidget {
  const _FinancialChartsSectionWidget();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 700) {
        // _ChartPlaceholder agora não é Expanded, então esta Column funcionará corretamente,
        // pois os filhos têm alturas definidas (pelo Container interno do _ChartPlaceholder).
        return Column(
          children: const [
            _ChartPlaceholder(title: 'Fluxo de Caixa', height: 250),
            SizedBox(height: 16),
            _ChartPlaceholder(title: 'Entradas vs Saídas', height: 250),
          ],
        );
      }
      // Para a Row, precisamos explicitamente que os _ChartPlaceholder se expandam horizontalmente.
      return Row(
        // Removido 'const' porque os children agora são dinamicamente envolvidos por Expanded
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: _ChartPlaceholder(
                  title: 'Fluxo de Caixa')), // <--- ENVOLVA COM Expanded
          const SizedBox(width: 16),
          Expanded(
              child: _ChartPlaceholder(
                  title: 'Entradas vs Saídas')), // <--- ENVOLVA COM Expanded
        ],
      );
    });
  }
}

class _UpcomingAppointmentsSectionWidget extends StatelessWidget {
  const _UpcomingAppointmentsSectionWidget(); // Adicionado const

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(
              title: 'Agendamentos Futuros',
              actions: [
                // Botões de exemplo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: OutlinedButton(
                      onPressed: () {}, child: const Text('Dia')),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200),
                      child: const Text('Semana')),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: OutlinedButton(
                      onPressed: () {}, child: const Text('Mês')),
                ),
              ],
              // onSeeAllPressed removido pois os botões de ação podem cobrir isso
            ),
            const SizedBox(height: 16),
            LayoutBuilder(builder: (context, constraints) {
              bool useColumn = constraints.maxWidth < 800;
              if (useColumn) {
                return Column(
                  children: [
                    _CalendarPlaceholderWidget(),
                    const SizedBox(height: 16),
                    _DailyAppointmentsListPlaceholderWidget(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _CalendarPlaceholderWidget()),
                  const SizedBox(width: 16),
                  Expanded(
                      flex: 3,
                      child: _DailyAppointmentsListPlaceholderWidget()),
                ],
              );
            }),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Novo Agendamento'),
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 71, 121, 233),
                    foregroundColor: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarPlaceholderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320, // Altura ajustada
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Junho 2025',
                style: Theme.of(context).textTheme.titleMedium), // Atualizado
            const SizedBox(height: 10),
            const Icon(Icons.calendar_today, size: 40, color: Colors.grey),
            const SizedBox(height: 10),
            const Text('Placeholder do Calendário'),
            const SizedBox(height: 10),
            TextButton(onPressed: () {}, child: const Text("Ver calendário"))
          ],
        ),
      ),
    );
  }
}

class _DailyAppointmentsListPlaceholderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Usando a data atual para o placeholder
    String formattedDate =
        DateFormat('dd \'de\' MMMM', 'pt_BR').format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Agendamentos para ${formattedDate}',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        _buildAppointmentItem(
            context,
            '11:00',
            'Apresentação de Proposta - Tech Solutions',
            'Videoconferência',
            2,
            Colors.blue.shade50,
            Colors.blue.shade700),
        _buildAppointmentItem(
            context,
            '14:30',
            'Revisão de Contrato - Startup 123',
            'Escritório Jurídico',
            2,
            Colors.orange.shade50,
            Colors.orange.shade700),
        _buildAppointmentItem(
            context,
            '16:00',
            'Reunião de Equipe - Planejamento Financeiro',
            'Sala de Reuniões 1',
            5,
            Colors.green.shade50,
            Colors.green.shade700),
      ],
    );
  }

  Widget _buildAppointmentItem(BuildContext context, String time, String title,
      String location, int participants, Color bgColor, Color borderColor) {
    // <<--- CORRIGIDO AQUI
    return Card(
      color: bgColor,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        side: BorderSide(
            color: borderColor.withOpacity(0.8),
            width: 1), // borderColor é usado aqui
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(time,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: borderColor,
                  fontWeight: FontWeight.bold)), // borderColor é usado aqui
        ),
        title: Text(title,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(location, style: Theme.of(context).textTheme.labelSmall),
            Text('$participants participantes',
                style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _SimpleListSectionWidget extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>>
      items; // 'value' pode ser String ou Color etc.
  final List<String> headers;
  final bool showValueOnRight;
  final Map<String, int> columnFlex; // Para controlar flex das colunas

  const _SimpleListSectionWidget({
    // Adicionado const
    required this.title,
    required this.items,
    this.headers = const [],
    this.showValueOnRight = false,
    this.columnFlex = const {},
  });

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty) // Só mostra o título se não estiver vazio
              _SectionTitle(
                  title: title, onSeeAllPressed: () {/* Ver todos */}),
            if (title.isNotEmpty) const SizedBox(height: 10),
            if (headers.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8.0, vertical: 8.0), // Ajuste do padding
                child: Row(
                  children: headers
                      .map((header) => Expanded(
                          flex: columnFlex[header] ??
                              (header.toLowerCase().contains('descrição') ||
                                      header
                                          .toLowerCase()
                                          .contains('projeto') ||
                                      header
                                          .toLowerCase()
                                          .contains('contrato') ||
                                      header.toLowerCase().contains('cliente')
                                  ? 2
                                  : 1),
                          child: Text(header,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade600))))
                      .toList(),
                ),
              ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                String displayValue = item['value']?.toString() ?? '';
                Color? valueColor = item['valueColor'] as Color?;

                if (item['value'] != null && item['isCurrency'] == true) {
                  try {
                    displayValue = currencyFormatter.format(double.parse(
                        item['value'].toString().replaceAll(',', '.')));
                  } catch (e) {/* Mantém o valor original */}
                }

                if (headers.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 12.0), // Ajuste do padding
                    child: Row(
                      children: headers.map((headerKey) {
                        // Assumindo que as chaves no item correspondem aos headers de alguma forma
                        // ou que temos uma forma de mapear headerKey para itemKey
                        // Simplificação: Usando item['colX'] ou item[headerKey.toLowerCase()]
                        String itemKey =
                            'col${headers.indexOf(headerKey) + 1}'; // Ex: col1, col2...
                        dynamic cellData = item[itemKey];
                        Widget cellWidget;

                        if (headerKey.toLowerCase() == 'status' &&
                            cellData is String) {
                          cellWidget = _StatusChip(status: cellData);
                        } else if (headerKey.toLowerCase() == 'ações' &&
                            cellData is Widget) {
                          cellWidget = cellData;
                        } else {
                          cellWidget = Text(
                              (headerKey == 'Valor' ||
                                          headerKey == 'Valor Total') &&
                                      item['isCurrency'] == true
                                  ? (item[itemKey] != null
                                      ? currencyFormatter.format(double.parse(
                                          item[itemKey]
                                              .toString()
                                              .replaceAll(',', '.')))
                                      : "")
                                  : cellData?.toString() ?? '',
                              style: Theme.of(context).textTheme.bodyMedium);
                        }
                        return Expanded(
                            flex: columnFlex[headerKey] ??
                                (headerKey
                                            .toLowerCase()
                                            .contains('descrição') ||
                                        headerKey
                                            .toLowerCase()
                                            .contains('projeto') ||
                                        headerKey
                                            .toLowerCase()
                                            .contains('contrato') ||
                                        headerKey
                                            .toLowerCase()
                                            .contains('cliente')
                                    ? 2
                                    : 1),
                            child: cellWidget);
                      }).toList(),
                    ),
                  );
                } else {
                  // Modo ListTile
                  return ListTile(
                    contentPadding: EdgeInsets.zero, // Ajuste do padding
                    leading: item['icon'] != null
                        ? Icon(
                            item['icon'] as IconData,
                            color: item['iconColor'] as Color?,
                            size: 20,
                          )
                        : null, // Tamanho do ícone
                    title: Text(item['title']!,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    subtitle: item['subtitle'] != null
                        ? Text(item['subtitle']!,
                            style: Theme.of(context).textTheme.labelSmall)
                        : null,
                    trailing: showValueOnRight
                        ? Text(displayValue,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: valueColor))
                        : null,
                  );
                }
              },
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, thickness: 1),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget para Status Chip
class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color chipColor;
    Color textColor;
    IconData? chipIcon;

    switch (status.toLowerCase()) {
      case 'em andamento':
      case 'ativo':
        chipColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        chipIcon = Icons.play_circle_outline;
        break;
      case 'pendente':
        chipColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        chipIcon = Icons.pause_circle_outline;
        break;
      case 'novo':
        chipColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        chipIcon = Icons.fiber_new_outlined;
        break;
      case 'inadimplente':
        chipColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        chipIcon = Icons.error_outline;
        break;
      default:
        chipColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
    }

    return Chip(
      avatar:
          chipIcon != null ? Icon(chipIcon, color: textColor, size: 16) : null,
      label: Text(status),
      backgroundColor: chipColor,
      labelStyle: TextStyle(
          color: textColor, fontWeight: FontWeight.w500, fontSize: 12),
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 2), // Padding do chip
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)), // Bordas mais arredondadas
    );
  }
}

class _ActiveProjectsSectionWidget extends StatelessWidget {
  const _ActiveProjectsSectionWidget(); // Adicionado const
  @override
  Widget build(BuildContext context) {
    return _SimpleListSectionWidget(
      title: 'Projetos Ativos',
      headers: const ['Projeto', 'Cliente', 'Status', 'Valor'],
      columnFlex: const {'Projeto': 2, 'Cliente': 2, 'Status': 1, 'Valor': 1},
      items: [
        {
          'col1': 'Redesign Website',
          'col2': 'Empresa ABC',
          'col3': 'Em andamento',
          'col4': '28500.00',
          'isCurrency': true
        },
        {
          'col1': 'App Mobile',
          'col2': 'Tech Solutions',
          'col3': 'Pendente',
          'col4': '45000.00',
          'isCurrency': true
        },
        {
          'col1': 'Marketing Digital',
          'col2': 'Loja XYZ',
          'col3': 'Em andamento',
          'col4': '12800.00',
          'isCurrency': true
        },
        {
          'col1': 'Identidade Visual',
          'col2': 'Startup 123',
          'col3': 'Novo',
          'col4': '8500.00',
          'isCurrency': true
        },
      ],
    );
  }
}

class _ClientStatusSectionWidget extends StatelessWidget {
  const _ClientStatusSectionWidget(); // Adicionado const
  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _SectionTitle(title: 'Status de Clientes', onSeeAllPressed: () {}),
          const SizedBox(height: 16),
          LayoutBuilder(builder: (context, constraints) {
            bool useWrap = constraints.maxWidth < 500;
            final kpis = [
              _buildClientStatusKpi(
                  context, "18", "Clientes Ativos", Colors.green.shade600),
              _buildClientStatusKpi(
                  context, "3", "Inadimplentes", Colors.red.shade600),
              _buildClientStatusKpi(
                  context, "5", "Novos (mês)", Colors.blue.shade600),
              _buildClientStatusKpi(
                  context, "85%", "Retenção", Colors.purple.shade600),
            ];
            if (useWrap) {
              return Wrap(
                alignment: WrapAlignment.spaceAround,
                spacing: 16,
                runSpacing: 16,
                children: kpis,
              );
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: kpis,
            );
          }),
          const SizedBox(height: 20),
          _SimpleListSectionWidget(title: "", headers: const [
            'Cliente',
            'Status',
            'Projetos',
            'Valor Total'
          ], columnFlex: const {
            'Cliente': 2,
            'Status': 1,
            'Projetos': 1,
            'Valor Total': 1
          }, items: [
            // Adicionado ícones de avatar placeholder
            {
              'col1': 'Empresa ABC',
              'col2': 'Ativo',
              'col3': '3',
              'col4': '78500.00',
              'isCurrency': true
            },
            {
              'col1': 'Tech Solutions',
              'col2': 'Ativo',
              'col3': '1',
              'col4': '45000.00',
              'isCurrency': true
            },
            {
              'col1': 'Loja XYZ',
              'col2': 'Inadimplente',
              'col3': '2',
              'col4': '14800.00',
              'isCurrency': true
            },
          ]),
        ],
      ),
    ));
  }

  Widget _buildClientStatusKpi(
      BuildContext context, String value, String label, Color color) {
    return Padding(
      // Adicionado padding para melhor espaçamento no Wrap
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Text(value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _BillsToPaySectionWidget extends StatelessWidget {
  const _BillsToPaySectionWidget(); // Adicionado const
  @override
  Widget build(BuildContext context) {
    return _SimpleListSectionWidget(
      title: 'Contas a Vencer',
      showValueOnRight: true,
      items: [
        {
          'title': 'Aluguel Escritório',
          'subtitle': 'Vence em 5 dias',
          'value': '3800.00',
          'isCurrency': true,
          'icon': Icons.home_work_outlined,
          'iconColor': Colors.blueGrey.shade700
        },
        {
          'title': 'Energia Elétrica',
          'subtitle': 'Vence em 3 dias',
          'value': '750.00',
          'isCurrency': true,
          'icon': Icons.lightbulb_outline,
          'iconColor': Colors.orange.shade700
        },
        {
          'title': 'Folha de Pagamento',
          'subtitle': 'Vence em 10 dias',
          'value': '12500.00',
          'isCurrency': true,
          'icon': Icons.payments_outlined,
          'iconColor': Colors.green.shade700
        },
        {
          'title': 'Serviços Cloud',
          'subtitle': 'Vence em 15 dias',
          'value': '1300.00',
          'isCurrency': true,
          'icon': Icons.cloud_outlined,
          'iconColor': Colors.lightBlue.shade700
        },
      ],
    );
  }
}

class _InstallmentEntriesSectionWidget extends StatelessWidget {
  const _InstallmentEntriesSectionWidget(); // Adicionado const
  @override
  Widget build(BuildContext context) {
    return _SimpleListSectionWidget(
      title: 'Entradas de Parcelas',
      showValueOnRight: true,
      items: [
        {
          'title': 'Empresa ABC',
          'subtitle': 'Parcela 2/3 - Website',
          'value': '9500.00',
          'isCurrency': true,
          'icon': Icons.receipt_long_outlined,
          'iconColor': Colors.teal.shade700
        },
        {
          'title': 'Tech Solutions',
          'subtitle': 'Parcela 1/4 - App',
          'value': '11250.00',
          'isCurrency': true,
          'icon': Icons.receipt_long_outlined,
          'iconColor': Colors.teal.shade700
        },
        {
          'title': 'Loja XYZ',
          'subtitle': 'Parcela 3/3 - Marketing',
          'value': '2133.00',
          'isCurrency': true,
          'icon': Icons.receipt_long_outlined,
          'iconColor': Colors.teal.shade700
        },
      ],
    );
  }
}

class _RecentTransactionsSectionWidget extends StatelessWidget {
  const _RecentTransactionsSectionWidget(); // Adicionado const
  Widget _buildFilterButton(BuildContext context, String text,
      {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 2.0), // Padding horizontal reduzido entre botões
      child: OutlinedButton(
        onPressed: () {
          // TODO: Implementar lógica de filtro e setState para 'isSelected'
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 6.0), // Padding interno do botão reduzido
          backgroundColor: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : null,
          side: BorderSide(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade400,
          ),
          textStyle: const TextStyle(
              fontSize: 12.5), // Fonte ligeiramente menor, se necessário
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(20)), // Bordas mais arredondadas
        ),
        child: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(
              title: 'Últimas Transações',
              onSeeAllPressed: () {/* Ver todas as transações */},
              actions: [
                // Substitua os botões antigos por chamadas ao novo método
                _buildFilterButton(context, 'Todos',
                    isSelected: true), // Exemplo com um selecionado
                _buildFilterButton(context, 'Entradas'),
                _buildFilterButton(context, 'Saídas'),
              ],
            ),
            const SizedBox(height: 10),
            _SimpleListSectionWidget(
              title: "", // Titulo já está acima
              showValueOnRight: true,
              items: [
                // Seus itens de transação...
                {
                  'title': 'Pagamento Tech Solutions',
                  /*...*/ 'iconColor': Colors.green.shade700
                },
                {
                  'title': 'Pagamento Fornecedor XYZ',
                  /*...*/ 'iconColor': Colors.red.shade700
                },
                {
                  'title': 'Impostos Federais',
                  /*...*/ 'iconColor': Colors.red.shade700
                },
                {
                  'title': 'Pagamento Startup 123',
                  /*...*/ 'iconColor': Colors.green.shade700
                },
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentContractsSectionWidget extends StatelessWidget {
  const _RecentContractsSectionWidget(); // Adicionado const
  @override
  Widget build(BuildContext context) {
    return _SimpleListSectionWidget(
      title: 'Contratos Recentes',
      headers: const [
        'Contrato',
        'Cliente',
        'Data Início',
        'Data Fim',
        'Valor Total',
        'Status',
        'Ações'
      ],
      columnFlex: const {
        'Contrato': 2,
        'Cliente': 2,
        'Data Início': 1,
        'Data Fim': 1,
        'Valor Total': 1,
        'Status': 1,
        'Ações': 1
      },
      items: [
        {
          'col1': 'CONT-2025-042',
          'col2': 'Empresa ABC',
          'col3': '01/05/2025',
          'col4': '30/07/2025',
          'col5': '28500.00',
          'isCurrency': true,
          'col6': 'Ativo',
          'col7': Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            IconButton(
                icon: const Icon(Icons.download_outlined, size: 20),
                onPressed: () {},
                tooltip: "Baixar contrato"),
            IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () {},
                tooltip: "Editar")
          ])
        },
        {
          'col1': 'CONT-2025-041',
          'col2': 'Tech Solutions',
          'col3': '15/05/2025',
          'col4': '15/01/2026',
          'col5': '45000.00',
          'isCurrency': true,
          'col6': 'Ativo',
          'col7': Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            IconButton(
                icon: const Icon(Icons.download_outlined, size: 20),
                onPressed: () {}),
            IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () {})
          ])
        },
        {
          'col1': 'CONT-2025-040',
          'col2': 'Loja XYZ',
          'col3': '01/04/2025',
          'col4': '30/06/2025',
          'col5': '12800.00',
          'isCurrency': true,
          'col6': 'Pendente',
          'col7': Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            IconButton(
                icon: const Icon(Icons.download_outlined, size: 20),
                onPressed: () {}),
            IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () {})
          ])
        },
      ],
    );
  }
}
