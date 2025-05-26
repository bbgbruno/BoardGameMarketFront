import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String apiUrl = 'http://localhost:5255/api'; // Altere se necessário

Future<bool> cadastrarUsuario(
    String nome, String email, String senha, String telefone, String cidade) async {
  final url = Uri.parse('$apiUrl/auth/register');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'id': "",
      'nome': nome,
      'email': email,
      'senhaHash': senha, // Backend espera no campo senhaHash
      'telefone': telefone,
      'cidade': cidade,
    }),
  );

  return response.statusCode == 200;
}

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final telefoneController = TextEditingController();
  final cidadeController = TextEditingController();

  void realizarCadastro() async {
    final sucesso = await cadastrarUsuario(
      nomeController.text.trim(),
      emailController.text.trim(),
      senhaController.text.trim(),
      telefoneController.text.trim(),
      cidadeController.text.trim(),
    );

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado com sucesso')),
      );
      context.go('/'); // Voltar para tela de login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao realizar cadastro')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro de Usuário')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_add, size: 80, color: Colors.blue),
                const SizedBox(height: 16),

                // Nome
                TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Email
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Senha
                TextField(
                  controller: senhaController,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),

                // Telefone
                TextField(
                  controller: telefoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefone',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Cidade
                TextField(
                  controller: cidadeController,
                  decoration: const InputDecoration(
                    labelText: 'Cidade',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                // Botão
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: realizarCadastro,
                    icon: const Icon(Icons.check),
                    label: const Text('Cadastrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
