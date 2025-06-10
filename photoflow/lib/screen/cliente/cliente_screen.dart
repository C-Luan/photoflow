import 'package:flutter/material.dart';

// Certifique-se de que _StatusChip e _AddEditClientDialog estejam definidos
// (código para eles será fornecido abaixo ou já existe no seu projeto)

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final List<String> _activeFilters = [
    "Status: Ativo",
    "Categoria: Varejo"
  ]; // Exemplo

  final List<Map<String, dynamic>> _allClients = List.generate(
    50, // Total de clientes para simular paginação
    (index) => {
      'id': index,
      'nome': [
        'Maria Silva',
        'João Santos',
        'Ana Oliveira',
        'Carlos Pereira',
        'Fernanda Lima',
        'Ricardo Alves',
        'Sofia Costa',
        'Bruno Gomes',
        'Clara Dias',
        'Daniel Araujo',
        'Laura Martins',
        'Gabriel Rocha'
      ][index % 12],
      'email': [
        'maria@example.com',
        'joao@example.com',
        'ana@example.com',
        'carlos@example.com',
        'fernanda@example.com',
        'ricardo@example.com',
        'sofia@example.com',
        'bruno@example.com',
        'clara@example.com',
        'daniel@example.com',
        'laura@example.com',
        'gabriel@example.com'
      ][index % 12]
          .replaceAll('example.com', 'cliente${index + 1}.com'),
      'telefone': '(11) 98765-432${index % 10}',
      'cpf': '123.456.789-0${index % 10}',
      'categoria': ['Varejo', 'Atacado', 'Distribuidor', 'Serviços'][index % 4],
      'status': ['Ativo', 'Inativo'][index % 2],
    },
  );

  int _currentPage = 1;
  final int _rowsPerPage = 10;
  List<Map<String, dynamic>> _paginatedClients = [];

  @override
  void initState() {
    super.initState();
    _updatePaginatedClients();
  }

  void _updatePaginatedClients() {
    final startIndex = (_currentPage - 1) * _rowsPerPage;
    final endIndex = startIndex + _rowsPerPage;
    setState(() {
      _paginatedClients = _allClients.sublist(startIndex,
          endIndex > _allClients.length ? _allClients.length : endIndex);
    });
  }

  void _showAddEditClientDialog({Map<String, dynamic>? clientData}) {
    showDialog(
      context: context,
      barrierDismissible: true, // Permitir fechar clicando fora, como na imagem
      builder: (BuildContext context) {
        return _AddEditClientDialog(client: clientData);
      },
    ).then((value) {
      if (value == true) {
        _updatePaginatedClients(); // Atualiza a lista após adicionar/editar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(clientData == null
                ? 'Cliente adicionado com sucesso!'
                : 'Cliente atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
// Ex: Roxo/Azul
// Branco

    return Scaffold(
      // Usar a cor de fundo do tema geral, que deve ser um cinza claro
      // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding:
            const EdgeInsets.all(24.0), // Padding maior para a página inteira
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cadastro de Clientes',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        // / Cor mais escura para o título
                      ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Novo Cliente'),
                  onPressed: () => _showAddEditClientDialog(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16), // Botão maior
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                elevation: 1.5, // Sombra sutil
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                // Card explicitamente branco
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                      child: _buildSearchAndFiltersSection(context),
                    ),
                    Expanded(
                        child: _buildClientsTable(context, _paginatedClients)),
                    _buildPaginationControls(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFiltersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar clientes...',
                  prefixIcon: Icon(Icons.search, size: 22),
                  // Fundo levemente acinzentado para o campo
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide:
                        BorderSide(width: 1.5), // Sem borda visível por padrão
                  ),
                  focusedBorder: OutlineInputBorder(
                    // Borda quando focado
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(width: 1.5),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                ),
                onChanged: (value) {/* TODO: Lógica de busca */},
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton.icon(
              icon: Icon(
                Icons.filter_list_alt,
                size: 20,
              ),
              label: Text(
                'Filtros',
              ),
              onPressed: () {/* TODO: Abrir modal de filtros */},
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                side: BorderSide(),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        if (_activeFilters.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8.0,
            runSpacing: 6.0,
            children: _activeFilters
                .map((filter) => Chip(
                      label: Text(filter,
                          style: TextStyle(
                            fontSize: 12.5,
                          )),
                      onDeleted: () {/* TODO: Remover filtro */},
                      deleteIcon: Icon(
                        Icons.close,
                        size: 16,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ))
                .toList(),
          ),
        ]
      ],
    );
  }

  Widget _buildClientsTable(
      BuildContext context, List<Map<String, dynamic>> clients) {
    final List<String> headers = [
      'NOME',
      'EMAIL',
      'TELEFONE',
      'CPF',
      'CATEGORIA',
      'STATUS',
      'AÇÕES'
    ];
    // Ajuste os flex factors. A soma deles influenciará a distribuição na totalTableWidth.
    final Map<String, int> columnFlex = {
      'NOME': 3, 'EMAIL': 4, 'TELEFONE': 2, 'CPF': 2, 'CATEGORIA': 2,
      'STATUS': 2, // Aumentei um pouco o STATUS
      'AÇÕES': 3 // Aumentei o flex para AÇÕES
    };
    // Ajuste esta largura para acomodar todas as colunas confortavelmente.
    // Ex: Soma dos flex: 3+4+2+2+2+2+3 = 18. Se cada unidade flex ~70px, 18*70 = 1260.
    const double totalTableWidth = 1300.0;

    final TextStyle headerStyle =
        TextStyle(fontSize: 12, fontWeight: FontWeight.w600);
    final TextStyle cellStyle = TextStyle(fontSize: 13);
    const EdgeInsets cellPadding = EdgeInsets.symmetric(
        horizontal: 8.0, vertical: 0); // Padding para cada célula

    final ButtonStyle editButtonStyle = TextButton.styleFrom(
      foregroundColor: Theme.of(context).primaryColor,
      padding: const EdgeInsets.symmetric(
          horizontal: 6, vertical: 4), // Padding reduzido
      textStyle: const TextStyle(
          fontSize: 12.5, fontWeight: FontWeight.w500), // Fonte um pouco menor
      tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Reduzir área de toque
    );
    final ButtonStyle deleteButtonStyle = TextButton.styleFrom(
      foregroundColor: Colors.red.shade600,
      padding: const EdgeInsets.symmetric(
          horizontal: 6, vertical: 4), // Padding reduzido
      textStyle: const TextStyle(
          fontSize: 12.5, fontWeight: FontWeight.w500), // Fonte um pouco menor
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        // Rolagem vertical para toda a tabela se ela for muito alta
        child: Column(
          children: [
            // Cabeçalho da Tabela
            Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 12.0), // Padding vertical para a linha do cabeçalho

              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: totalTableWidth,
                  child: Row(
                    children: headers.map((header) {
                      return Expanded(
                        flex: columnFlex[header] ?? 1,
                        child: Padding(
                          padding: cellPadding, // Padding consistente da célula
                          child: Text(header, style: headerStyle),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            // Linhas da Tabela
            if (clients.isEmpty)
              const Padding(
                padding: EdgeInsets.all(30.0),
                child: Center(child: Text("Nenhum cliente encontrado.")),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: clients.length,
                itemBuilder: (context, index) {
                  final client = clients[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        vertical:
                            8.0), // Padding vertical para a linha de dados
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Colors.grey.shade200, width: 1)),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: totalTableWidth,
                        child: Row(
                          children: [
                            Expanded(
                                flex: columnFlex['NOME']!,
                                child: Padding(
                                    padding: cellPadding,
                                    child: Text(client['nome'] ?? '',
                                        style: cellStyle,
                                        overflow: TextOverflow.ellipsis))),
                            Expanded(
                                flex: columnFlex['EMAIL']!,
                                child: Padding(
                                    padding: cellPadding,
                                    child: Text(client['email'] ?? '',
                                        style: cellStyle,
                                        overflow: TextOverflow.ellipsis))),
                            Expanded(
                                flex: columnFlex['TELEFONE']!,
                                child: Padding(
                                    padding: cellPadding,
                                    child: Text(client['telefone'] ?? '',
                                        style: cellStyle))),
                            Expanded(
                                flex: columnFlex['CPF']!,
                                child: Padding(
                                    padding: cellPadding,
                                    child: Text(client['cpf'] ?? '',
                                        style: cellStyle))),
                            Expanded(
                                flex: columnFlex['CATEGORIA']!,
                                child: Padding(
                                    padding: cellPadding,
                                    child: Text(client['categoria'] ?? '',
                                        style: cellStyle))),
                            Expanded(
                                flex: columnFlex['STATUS']!,
                                child: Padding(
                                    padding: cellPadding,
                                    child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: _StatusChip(
                                            status: client['status'] ??
                                                'Desconhecido')))),
                            Expanded(
                              flex: columnFlex['AÇÕES']!,
                              child: Padding(
                                padding: cellPadding,
                                child: FittedBox(
                                  // Adicionado FittedBox para encolher os botões se necessário
                                  fit: BoxFit
                                      .scaleDown, // Encolhe o conteúdo para caber, mantendo a proporção
                                  alignment: Alignment
                                      .centerLeft, // Alinha à esquerda dentro da célula
                                  child: Row(
                                    mainAxisSize: MainAxisSize
                                        .min, // Para que a Row não tente expandir desnecessariamente
                                    children: [
                                      TextButton.icon(
                                        icon: const Icon(Icons.edit_outlined,
                                            size: 16),
                                        label: const Text('Editar'),
                                        style: editButtonStyle,
                                        onPressed: () =>
                                            _showAddEditClientDialog(
                                                clientData: client),
                                      ),
                                      const SizedBox(
                                          width:
                                              4), // Espaçamento mínimo entre botões
                                      TextButton.icon(
                                        icon: const Icon(Icons.delete_outline,
                                            size: 16),
                                        label: const Text('Excluir'),
                                        style: deleteButtonStyle,
                                        onPressed: () {/* TODO: Excluir */},
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      );
    });
  }

  Widget _buildPaginationControls(BuildContext context) {
    int totalClients = _allClients.length; // Usar o total geral de clientes
    int totalPages = (totalClients / _rowsPerPage).ceil();
    if (totalPages == 0) totalPages = 1;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            totalClients > 0
                ? 'Mostrando ${((_currentPage - 1) * _rowsPerPage) + 1} a ${(_currentPage * _rowsPerPage > totalClients ? totalClients : _currentPage * _rowsPerPage)} de $totalClients resultados'
                : 'Nenhum resultado',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left,
                    color: _currentPage > 1
                        ? Colors.black54
                        : Colors.grey.shade300),
                iconSize: 22,
                onPressed: _currentPage > 1
                    ? () {
                        _currentPage--;
                        _updatePaginatedClients();
                      }
                    : null,
                tooltip: 'Página Anterior',
                splashRadius: 20,
              ),
              // Simplificação da paginação para mostrar apenas página atual e total
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('$_currentPage de $totalPages',
                    style:
                        TextStyle(fontSize: 13, color: Colors.grey.shade700)),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right,
                    color: _currentPage < totalPages
                        ? Colors.black54
                        : Colors.grey.shade300),
                iconSize: 22,
                onPressed: _currentPage < totalPages
                    ? () {
                        _currentPage++;
                        _updatePaginatedClients();
                      }
                    : null,
                tooltip: 'Próxima Página',
                splashRadius: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- WIDGET _StatusChip (COPIADO DO DASHBOARD, AJUSTE SE NECESSÁRIO) ---
// ... (código do _StatusChip já fornecido e ajustado anteriormente) ...
// Lembre-se de ter o widget _StatusChip definido em algum lugar acessível.

// Certifique-se de que o 'intl' está importado se você o usar em algum lugar,
// mas para este dialog específico, não é diretamente necessário.

// --- FORMULÁRIO NOVO/EDITAR CLIENTE (DIALOG - OPÇÃO 2) ---
class _AddEditClientDialog extends StatefulWidget {
  final Map<String, dynamic>? client; // Cliente existente para edição

  const _AddEditClientDialog({this.client});

  @override
  State<_AddEditClientDialog> createState() => _AddEditClientDialogState();
}

class _AddEditClientDialogState extends State<_AddEditClientDialog> {
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

  void _salvarCliente() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implementar lógica de salvar/atualizar cliente
      // Exemplo de coleta de dados:
      // Map<String, dynamic> clientDataToSave = {
      //   'nome': _nomeController.text,
      //   'email': _emailController.text,
      //   // ... outros campos
      //   'categoria': _categoriaSelecionada,
      //   'status': _statusSelecionado,
      // };
      // if (widget.client != null) {
      //   clientDataToSave['id'] = widget.client!['id']; // para atualização
      // }
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
        chipColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        chipIcon = Icons.check_circle_outline;
        break;
      case 'pendente':
        chipColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        chipIcon = Icons.pause_circle_outline;
        break;
      case 'novo':
        chipColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        chipIcon = Icons.fiber_new_outlined;
        break;
      case 'inadimplente':
      case 'inativo':
        chipColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        chipIcon = Icons.cancel_outlined;
        break;
      default:
        chipColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
        chipIcon = Icons.help_outline;
    }

    return Chip(
      avatar:
          chipIcon != null ? Icon(chipIcon, color: textColor, size: 15) : null,
      label: Text(status,
          style: TextStyle(
              fontSize: 12, color: textColor, fontWeight: FontWeight.w500)),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
      labelPadding:
          chipIcon != null ? const EdgeInsets.only(left: 0, right: 6) : null,
      visualDensity: VisualDensity.compact,
      side: BorderSide.none,
    );
  }
}
