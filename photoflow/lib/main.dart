import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:photoflow/dependency_injector/dependency_injector.dart';
import 'package:photoflow/firebase_options.dart';
import 'package:photoflow/screen/laddingscreen.dart';
import 'package:photoflow/style/themedata.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(DependencyInjector(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final ThemeData light = lightTheme();
    final ThemeData dark = darkTheme();
    return MaterialApp(
      title: 'Flutter Demo',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('pt', 'BR'), // Português do Brasil
      ],
      locale: Locale('pt', 'BR'),
      theme: light, // Tema claro como padrão
      darkTheme: dark, // Tema escuro
      themeMode: ThemeMode
          .system, // Ou ThemeMode.light, ThemeMode.dark, ou controle com um provider
      home: LandingScreen(),
    );
  }
}
