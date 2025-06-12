// --- FORMULÁRIO NOVO/EDITAR CLIENTE (DIALOG - OPÇÃO 2) ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photoflow/models/cliente/cliente.dart';
import 'package:photoflow/services/apis/clientes/createcliente.dart';

class AddEditClientDialog extends StatefulWidget {
  final Map<String, dynamic>? client; // Cliente existente para edição

  const AddEditClientDialog({super.key, this.client});

  @override
  State<AddEditClientDialog> createState() => _AddEditClientDialogState();
}

class _AddEditClientDialogState extends State<AddEditClientDialog> {
  final _formKey = GlobalKey<FormState>();
  // Controladores para os campos do formulário
  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late TextEditingController _telefoneController;
  late TextEditingController _cpfController;
  late TextEditingController _rgController;
  late TextEditingController _cnpjController;
  late TextEditingController _enderecoController;
  late TextEditingController _cidadeController;
  late TextEditingController _estadoController;
  late TextEditingController _obsController;

  String? _categoriaSelecionada;
  String _statusSelecionado = 'Ativo'; // Valor padrão

  final List<String> _categorias = [
    'Varejo',
    'Atacado',
    'Distribuidor',
    'Serviços',
    'Outro'
  ];

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.client?['nome'] ?? '');
    _emailController =
        TextEditingController(text: widget.client?['email'] ?? '');
    _telefoneController =
        TextEditingController(text: widget.client?['telefone'] ?? '');
    _cpfController = TextEditingController(text: widget.client?['cpf'] ?? '');
    _rgController = TextEditingController(text: widget.client?['rg'] ?? '');
    _cnpjController = TextEditingController(text: widget.client?['cnpj'] ?? '');
    _categoriaSelecionada = widget.client?['categoria'];
    if (_categoriaSelecionada != null &&
        !_categorias.contains(_categoriaSelecionada)) {
      _categorias.add(_categoriaSelecionada!);
    }
    _enderecoController =
        TextEditingController(text: widget.client?['endereco'] ?? '');
    _cidadeController =
        TextEditingController(text: widget.client?['cidade'] ?? '');
    _estadoController =
        TextEditingController(text: widget.client?['estado'] ?? '');
    _obsController = TextEditingController(text: widget.client?['obs'] ?? '');
    _statusSelecionado = widget.client?['status'] ?? 'Ativo';
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _cpfController.dispose();
    _rgController.dispose();
    _cnpjController.dispose();
    _enderecoController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  Future<void> _salvarCliente() async {
    if (_formKey.currentState!.validate()) {
      Cliente cliente = Cliente(
        nome: _nomeController.text,
        email: _emailController.text,
        telefone: _telefoneController.text,
        ativo: _statusSelecionado == 'Ativo',
        cpf: _cpfController.text,
        cnpj: _cnpjController.text,
        // rg: _rgController.text,
      );
      String? token = await FirebaseAuth.instance.currentUser?.getIdToken();

      await createClienteService(token: token ?? '', data: cliente.toJson())
          .then((onValue) {});
      Navigator.of(context).pop(true); // Retorna true para indicar sucesso
    }
  }

  // Helper para campos de formulário com rótulo acima
  Widget _buildLabeledTextFormField({
    required String label,
    required TextEditingController controller,
    bool isRequired = false,
    TextInputType? keyboardType,
    int? maxLines = 1,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide()),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide()),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, width: 1.5)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              // filled: true,
              // fillColor: Colors.white,
            ),
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: (value) {
              if (isRequired && (value == null || value.isEmpty)) {
                return 'Campo obrigatório';
              }
              if (validator != null) {
                return validator(value);
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledDropdownFormField({
    required String label,
    String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide()),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide()),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide()),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14), // Ajustado para alinhar com TextFormField
            ),
            value: value,
            items: items.map((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
            onChanged: onChanged,
            validator: (val) =>
                isRequired && val == null ? 'Campo obrigatório' : null,
            isExpanded: true, // Para o dropdown ocupar a largura disponível
          ),
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      // A validação de 'isRequired' já cuida disso se o campo for obrigatório.
      // Se não for obrigatório e estiver vazio, é válido.
      return null;
    }
    final emailRegex = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (!emailRegex.hasMatch(value)) {
      return 'Digite um email válido';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.client != null;
    final Color primaryColor = Theme.of(context).primaryColor;

    return Dialog(
      // backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      insetPadding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 24.0), // Permite que o dialog seja mais largo
      child: Container(
        // Use Container para definir a largura e altura máxima
        width: MediaQuery.of(context).size.width < 700
            ? MediaQuery.of(context).size.width *
                0.9 // Para telas menores, 90% da largura
            : 650, // Largura máxima para telas maiores (ex: desktop)
        constraints: BoxConstraints(
          // Definir uma altura máxima para o dialog, o conteúdo interno rolará
          maxHeight: MediaQuery.of(context).size.height *
              0.85, // Ex: 85% da altura da tela
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize
                .min, // Importante para Column dentro de Container com altura limitada
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título do Dialog
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Editar Cliente' : 'Novo Cliente',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: "Fechar",
                    splashRadius: 20,
                  )
                ],
              ),
              const SizedBox(height: 16),

              // Formulário com rolagem
              Flexible(
                // Permite que o Form/SingleChildScrollView ocupe o espaço restante e role
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize
                          .min, // Para a Column interna não tentar ser infinita
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildLabeledTextFormField(
                            label: 'Nome completo',
                            controller: _nomeController,
                            isRequired: true),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: _buildLabeledTextFormField(
                                    label: 'Email',
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    isRequired: true,
                                    validator: _validateEmail)),
                            const SizedBox(width: 16),
                            Expanded(
                                child: _buildLabeledTextFormField(
                                    label: 'Telefone',
                                    controller: _telefoneController,
                                    keyboardType: TextInputType.phone,
                                    isRequired: true)),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: _buildLabeledTextFormField(
                                    label: 'CPF',
                                    controller: _cpfController,
                                    isRequired: true,
                                    hintText: "000.000.000-00")),
                            const SizedBox(width: 16),
                            Expanded(
                                child: _buildLabeledTextFormField(
                                    label: 'RG',
                                    controller: _rgController,
                                    hintText: "00.000.000-0")),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: _buildLabeledTextFormField(
                                    label: 'CNPJ (se aplicável)',
                                    controller: _cnpjController,
                                    hintText: "00.000.000/0000-00")),
                            const SizedBox(width: 16),
                            Expanded(
                                child: _buildLabeledDropdownFormField(
                                    label: 'Categoria',
                                    value: _categoriaSelecionada,
                                    items: _categorias,
                                    onChanged: (val) => setState(
                                        () => _categoriaSelecionada = val))),
                          ],
                        ),
                        _buildLabeledTextFormField(
                            label: 'Endereço', controller: _enderecoController),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: _buildLabeledTextFormField(
                                    label: 'Cidade',
                                    controller: _cidadeController)),
                            const SizedBox(width: 16),
                            Expanded(
                                child: _buildLabeledTextFormField(
                                    label: 'Estado',
                                    controller: _estadoController)),
                          ],
                        ),
                        _buildLabeledTextFormField(
                            label: 'Observações',
                            controller: _obsController,
                            maxLines: 3),
                        const SizedBox(height: 16),
                        Text('Status',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700)),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Ativo',
                                    style: TextStyle(fontSize: 14)),
                                value: 'Ativo',
                                groupValue: _statusSelecionado,
                                onChanged: (value) =>
                                    setState(() => _statusSelecionado = value!),
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Inativo',
                                    style: TextStyle(fontSize: 14)),
                                value: 'Inativo',
                                groupValue: _statusSelecionado,
                                onChanged: (value) =>
                                    setState(() => _statusSelecionado = value!),
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Ações do Dialog
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12)),
                    child: Text('Cancelar', style: TextStyle(fontSize: 14)),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _salvarCliente,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                        isEditing ? 'Salvar Alterações' : 'Salvar Cliente',
                        style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
