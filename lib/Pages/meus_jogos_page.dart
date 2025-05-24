import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'usuario_logado.dart';
import 'cadastro_jogo.dart';

const String apiUrl = 'http://localhost:5255/api';

class MeusJogosPage extends StatefulWidget {
  const MeusJogosPage({super.key});

  @override
  State<MeusJogosPage> createState() => _MeusJogosPageState();
}

class _MeusJogosPageState extends State<MeusJogosPage> {
  List<dynamic> jogos = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregarJogos();
  }

  Future<void> carregarJogos() async {
    setState(() => carregando = true);
    try {
      final url = Uri.parse('$apiUrl/jogos/usuario/${UsuarioLogado.id}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          jogos = jsonDecode(response.body);
          carregando = false;
        });
      } else {
        throw Exception('Erro ao carregar jogos');
      }
    } catch (e) {
      setState(() => carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Jogos à Venda'),
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : jogos.isEmpty
              ? const Center(child: Text('Nenhum jogo cadastrado.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: jogos.length,
                  itemBuilder: (context, index) {
                    final jogo = jogos[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: jogo['imagemUrl'] != null &&
                                      jogo['imagemUrl'].toString().isNotEmpty
                                  ? Image.network(
                                      jogo['imagemUrl'],
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => 
                                        Container(
                                          width: 100,
                                          height: 100,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.image, size: 40),
                                        ),
                                    )
                                  : Container(
                                      width: 100,
                                      height: 100,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image, size: 40),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    jogo['titulo'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    jogo['descricao'] ?? '',
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Chip(
                                        label: Text(
                                          jogo['estado'] ?? 'Indefinido',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        backgroundColor: Colors.blueAccent,
                                      ),
                                      Text(
                                        'R\$ ${jogo['preco'].toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CadastroJogoPage()),
          );
          carregarJogos(); // Atualiza a lista após cadastrar
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
