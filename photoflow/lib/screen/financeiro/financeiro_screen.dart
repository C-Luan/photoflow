// Flutter imports:
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatação de números e datas

// TODO: Considere importar um pacote de gráficos como fl_chart ou charts_flutter
// import 'package:fl_chart/fl_chart.dart';

// --- PLACEHOLDER MODELS (Defina-os corretamente em seus arquivos de modelo) ---
enum TipoTransacao { receita, despesa }

class CategoriaTransacao {
  final String id;
  final String nome;
  final TipoTransacao tipo; // Para saber se é categoria de receita ou despesa

  CategoriaTransacao({required this.id, required this.nome, required this.tipo});
}

class Transacao {
  final String id;
  final TipoTransacao tipo;
  final String descricao;
  final double valor;
  final DateTime data;
  final String parcelamentoInfo; // Ex: "À vista", "Parcela 1/3"
  final CategoriaTransacao categoria;
  final String? observacao;

  Transacao({
    required this.id,
    required this.tipo,
    required this.descricao,
    required this.valor,
    required this.data,
    required this.parcelamentoInfo,
    required this.categoria,
    this.observacao,
  });
}

class ParcelaFutura {
  final String id;
  final String descricaoProjeto; // Ex: "Ensaio Casamento Silva"
  final DateTime dataVencimento;
  final String parcelaInfo; // Ex: "Parcela 2/3"
  final double valor;
  final String status; // Ex: "Pendente"

  ParcelaFutura({
    required this.id,
    required this.descricaoProjeto,
    required this.dataVencimento,
    required this.parcelaInfo,
    required this.valor,
    required this.status,
  });
}
// --- FIM DOS PLACEHOLDER MODELS ---


class FinanceiroScreen extends StatefulWidget {
  const FinanceiroScreen({super.key});

  @override
  State<FinanceiroScreen> createState() => _FinanceiroScreenState();
}

class _FinanceiroScreenState extends State<FinanceiroScreen> {
  final _formKeyNovaTransacao = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _dataTransacaoController = TextEditingController();
  
  TipoTransacao _tipoNovaTransacao = TipoTransacao.receita;
  String? _parcelamentoSelecionado;
  CategoriaTransacao? _categoriaNovaTransacaoSelecionada;
  DateTime? _dataNovaTransacao;

  // Dados Mockados (Substitua por dados reais do seu backend/provider)
  final List<String> _opcoesParcelamento = ["À vista", "2x", "3x", "4x", "5x", "6x", "10x", "12x"];
  final List<CategoriaTransacao> _categoriasReceita = [
    CategoriaTransacao(id: "serv_foto", nome: "Venda de Serviço Fotográfico", tipo: TipoTransacao.receita),
    CategoriaTransacao(id: "serv_video", nome: "Venda de Serviço de Vídeo", tipo: TipoTransacao.receita),
    CategoriaTransacao(id: "aluguel_estudio", nome: "Aluguel de Estúdio", tipo: TipoTransacao.receita),
    CategoriaTransacao(id: "cursos", nome: "Cursos e Workshops", tipo: TipoTransacao.receita),
    CategoriaTransacao(id: "outras_receitas", nome: "Outras Receitas", tipo: TipoTransacao.receita),
  ];
   final List<CategoriaTransacao> _categoriasDespesa = [
    CategoriaTransacao(id: "aluguel_local", nome: "Aluguel (Escritório/Estúdio)", tipo: TipoTransacao.despesa),
    CategoriaTransacao(id: "equip", nome: "Equipamentos e Manutenção", tipo: TipoTransacao.despesa),
    CategoriaTransacao(id: "marketing", nome: "Marketing e Publicidade", tipo: TipoTransacao.despesa),
    CategoriaTransacao(id: "transporte", nome: "Transporte e Combustível", tipo: TipoTransacao.despesa),
    CategoriaTransacao(id: "impostos", nome: "Impostos e Taxas", tipo: TipoTransacao.despesa),
    CategoriaTransacao(id: "software", nome: "Software e Assinaturas", tipo: TipoTransacao.despesa),
    CategoriaTransacao(id: "outras_despesas", nome: "Outras Despesas", tipo: TipoTransacao.despesa),
  ];

  List<CategoriaTransacao> get _categoriasDisponiveisParaForm => 
    _tipoNovaTransacao == TipoTransacao.receita ? _categoriasReceita : _categoriasDespesa;

  List<Transacao> _transacoesRecentes = [];
  List<ParcelaFutura> _parcelasFuturas = [];

  String _fluxoCaixaPeriodo = "Mês"; // Mês, Trimestre, Ano

  @override
  void initState() {
    super.initState();
    _loadDadosFinanceiros();
    // Inicializa o campo de data da transação com a data atual
    _dataNovaTransacao = DateTime.now();
    _dataTransacaoController.text = DateFormat('dd/MM/yyyy').format(_dataNovaTransacao!);
  }

  void _loadDadosFinanceiros() {
    // TODO: Carregar dados reais
    setState(() {
      _transacoesRecentes = [
        Transacao(id: "1", tipo: TipoTransacao.receita, descricao: "Ensaio Casamento Silva", valor: 2500.00, data: DateTime(2025, 9, 15), parcelamentoInfo: "Parcela 1/3", categoria: _categoriasReceita.first),
        Transacao(id: "2", tipo: TipoTransacao.despesa, descricao: "Aluguel do Estúdio", valor: 1800.00, data: DateTime(2025, 9, 9), parcelamentoInfo: "Mensal", categoria: _categoriasDespesa.firstWhere((c) => c.id == 'aluguel_local')),
        Transacao(id: "3", tipo: TipoTransacao.receita, descricao: "Book Formatura Ana", valor: 1200.00, data: DateTime(2025, 9, 9), parcelamentoInfo: "À vista", categoria: _categoriasReceita.first),
        Transacao(id: "4", tipo: TipoTransacao.despesa, descricao: "Equipamento - Lente 50mm", valor: 850.00, data: DateTime(2025, 9, 8), parcelamentoInfo: "Parcela 2/5", categoria: _categoriasDespesa.firstWhere((c) => c.id == 'equip')),
        Transacao(id: "5", tipo: TipoTransacao.receita, descricao: "Ensaio Família Oliveira", valor: 800.00, data: DateTime(2025, 9, 1), parcelamentoInfo: "À vista", categoria: _categoriasReceita.first),
      ];
      _parcelasFuturas = [
        ParcelaFutura(id: "p1", descricaoProjeto: "Ensaio Casamento Silva", dataVencimento: DateTime(2025,10,16), parcelaInfo: "Parcela 2/3", valor: 2500.00, status: "Pendente"),
        ParcelaFutura(id: "p2", descricaoProjeto: "Equipamento - Lente 50mm", dataVencimento: DateTime(2025,10,10), parcelaInfo: "Parcela 3/5", valor: 850.00, status: "Pendente"),
        ParcelaFutura(id: "p3", descricaoProjeto: "Ensaio Casamento Silva", dataVencimento: DateTime(2025,11,16), parcelaInfo: "Parcela 3/3", valor: 2500.00, status: "Pendente"),
      ];
    });
  }
  
  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    _dataTransacaoController.dispose();
    super.dispose();
  }

  Widget _buildFinanceSummaryCard({
    required String title,
    required double value,
    required double percentageChange,
    required IconData icon,
    required Color color,
  }) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    bool isPositive = percentageChange >= 0;
    return Expanded(
      child: Card(
        elevation: 1.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                  Icon(icon, size: 20, color: color),
                ],
              ),
              const SizedBox(height: 8),
              Text(currencyFormat.format(value), style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 4),
              Text(
                "${isPositive ? '+' : ''}${percentageChange.toStringAsFixed(0)}% em relação ao mês anterior",
                style: TextStyle(fontSize: 12, color: isPositive ? Colors.green.shade700 : Colors.red.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCashFlowChartPlaceholder() {
    // TODO: Integrar um pacote de gráficos aqui (ex: fl_chart)
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_rounded, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text("Gráfico de Fluxo de Caixa (Placeholder)", style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text("Jan | Fev | Mar | Abr | Mai | Jun | Jul | Ago | Set", style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionListItem(Transacao transacao) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: ''); // Sem símbolo aqui, pois já tem +/-
    bool isReceita = transacao.tipo == TipoTransacao.receita;
    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.only(bottom: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (isReceita ? Colors.green : Colors.red).withOpacity(0.1),
          child: Icon(isReceita ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, 
                      color: isReceita ? Colors.green.shade700 : Colors.red.shade700, size: 20),
        ),
        title: Text(transacao.descricao, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        subtitle: Text(DateFormat('dd/MM/yyyy').format(transacao.data), style: TextStyle(fontSize: 12)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${isReceita ? '+' : '-'} R\$ ${currencyFormat.format(transacao.valor)}",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isReceita ? Colors.green.shade700 : Colors.red.shade700),
            ),
            Text(transacao.parcelamentoInfo, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
        onTap: () { /* TODO: Ver detalhes da transação */ },
      ),
    );
  }

  Widget _buildInstallmentListItem(ParcelaFutura parcela) {
     final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
     return Card(
      elevation: 0.5,
      margin: const EdgeInsets.only(bottom: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(parcela.descricaoProjeto, style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                  Text("Vencimento: ${DateFormat('dd/MM/yyyy').format(parcela.dataVencimento)}", style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  Text(parcela.parcelaInfo, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(currencyFormat.format(parcela.valor), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).primaryColorDark)),
                Chip(
                  label: Text(parcela.status, style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.orange.shade400,
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  visualDensity: VisualDensity.compact,
                )
              ],
            )
          ],
        ),
      ),
     );
  }

  Widget _buildNewTransactionForm() {
    return Form(
      key: _formKeyNovaTransacao,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
           Text("Nova Transação", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
           const SizedBox(height: 16),
           Text("Tipo", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
           Row(
             children: [
               Expanded(child: RadioListTile<TipoTransacao>(title: Text("Receita"), value: TipoTransacao.receita, groupValue: _tipoNovaTransacao, dense:true, onChanged: (val) => setState(() { _tipoNovaTransacao = val!; _categoriaNovaTransacaoSelecionada = null; }))),
               Expanded(child: RadioListTile<TipoTransacao>(title: Text("Despesa"), value: TipoTransacao.despesa, groupValue: _tipoNovaTransacao, dense:true, onChanged: (val) => setState(() { _tipoNovaTransacao = val!; _categoriaNovaTransacaoSelecionada = null; }))),
             ],
           ),
           const SizedBox(height: 12),
           TextFormField(controller: _descricaoController, decoration: InputDecoration(labelText: "Descrição", hintText: "Ex: Ensaio fotográfico", border: OutlineInputBorder()), validator: (v) => v == null || v.isEmpty ? "Descrição é obrigatória" : null),
           const SizedBox(height: 12),
           TextFormField(controller: _valorController, decoration: InputDecoration(labelText: "Valor (R\$)", hintText: "0,00", border: OutlineInputBorder()), keyboardType: TextInputType.numberWithOptions(decimal: true), validator: (v) { if(v==null || v.isEmpty) return "Valor é obrigatório"; if(double.tryParse(v.replaceAll(',', '.')) == null) return "Valor inválido"; return null;}),
           const SizedBox(height: 12),
           TextFormField(
            controller: _dataTransacaoController,
            decoration: InputDecoration(labelText: "Data", border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
            readOnly: true,
            onTap: () async {
              DateTime? picked = await showDatePicker(context: context, initialDate: _dataNovaTransacao ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2101), locale: Locale('pt', 'BR'));
              if (picked != null) { setState(() { _dataNovaTransacao = picked; _dataTransacaoController.text = DateFormat('dd/MM/yyyy').format(picked); }); }
            },
            validator: (v) => v == null || v.isEmpty ? "Data é obrigatória" : null,
           ),
           const SizedBox(height: 12),
           DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: "Parcelamento", border: OutlineInputBorder()),
            value: _parcelamentoSelecionado,
            hint: Text("Selecione"),
            items: _opcoesParcelamento.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
            onChanged: (val) => setState(() => _parcelamentoSelecionado = val),
            validator: (v) => v == null ? "Selecione o parcelamento" : null,
           ),
           const SizedBox(height: 12),
           DropdownButtonFormField<CategoriaTransacao>(
            decoration: InputDecoration(labelText: "Categoria", border: OutlineInputBorder()),
            value: _categoriaNovaTransacaoSelecionada,
            hint: Text("Selecione uma categoria"),
            isExpanded: true,
            items: _categoriasDisponiveisParaForm.map((cat) => DropdownMenuItem(value: cat, child: Text(cat.nome, overflow: TextOverflow.ellipsis))).toList(),
            onChanged: (val) => setState(() => _categoriaNovaTransacaoSelecionada = val),
            validator: (v) => v == null ? "Selecione uma categoria" : null,
           ),
           const SizedBox(height: 20),
           SizedBox(
             width: double.infinity,
             child: ElevatedButton.icon(
                icon: Icon(Icons.add_circle_outline),
                label: Text("Adicionar Transação"),
                style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 12)),
                onPressed: () {
                  if(_formKeyNovaTransacao.currentState!.validate()){
                    // TODO: Lógica para salvar a transação
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Transação adicionada (simulação)")));
                    // Limpar form
                    _descricaoController.clear();_valorController.clear(); 
                    setState(() { _parcelamentoSelecionado = null; _categoriaNovaTransacaoSelecionada = null; });
                  }
                },
             ),
           )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    // Mock data para resumo - TODO: calcular com base nas transações
    double faturamentoTotal = 12580.00;
    double despesasTotais = 7320.00;
    double saldo = faturamentoTotal - despesasTotais;

    return Scaffold( // Adiciona Scaffold para um fundo e estrutura de tela mais comum
      // appBar: AppBar(title: Text("Painel Financeiro"), elevation: 0), // Opcional: AppBar se esta tela for standalone
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isDesktop = constraints.maxWidth > 900; // Breakpoint para layout de duas colunas

          Widget leftPane = SingleChildScrollView( // Conteúdo principal à esquerda
            padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Linha de Resumo Financeiro
                Row(children: [
                  _buildFinanceSummaryCard(title: "Receitas Totais", value: faturamentoTotal, percentageChange: 15, icon: Icons.attach_money, color: Colors.green.shade600),
                  const SizedBox(width: 16),
                  _buildFinanceSummaryCard(title: "Despesas Totais", value: despesasTotais, percentageChange: -3, icon: Icons.money_off, color: Colors.red.shade600),
                  if (isDesktop) ...[ // Saldo só aparece ao lado em desktop
                    const SizedBox(width: 16),
                    _buildFinanceSummaryCard(title: "Saldo", value: saldo, percentageChange: 32, icon: Icons.account_balance_wallet_outlined, color: Colors.blue.shade700),
                  ]
                ]),
                if (!isDesktop) ...[ // Saldo abaixo em mobile
                   const SizedBox(height: 16),
                  Row(children: [_buildFinanceSummaryCard(title: "Saldo", value: saldo, percentageChange: 32, icon: Icons.account_balance_wallet_outlined, color: Colors.blue.shade700)])
                ],
                const SizedBox(height: 24),

                // Fluxo de Caixa
                Text("Fluxo de Caixa", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: ["Mês", "Trimestre", "Ano"].map((periodo) => 
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: ActionChip(
                        label: Text(periodo, style: TextStyle(fontSize: 12, color: _fluxoCaixaPeriodo == periodo ? Colors.white : Theme.of(context).primaryColor)),
                        backgroundColor: _fluxoCaixaPeriodo == periodo ? Theme.of(context).primaryColor : Colors.grey.shade200,
                        onPressed: () => setState(() => _fluxoCaixaPeriodo = periodo),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                  ).toList(),
                ),
                const SizedBox(height: 8),
                _buildCashFlowChartPlaceholder(),
                const SizedBox(height: 24),

                // Transações Recentes
                Text("Transações Recentes", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                // TODO: Adicionar filtro para transações (Todos, Receitas, Despesas)
                const SizedBox(height: 8),
                _transacoesRecentes.isEmpty
                  ? Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 30), child: Text("Nenhuma transação recente.", style: TextStyle(color: Colors.grey.shade600))))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _transacoesRecentes.length > 5 ? 5 : _transacoesRecentes.length, // Limita a 5 por exemplo
                      itemBuilder: (context, index) => _buildTransactionListItem(_transacoesRecentes[index]),
                    ),
              ],
            ),
          );

          Widget rightPane = Container( // Painel Lateral Direito
            width: isDesktop ? (constraints.maxWidth * 0.35 < 380 ? 380 : constraints.maxWidth * 0.35) : double.infinity, // Largura fixa ou % da tela
            height: isDesktop ? constraints.maxHeight : null, // Altura total em desktop
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0).copyWith(top: isDesktop ? 24 : 0), // Ajusta padding superior
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNewTransactionForm(),
                  const SizedBox(height: 24),
                  Text("Parcelas Futuras", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  _parcelasFuturas.isEmpty
                    ? Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 30), child: Text("Nenhuma parcela futura.", style: TextStyle(color: Colors.grey.shade600))))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _parcelasFuturas.length,
                        itemBuilder: (context, index) => _buildInstallmentListItem(_parcelasFuturas[index]),
                      ),
                ],
              ),
            ),
          );

          if (isDesktop) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 65, child: leftPane), // Ajuste o flex conforme necessário
                VerticalDivider(width: 1, thickness: 1, color: Colors.grey.shade300),
                ConstrainedBox( // Garante que o painel direito não seja muito estreito ou muito largo
                  constraints: BoxConstraints(minWidth: 350, maxWidth: 450),
                  child: rightPane
                ),
              ],
            );
          } else { // Mobile: Empilha tudo
            return SingleChildScrollView( // Garante rolagem se o conteúdo do rightPane for grande no mobile
              child: Column(children: [leftPane, Divider(height: 30), rightPane]),
            );
          }
        },
      ),
    );
  }
}