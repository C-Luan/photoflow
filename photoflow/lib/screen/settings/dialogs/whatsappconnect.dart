import 'package:flutter/material.dart';
import 'package:photoflow/screen/settings/dialogs/conexaowhatsapp.dart';

// --- WhatsApp Connect Dialog Content ---
class WhatsAppConnectDialogContent extends StatelessWidget {
  WhatsAppConnectDialogContent({super.key});
  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding:
          const EdgeInsets.all(20), // Standard padding around the dialog
      child: ConstrainedBox(
        // To control max width, useful for web
        constraints: const BoxConstraints(maxWidth: 450),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Important for dialog content
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Conectar ao WhatsApp',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Fechar',
                    splashRadius: 20,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                  'Digite o número de telefone que você deseja conectar ao WhatsApp:',
                  style: TextStyle(fontSize: 14)),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Ex: 5591912345678',
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20),

                  // Using theme for input decoration
                  // border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  // contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 8),
              Text('Inclua o código do país e DDD',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // _showCustomDialog(
                      //     context: context,
                      //     dialogContent: WhatsappConnectionPage(
                      //         sessionNumber: controller.text));
                      // Navigator.of(context).pop();
                    },
                    child: const Text('Conectar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

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
}
