// File: lib/panels/dialogs/novo_agendamento_dialog.dart

// Flutter imports:
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
// Package imports:
import 'package:intl/intl.dart';
import 'package:photoflow/constants/constants.dart';

// Project imports:
import 'package:photoflow/models/agendamento/agendamento.dart';
import 'package:photoflow/models/cliente/cliente.dart';
import 'package:photoflow/models/tiposervico/categoria.dart';
import 'package:photoflow/models/tiposervico/tiposervico.dart';
import 'package:photoflow/screen/cliente/dialog/addcliente_dialog.dart';
import 'package:photoflow/services/apis/agendamento/create_agendamento_service.dart';
import 'package:photoflow/services/apis/categoria/get_categorias_service.dart';
import 'package:photoflow/services/apis/clientes/readcliente.dart';
import 'package:photoflow/widgets/auxiliar_dialog.dart';

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
  String? statusSelecionado = 'PENDENTE';
  // Controladores para os campos de texto
  final _nomeClienteController = TextEditingController();
  final _dataController = TextEditingController();
  final _horaController = TextEditingController();
  final _valorController = TextEditingController();
  Cliente? _selectedCliente;
  final _clienteDropdown = GlobalKey<DropdownSearchState>();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _observacoesController = TextEditingController();
  String? horarioSelecionado;

  // Estado para os dropdowns e seletores
  CategoriaServico? _categoriaSelecionada;
  Tiposervico? _tipoServicoSelecionado;
  List<Tiposervico> _tiposServicoFiltrados = [];
  final List<String> statusList = ['PENDENTE', 'CONFIRMADO', 'CANCELADO'];

  // Estado para os valores de data e hora
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    // Define a data inicial com base no que foi passado para o widget
    _selectedDate = widget.initialDate;
    _dataController.text = DateFormat(
      'dd/MM/yyyy',
      'pt_BR',
    ).format(_selectedDate!);
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
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _horaController.text = picked.format(context);
      });
    }
  }

  // Função para validar e salvar o formulário
  Future<void> _saveForm() async {
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
        cliente: _selectedCliente!,
        email: _emailController.text,
        telefone: _telefoneController.text,
        data: dataHoraFinal,
        servico: _tipoServicoSelecionado!.id!,
        observacoes: _observacoesController.text,
      );
      await createAgendamentoService(data: novoAgendamento.toMap()).then((
        onValue,
      ) async {
        if (onValue!.statusCode == 201) {
          await mostrarDialogoCriarProjeto(context).then((onValue) {
            if (onValue != null && onValue) {
              Navigator.of(context).pop();
              // Navigator.of(context).pop(true);
              // Navigator.of(context).pushNamed(
              //   AppRoutes.CRIAR_PROJETO,
              //   arguments: novoAgendamento,
              // );
            }
          });
        }
        print(onValue!.data.toString());
      });
      // Chama o callback onSave para passar o novo agendamento de volta
      widget.onSave(novoAgendamento);

      // Fecha o diálogo
      Navigator.of(context).pop();
    }
  }

  Future<bool?> mostrarDialogoCriarProjeto(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // impede fechar clicando fora
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Agendamento criado',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Deseja criar um projeto para este agendamento?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // NÃO
              },
              child: const Text('Não'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // SIM
              },
              child: const Text('Sim'),
            ),
          ],
        );
      },
    );
  }

  List<String> gerarHorarios() {
    List<String> horarios = [];
    for (int hora = 0; hora < 24; hora++) {
      for (int minuto = 0; minuto < 60; minuto += 5) {
        final h = hora.toString().padLeft(2, '0');
        final m = minuto.toString().padLeft(2, '0');
        horarios.add("$h:$m");
      }
    }
    return horarios;
  }

  @override
  Widget build(BuildContext context) {
    final horarios = gerarHorarios();
    final screenWidth = MediaQuery.of(context).size.width;
    final panelWidth = screenWidth * 0.45 > 600 ? screenWidth * 0.6 : 600.0;

    InputDecoration deco(String label) {
      return InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      );
    }

    return FocusDialog(
      onClose: () {},
      child: Container(
        width: panelWidth,
        height: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Novo agendamento",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ─────────────── CLIENTE / DATA / STATUS ───────────────
              Row(
                spacing: 16,
                children: [
                  // CLIENTE
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Cliente",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        DropdownSearch<Cliente>(
                          key: _clienteDropdown,
                          compareFn: (a, b) => a.id == b.id,
                          selectedItem: _selectedCliente,
                          itemAsString: (i) => i.nome,
                          popupProps: PopupProps.menu(
                            showSearchBox: true,
                            searchFieldProps: const TextFieldProps(
                              decoration: InputDecoration(
                                labelText: "Buscar cliente",
                              ),
                            ),
                          ),
                          onChanged: (v) =>
                              setState(() => _selectedCliente = v),
                          items: (f, p) async {
                            final tk = await FirebaseAuth.instance.currentUser
                                ?.getIdToken();
                            if (tk == null) return [];
                            final res = await getClienteService(token: tk);
                            return res!.data
                                .map<Cliente>((e) => Cliente.fromJson(e))
                                .toList();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // DATA
                  Expanded(
                    child: TextFormField(
                      controller: _dataController,
                      readOnly: true,
                      onTap: _pickDate,
                      decoration: deco("Data").copyWith(
                        suffixIcon: const Icon(Icons.calendar_today, size: 20),
                      ),
                      validator: (v) => v!.isEmpty ? "Obrigatório" : null,
                    ),
                  ),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: statusSelecionado,
                      decoration: deco("Status"),
                      items: statusList
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => statusSelecionado = v),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // COR
                  Expanded(
                    child: TextFormField(
                      enabled: false,
                      decoration: deco("Cor").copyWith(hintText: "Padrão"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ─────────────── TÍTULO: Itens do agendamento ───────────────
              const Text(
                "Itens do agendamento",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // ─────────────── DESCRIÇÃO / PROFISSIONAL / HORÁRIO ───────────────
              Row(
                children: [
                  // DESCRIÇÃO
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Descrição",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<Tiposervico>(
                          value: _tipoServicoSelecionado,
                          isExpanded: true,
                          decoration: deco("Selecione o serviço"),
                          items: _tiposServicoFiltrados
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.nome),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _tipoServicoSelecionado = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // PROFISSIONAL
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Profissional",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<Tiposervico>(
                          value: _tipoServicoSelecionado,
                          decoration: deco("Profissional"),
                          items: _tiposServicoFiltrados
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.nome),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _tipoServicoSelecionado = v),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Horário",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: horarioSelecionado,
                          isExpanded: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            // labelText: "Horário",
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                          ),
                          items: horarios.map((h) {
                            return DropdownMenuItem(value: h, child: Text(h));
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              horarioSelecionado = value;

                              // Atualiza seu controller antigo para manter compatibilidade com a lógica existente
                              _horaController.text = value!;
                              _selectedTime = TimeOfDay(
                                hour: int.parse(value.split(':')[0]),
                                minute: int.parse(value.split(':')[1]),
                              );
                            });
                          },
                          validator: (v) => v == null || v.isEmpty
                              ? 'Selecione um horário.'
                              : null,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Duração",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: horarioSelecionado,
                          isExpanded: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            // labelText: "Duração",
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                          ),
                          items: horarios.map((h) {
                            return DropdownMenuItem(value: h, child: Text(h));
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              horarioSelecionado = value;

                              // Atualiza seu controller antigo para manter compatibilidade com a lógica existente
                              _horaController.text = value!;
                              _selectedTime = TimeOfDay(
                                hour: int.parse(value.split(':')[0]),
                                minute: int.parse(value.split(':')[1]),
                              );
                            });
                          },
                          validator: (v) => v == null || v.isEmpty
                              ? 'Selecione um horário.'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              const SizedBox(height: 32),

              // OBSERVAÇÕES
              const Text(
                "Observações",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _observacoesController,
                maxLines: 3,
                decoration: deco("Digite observações"),
              ),

              const SizedBox(height: 40),

              // BOTÕES
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancelar"),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: _saveForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Salvar"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () => null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 90, 134, 92),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Faturar"),
                    ),
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
