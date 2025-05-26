import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'usuario_logado.dart';

const String apiUrl = 'https://boardgamemarketapi.onrender.com/api';

class MeusJogosPage extends StatefulWidget {
  const MeusJogosPage({super.key});

  @override
  State<MeusJogosPage> createState() => _MeusJogosPageState();
}

class _MeusJogosPageState extends State<MeusJogosPage> {
  List<dynamic> jogos = [];
  List<dynamic> jogosFiltrados = [];
  bool isLoading = true;

  String buscaTitulo = '';

  @override
  void initState() {
    super.initState();
    carregarJogos();
  }

  Future<void> carregarJogos() async {
    try {
      final url = Uri.parse('$apiUrl/jogos/usuario/${UsuarioLogado.id}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          jogos = jsonDecode(response.body);
          jogosFiltrados = List.from(jogos);
          isLoading = false;
        });
      } else {
        throw Exception('Erro ao carregar jogos');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  Future<void> deletarJogo(String id) async {
    try {
      final url = Uri.parse('$apiUrl/jogos/$id');
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jogo excluído com sucesso')),
        );
        carregarJogos();
      } else {
        throw Exception('Erro ao excluir jogo');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  void aplicarFiltros() {
    setState(() {
      jogosFiltrados = jogos.where((jogo) {
        final titulo = (jogo['titulo'] ?? '').toString().toLowerCase();
        return titulo.contains(buscaTitulo.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Jogos à Venda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Cadastrar Jogo',
            onPressed: () async {
              await context.push('/cadastro-jogo');
              carregarJogos();
            },
          ),
          IconButton(
            icon: const Icon(Icons.storefront),
            tooltip: 'Ver Jogos à Venda',
            onPressed: () {
              context.go('/jogos-venda');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              context.go('/');
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 🔍 Filtro por título
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Buscar por nome',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      buscaTitulo = value;
                      aplicarFiltros();
                    },
                  ),
                ),

                // 🃏 Lista de jogos
                Expanded(
                  child: jogosFiltrados.isEmpty
                      ? const Center(child: Text('Nenhum jogo encontrado'))
                      : ListView.builder(
                          itemCount: jogosFiltrados.length,
                          itemBuilder: (context, index) {
                            final jogo = jogosFiltrados[index];
                            final jogoId = jogo['id'] ?? jogo['Id'];

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: Colors.blueGrey.shade50,
                                child: Row(
                                  children: [
                                    // 📷 Imagem
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        bottomLeft: Radius.circular(16),
                                      ),
                                      child: Image.network(
                                        jogo['imagemUrl'] ?? '',
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            width: 100,
                                            height: 100,
                                            color: Colors.grey.shade300,
                                            child: const Icon(
                                              Icons.image_not_supported,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    // 📄 Detalhes
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              jogo['titulo'] ?? '',
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              jogo['descricao'] ?? '',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: Colors.black54),
                                            ),
                                            const SizedBox(height: 8),

                                            // Estado, Preço e Deletar
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        Colors.blue.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: Text(
                                                    jogo['estado'] ?? 'Usado',
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.blue),
                                                  ),
                                                ),
                                                Text(
                                                  'R\$ ${jogo['preco'].toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.green),
                                                ),
                                                TextButton.icon(
                                                  icon: const Icon(Icons.delete,
                                                      color: Colors.red),
                                                  label: const Text(
                                                    'Excluir',
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (ctx) =>
                                                          AlertDialog(
                                                        title: const Text(
                                                            'Confirmar exclusão'),
                                                        content: const Text(
                                                            'Tem certeza que deseja excluir este jogo?'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(ctx)
                                                                  .pop();
                                                            },
                                                            child: const Text(
                                                                'Cancelar'),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.of(ctx)
                                                                  .pop();
                                                              deletarJogo(
                                                                  jogoId);
                                                            },
                                                            child: const Text(
                                                              'Excluir',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
