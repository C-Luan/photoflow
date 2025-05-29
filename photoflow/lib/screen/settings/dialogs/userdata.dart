import 'package:flutter/material.dart';

// --- User Data Dialog Content ---
class UserDataDialogContent extends StatefulWidget {
  const UserDataDialogContent({super.key});

  @override
  State<UserDataDialogContent> createState() => _UserDataDialogContentState();
}

class _UserDataDialogContentState extends State<UserDataDialogContent> {
  bool _isAvatarHovering = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // shape: Theme.of(context).dialogTheme.shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // backgroundColor: Theme.of(context).dialogTheme.backgroundColor ?? Colors.white,
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: 500), // Wider for more fields
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Dados do Usuário',
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
              const SizedBox(height: 20),
              Center(
                child: MouseRegion(
                  onEnter: (_) => setState(() => _isAvatarHovering = true),
                  onExit: (_) => setState(() => _isAvatarHovering = false),
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      // Implement avatar upload logic for web
                      print('Avatar tapped - Implement web file picker');
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor:
                              Colors.black12, // Placeholder background
                          // child: Icon(Icons.person_outline, size: 50, color: Colors.white70), // Alternative placeholder
                          // backgroundImage: AssetImage('assets/default_avatar.png'), // Add your asset
                        ),
                        // Avatar Overlay: opacity: 1 on hover
                        AnimatedOpacity(
                          duration: const Duration(
                              milliseconds: 200), // CSS transition for opacity
                          opacity: _isAvatarHovering ? 1.0 : 0.0,
                          child: Container(
                            width: 100, // Match CircleAvatar diameter
                            height: 100, // Match CircleAvatar diameter
                            decoration: BoxDecoration(
                              color: Colors.black
                                  .withOpacity(0.4), // Overlay color
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_outlined,
                                color: Colors.white, size: 30),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                  label: 'Nome completo', iconData: Icons.person_outline),
              const SizedBox(height: 16),
              _buildTextField(
                  label: 'Email',
                  iconData: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildTextField(
                  label: 'Telefone',
                  iconData: Icons.phone_outlined,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildTextField(
                  label: 'Data de nascimento',
                  iconData: Icons.calendar_today_outlined,
                  keyboardType: TextInputType.datetime,
                  hintText: 'DD/MM/AAAA'),
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
                      // Implement save logic
                      Navigator.of(context).pop();
                    },
                    child: const Text('Salvar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required String label,
      required IconData iconData,
      TextInputType? keyboardType,
      String? hintText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Color(0xFF444444))),
        const SizedBox(height: 6),
        TextField(
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(iconData, size: 20),
            // border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            // contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            // filled: true, // Optional: if you want a fill color
            // fillColor: Colors.grey[50],
          ),
          style: const TextStyle(fontSize: 15),
        ),
      ],
    );
  }
}
