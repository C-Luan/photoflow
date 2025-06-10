// Flutter imports:
import 'package:flutter/material.dart';
import 'package:photoflow/providers/autenticacaoprovider.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:

class DependencyInjector extends StatefulWidget {
  final Widget child;

  const DependencyInjector({
    super.key,
    required this.child,
  });

  @override
  State<DependencyInjector> createState() => _DependencyInjectorState();
}

class _DependencyInjectorState extends State<DependencyInjector> {
  DateTime now = DateTime.now();
  bool autenticado = false;
  String idFuncionario = '';
  String nome = '';
  String token = '';
  String email = '';
  String localImage = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AutenticacaoProvider>(
          create: (_) => AutenticacaoProvider(false),
        ),
      ],
      child: widget.child,
    );
  }
}
