import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import './usuario_logado.dart';

// ✅ Defina a URL da API
const String apiUrl = 'http://localhost:5255/api';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  // 🔐 Função para realizar login
  Future<void> realizarLogin() async {
    final email = emailController.text.trim();
    final senha = senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha email e senha')),
      );
      return;
    }

    try {
      final url = Uri.parse('$apiUrl/auth/login?email=$email&senha=$senha');
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final usuario =  jsonDecode(response.body);  // Aqui retorna o usuário com o ID
        
        if (usuario != null) {
          UsuarioLogado.id = usuario['id'];
          UsuarioLogado.nome = usuario['nome'];
          UsuarioLogado.email = usuario['email'];
        };

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login realizado com sucesso')),
        );
        context.go('/meus-jogos');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email ou senha inválidos')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao conectar com a api: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.videogame_asset, size: 80, color: Colors.blue),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: senhaController,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: realizarLogin,
                    icon: const Icon(Icons.login),
                    label: const Text('Entrar'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    context.go('/cadastro');
                  },
                  child: const Text('Não tem uma conta? Cadastre-se'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
