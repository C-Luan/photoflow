// File: lib/panels/widgets/main_menu_bar.dart

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:photoflow/screen/agenda/agendahome.dart';

// Project imports:

class MainMenuBar extends StatelessWidget {
  final MainSection selectedSection;
  final ValueChanged<MainSection> onSectionSelected;
  final VoidCallback onLogout;

  const MainMenuBar({
    super.key,
    required this.selectedSection,
    required this.onSectionSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    String userName = "Usuário"; // Placeholder

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.camera_alt,
                  size: 32, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                "PhotoFlow",
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 32),
              _buildStyledMenuItem(
                context: context,
                text: 'Calendário',
                icon: Icons.calendar_today,
                isSelected: selectedSection == MainSection.calendario,
                onPressed: () => onSectionSelected(MainSection.calendario),
              ),
              _buildStyledMenuItem(
                context: context,
                text: 'Agendamentos',
                icon: Icons.list_alt,
                isSelected: selectedSection == MainSection.agendamentos,
                onPressed: () => onSectionSelected(MainSection.agendamentos),
              ),
              _buildStyledMenuItem(
                context: context,
                text: 'Relatório',
                icon: Icons.bar_chart,
                isSelected: selectedSection == MainSection.relatorio,
                onPressed: () => onSectionSelected(MainSection.relatorio),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                    color: Theme.of(context).hoverColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.1),
                      radius: 14,
                      child: Icon(Icons.person,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      userName,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _buildStyledMenuItem(
                context: context,
                text: 'Sair',
                icon: Icons.exit_to_app,
                isLogout: true,
                onPressed: onLogout,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStyledMenuItem({
    required BuildContext context,
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    bool isSelected = false,
    bool isLogout = false,
  }) {
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
          ?.withOpacity(0.7);
    }

    return TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: foregroundColor,
        textStyle: TextStyle(fontSize: 15, fontWeight: fontWeight),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ).copyWith(
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.hovered)) {
              return foregroundColor?.withOpacity(0.08);
            }
            if (states.contains(MaterialState.pressed)) {
              return foregroundColor?.withOpacity(0.12);
            }
            return null;
          },
        ),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(text),
    );
  }
}