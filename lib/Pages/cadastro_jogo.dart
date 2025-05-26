import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './usuario_logado.dart';

// ✅ URL da sua API
const String apiUrl = 'http://localhost:5255/api';

class CadastroJogoPage extends StatefulWidget {
  const CadastroJogoPage({super.key});

  @override
  State<CadastroJogoPage> createState() => _CadastroJogoPageState();
}

class _CadastroJogoPageState extends State<CadastroJogoPage> {
  final tituloController = TextEditingController();
  final descricaoController = TextEditingController();
  final imagemUrlController = TextEditingController();
  final precoController = TextEditingController();

  String estadoSelecionado = 'Usado';

  Future<void> cadastrarJogo() async {
    final titulo = tituloController.text.trim();
    final descricao = descricaoController.text.trim();
    final imagemUrl = imagemUrlController.text.trim();
    final precoText = precoController.text.trim();

    if (titulo.isEmpty || precoText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Título e Preço são obrigatórios')),
      );
      return;
    }

    final preco = double.tryParse(precoText);
    if (preco == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preço inválido')),
      );
      return;
    }

    try {
      final url = Uri.parse('$apiUrl/jogos');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id':"",
          'titulo': titulo,
          'descricao': descricao,
          'imagemUrl': imagemUrl,
          'preco': preco,
          'estado': estadoSelecionado,
          'usuarioId': UsuarioLogado.id,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jogo cadastrado com sucesso')),
        );
        Navigator.pop(context); // Voltar para a tela anterior
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao cadastrar jogo: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar Jogo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: tituloController,
              decoration: const InputDecoration(
                labelText: 'Título',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: imagemUrlController,
              decoration: const InputDecoration(
                labelText: 'URL da Imagem',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: precoController,
              decoration: const InputDecoration(
                labelText: 'Preço',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: estadoSelecionado,
              decoration: const InputDecoration(
                labelText: 'Estado do Jogo',
                border: OutlineInputBorder(),
              ),
              items: ['Novo', 'Usado', 'Lacrado'].map((estado) {
                return DropdownMenuItem(
                  value: estado,
                  child: Text(estado),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  estadoSelecionado = value!;
                });
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: cadastrarJogo,
                icon: const Icon(Icons.save),
                label: const Text('Salvar Jogo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
