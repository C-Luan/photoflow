import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// ... (outros imports, se houver)

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _rememberMe = false;

  // ... (resto do _LoginScreenState: initState, dispose, buildBokehCircle, etc. como antes) ...

  @override
  Widget build(BuildContext context) {
    const Color pageBackgroundColor = Color.fromARGB(255, 25, 30, 53);
    const Color cardBackgroundColor = Color(0xFF252A4A);
    const Color primaryTextColor = Colors.white;
    const Color secondaryTextColor = Colors.white70;
    const Color linkColor = Color(0xFF8293FF);
    const Color fieldBackgroundColor = Color(0xFF1E2240);
    final List<Color> buttonGradientColors = [
      Color.fromARGB(255, 94, 114, 235),
      const Color(0xFF8B78FF)
    ];

    Widget buildBokehCircle(Color color, double size, Alignment alignment) {
      return Align(
        alignment: alignment,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.05),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: pageBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Stack(
              children: [
                buildBokehCircle(
                    Colors.blueAccent, 300, const Alignment(-0.8, -0.8)),
                buildBokehCircle(
                    Colors.purpleAccent, 250, const Alignment(0.9, 0.7)),
                buildBokehCircle(
                    Colors.lightBlueAccent, 200, const Alignment(0.5, -0.6)),
              ],
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(28.0),
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ... (Logo, Nome do App, Tagline, Email, Senha, Lembrar de mim, Entrar, Registre-se - como antes) ...
                    Icon(
                      Icons.camera_enhance_outlined,
                      size: 56,
                      color: linkColor,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "PhotoFlow",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Sua plataforma de fotografia e audiovisual",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: secondaryTextColor),
                    ),
                    const SizedBox(height: 32),
                    _buildTextField(
                      label: "Email",
                      hint: "seu@email.com",
                      textColor: primaryTextColor,
                      fieldBackgroundColor: fieldBackgroundColor,
                    ),
                    const SizedBox(height: 18),
                    _buildPasswordField(
                      label: "Senha",
                      hint: "••••••••",
                      textColor: primaryTextColor,
                      fieldBackgroundColor: fieldBackgroundColor,
                      linkColor: linkColor,
                    ),
                    const SizedBox(height: 18),
                    _buildRememberMeCheckbox(
                      textColor: secondaryTextColor,
                      activeColor: linkColor,
                      value: _rememberMe,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _rememberMe = newValue ?? false;
                        });
                      },
                    ),
                    const SizedBox(height: 28),
                    _buildLoginButton(
                      text: "Entrar",
                      gradientColors: buttonGradientColors,
                      textColor: primaryTextColor,
                      onPressed: () {
                        print("Botão Entrar pressionado");
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildSignUpLink(
                      context: context,
                      text: "Não tem uma conta? ",
                      linkText: "Registre-se",
                      textColor: secondaryTextColor,
                      linkColor: linkColor,
                    ),
                    const SizedBox(height: 28),
                    _buildDividerText(
                        text: "Ou continue com", textColor: secondaryTextColor),
                    const SizedBox(height: 20),

                    // Chamadas ATUALIZADAS para _buildSocialLoginButton:
                    _buildSocialLoginButton(
                        imageAssetPath: "assets/logos/google.png",
                        text: "Google",
                        // backgroundColor e textColor não são mais passados, são definidos dentro do método
                        onPressed: () {/* TODO: Login com Google */}),
                    const SizedBox(
                        height: 12), // Espaçamento entre os botões sociais
                    _buildSocialLoginButton(
                        imageAssetPath: "assets/logos/apple.png",
                        text: "Apple",
                        onPressed: () {/* TODO: Login com Apple */}),
                    const SizedBox(height: 12),
                    _buildSocialLoginButton(
                        imageAssetPath: "assets/logos/microsoft.png",
                        text: "Microsoft",
                        onPressed: () {/* TODO: Login com Microsoft */}),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- MÉTODOS AUXILIARES ---
  // _buildTextField, _buildPasswordField, _buildRememberMeCheckbox,
  // _buildLoginButton, _buildSignUpLink, _buildDividerText
  // PERMANECEM OS MESMOS da resposta anterior.
  // Cole-os aqui se precisar do contexto completo.
  // Exemplo:
  Widget _buildTextField({
    required String label,
    required String hint,
    required Color textColor,
    required Color fieldBackgroundColor,
    bool isObscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: textColor.withOpacity(0.9),
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          obscureText: isObscure,
          keyboardType: keyboardType,
          style: TextStyle(color: textColor, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
            filled: true,
            fillColor: fieldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required Color textColor,
    required Color fieldBackgroundColor,
    required Color linkColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    color: textColor.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
            InkWell(
              onTap: () {
                print("Esqueceu a senha?");
              },
              child: Text(
                "Esqueceu a senha?",
                style: TextStyle(
                    color: linkColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          obscureText: true,
          style: TextStyle(color: textColor, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
            filled: true,
            fillColor: fieldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildRememberMeCheckbox({
    required Color textColor,
    required Color activeColor,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor,
            checkColor: Colors.white,
            side: MaterialStateBorderSide.resolveWith(
              (states) =>
                  BorderSide(width: 1.5, color: textColor.withOpacity(0.7)),
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          ),
        ),
        const SizedBox(width: 10),
        Text("Lembrar de mim",
            style: TextStyle(color: textColor, fontSize: 13)),
      ],
    );
  }

  Widget _buildLoginButton({
    required String text,
    required List<Color> gradientColors,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
                color: gradientColors.last.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4))
          ]),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          textStyle: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        ),
        child: Text(text, style: TextStyle(color: textColor)),
      ),
    );
  }

  Widget _buildSignUpLink({
    required BuildContext context,
    required String text,
    required String linkText,
    required Color textColor,
    required Color linkColor,
  }) {
    return Center(
      child: RichText(
        text: TextSpan(
          text: text,
          style: TextStyle(color: textColor, fontSize: 14),
          children: <TextSpan>[
            TextSpan(
              text: linkText,
              style: TextStyle(
                  color: linkColor, fontWeight: FontWeight.bold, fontSize: 14),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  print("Ir para registro");
                },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDividerText({required String text, required Color textColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(text,
              style:
                  TextStyle(color: textColor.withOpacity(0.8), fontSize: 12)),
        ),
      ],
    );
  }

// ... (outros imports e o início da classe _LoginScreenState)

// MÉTODO _buildSocialLoginButton ATUALIZADO:
  Widget _buildSocialLoginButton({
    required String imageAssetPath,
    required String text,
    // A cor de fundo agora será fixa ou baseada em um novo parâmetro,
    // mas para este design, ela é consistente.
    // required Color backgroundColor, // <- Removido, usaremos uma cor fixa baseada na imagem
    // required Color textColor, // <- Removido, usaremos uma cor fixa baseada na imagem
    required VoidCallback onPressed,
  }) {
    // Cor de fundo dos botões sociais baseada na imagem image_72c983.png
    const Color socialButtonBackgroundColor =
        Color(0xFF3A3F5F); // Um cinza-azulado escuro
    const Color socialButtonTextColor = Colors.white; // Texto branco/claro

    return ElevatedButton.icon(
      icon: Image.asset(
        imageAssetPath,
        height: 22, // Ajuste o tamanho do logo conforme necessário
        width: 22,
        // Para logos como o da Apple que podem ser brancos e sumir em fundo branco (não é o caso aqui)
        // você pode precisar de um colorBlendMode ou tratar a imagem.
        // Mas para este design com fundo escuro, deve funcionar bem.
        errorBuilder: (context, error, stackTrace) {
          // Fallback caso a imagem não carregue
          return Icon(Icons.error_outline,
              size: 22, color: socialButtonTextColor.withOpacity(0.7));
        },
      ),
      label: Text(
        text,
        style: const TextStyle(
          fontSize: 14, // Tamanho da fonte como na imagem
          fontWeight: FontWeight.w500, // Peso da fonte
          color: socialButtonTextColor,
        ),
      ),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: socialButtonBackgroundColor, // Nova cor de fundo
        foregroundColor:
            socialButtonTextColor, // Cor para o ripple effect e texto/ícone padrão (se não sobrescrito)
        minimumSize: const Size(double.infinity, 50), // Altura do botão
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0)), // Cantos arredondados
        elevation: 0, // Sem elevação, como na imagem
        // O alinhamento padrão do ElevatedButton.icon deve centralizar o conteúdo.
        // Se precisar de ajuste fino, pode usar o padding ou alignment.
        // alignment: Alignment.center, // Geralmente o padrão já é bom
        padding: const EdgeInsets.symmetric(
            vertical: 0, horizontal: 16), // Padding interno do botão
      ),
    );
  }

// Dentro do método build da _LoginScreenState:
// ...
// const SizedBox(height: 20), // Espaço antes dos botões sociais
// _buildDividerText(text: "Ou continue com", textColor: secondaryTextColor),
// const SizedBox(height: 20),

// ... (fim do Column e do build method)
// ...
}
