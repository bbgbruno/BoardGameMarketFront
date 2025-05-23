import 'package:flutter/material.dart';

class MeusJogosPage extends StatelessWidget {
  const MeusJogosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Jogos a venda'),
      ),
      body: Center(
        child: const Text('Aqui você verá seus jogos cadastrados.'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aqui depois colocamos a navegação para adicionar jogo
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
