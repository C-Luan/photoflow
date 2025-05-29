// import 'dart:convert';

// import 'package:flutter/material.dart';


// class WhatsappConnectionPage extends StatefulWidget {
//   const WhatsappConnectionPage({super.key, required this.sessionNumber});
//   final String sessionNumber;
//   @override
//   State<WhatsappConnectionPage> createState() => _WhatsappConnectionPageState();
// }

// class _WhatsappConnectionPageState extends State<WhatsappConnectionPage> {
//   final WhatsappSocketIOService _ws = WhatsappSocketIOService();
//   late String sessionNumber; // número ou ID da sessão

//   String? qrBase64;
//   String status = 'Verificando conexão...';

//   @override
//   void initState() {
//     sessionNumber = widget.sessionNumber;
//     super.initState();
//     _initializeSocketIO();

//     final user = context.read<UserProvider>();
//     _checkSessionStatus(user.token);
//   }

//   Future<void> _checkSessionStatus(String token) async {
//     final url = 'http://localhost:3000/whatsapp/$sessionNumber/status';

//     try {
//       final response = await Dio().get(
//         url,
//         options: Options(headers: {
//           "Content-Type": "application/json",
//           'authorization': "Bearer $token"
//         }),
//       );

//       if (!mounted) return;

//       final statusServer = response.data['status'];
//       setState(() {
//         status = 'Status atual: $statusServer';
//       });

//       if (statusServer == 'conectado') {
//         _sendTestMessage(token);
//       }
//     } catch (e) {
//       setState(() {
//         status = 'Erro ao consultar status: $e';
//       });
//     }
//   }

//   Future<void> _sendTestMessage(String token) async {
//     final url = 'http://localhost:3000/whatsapp/$sessionNumber/send';

//     try {
//       final response = await Dio().post(
//         url,
//         data: {
//           "to": sessionNumber,
//           "message": "✅ WhatsApp já está conectado! (Mensagem de teste)"
//         },
//         options: Options(headers: {
//           "Content-Type": "application/json",
//           'authorization': "Bearer $token"
//         }),
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           status = 'Mensagem de teste enviada com sucesso.';
//         });
//       } else {
//         setState(() {
//           status = 'Falha ao enviar mensagem de teste.';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         status = 'Erro ao enviar mensagem: $e';
//       });
//     }
//   }

//   Future<void> _startSession(String token, String usuario) async {
//     final url = 'http://localhost:3000/whatsapp/$sessionNumber/connect';

//     setState(() {
//       status = 'Iniciando sessão via API...';
//     });

//     try {
//       final response = await Dio().post(
//         url,
//         data: {'usuarioUuid': usuario},
//         options: Options(headers: {
//           "Content-Type": "application/json",
//           'authorization': "Bearer $token"
//         }),
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           status = 'Sessão iniciada. Conectando socket...';
//         });
//         _initializeSocketIO();
//       } else {
//         setState(() {
//           status = 'Erro ao iniciar sessão: ${response.statusCode}';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         status = 'Erro ao iniciar sessão: $e';
//       });
//     }
//   }

//   void _initializeSocketIO() {
//     _ws.onQr = (qr) {
//       if (!mounted) return;
//       setState(() {
//         qrBase64 = qr;
//         status = '📲 Escaneie o QR Code no WhatsApp';
//       });
//     };

//     _ws.onReady = () {
//       if (!mounted) return;
//       setState(() {
//         status = '✅ WhatsApp está pronto!';
//         qrBase64 = null;
//       });
//     };

//     _ws.onAuthenticated = () {
//       if (!mounted) return;
//       setState(() {
//         status = '🔐 WhatsApp autenticado!';
//       });
//     };

//     _ws.onMessage = (msg) {
//       print('📩 Nova mensagem: $msg');
//     };

//     _ws.onError = (error) {
//       if (!mounted) return;
//       setState(() {
//         status = '❌ Erro: $error';
//       });
//     };

//     _ws.connect(sessionNumber);

//     if (!mounted) return;
//     setState(() {
//       status = '🔄 Conectando socket...';
//     });
//   }

//   Widget _buildQrImage() {
//     if (qrBase64 == null) {
//       return const Text('Aguardando QR Code...');
//     }

//     try {
//       final cleanedBase64 = qrBase64!.split(',').last;
//       final bytes = base64Decode(cleanedBase64);
//       return Image.memory(bytes, width: 300);
//     } catch (e) {
//       return Text('Erro ao carregar QR Code: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _ws.onQr = null;
//     _ws.onReady = null;
//     _ws.onAuthenticated = null;
//     _ws.onMessage = null;
//     _ws.onError = null;
//     _ws.disconnect();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     var user = context.read<UserProvider>();
//     return Dialog(
//       insetPadding: const EdgeInsets.all(20),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(status, style: const TextStyle(fontSize: 20)),
//             const SizedBox(height: 24),
//             _buildQrImage(),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: () {
//                 _ws.disconnect();
//                 _initializeSocketIO();
//               },
//               child: const Text('🔄 Reconectar Socket'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 _startSession(user.token, user.uuid);
//               },
//               child: const Text('▶️ Iniciar Sessão'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
