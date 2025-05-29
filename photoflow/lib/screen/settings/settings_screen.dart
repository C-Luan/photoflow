import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'dialogs/userdata.dart';
import 'dialogs/whatsappconnect.dart'; // For math.pi

// You would integrate this SettingsPage into your existing app's widget tree,
// likely as a route or a part of a larger Scaffold.
// Ensure this page is a descendant of a MaterialApp to have access to themes,
// navigation, and MaterialLocalizations.

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _showWhatsAppDialog(BuildContext context) {
    _showCustomDialog(
      context: context,
      dialogContent: WhatsAppConnectDialogContent(),
    );
  }

  void _showUserDataDialog(BuildContext context) {
    _showCustomDialog(
      context: context,
      dialogContent: const UserDataDialogContent(),
    );
  }

  // Helper function to show dialogs with the specified custom transition
  void _showCustomDialog(
      {required BuildContext context, required Widget dialogContent}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context)
          .modalBarrierDismissLabel, // Needs MaterialLocalizations
      barrierColor:
          Colors.black54.withOpacity(0), // Start with transparent barrier
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        // This is the actual content of the dialog.
        // It's wrapped in Center to position it, and Material for theming.
        return dialogContent;
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // Animate barrier opacity (the .dialog-overlay opacity)
        final curvedAnimation =
            CurvedAnimation(parent: animation, curve: Curves.ease);
        final barrierOpacity = Tween<double>(begin: 0.0, end: 0.5)
            .animate(curvedAnimation); // Target opacity for overlay

        // Animate dialog content slide (the .dialog-content transform: translateY)
        // and fade (though CSS only had transform, a slight fade improves perceived smoothness)
        final slideTween = Tween<Offset>(
            begin: const Offset(0, -0.05),
            end: Offset.zero); // translateY(-20px) approx
        final fadeTween =
            Tween<double>(begin: 0.8, end: 1.0); // Optional fade for content

        return AnimatedBuilder(
          animation: barrierOpacity, // Listen to the animation progress
          builder: (context, widget) {
            return Container(
              color: Colors.black.withOpacity(
                  barrierOpacity.value), // Apply animated overlay opacity
              child: FadeTransition(
                opacity: fadeTween.animate(curvedAnimation),
                child: SlideTransition(
                  position: slideTween.animate(curvedAnimation),
                  child:
                      child, // The 'child' here is the dialogContent built by pageBuilder
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // This Scaffold would typically be part of your app's navigation.
    // If you're embedding this page within another Scaffold, you might
    // adjust this structure (e.g., remove the AppBar if it's already provided).
    return Scaffold(
      // Using a light grey background similar to many web settings pages
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Configurações',
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
        backgroundColor: Colors.white, // Clean white AppBar
        elevation: 1.0, // Subtle shadow for web
        iconTheme:
            IconThemeData(color: Colors.black54), // For back button, etc.
      ),
      body: Center(
        // Center the content on wider screens
        child: ConstrainedBox(
          constraints: const BoxConstraints(
              maxWidth: 800), // Max width for the content area
          child: ListView(
            padding: const EdgeInsets.all(16.0), // Overall padding for the list
            children: [
              SettingsCard(
                icon: Icons.message_outlined, // Placeholder for WhatsApp icon
                title: 'WhatsApp',
                subtitle: 'Conecte sua conta do WhatsApp',
                buttonText: 'Conectar',
                onButtonPressed: () => _showWhatsAppDialog(context),
              ),
              SettingsCard(
                icon: Icons.tune_outlined, // Placeholder for Preferences icon
                title: 'Preferências',
                subtitle: 'Ajuste suas preferências',
                buttonText: 'Editar',
                onButtonPressed: () => _showUserDataDialog(context),
              ),
              SettingsCard(
                icon: Icons.info_outline,
                title: 'Sobre',
                subtitle: 'Informações do aplicativo',
                buttonText: 'Ver',
                onButtonPressed: () {
                  // For web, a simple AboutDialog is fine.
                  // You might navigate to a dedicated About page in a real app.
                  showDialog(
                    context: context,
                    builder: (context) => const AboutDialog(
                      applicationName: 'Meu Aplicativo Web',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2024 Sua Empresa',
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 15),
                          child:
                              Text('Mais informações sobre o aplicativo aqui.'),
                        )
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const SettingsCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onButtonPressed,
  });

  @override
  State<SettingsCard> createState() => _SettingsCardState();
}

class _SettingsCardState extends State<SettingsCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    // Using Theme.of(context) for card properties to align with MaterialApp theme
    final cardTheme = Theme.of(context).cardTheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click, // Indicate interactivity
      child: Card(
        elevation: _isHovering
            ? (cardTheme.elevation ?? 1.0) + 3
            : (cardTheme.elevation ?? 1.0),
        shape: cardTheme.shape ??
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: cardTheme.margin ??
            const EdgeInsets.symmetric(
                horizontal: 0,
                vertical: 8), // No horizontal margin if centered list
        child: Padding(
          padding: const EdgeInsets.all(
              20.0), // Increased padding for a more spacious look
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(
                    milliseconds:
                        300), // Matches CSS: transition: transform 0.3s ease;
                curve: Curves.ease,
                transformAlignment: Alignment.center,
                transform: _isHovering
                    ? (Matrix4.identity()..rotateZ(30 * math.pi / 180))
                    : Matrix4.identity(), // rotate(30deg)
                child: Icon(widget.icon,
                    size: 32, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF333333))),
                    const SizedBox(height: 5),
                    Text(widget.subtitle,
                        style:
                            TextStyle(fontSize: 14, color: Colors.grey[600])),
                  ],
                ),
              ),
              const SizedBox(width: 16), // Space before button
              ElevatedButton(
                onPressed: widget.onButtonPressed,
                style: ElevatedButton.styleFrom(
                    // Using theme for button style but can override
                    // backgroundColor: Theme.of(context).colorScheme.secondary,
                    // foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    textStyle: const TextStyle(fontWeight: FontWeight.w500)),
                child: Text(widget.buttonText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
