import 'dart:developer';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:intl/intl.dart';
import 'package:photoflow/models/cliente/cliente.dart'; // Ajuste o caminho se necessário
import 'package:photoflow/models/projeto/etapa_projeto.dart'; // Ajuste o caminho se necessário
import 'package:photoflow/models/projeto/projeto.dart'; // Ajuste o caminho se necessário
import 'package:photoflow/models/tiposervico/categoria.dart'; // Ajuste o caminho se necessário
import 'package:photoflow/models/tiposervico/tiposervico.dart';
import 'package:photoflow/services/apis/clientes/readcliente.dart';
import 'package:photoflow/services/apis/etapaprojeto/readetapaprojeto.dart';

import '../../../services/apis/categoria/get_categorias_service.dart';
import '../../cliente/dialog/addcliente_dialog.dart'; // Ajuste o caminho se necessário

class NovoProjetoDialog extends StatefulWidget {
  const NovoProjetoDialog({
    super.key,
    required this.onSave,
  });
  final Function(Projeto) onSave;
  @override
  State<NovoProjetoDialog> createState() => _NovoProjetoDialogState();
}

class _NovoProjetoDialogState extends State<NovoProjetoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _clienteDropdown = GlobalKey<DropdownSearchState>();
  final _nomeClienteController = TextEditingController();
  final _dataInicioController = TextEditingController();
  final _prazoController = TextEditingController();
  final _valorController = TextEditingController();
  final _observacoesController = TextEditingController();
  CategoriaServico? _categoriaSelecionada;
  Tiposervico? _tipoServicoSelecionado;

  List<Tiposervico> _tiposServicoFiltrados = [];
  Tiposervico? _selectedTipoServico;
  EtapaProjeto? _selectedEtapaProjeto;
  Cliente? _selectedCliente;
  DateTime? _selectedDataInicio;
  DateTime? _selectedPrazo;

  // Constantes de espaçamento para facilitar ajustes
  final double _spacerHeightSmall = 8.0;
  final double _spacerHeightMedium = 20.0; // Aumentado de 16 para 20

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nomeClienteController.dispose();
    _dataInicioController.dispose();
    _prazoController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(
      BuildContext context,
      TextEditingController controller,
      DateTime? initialDate,
      ValueChanged<DateTime> onDateSelected) async {
    FocusScope.of(context).requestFocus(FocusNode());
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('pt', 'BR'),
    );
    if (pickedDate != null) {
      onDateSelected(pickedDate);
      controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
    }
  }

  void _salvarProjeto() {
    if (_formKey.currentState!.validate()) {
      Projeto novoProjeto = Projeto(
        cliente: _selectedCliente!,
        tipoServico: _selectedTipoServico!,
        etapaProjeto: _selectedEtapaProjeto!,
        categoriaServico: _categoriaSelecionada!,
        observacao: _observacoesController.text,
        conclusao: false,
        dataInicio: _selectedDataInicio!,
        prazo: _selectedPrazo!,
        valor: double.parse(_valorController.text),
      );
      widget.onSave(novoProjeto);
      Navigator.of(context).pop(novoProjeto);
    }
  }

  Widget _buildFormFieldTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: _spacerHeightSmall / 2), // Espaçamento entre título e campo
      child: Text(title,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(
          24.0, 24.0, 24.0, 10.0), // Ajuste no padding do título
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 24.0, vertical: 20.0), // Padding do conteúdo aumentado
      actionsPadding: const EdgeInsets.fromLTRB(
          24.0, 10.0, 24.0, 24.0), // Padding das ações aumentado
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12.0)), // Bordas mais arredondadas
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Novo Projeto',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            splashRadius: 20,
            padding: EdgeInsets.zero, // Remove padding extra do IconButton
            constraints: BoxConstraints(), // Remove constraints extras
          ),
        ],
      ),
      content: SizedBox(
        width: 800,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: 800, minWidth: 300), // Largura mínima e máxima
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildFormFieldTitle("Cliente"),
                  DropdownSearch<Cliente>(
                    key: _clienteDropdown,
                    compareFn: (item, selectedItem) =>
                        item.id == selectedItem.id,
                    onChanged: (value) async {
                      if (value?.id == -1) {
                        // Item fictício clicado: abrir diálogo de cadastro
                        final novoCliente = await showDialog<Cliente>(
                          context: context,
                          builder: (BuildContext context) =>
                              AddEditClientDialog(),
                        );

                        if (novoCliente != null) {
                          setState(() {
                            _selectedCliente = novoCliente;
                          });
                        }
                      } else {
                        setState(() {
                          _selectedCliente = value;
                        });
                      }
                    },
                    selectedItem: _selectedCliente,
                    itemAsString: (item) => item.nome,
                    popupProps: PopupProps.menu(
                      searchDelay: Duration.zero,
                      title: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Selecione um Cliente',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                                onPressed: () async => await showDialog(
                                            context: context,
                                            builder: (builder) =>
                                                AddEditClientDialog())
                                        .then((onValue) {
                                      _clienteDropdown.currentState
                                          ?.closeDropDownSearch() ;
                                    }),
                                child: Text('Adicionar Cliente'))
                          ],
                        ),
                      ),
                      showSearchBox: true,
                      searchFieldProps: const TextFieldProps(
                        cursorColor: Colors.blue,
                        decoration: InputDecoration(
                          labelText: 'Buscar Cliente',
                          hintText: 'Digite o nome do cliente...',
                        ),
                      ),
                    ),
                    items: (filter, loadProps) async {
                      List<Cliente> clientes = [];
                      String? token =
                          await FirebaseAuth.instance.currentUser?.getIdToken();
                      if (token == null) return [];

                      final response = await getClienteService(token: token);
                      if (response != null && response.statusCode == 200) {
                        for (var element in response.data) {
                          clientes.add(Cliente.fromJson(element));
                        }
                      }

                      // Adiciona o botão como último "cliente fictício"

                      return clientes;
                    },
                  ),

                  SizedBox(height: _spacerHeightMedium),
                  _buildFormFieldTitle("Categoria"),
                  DropdownSearch<CategoriaServico>(
                    compareFn: (item, selectedItem) =>
                        item.nome ==
                        selectedItem.nome, // Or item.nome == selectedItem.nome

                    onChanged: (value) {
                      _categoriaSelecionada = value;
                      setState(() {
                        _tiposServicoFiltrados =
                            _categoriaSelecionada!.tiposServicos;
                      });
                    },
                    selectedItem: _categoriaSelecionada,
                    itemAsString: (item) => item.nome,
                    items: (filter, loadProps) async {
                      List<CategoriaServico> categorias = [];
                      String? token =
                          await FirebaseAuth.instance.currentUser!.getIdToken();
                      await getCategoriasService(token: token ?? '')
                          .then((onValue) {
                        if (onValue != null && onValue.statusCode == 200) {
                          for (var element in onValue.data) {
                            categorias.add(CategoriaServico.fromJson(element));
                          }
                        }
                      });
                      return categorias;
                    },
                  ),

                  const SizedBox(height: 16),

                  // --- Dropdown de Tipo de Serviço ---
                  const Text("Tipo de Serviço",
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<Tiposervico>(
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Selecione um tipo de serviço"),
                    value: _tipoServicoSelecionado,
                    isExpanded: true,
                    disabledHint: _categoriaSelecionada == null
                        ? const Text("Selecione uma categoria primeiro")
                        : const Text("Nenhum serviço nesta categoria"),
                    items: _tiposServicoFiltrados.map((ts) {
                      return DropdownMenuItem<Tiposervico>(
                        value: ts,
                        child: Text(ts.nome, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTipoServico = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Selecione um tipo de serviço.' : null,
                  ),
                  SizedBox(height: _spacerHeightMedium),
                  _buildFormFieldTitle("Data de Início"),
                  TextFormField(
                    controller: _dataInicioController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'dd/mm/aaaa',
                        suffixIcon: Icon(Icons.calendar_today)),
                    readOnly: true,
                    onTap: () => _selecionarData(
                        context,
                        _dataInicioController,
                        _selectedDataInicio,
                        (date) => setState(() => _selectedDataInicio = date)),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Campo obrigatório.'
                        : null,
                  ),
                  SizedBox(height: _spacerHeightMedium),
                  _buildFormFieldTitle("Data de Entrega Prevista (Prazo)"),
                  TextFormField(
                    controller: _prazoController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'dd/mm/aaaa',
                        suffixIcon: Icon(Icons.calendar_today)),
                    readOnly: true,
                    onTap: () => _selecionarData(
                        context,
                        _prazoController,
                        _selectedPrazo,
                        (date) => setState(() => _selectedPrazo = date)),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Campo obrigatório.'
                        : null,
                  ),
                  _buildFormFieldTitle("Valor do Projeto (R\$)"),
                  TextFormField(
                    controller: _valorController,
                    inputFormatters: [PosInputFormatter()],
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Digite o valor do projeto"),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Campo obrigatório.'
                        : null,
                  ),
                  SizedBox(height: _spacerHeightMedium),
                  _buildFormFieldTitle("Status Inicial"),
                  DropdownSearch<EtapaProjeto>(
                    compareFn: (item, selectedItem) =>
                        item.nome ==
                        selectedItem.nome, // Or item.nome == selectedItem.nome

                    onChanged: (value) {
                      _selectedEtapaProjeto = value;
                    },
                    selectedItem: _selectedEtapaProjeto,
                    itemAsString: (item) => item.nome,
                    items: (filter, loadProps) async {
                      List<EtapaProjeto> categorias = [];
                      String? token =
                          await FirebaseAuth.instance.currentUser!.getIdToken();
                      await getEtapaprojetoService(token: token ?? '')
                          .then((onValue) {
                        if (onValue != null && onValue.statusCode == 200) {
                          for (var element in onValue.data) {
                            categorias.add(EtapaProjeto.fromJson(element));
                          }
                        }
                      });
                      return categorias;
                    },
                  ),

                  SizedBox(height: _spacerHeightMedium),
                  _buildFormFieldTitle("Observações"),
                  TextFormField(
                    controller: _observacoesController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Detalhes adicionais..."),
                    maxLines: 4, // Aumentei um pouco o maxLines
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.end,
      actions: <Widget>[
        OutlinedButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.of(context).pop(),
          style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                  horizontal: 24, vertical: 14), // Padding aumentado
              textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 12), // Espaçamento entre botões aumentado
        ElevatedButton(
          child: const Text('Salvar'),
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                  horizontal: 30, vertical: 14), // Padding aumentado
              textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          onPressed: _salvarProjeto,
        ),
      ],
    );
  }
}
