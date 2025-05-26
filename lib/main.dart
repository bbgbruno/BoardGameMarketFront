import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/login_page.dart';
import 'pages/cadastro_page.dart';
import 'pages/meus_jogos_page.dart';
import 'pages/jogos_venda_page.dart';
import 'pages/cadastro_jogo.dart';

void main() {
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/cadastro',
      builder: (context, state) => const CadastroPage(),
    ),
    GoRoute(
      path: '/meus-jogos',
      builder: (context, state) => const MeusJogosPage(),
    ),
    GoRoute(
      path: '/jogos-venda',
      builder: (context, state) => const JogosVendaPage(),
    ),
     GoRoute(
      path: '/cadastro-jogo',
      builder: (context, state) => const CadastroJogoPage(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      title: 'Board Game Market',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
    );
  }
}
