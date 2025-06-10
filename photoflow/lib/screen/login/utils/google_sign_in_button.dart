// import 'dart:async';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// // Lógica de UI específica para a Web, importada condicionalmente
// import 'dart:html' if (dart.library.io) '' as html;
// import 'dart:ui' if (dart.library.io) '' as ui;

// import 'package:photoflow/services/loginserver/authservicefirebase.dart';

// class GoogleSignInButton extends StatefulWidget {
//   const GoogleSignInButton({super.key});

//   @override
//   State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
// }

// class _GoogleSignInButtonState extends State<GoogleSignInButton> {
//   final AuthServiceFirebase _authService = AuthServiceFirebase();
//   bool _isLoading = false;
//   StreamSubscription? _streamSubscription;

//   @override
//   void initState() {
//     super.initState();

//     // A configuração a seguir é EXCLUSIVA para a WEB
//     if (kIsWeb) {
//       // Registra a view factory para o elemento HTML que hospedará o botão do Google.
//       // O 'google-sign-in-button' é um ID único que nós criamos.
//       // ignore: undefined_prefixed_name
//       ui.platformViewRegistry.registerViewFactory(
//         'google-sign-in-button',
//         (int viewId) => html.DivElement()
//           ..id = 'google-signin-button'
//           ..style.width = '100%'
//           ..style.height = '100%',
//       );

//       // Instancia o GoogleSignIn para usar seus métodos web
//       final googleSignIn = GoogleSignIn();
      
//       // Ouve o stream `onCurrentUserChanged`. O Google emite um evento neste stream
//       // quando o usuário clica no botão renderizado e completa o login.
//       _streamSubscription =
//           googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) async {
//         if (account != null) {
//           // Se o login com Google foi bem-sucedido, mostra o loading e chama o serviço
//           setState(() => _isLoading = true);
//           await _authService.signInWithGoogleWeb(account);
//           // Não é necessário mudar o estado de _isLoading para false aqui,
//           // pois o `authStateChanges` principal irá reconstruir a árvore de widgets.
//         }
//       }, onError: (error) {
//         print("Erro no stream do Google Sign In: $error");
//         if(mounted) {
//            setState(() => _isLoading = false);
//         }
//       });
      
//       // Dispara a renderização do botão oficial do Google.
//       // Ele procurará um elemento com o ID 'google-signin-button' e se desenhará dentro dele.
//       googleSignIn.renderButton();
//     }
//   }

//   @override
//   void dispose() {
//     // Cancela a inscrição no stream para evitar memory leaks quando o widget for destruído.
//     _streamSubscription?.cancel();
//     super.dispose();
//   }
  
//   // Função para lidar com o clique no botão para plataformas mobile
//   Future<void> _handleMobileSignIn() async {
//     try {
//       setState(() => _isLoading = true);
//       await _authService.signInWithGoogleMobile();
//       // O `authStateChanges` cuidará da navegação.
//     } catch (error) {
//        print("Erro no clique de login mobile: $error");
//        if(mounted){
//          setState(() => _isLoading = false);
//        }
//     }
//     // Não precisa de um `setState` para false aqui se o login for bem-sucedido,
//     // pois a tela será trocada. Mas é uma boa prática em caso de falha.
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Se estiver em processo de autenticação, mostra um indicador de carregamento
//     if (_isLoading) {
//       return const Center(
//         child: CircularProgressIndicator(),
//       );
//     }
    
//     // Usa a constante kIsWeb para decidir qual botão renderizar
//     if (kIsWeb) {
//       // Na WEB, nós fornecemos um espaço em branco onde o Google irá desenhar seu botão.
//       return SizedBox(
//         height: 50, // Altura padrão para o botão do Google
//         width: 230, // Largura para caber o texto padrão
//         child: HtmlElementView(
//           viewType: 'google-sign-in-button',
//           onPlatformViewCreated: (int id) {
//              // A renderização já foi chamada no initState
//           },
//         ),
//       );
//     } else {
//       // No MOBILE, nós criamos nosso próprio botão estilizado.
//       return OutlinedButton.icon(
//         icon: Image.asset(
//           'assets/images/google_logo.png', // IMPORTANTE: Adicione o logo do Google aos seus assets
//           height: 24.0,
//         ),
//         label: const Text(
//           'Entrar com o Google',
//           style: TextStyle(fontSize: 16),
//         ),
//         onPressed: _handleMobileSignIn,
//         style: OutlinedButton.styleFrom(
//           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8.0),
//           ),
//         ),
//       );
//     }
//   }
// }