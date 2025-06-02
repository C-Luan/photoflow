import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:photoflow/screen/home/home_screen.dart';
import 'package:photoflow/screen/login/login_screen.dart';
import 'package:photoflow/screen/novo_usuario/sign_up_screen.dart';
import 'package:photoflow/style/themedata.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final ThemeData light = lightTheme();

    return MaterialApp(
      title: 'Flutter Demo',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('pt', 'BR'), // Português do Brasil
        // Adicione outros locales que seu app suportará aqui, se houver
        // const Locale('en', 'US'), // Inglês, por exemplo
      ],
      locale: Locale('pt', 'BR'),
      theme: light, // Tema claro como padrão
      // darkTheme: darkTheme, // Tema escuro
      themeMode: ThemeMode
          .system, // Ou ThemeMode.light, ThemeMode.dark, ou controle com um provider
      home: MainScreen(),
    );
  }
}
