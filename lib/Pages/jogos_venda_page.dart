import 'package:flutter/material.dart';

class JogosVendaPage extends StatelessWidget {
  const JogosVendaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jogos à Venda'),
      ),
      body: Center(
        child: const Text('Aqui você verá todos os jogos anunciados.'),
      ),
    );
  }
}
