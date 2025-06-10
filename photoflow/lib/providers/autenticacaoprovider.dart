import 'package:flutter/material.dart';

class AutenticacaoProvider extends ChangeNotifier {
  bool _conectado;
  
  AutenticacaoProvider(this._conectado);

  bool get autenticado => _conectado;

  void setAutenticado(bool autenticado) {
    _conectado = autenticado;
    notifyListeners(); // Notifica quem estiver ouvindo
    _debug();
  }

  void _debug() {
    debugPrint('Usuário conectado: $_conectado');
  }
}
