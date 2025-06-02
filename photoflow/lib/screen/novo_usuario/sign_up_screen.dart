import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _agreeToTerms = false;
  DateTime? _selectedDate;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  String? _selectedState;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final List<String> _brazilianStates = [
    'Acre',
    'Alagoas',
    'Amapá',
    'Amazonas',
    'Bahia',
    'Ceará',
    'Distrito Federal',
    'Espírito Santo',
    'Goiás',
    'Maranhão',
    'Mato Grosso',
    'Mato Grosso do Sul',
    'Minas Gerais',
    'Pará',
    'Paraíba',
    'Paraná',
    'Pernambuco',
    'Piauí',
    'Rio de Janeiro',
    'Rio Grande do Norte',
    'Rio Grande do Sul',
    'Rondônia',
    'Roraima',
    'Santa Catarina',
    'São Paulo',
    'Sergipe',
    'Tocantins'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _cepController.dispose();
    _cityController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Você precisa concordar com os Termos de Serviço e Política de Privacidade.')),
        );
        return;
      }
      print('Formulário válido e termos aceitos!');
    }
  }

  // Helper para criar as bolhas do bokeh estático
  Widget _buildBokehCircle(Color color, double size, Alignment alignment,
      {double opacity = 0.05}) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(opacity),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Cores consistentes com a tela de login
    const Color pageBackgroundColor =
        Color(0xFF1A1D3B); // Azul bem escuro (igual ao login)
    const Color cardBackgroundColor = Color.fromARGB(255, 248, 248, 248);
    const Color primaryTextColorOnCard = Color(0xFF333333);
    const Color secondaryTextColorOnCard = Color(0xFF666666);
    const Color primaryButtonColor = Color(0xFF5C67C6);
    const Color linkColor = Color(0xFF5C67C6);

    return Scaffold(
      backgroundColor: pageBackgroundColor, // Cor de fundo base da tela
      body: Stack(
        // Usar Stack para sobrepor o card ao fundo com bokeh
        children: [
          // Camada de Fundo com Bokeh Estático
          Positioned.fill(
            child: Stack(
              // Stack para as múltiplas bolhas
              children: [
                _buildBokehCircle(
                    Colors.blueAccent, 300, const Alignment(-0.9, -0.8),
                    opacity: 0.03),
                _buildBokehCircle(
                    Colors.purpleAccent, 250, const Alignment(0.9, 0.7),
                    opacity: 0.04),
                _buildBokehCircle(
                    Colors.lightBlueAccent, 200, const Alignment(0.5, -0.5),
                    opacity: 0.02),
                _buildBokehCircle(
                    Colors.pinkAccent, 150, const Alignment(-0.8, 0.6),
                    opacity: 0.03),
              ],
            ),
          ),

          // Camada do Conteúdo de Cadastro (Card Centralizado)
          Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 500),
                padding: const EdgeInsets.symmetric(
                    horizontal: 28.0, vertical: 32.0),
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Cadastre-se",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColorOnCard,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Preencha os dados abaixo para criar sua conta",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14, color: secondaryTextColorOnCard),
                      ),
                      const SizedBox(height: 28),
                      _buildLabeledTextField(
                          label: "Nome completo *",
                          controller: _nameController,
                          hintText: "Digite seu nome completo",
                          isRequired: true),
                      _buildLabeledTextField(
                          label: "CPF *",
                          controller: _cpfController,
                          hintText: "000.000.000-00",
                          keyboardType: TextInputType.number,
                          isRequired: true),
                      _buildLabeledTextField(
                          label: "Email *",
                          controller: _emailController,
                          hintText: "seu@email.com",
                          keyboardType: TextInputType.emailAddress,
                          isRequired: true),
                      _buildLabeledTextField(
                          label: "Telefone *",
                          controller: _phoneController,
                          hintText: "(00) 00000-0000",
                          keyboardType: TextInputType.phone,
                          isRequired: true),
                      _buildLabeledTextField(
                        label: "Data de nascimento *",
                        controller: _dobController,
                        hintText: "dd/mm/aaaa",
                        isRequired: true,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        suffixIcon: Icon(Icons.calendar_today_outlined,
                            color: Colors.grey.shade600, size: 20),
                      ),
                      _buildLabeledTextField(
                          label: "Endereço *",
                          controller: _addressController,
                          hintText: "Rua, número, complemento",
                          isRequired: true),
                      _buildLabeledTextField(
                          label: "CEP *",
                          controller: _cepController,
                          hintText: "00000-000",
                          keyboardType: TextInputType.number,
                          isRequired: true),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: _buildLabeledTextField(
                                  label: "Cidade *",
                                  controller: _cityController,
                                  hintText: "Sua cidade",
                                  isRequired: true)),
                          const SizedBox(width: 16),
                          Expanded(
                              child: _buildLabeledDropdownField(
                            label: "Estado *",
                            value: _selectedState,
                            hintText: "Selecione",
                            items: _brazilianStates,
                            onChanged: (value) =>
                                setState(() => _selectedState = value),
                            isRequired: true,
                          )),
                        ],
                      ),
                      _buildLabeledTextField(
                          label: "Senha *",
                          controller: _passwordController,
                          hintText: "Mínimo 8 caracteres",
                          isRequired: true,
                          obscureText: true,
                          validator: (val) {
                            if (val == null || val.isEmpty)
                              return 'Campo obrigatório';
                            if (val.length < 8) return 'Mínimo 8 caracteres';
                            return null;
                          }),
                      _buildLabeledTextField(
                          label: "Confirmar senha *",
                          controller: _confirmPasswordController,
                          hintText: "Confirme sua senha",
                          isRequired: true,
                          obscureText: true,
                          validator: (val) {
                            if (val == null || val.isEmpty)
                              return 'Campo obrigatório';
                            if (val != _passwordController.text)
                              return 'As senhas não coincidem';
                            return null;
                          }),
                      const SizedBox(height: 16),
                      _buildTermsCheckbox(
                        value: _agreeToTerms,
                        onChanged: (bool? newValue) {
                          setState(() {
                            _agreeToTerms = newValue ?? false;
                          });
                        },
                        linkColor: linkColor,
                        textColor: secondaryTextColorOnCard,
                      ),
                      const SizedBox(height: 28),
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryButtonColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0)),
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        child: const Text("Criar conta",
                            style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: "Já tem uma conta? ",
                            style: TextStyle(
                                color: secondaryTextColorOnCard, fontSize: 14),
                            children: <TextSpan>[
                              TextSpan(
                                text: "Entrar",
                                style: TextStyle(
                                    color: linkColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pop(context);
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- MÉTODOS AUXILIARES (_buildLabeledTextField, _buildLabeledDropdownField, _buildTermsCheckbox) ---
  // Cole os métodos auxiliares definidos na resposta anterior aqui.
  // Eles são responsáveis por criar os campos de formulário e o checkbox de termos.
  // Exemplo:
  Widget _buildLabeledTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    bool isRequired = false,
    bool obscureText = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: label,
              children: isRequired
                  ? const [
                      TextSpan(text: ' *', style: TextStyle(color: Colors.red))
                    ]
                  : [],
            ),
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4A5568)),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                    color: Theme.of(context).primaryColor, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              suffixIcon: suffixIcon,
            ),
            obscureText: obscureText,
            keyboardType: keyboardType,
            maxLines: maxLines,
            readOnly: readOnly,
            onTap: onTap,
            validator: validator ??
                (value) {
                  if (isRequired && (value == null || value.isEmpty)) {
                    return 'Este campo é obrigatório.';
                  }
                  return null;
                },
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledDropdownField({
    required String label,
    required String? value,
    required String hintText,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: label,
              children: isRequired
                  ? const [
                      TextSpan(text: ' *', style: TextStyle(color: Colors.red))
                    ]
                  : [],
            ),
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4A5568)),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                    color: Theme.of(context).primaryColor, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
            value: value,
            isExpanded: true,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item, style: const TextStyle(fontSize: 14)),
              );
            }).toList(),
            onChanged: onChanged,
            validator: (val) {
              if (isRequired && val == null) {
                return 'Este campo é obrigatório.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required Color linkColor,
    required Color textColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment
          .center, // Alinhar checkbox com a primeira linha do texto
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: linkColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            side: BorderSide(color: Colors.grey.shade400, width: 1.5),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: "Eu concordo com os ",
              style: TextStyle(
                  fontSize: 13,
                  color: textColor,
                  height: 1.4), // Ajuste a altura da linha
              children: <TextSpan>[
                TextSpan(
                  text: "Termos de Serviço",
                  style: TextStyle(
                      color: linkColor,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      print("Termos");
                    },
                ),
                const TextSpan(text: " e "),
                TextSpan(
                  text: "Política de Privacidade",
                  style: TextStyle(
                      color: linkColor,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      print("Política");
                    },
                ),
                const TextSpan(text: "."),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
