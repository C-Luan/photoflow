// File: lib/panels/widgets/report_cards.dart

import 'package:flutter/material.dart';

// Card para exibir um resumo de métricas (Ex: Faturamento Total)
class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData iconData;
  final Color iconColor;
  final double percentageChange;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.iconData,
    required this.iconColor,
    required this.percentageChange,
  });

  @override
  Widget build(BuildContext context) {
    bool isPositive = percentageChange >= 0;
    return Expanded(
      child: Card(
        elevation: 2.0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade700)),
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: iconColor.withOpacity(0.15),
                    child: Icon(iconData, size: 14, color: iconColor),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    color: isPositive ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      "${percentageChange.abs().toStringAsFixed(0)}% em relação ao período anterior",
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Card genérico para seções de detalhes do relatório (Ex: Gráfico de Faturamento)
class ReportDetailCard extends StatelessWidget {
  final String title;
  final Widget content;
  final double? height;

  const ReportDetailCard({
    super.key,
    required this.title,
    required this.content,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Container(
        height: height,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }
}