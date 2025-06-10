// File: lib/panels/dialogs/novo_agendamento_dialog.dart

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:photoflow/models/agendamento/agendamento.dart';
import 'package:photoflow/models/tiposervico/categoria.dart';
import 'package:photoflow/models/tiposervico/tiposervico.dart';

class NovoAgendamentoDialog extends StatefulWidget {
  final List<CategoriaServico> categorias;
  final List<Tiposervico> todosTiposServico;
  final Function(Agendamento) onSave;
  final DateTime initialDate;

  const NovoAgendamentoDialog({
    super.key,
    required this.categorias,
    required this.todosTiposServico,
    required this.onSave,
    required this.initialDate,
  });

  @override
  State<NovoAgendamentoDialog> createState() => _NovoAgendamentoDialogState();
}

class _NovoAgendamentoDialogState extends State<NovoAgendamentoDialog> {
  // Chave do formulário para validação
  final _formKey = GlobalKey<FormState>();

  // Controladores para os campos de texto
  final _nomeClienteController = TextEditingController();
  final _dataController = TextEditingController();
  final _horaController = TextEditingController();
  final _valorController = TextEditingController();
  final _observacoesController = TextEditingController();

  // Estado para os dropdowns e seletores
  CategoriaServico? _categoriaSelecionada;
  Tiposervico? _tipoServicoSelecionado;
  List<Tiposervico> _tiposServicoFiltrados = [];

  // Estado para os valores de data e hora
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    // Define a data inicial com base no que foi passado para o widget
    _selectedDate = widget.initialDate;
    _dataController.text =
        DateFormat('dd/MM/yyyy', 'pt_BR').format(_selectedDate!);
  }

  @override
  void dispose() {
    // Limpa os controladores para evitar vazamentos de memória
    _nomeClienteController.dispose();
    _dataController.dispose();
    _horaController.dispose();
    _valorController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  // Função para lidar com a mudança de categoria
  void _onCategoriaChanged(CategoriaServico? newValue) {
    setState(() {
      _categoriaSelecionada = newValue;
      _tipoServicoSelecionado = null; // Reseta o tipo de serviço
      _tiposServicoFiltrados.clear();
      if (newValue != null) {
        // Filtra a lista de serviços com base na categoria selecionada
        _tiposServicoFiltrados = _categoriaSelecionada!.tiposServicos;
      }
    });
  }

  // Função para abrir o seletor de data
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dataController.text = DateFormat('dd/MM/yyyy', 'pt_BR').format(picked);
      });
    }
  }

  // Função para abrir o seletor de hora
  Future<void> _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: _selectedTime ?? TimeOfDay.now(),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        });

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _horaController.text = picked.format(context);
      });
    }
  }

  // Função para validar e salvar o formulário
  void _saveForm() {
    // Verifica se o formulário é válido
    if (_formKey.currentState?.validate() ?? false) {
      // Combina a data e a hora selecionadas em um único objeto DateTime
      final DateTime dataHoraFinal = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // Cria o novo objeto Agendamento
      final novoAgendamento = Agendamento(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // ID temporário
        nome: _nomeClienteController.text,
        email: '', // TODO: Adicionar campo de email se necessário
        telefone: '', // TODO: Adicionar campo de telefone se necessário
        data: dataHoraFinal,
        servico: _tipoServicoSelecionado!.nome,
        // Você pode querer salvar mais detalhes no seu modelo, como:
        // categoria: _categoriaSelecionada!.nome,
        // valor: double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0.0,
        // observacoes: _observacoesController.text,
      );

      // Chama o callback onSave para passar o novo agendamento de volta
      widget.onSave(novoAgendamento);

      // Fecha o diálogo
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Novo Agendamento'),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            splashRadius: 20,
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // --- Campo Nome do Cliente ---
              const Text("Nome do Cliente",
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              TextFormField(
                controller: _nomeClienteController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), hintText: "Nome completo"),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nome é obrigatório.' : null,
              ),
              const SizedBox(height: 16),

              // --- Campos Data e Hora ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Data",
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _dataController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'dd/mm/aaaa',
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          onTap: _pickDate,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Data é obrigatória.'
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Hora",
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        TextFormField(
                          controller: _horaController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '--:--',
                            suffixIcon: Icon(Icons.access_time),
                          ),
                          readOnly: true,
                          onTap: _pickTime,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Hora é obrigatória.'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- Dropdown de Categoria ---
              const Text("Categoria",
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              DropdownButtonFormField<CategoriaServico>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Selecione uma categoria",
                ),
                value: _categoriaSelecionada,
                isExpanded: true,
                items: widget.categorias.map((cat) {
                  return DropdownMenuItem<CategoriaServico>(
                    value: cat,
                    child: Text(cat.nome, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: _onCategoriaChanged,
                validator: (value) =>
                    value == null ? 'Selecione uma categoria.' : null,
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
                onChanged: _tiposServicoFiltrados.isEmpty
                    ? null
                    : (newValue) =>
                        setState(() => _tipoServicoSelecionado = newValue),
                validator: (value) =>
                    value == null ? 'Selecione um tipo de serviço.' : null,
              ),
              const SizedBox(height: 16),

              // --- Campo Valor (Opcional) ---
              const Text("Valor (R\$)",
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              TextFormField(
                  controller: _valorController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: "0,00"),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v != null &&
                        v.isNotEmpty &&
                        num.tryParse(v.replaceAll(',', '.')) == null) {
                      return 'Valor inválido.';
                    }
                    return null;
                  }),
              const SizedBox(height: 16),

              // --- Campo Observações (Opcional) ---
              const Text("Observações",
                  style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              TextFormField(
                controller: _observacoesController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Detalhes adicionais...",
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: _saveForm,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
