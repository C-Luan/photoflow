import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:photoflow/providers/autenticacaoprovider.dart';
import 'package:photoflow/screen/home/home_screen.dart';
import 'package:photoflow/screen/login/login_screen.dart';
import 'package:provider/provider.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      final authProvider = Provider.of<AutenticacaoProvider>(context, listen: false);
      authProvider.setAutenticado(user != null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AutenticacaoProvider>(
      builder: (context, auth, _) {
        return auth.autenticado ? const MainScreen() : const LoginScreen();
      },
    );
  }
}
