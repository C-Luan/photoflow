import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photoflow/models/cliente/cliente.dart'; // Ajuste o caminho se necessário
import 'package:photoflow/models/projeto/etapa_projeto.dart'; // Ajuste o caminho se necessário
import 'package:photoflow/models/projeto/projeto.dart'; // Ajuste o caminho se necessário
import 'package:photoflow/models/tiposervico/categoria.dart'; // Ajuste o caminho se necessário
import 'package:photoflow/models/tiposervico/tiposervico.dart'; // Ajuste o caminho se necessário

class NovoProjetoDialog extends StatefulWidget {
  final List<Tiposervico> tiposDeServicoDisponiveis;
  final List<EtapaProjeto> etapasDeProjetoDisponiveis;

  const NovoProjetoDialog({
    super.key,
    required this.tiposDeServicoDisponiveis,
    required this.etapasDeProjetoDisponiveis,
  });

  @override
  State<NovoProjetoDialog> createState() => _NovoProjetoDialogState();
}

class _NovoProjetoDialogState extends State<NovoProjetoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeClienteController = TextEditingController();
  final _dataInicioController = TextEditingController();
  final _prazoController = TextEditingController();
  final _observacoesController = TextEditingController();

  Tiposervico? _selectedTipoServico;
  EtapaProjeto? _selectedEtapaProjeto;
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
      if (_selectedTipoServico == null ||
          _selectedDataInicio == null ||
          _selectedPrazo == null ||
          _selectedEtapaProjeto == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Por favor, preencha todos os campos obrigatórios.')),
        );
        return;
      }
      if (_selectedTipoServico!.categoria == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Erro: Categoria não encontrada para o tipo de serviço selecionado.')),
        );
        return;
      }

      final cliente = Cliente(nome: _nomeClienteController.text);
      final novoProjeto = Projeto(
        valor: 0,
        cliente: cliente,
        tipoServico: _selectedTipoServico!,
        etapaProjeto: _selectedEtapaProjeto!,
        categoriaServico: _selectedTipoServico!.categoria!,
        observacao: _observacoesController.text,
        conclusao: false,
        dataInicio: _selectedDataInicio!,
        prazo: _selectedPrazo!,
        dataFim: null,
      );
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
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: 500, minWidth: 300), // Largura mínima e máxima
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildFormFieldTitle("Nome do Cliente"),
                TextFormField(
                  controller: _nomeClienteController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Nome completo do cliente"),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Campo obrigatório.'
                      : null,
                ),
                SizedBox(height: _spacerHeightMedium),
                _buildFormFieldTitle("Tipo de Ensaio/Serviço"),
                DropdownButtonFormField<Tiposervico>(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Selecione um tipo"),
                  value: _selectedTipoServico,
                  isExpanded: true,
                  items:
                      widget.tiposDeServicoDisponiveis.map((Tiposervico tipo) {
                    return DropdownMenuItem<Tiposervico>(
                      value: tipo,
                      child: Text(tipo.nome, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (Tiposervico? newValue) {
                    setState(() {
                      _selectedTipoServico = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Campo obrigatório.' : null,
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
                SizedBox(height: _spacerHeightMedium),
                _buildFormFieldTitle("Status Inicial"),
                DropdownButtonFormField<EtapaProjeto>(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Selecione o status"),
                  value: _selectedEtapaProjeto,
                  isExpanded: true,
                  items: widget.etapasDeProjetoDisponiveis
                      .map((EtapaProjeto etapa) {
                    return DropdownMenuItem<EtapaProjeto>(
                      value: etapa,
                      child: Text(etapa.nome, overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (EtapaProjeto? newValue) {
                    setState(() {
                      _selectedEtapaProjeto = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Campo obrigatório.' : null,
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
